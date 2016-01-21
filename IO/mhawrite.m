function mhawrite(varargin)
%mhawrite  Writes an ITK meta image file (ext - .mha)
%
%   mhawrite(I,FILENAME) writes the binary or grayscale image I to the file
%   specified by the string FILENAME. The file extension need not be provided.
%   Only CPU information and image parameters specific to I are used togenerate
%   this header.
%
%   mhawrite(DCM,FILENAME) write the metaimage file to the file FILENAME for a
%   list of DICOM images names stored in the cell array of strings DCM. To avoid
%   ambiguity, the full file name should be used. Alternatively, an array of
%   N-by-1 or 1-by-N structures of DICOM headers can be passed as DCM. This
%   functionality is limited to loading pertinent image parameters (e.g. voxel
%   size) and no further processing (e.g. sorting of the slices) is performed.
%
%   mhawrite(I,FILENAME,HDR) write the binary or grayscale image I to the file
%   specified by the MHA metadata stored in HDR. HDR must be a 1-by-1 structure.
%   To manually generate a metadata structure see the ITK documentation:
%
%           http://www.itk.org/Wiki/ITK/MetaIO/Documentation
%
%
%   Note: to avoid toolbox dependencies, error checking is performed on DICOM
%   files and those headers parsed only when the Image Processing Toolbox is
%   present
%
%   See also mhainfo mharead

    % Parse inputs
    hdr = parse_inputs( varargin{:} );

    % Get the file name and image from the header structure
    I     = hdr.Image;
    fName = hdr.Filename;
    hdr   = rmfield(hdr,{'Image','Filename'});

    % Attempt to open file
    [fPath,fName] = fileparts(fName);
    fid = fopen(fullfile(fPath,[fName '.mha']),'w');
    if (fid==-1)
        error([mfilename ':invalidFile'],...
                                       'Unable to open image file for writing');
    end

    % Print the header
    flds = fieldnames(hdr);
    vals = struct2cell(hdr);
    cellfun(@(x,y) fprintf(fid,'%s = %s\n',x,y),flds,vals);

    % Determine how to write the image data
    precision = lower( strrep(hdr.ElementType,'MET_','') );
    if strcmpi(hdr.ElementDataFile,'local')

        write_image(fid,I,precision);

    elseif ~isempty( strfind(hdr.ElementDataFile,fName) )

        fclose(fid); %close the *.mha file
        [fPath,fName] = fileparts(fName); %removes extension
        fid           = fopen(fullfile(fPath,[fName '.raw']),'w');
        write_image(fid,I,precision);

    end

    % Close the file
    fclose(fid);

end %mhawrite


%------------------------------------
function hdr = parse_inputs(varargin)

    if nargin<2
        error([mfilename ':inputChk'],'Invalid number of inputs.');
    end

    % Determine what the first input is
    if isnumeric(varargin{1}) %image specified
        hdrInputs{2} = varargin{1};

    else %DICOM list specified
        dcmList = varargin{1};
        [hdrInputs{2:3}] = deal( validate_dcm( dcmList ) );

    end

    % Get the file name
    if ischar(varargin{2}) %file name specified
        hdrInputs{1} = varargin{2};
    else
        error([mfilename ':inputChk'],'Invalid file name specified');
    end

    % Determine if metadata header was given
    if nargin==3 && isstruct(varargin{3})
        hdrInputs{4} = varargin{3};
    end

    % Generate the header
    hdr = cast_mha_header(hdrInputs{:});

end %parse_inputs


%-------------------------------------
function [lst,hdr] = validate_dcm(lst)

    % Get the file names
    if isstruct(lst)
        fNames = {lst.Filename};
    elseif iscell(lst)
        fNames = lst;
    end

    % Validate that the files exist
    isfile = cellfun(@(x) exist(x,'file'),fNames);
    if any(~isfile)
        str = sprintf('%s\n',fNames{~isfile});
        error([mfilename ':fileChk'],['The following files do not exist ',...
                                             'or could not be found:\n%s'],str);
    end

    % Validate that the files are all DICOM files
    imTool = ver('images');
    if isempty(imTool)
        return
    end
    isdcm = cellfun(@isdicom,fNames);
    if any(~isdcm)
        str = sprintf('%s\n',fNames{~isdcm});
        error([mfilename ':dcmChk'],['The following files are not ',...
                                                'valid DICOM images:\n%s'],str);
    end

    % Read the first DICOM header. NOTE: in a future release these parsing
    % operations will be more advanced
    hdr = dicominfo(fNames{1});

end %validate_dcm


