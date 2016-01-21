function varargout = export(obj,varargin)
%export  Exports image/metadata
%
%   [I,HDR] = export(OBJ) outputs the image I and associated meta-data HDR from
%   the QT_IMAGE object OBJ. For those image formats that do not support
%   meta-data output, HDR will be an empty structure with no fields.
%
%   [...] = export(OBJ,FILE) exports the QT_IMAGE object OBJ to the file
%   specified by FILE. Both the image data and meta-data are writtne to the
%   file.
%
%   [...] = export(...,FORMAT) exports the QT_IMAGE object as described
%   previously, using the image format specified by FORMAT.
%
%   NOTE ON EXPORT FORMAT: QT_IMAGE currently supports only DICOM and RAW image
%   export. This will change in a future release.

    % Special case for no requested output
    if (nargin==1)
        varargout = {obj.value,obj.metaData};
        return
    end

    % Parse the inputs
    [fileName,outFormat] = parse_inputs(varargin{:});

    % Perform the appropriate export operation
    hdr = struct([]);
    switch lower(outFormat)
        case 'dicom'
            [im,hdr] = write_dicom(obj,fileName);
        case 'raw'
            im       = write_raw(obj,fileName);
        otherwise
    end

    % Deal the outputs if requested
    if nargout
        varargout = {im,hdr};
    end

end %qt_image.export


%-----------------------------------------
function [im,hdr] = write_dicom(obj,fName)

    % Grab the image and meta-data output
    im  = double(obj.value);
    hdr = obj.metaData;

    % Test for INF values. Since these will destroy the scaling, replace them
    % with NaNs and warn the user
    if any( isinf(im(:)) )
        im(isinf(im(:))) = NaN;
        warning(['qt_image:' mfilename ':infDicomVoxel'],...
                ['Infinite voxel values detected. DICOM export does not ',...
                 'support infinte values. All INFs have been replaced with ',...
                 'NaNs.']);
    end

    % DICOM V3 supports encoding the pixel physical units in (0018,604C). The
    % following code uses the qt_image property "units" to determine the
    % appropriate value
    %
    %   Value       Unit
    %   ----------------
    %   0000H       None or N/A
    %   0001H       percent
    %   0002H       dB
    %   0003H       cm
    %   0004H       seconds
    %   0005H       hertz (or seconds^-1)
    %   0006H       dB/seconds
    %   0007H       cm/second
    %   0008H       cm^2
    %   0009H       cm^2/second
    %   000AH       cm^3
    %   000BH       cm^3/second
    %   000CH       degrees
    if isfield(hdr,dicomlookup('0018','604C'))
        hdr = rmfield(hdr,dicomlookup('0018','604C'));
    end
%     unitTag = dicomlookup('0018','604C');
%     if strcmpi(obj.units,'arb') || isempty(obj.units)
%         hdr.(unitTag) = sprintf('%04X',0000H';
%     end

    % Write the data
    if (exist( fileparts(fName), 'dir')==7)

        % Determine the image min/max. These values will potentially be used
        % later to modify image scaling and shifting.
        imMinMax = [max(im(~isnan(im))) min(im(~isnan(im)))];
        if isempty(imMinMax) %the image is all NaNs
            imMinMax = [0 0];
        end
        imMaxRange = abs( diff(imMinMax) );

        % Initialize maximum range unsigned 16-bit integer range and the real
        % world value header tags
        maxRange                           = double( intmax('uint16') );
        hdr.RealWorldValueLastValueMapped  = maxRange-1;
        hdr.RealWorldValueFirstValueMapped = 1;

        % Initialize the default values for the rescaling slope and intercept;
        % these values perform an identity mapping. Determine if the data
        % require scaling/shifting to: (1) store non-integer values (2) store
        % integer values that exceed 16 bits, (3) store negative values. If so,
        % for DICOM rescale to a 16-bit unsigned integer to best preserve
        % floating point fidelity 
        hdr.RescaleIntercept = 0;
        hdr.RescaleSlope     = 1;
        isRescale            = any( round(im(~isnan(im)))~=im(~isnan(im)) );
        if (imMaxRange>maxRange) || isRescale %case (1) and (2)
                                    
            % Determine the intercept and slope necessary to map the floating
            % point voxel values to the interval [1 65535].
            hdr.RescaleSlope     = imMaxRange/maxRange;
            hdr.RescaleIntercept = imMinMax(2)-hdr.RescaleSlope;

        elseif imMinMax(2)<0 %case (3) - negative values only
            hdr.RescaleIntercept = imMinMax(2);
        end

        % Perform any rescaling/shifting of the image values and convert to an
        % unsigned 16-bit integer
        im = uint16((im-hdr.RescaleIntercept)/hdr.RescaleSlope);

        % Write the data
        %TODO: program support for more than just DICOM...
        dicomwrite(im,fName,hdr,'WritePrivate',true,'CreateMode','copy');

    else
%FIXME: this code is a temporary solution to the problem of storing the image
%units in the meta-data
        hdr.Units = obj.units;
    end

end %write_dicom

%---------------------------------
function im = write_raw(obj,fName)

    % Grab the image output and open the file for writing
    im  = double(obj.value);
    fid = fopen(fName,'w+','l'); %always write as little endian

    % Write the image and close the file stream
    fwrite(fid,im,'double');
    fclose(fid);

end %write_raw


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Validate the number of inputs
    try
        narginchk(1,2);
    catch ME
        throwAsCaller(ME);
    end

    % Set up the input parser
    parser = inputParser;
    parser.addOptional('file','',@(x) ischar(x) && (exist(fileparts(x),'dir')));
    parser.addOptional('format','dicom',@ischar);

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % Perform some additional validation on the image format
    results.format = validatestring(results.format,{'dicom','raw'});

    % Ensure that the file can be opened for reading
    try
        fid = fopen(results.file,'w');
        fclose(fid);
    catch ME
        rethrow(ME);
    end

    % Deal the outputs
    varargout = struct2cell(results);

end %parse_inputs