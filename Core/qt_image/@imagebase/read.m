function varargout = read(obj,varargin)
%read  Reads an image into the qt_image object
%
%   TF = read(OBJ) uses the image object properties "fileName" and "format" of
%   OBJ to attempt loading image data. When successful (or if the image is
%   already loaded), the output TF will have a value of TRUE.
%
%   [TF,I] = read(OBJ) reads the image as before, returning the load flag TF in
%   addition to the image data I.
%
%   MEMORY SAVER MODE: while in this mode, image data are only read during calls
%   to the "image" property of the associated image object or when requesting
%   the optional second output of this method. For larger images and certain
%   formats, read operations can unncessarily slow image operations.
%
%   NOTE ON USAGE: generally speaking, the user should never need to call this
%   method directly, but should instead rely on the image object to handle read
%   operations.

    % Initialize the workspace
    [varargout{1:2}] = deal(false,[]); %initialize output
    mData            = obj.metaData;
    metaDataRead     = ~isempty(mData);
    readMetaOnly     = (nargout==1) && obj.memorySaver;

    % Check for existing data
    
    if (metaDataRead && obj.memorySaver && nargout==1) ||...
                                     (metaDataRead && ~isempty(obj.imageRaw))
        varargout{1} = true; %data already loaded, return true
        return
    end

    % When the user has failed to specify the file name, check the meta data.
    % When the fileName property is set, this check is ignored
    if isempty(obj.fileName) && metaDataRead
        flds    = fieldnames(mData);
        fileIdx = strcmpi('filename',flds);
        if any(fileIdx)
            obj.fileName = mData.(flds{fileIdx});
        end
    end

    % At the minimum, the "fileName" property should contain something other
    % than an empty string. At this point, an attempt to locate the file name
    % has already been made, so return if no file name exists or warn the user
    % if there is a non-empty invalid file name
    if isempty(obj.fileName)
        return
    elseif ~exist(obj.fileName,'file')
        warning(['imagebase:' mfilename ':missingFile'],...
                                    'Unable to locate image "%s"',obj.fileName);
        return
    end

    % Image type specific loading
    switch lower(obj.format)
        case 'analyze'
        case {'brick','unknown'}
            warning(['imagebase:' mfilename ':formatChk'],...
                    'Images of type ''%s'' are not supported currently.',...
                                                                    obj.format);
        case 'dicom'
            % Try to load the DICOM image
            if ~isdicom(obj.fileName)
                warning(['imagebase:' mfilename ':invalidDicom'],...
                        'Unable to read DICOM data from %s',obj.fileName);
                return
            else
                if ~metaDataRead %only read once
                    mData = dicominfo(obj.fileName);
                end
                if ~readMetaOnly
                    image = dicomread(mData);
                end
            end

        case 'metaimage'
        otherwise %all other MATLAB supported formats
            if isempty(mData) %only read once
                mData = imfinfo(obj.fileName,obj.format);
            end
            if ~readMetaOnly
                image = imread(obj.fileName,obj.format);
            end
    end

    % There are circumstances that can cause 

    % Many images don't have meta data and sometimes those that support meta
    % data often have missing image information. The following code captures as
    % much usable information from the image, storing those computations in the
    % "metaData" property
    if ~isempty(mData) && exist('image','var') && ~isempty(image)
        [tf,mData] = validate_meta_data(mData,image);
        if tf
            obj.metaData = mData;
        end
    elseif ~isempty(mData)
        obj.metaData = mData;
    end

    % Store image if needed
    if ~readMetaOnly
        obj.imageRaw = image;
    end

    % Deal outputs
    varargout{1} = true; %if the function made it this far, give it an A+
    if nargout>1
        varargout{2} = image;
    end

end %qt_image.read


%------------------------------------
function [tf,s] = validate_meta_data(s,im)
%validate_meta_data  Validates all necessary image meta data

    tf = false; %initialize the change data flag

    if ~isfield(s,'WindowWidth')
        s.WindowWidth = double((max(im(:))-min(im(:))));
        tf            = true;
    end
    if ~isfield(s,'WindowCenter')
        s.WindowCenter = double(min(im(:)))+s.WindowWidth/2;
        tf             = true;
    end
    if ~isfield(s,'Modality')
        s.Modality = 'unknown';
        tf         = true;
    end

    end %validate_meta_data