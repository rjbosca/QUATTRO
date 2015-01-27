function varargout = export(obj,varargin)
%export  Exports image/metadata
%
%   [I,HDR] = export(OBJ) outputs the image I and associated meta-data HDR from
%   the qt_image object OBJ.
%
%   export(OBJ,FILE) exports the qt_image object OBJ to the file specified by
%   FILE. Both the image data and meta-data are writtne to the file.
%
%   NOTE ON EXPORT FORMAT: qt_image currently supports only DICOM image export.
%   This will change in a future release.

    % Validate and parse the input(s)
    narginchk(1,2);
    fileName = '';
    if nargin>1
        fileName = varargin{1};
    end

    % Grab the image and meta-data output
    im  = double(obj.image);
    hdr = obj.metaData;

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
    if (exist( fileparts(fileName), 'dir')==7)

        % Determine the image min/max. These values will potentially be
        % used later to modify image scaling and shifting. 
        imMinMax = [max(im(~isnan(im))) min(im(~isnan(im)))];
        if isempty(imMinMax) %the image is all NaNs
            imMinMax = [0 0];
        end
        imMaxRange = abs( diff(imMinMax) );

        % Determine if NaN values exist and the maximum voxel range. When
        % NaNs exist, map those voxels to the largest unsigned integer
        % (65535) and use the "RealWorldValueLastValueMapped" DICOM tag to
        % ignore those values on load. If necessary, the data can be
        % rescaled to fit in the smaller space
        isNan    = any( isnan(im(:)) );
        maxRange = double( intmax('uint16') );
        if isNan
            hdr.RealWorldValueLastValueMapped = maxRange;
            maxRange                          = maxRange-1;
        end

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
            % point numbers to the maximum unsigned 16-bit integer range.
            hdr.RescaleIntercept = imMinMax(2);
            hdr.RescaleSlope     = imMaxRange/maxRange;

        elseif imMinMax(2)<0 %case (3) - negative values only
            hdr.RescaleIntercept = imMinMax(2);
        end

        % Perform any rescaling/shifting of the image values and convert to an
        % unsigned 16-bit integer
        im = uint16((im-hdr.RescaleIntercept)/hdr.RescaleSlope);

        % Write the data
        %TODO: program support for more than just DICOM...
        dicomwrite(im,fileName,hdr,'WritePrivate',true,'CreateMode','copy');

    else
%FIXME: this code is a temporary solution to the problem of storing the image
%units in the meta-data
        hdr.Units = obj.units;
    end

    % Deal the outputs if requested
    if nargout
        varargout = {im,hdr};
    end

end %qt_image.export