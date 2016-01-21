classdef imagebase < handle


    %-------------------------------- Properties -------------------------------
    properties (Dependent)

        % Image array
        %
        %   "value" is an array containing the actual image data. This 
        %
        %   NOTE: for DICOM images, which nominally only support 2D storage, a
        %   volume must be represented by an arry of N image objects, where N is
        %   the number of images in the third dimension.
        value

        % Physical position within the image
        %
        %   "elementPos" is a numeric vector representing the physical position
        %   within the image array. The properties "elementSpacing" and
        %   "imagePos" are used to determine the value of this property
        %
        %   See also imagebase.imagePos and imagebase.elementSpacing
        elementPos

    end

    properties (Abstract)

        % Dimension size
        %
        %   "dimSize" is a numeric vector representing the number of elements in
        %   each dimension
        dimSize

        % Physical element size
        %
        %   "elementSpacing" is a numeric vector representing the physical size
        %   of elements in each dimension. By default, this value is set to
        %   ONES(1,N), where N is the number of dimensions
        elementSpacing

        % Position within an image
        %
        %   "imagePos" is a numeric vector representing the indexed position
        %   within an image for each dimension. By default, this value is set to
        %   ONES(1,N), where N is the number of dimensions.
        %
        %   Unlike other programming languages (e.g., C, C++, etc.) MATLAB
        %   arrays are one-based (not zero-based), so the origin of an image
        %   will be at (1,1,...)
        imagePos

    end

    properties (SetObservable)

        % Physical coordinate system orientation
        %
        %   "coorOrientation" is a three-element string specifying the physical 
        %   physical coordinate system's orientation
        %
        %   Default: 'RAS'
        coorOrientation = 'RAS';

        % Element numeric class
        %
        %   "elementClass" is the numeric class (e.g., 'uint8' or 'double') used
        %   to represent the image array. By default, this property has the
        %   value 'double'. When the value of this property is different than
        %   the actual class of the image array, the image data will be type
        %   cast to the specified class when getting the "image" property.
        %
        %   This property can assist in saving memory. For example, DICOM images
        %   are represented by a 16-bit integer, but often require conversion to
        %   a floating point value to perform computations.
        elementClass = 'double';

        % Minimum element value
        %
        %   "elementMin" is the minimum element value in the image. For true
        %   color images, this property will be a vector of values
        elementMin

        % Maximum element value
        %
        %   "elementMax" is the maximum element value in the image. For true
        %   color images, this property will be a vector of values
        elementMax

        % Full file name of the image
        %
        %   "fileName" is a cell of strings specifying the full file name from
        %   which image data are read and the file to which image data are
        %   written
        fileName = {};

        % Image format
        %
        %   "format" is a string specifying the image file format (see supported
        %   formats below) to be used during read/write operations. Many methods
        %   perform specific operations based on "format". While all attempts
        %   are made to automatically determine this property, the user is
        %   ultimately responsible for ensuring that an appropriate value is
        %   specified to ensure that data are loaded properly.
        %
        %       Supported Formats
        %       -----------------
        %      'dicom'
        %      'metaimage'
        format = 'dicom'; %image type used to perform operations

        % Flag for reading images on-the-fly
        %
        %   "memorySaver" is a logical flag specifying, when TRUE (default),
        %   that image data stored in a file should be read only when requested.
        %   When FALSE, the image data read loaded after setting the "fileName"
        %   property
        memorySaver = true;

        % Image meta-data structure
        %
        %   "metaData" is a structure containing additional information about an
        %   image. For example, this could be the information associated with a
        %   DICOM file (see DICOMINFO).
        %
        %   This information is not standardized and will vary by image type.
        %   Meta-data can include spatial information (e.g. pixel size),
        %   acquisition parameters (e.g. field of view), and/or pixel value
        %   representation information (e.g. parameter map name or pixel units).
        metaData = struct([]);

    end

    properties (Access='protected',Hidden,SetObservable)

        % Coordinate transformation matrix
        %
        %   "coorTrafo" is a transformation matrix that converts indexed image
        %   locations to physical coordinates. Not all image types support this
        %   transformation
        coorTrafo = eye(4);

        % Raw image storage
        %
        %   "imageRaw" is a non-dependent storage for the original, unaltered
        %   image data.
        imageRaw

        % Image object property update flag
        %
        %   "isPropsUpdated" is a logical flag that, when TRUE, specifies that
        %   all image properties associated with the actual image data have been
        %   updated.
        %
        %   This flag is used to avoid unnecessary loading of image data during
        %   the population of the "metaData" field. Instead, properties such as
        %   "dimSize", "ww", "wl", etc. are updated after the image data are
        %   loaded
        isPropsUpdated = false;

        % Sparse image flag
        %
        %   "isSparse" is a logical flag that specifies when an image is using
        %   the sparse representation.
        isSparse = false;

    end

    properties (Constant,Hidden)

        % Flag for Image Processing Toolbox
        %
        %   "isIpt" is a logical flag that is TRUE when the Image Processing
        %   Toolbox is installed
        isIpt = ~isempty( ver('Images') );

    end


    %-------------------------------- Properties -------------------------------
    events

        % Delete temporary image data
        %
        %   "flushCace" empties all cache properties of the imagebase sub-class
        %   object
        flushCache

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = imagebase(varargin)

            % Attach the post-set property listeners
            addlistener(obj,'metaData','PostSet',@obj.metaData_postset);
            addlistener(obj,'imageRaw','PostSet',@obj.imageRaw_postset);

            % Attach the event listeners
            addlistener(obj,'flushCache',@obj.flush_cache);

            % Lock out the 'dicom' image format when the Image Processing
            % Toolbox is inaccessible
            if ~obj.isIpt
                warning(['imagebase:' mfilename ':missingToolbox'],...
                         'DICOM support requires the Image Processing Toolbox.');
                obj.format = 'metaimage';
            end

        end %imagebase.imagebase

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.elementPos(obj)

            % Create an IJK vector to be multiplied by the coordinate transform
            % matrix. Since the transform matrix only operates on the spatial
            % dimensions, ignore image dimensions higher than 3.
            nd        = min( [numel(obj.imagePos) 3] );
            ijk       = zeros(4,1);
            ijk(1:nd) = (obj.imagePos-1); %"-1" for zero-indexing

            % Calculate the position
            val = obj.coorTrafo*ijk;
            val = val(1:3);

        end %imagebase.get.elementPos

        function val = get.value(obj)
        %image  Image property of imagebase object
        %
        %   I = OBJ.value returns the image data I, type cast according to the
        %   "elementClass" property, of the imagebase object OBJ. If the
        %   "memorySaver" propeerty is TRUE, the image is first read and is
        %   returned, but not stored 

            val = obj.imageRaw; %alias

            % When getting the "value" property, only consider a single slice.
            % For images with more than 2 dimensions, simply use the current
            % index
            %FIXME: how is the user supposed to get the full image array for N-D
            %images???
            if (numel(obj.imagePos)>2)
                idx = num2cell(obj.imagePos(3:end));
                val = squeeze( val(:,:,idx{:}) );
            end

            % Handle sparse representation first, if necessary. Otherwise get
            % the image data - either from the "imageRaw" property or load it
            % from the file
            if obj.isSparse
                val = repmat(val,obj.dimSize); %#ok - used in EVAL below...
            elseif isempty(obj.imageRaw) && ~isempty(obj.fileName)
                [tf,val] = obj.read;
                if tf && ~obj.memorySaver
                    obj.imageRaw = val;
                elseif ~tf
                    warning('imagebase:noImageLoaded',...
                            'Unable to read image data from file "%s".',...
                            obj.fileName);
                end
            end

            % Type cast the output
            val = eval([obj.elementClass '(val);']);

        end %imagebase.get.image

    end %get methods


    %------------------------------- Set Methods -------------------------------
    methods

        function set.coorOrientation(obj,val)

            % Validate the user string
            validateattributes(val,{'char'},{'numel',3});
            arrayfun(@(x) validatestring(x,{'r','l','a','p','s','i'}),val);

            % Convert to a directional vector

            obj.coorOrientation = val;

        end

        function set.elementMax(obj,val)
            validateattributes(val,{'numeric'},{'scalar'});
            obj.elementMax = double(val);
        end %imagebase.set.elementMax

        function set.elementMin(obj,val)
            validateattributes(val,{'numeric'},{'scalar'});
            obj.elementMin = double(val);
        end %imagebase.set.elementMin

        function set.format(obj,val)

            % Attempt to validate the requested image format
            try
                val = validatestring(val,{'dicom','metaimage'});
            catch ME
                if ~strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
                    rethrow(ME)
                end
                warning(['imagebase:' mfilename ':formatChk'],...
                         'Images of type ''%s'' are not supported currently.',...
                                                                    obj.format);
                return
            end

            % Check for DICOM support...
            if ~obj.isIpt && strcmpi(val,'dicom')
                warning('imagebase:missingToolbox',...
                         'DICOM support requires the image processing toolbox.');
                return
            end

            % Update the property
            obj.format = val;

        end %imagebase.get.image

        function set.fileName(obj,val)

            % The "fileName" property now supports a cell array of strings. For
            % simplicity, catch input strings and convert to a cell
            if ischar(val)
                val = {val};
            end

            % Ensure a non-empty string was provided
            cellfun(@(x) validateattributes(x,{'char'},{'nonempty'}), val);

            % Attempt to validate the proposed file location
            fDirs = cellfun(@fileparts,val,'UniformOutput',false);
            isDir = cellfun(@(x) (exist(x,'dir')==7),fDirs);
            if any( ~isDir )
                warning( 'imagebase:invalidFileLocation',...
                        ['"fileName" must specify an existing directory. ',...
                         'No image data can be written or read until a valid ',...
                         'location is specified.'])
                return
            end

            obj.fileName = val;

        end %imagebase.set.fileName

        function set.value(obj,val)

            % Update some of the image object properties that depend on the
            % image data
            if obj.isSparse
                [obj.elementMin,obj.elementMax] = deal(val);
            else
                obj.dimSize    = size(val);
                obj.elementMin = min(val(~isnan(val)));
                obj.elementMax = max(val(~isnan(val)));
            end

            % Disable the memory saver mode to ensure that image data are not
            % deleted
            obj.memorySaver = false;

            % Store the image data in the "imageRaw" property
            obj.imageRaw    = val;

            % Update the date in the meta-data. This is hack that forces the
            % post-set event for "metaData" to fire, which, in turn, will update
            % a number of the meta-data information
            obj.metaData(1).ContentDate = datestr(now,'YYYYMMDD');

        end %imagebase.set.value

    end %set methods

end %imagebase