%---------------------------------------
function hdr = cast_mha_header(varargin)

    [flds,vals] = deal({}); %initialize

    % Deal the inputs
    if nargin>3 && ~isempty(varargin{4})
        hdr = varargin{4};

        % Get the fields and values
        flds = fieldnames(hdr);
        vals = struct2cell(hdr);

        % Remove empty values
        emptyInds = cellfun(@isempty,vals);
        flds(emptyInds) = [];
        vals(emptyInds) = [];
    end
    if nargin>1
        I = varargin{2};
    end
    if nargin>2
        dcm = varargin{3};
    end

    % List of metadata - MHA field,            data types, # of elements, required field
    metaInfo =      {'ObjectType',            'string',    1,          true;...
                     'NDims',                 'int',       1,          true;...
                     'BinaryData',            'logical',   1,          false;...
                     'BinaryDataByteOrderMSB','logical',   1,          true;...
                     'TransformMatrix',       'float',    2:12,        false;...
                     'Offset',                'float',    2:3,         false;...
                     'CenterOfRotation',      'float',    2:3,         false;...
                     'DimSize',               'int',      2:3,         true;...
                     'AnatomicalOrientation', 'string',    1,          false;...
                     'ElementSpacing',        'float',    2:3,         false;...
                     'ElementType',           'string',    1,          false;...
                     'ElementDataFile',       'string',    1,          true};

    % Add the file name and image
    [fPath,fName] = fileparts(varargin{1});
    hdr = struct('Filename',fullfile(fPath,[fName '.mha'])); %clear the header
    if exist('I','var')
        hdr.Image = I;
    end

    % Verify, typecast, and store the data
    for metaIdx = 1:length(metaInfo)

        % Handle the case of necessary but missing data
        newFld = metaInfo{metaIdx,1};
        if ~any( strcmpi(flds,newFld) ) &&...case: required, but missing data
                                        metaInfo{metaIdx,end}
            switch metaInfo{metaIdx,1}
                case 'BinaryDataByteOrderMSB'
                    if ispc
                        val = 'False';
                    else
                        val = 'True';
                    end
                case 'DimSize'
                    val = int2str( size(I) );
                case 'NDims'
                    val = int2str( sum(size(I)~=1) );
                case 'ObjectType' 
                    val = 'Image';
                case 'ElementDataFile'
                    if exist('dcm','var') && ~isempty(dcm)
                        val = 'LIST';
                    elseif exist('I','var') && ~isempty(I)
                        val = 'LOCAL';
                    end
            end

            % Store the value
            hdr(1).(newFld) = val;

        elseif any( strcmpi(flds,newFld) ) %Validate/typecast user specified known data
            ind    = strcmpi(newFld,flds);
            newVal = vals{ind};
            isErr  = false;
            validN = metaInfo{metaIdx,3};
            switch metaInfo{metaIdx,2}
                case 'logical'
                    if islogical(newVal) || isnumeric(newVal)
                        newVal = num2str( logical(newVal) );
                        newVal = strrep(newVal,'0','False');
                        newVal = strrep(newVal,'1','True');
                    elseif any( strcmpi(newVal,{'true','false'}) )
                        newVal    = lower(newVal);
                        newVal(1) = upper(newVal(1));
                    else
                        isErr = true;
                    end
                case 'int'
                    if ischar(newVal)
                        mat   = sscanf('%f',newVal);
                        isErr = ~any(validN==numel(mat));
                    elseif isnumeric(newVal)
                        newVal      = sprintf('%d ',newVal);
                        newVal(end) = [];
                    else
                        isErr = true;
                    end
                case 'float'
                    if ischar(newVal)
                        mat   = sscanf('%f',newVal);
                        isErr = ~any(validN==numel(mat));
                    elseif isnumeric(newVal)
                        newVal      = sprintf('%f ',newVal);
                        newVal(end) = [];
                    else
                        isErr = true;
                    end
                case 'string'
                    isErr = ~ischar(newVal);
                    if strcmpi(newFld,'ElementDataFile') &&...%special and important case
                                        ~any( strcmpi(newVal,{'local','list'}) )
                        [fPath,fName] = fileparts(newVal);
                        newVal        = fullfile(fPath,[fName '.raw']);
                        hdr.Filename  = newVal;
                    end

            end

            % Throw any error
            if isErr
                error([mfilename ':invalidMetaValue'],...
                       '%s should be of type %s\n',...
                                       metaInfo{metaIdx,1},metaInfo{metaIdx,2});
            end

            % Store the validated value and field
            hdr.(newFld) = newVal;
        end

    end

end %cast_mha_header


%------------------------------------
function write_image(fid,I,precision)

    for metaIdx = 1:size(I,3)
        if ndims(I)==3
            Iw = I(:,:,metaIdx);
        else
            Iw = I;
        end
        fwrite(fid,Iw(:),precision);
    end

end %write_image