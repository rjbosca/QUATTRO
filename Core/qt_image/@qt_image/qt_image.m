classdef qt_image < generalopts
%QUATTRO image base class
%
%   Type "doc qt_image" for a summary of all properties and methods.
%
%       Properties
%       ----------------------------
%       image           Read/processed image data
%       fileName        Full file name used for reading/writing operations
%       metaData        Structure specifying image meta information
%       format          Image format used for reading/writing operations
%       tag             Specific image/map tag (e.g. MR, adc, ktrans, etc.)
%       units           Physical units of pixel/voxel values
%       scale           Scaling factor to apply to resize images when displayed
%       memorySaver     Logical flag for on-the-fly reading of image files
%       color           Color map string
%       transparency    Numeric value specifying the image transparency
%       wl              Displayed image window level
%       ww              Displayed image window width
%       wwwlMode        Window width/level update mode
%
%
%       Methods
%       -------
%       addfilter       Add a processing step to the image pipeline
%       addroi          Associate an qt_roi object with the image
%       img2mat         Convert an array of qt_image objects to a numeric array
%       read            Reads an image
%       show            Displays an image on a specified axis or new figure
%       sort            Sorts a stack of qt_image objects using "metaData"
%       
%
%
%   A note on image objects: Image objects can represent a wide array of data,
%   such as DICOM images, parametric maps, Pinnacle dose maps or any spatial
%   information for that matter. Image objects have two primary components:
%   image data and image meta data. The latter stores important information
%   regarding the spatial properties and image content properties, although
%   optional the image meta data should be considered an essential image
%   component. Image data without meta data is meaningless in the context of
%   QUATTRO and potentially dangerous to use.
%
%
%   Examples
%   ========
%
%   % Create an image object array from a directory of images
%   vfaDir = qt_examples('vfa');
%   img = qt_image( vfaDir );
%
%   % Sort and stack the images by flip angle
%   [img,vals] = img.sort('FlipAngle')
%   img = reshape(img,[],numel(vals));
%
%   % Display the flip angles and slice locations when the image is viewed
%   flds = {'FlipAngle','SliceLocation'};
%   [img.dispFields] = deal(flds);
%
%   % Show the image
%   img.show;

    properties (Dependent)

        % 2D or 3D image array.
        %
        %   "value" is an array containing the processed 2D image (i.e. scaling,
        %   transformations, etc. are applied) at the location specified by the
        %   "index" property. The entire pipeline is evaluated on the array
        %   before returning the values to the user.
        %
        %   NOTE: for DICOM images, which nominally only support 2D storage, a
        %   volume must be represented by an arry of N image objects, where N is
        %   the number of images in the third dimension.
        value

        % Full file name of the image
        %
        %   "fileName" is full file name from which image data are read and the
        %   file to which image data are written
        fileName = '';
        %TODO: update this information to refelct the fact that read/write
        %opeartions will be handled differently (i.e. imageread imagewrite)

        % Image format
        %
        %   "format" is a string specifying the image file format (see supported
        %   formats below) to be used during read/write operations. Many methods
        %   perform specific operations based on "format". While all attempts
        %   are made to automatically determine this property, the user is
        %   ultimately responsible for ensuring that an appropriate value is
        %   specified.
        format

        % Flag for reading images on-the-fly
        %
        %   "memorySaver" is a logical flag specifying, when TRUE (default),
        %   that image data stored in a file should be read only when requested.
        %   When FALSE, the image data read loaded after setting the "fileName"
        %   property
        memorySaver = true;

        % Image meta data structure
        %
        %   This information is not standardized and will vary by image type.
        %   Meta data can include spatial information (e.g. pixel size),
        %   acquisition parameters (e.g. Field of View), and/or pixel value
        %   representation information (e.g. parameter map name or pixel units).
        %   While there is no standard format for the meta data, this
        %   information is frequently used in display and manipulation of
        %   images.
        metaData

    end

    properties (SetObservable)

        % Basic image properties
        %-----------------------

        % Image tag
        %
        %   "tag" is a user-specified string (that follows MATLAB's variable
        %   naming convention) denoting the specific image type; the default is
        %   'image'. This is used currently when displaying image/map overlays
        %   to ensure proper display. Functionality will likely expand in the
        %   future.
        %
        %   For example, a map of T1 relaxation times measured from a variable
        %   flip angle MR study might be called 'T1'.
        tag = 'image';

        % Image units
        %
        %   "units" is a user-specified string denoting the physical units of
        %   the values represented in the image pixels/voxels; the defualt is
        %   'arb' (arbitrary). This property is especially important when
        %   deriving quantities from images, and facilitates unit conversions.
        %
        %   For more information about valid strings for this property, type
        %   "help unit". This class definition can be found in the "Third Party"
        %   sub-directory of QUATTRO. When possible, the full unit name should
        %   be used for clarity (e.g., use 'seconds' instead of 's')
        units = 'arb';

        % Image rescale display factor
        %
        %   An integer factor used to rescale the current image data using cubic
        %   interpolation, providing a more visually appealing image. Speed is
        %   sacrificed with increasing scaling factors. Default: 1.
        scale = 1;

        % Color map to use for display purposes
        %
        %   "color" is the name of an appropriate built-in color map function
        %   (e.g., 'gray', 'hsv', and 'copper') to be used when displaying the
        %   qt_image object. The default value is 'gray'.
        color = 'gray';

        % Image transparency
        %
        %   "transparency" is a numeric scalar between 0 and 1 (default) that
        %   specifies the transparency of an image with 0 being complete
        %   transparent
        transparency = 1;

        % Window level
        %
        %   "wl" is a numeric scalar specifying the window level to be used when
        %   displaying the image
        wl = 0;

        % Window width
        %
        %   "ww" is a numeric scalar specifying the total window width to be
        %   used when displaying the image
        ww = eps;

        % Mode for displaying the image WW/WL
        %
        %   "wwwlMode" is a string specifying the mode by which the WW/WL of the
        %   displayed image is set (or calculated). Valid modes are:
        %
        %       Mode            Description
        %       =======================
        %       'axis'          The current axis' "CLim" property values are
        %                       used in lieu of the "wl" and "ww" object
        %                       properties. While in this mode, "wl" and "ww"
        %                       values can be altered manually or by using the
        %                       interactive mouse feature 
        %
        %      {'internal'}     Values stored in the "wl" and "ww" properties
        %                       are used to set the WW/WL (i.e. "CLim") during
        %                       image display
        %
        %       'immean'        Calculates the window level based on the average
        %                       of all non-zero voxels in an image. The window
        %                       width is twice the window level. This mode makes
        %                       no changes to the "wl" and "ww" properties, but
        %                       rather only updates the axis' "CLim" property
        %
        %   In the event that a new axis is created, qt_image properties are
        %   used to initially set the axis' "CLim" property values, but are then
        %   using the specified WW/WL mode.
        wwwlMode = 'internal';

    end

    properties(Dependent,Hidden)

        % Handle(s) of axis used to dislpay the image.
        %
        %   "hAxes" is an array of axis handles that are currently displaying
        %   the QT_IMAGE object's image data
        hAxes

        % Image size
        %
        %   "dimSize" is a vector specifying the size of each dimension of the
        %   "image" property
        dimSize

        % Image ROI values
        %
        %   "imageValues" is an array of voxel values conatined within linked
        %   ROIs
        imageValues

        % Zoom state of the image
        %
        %   "isZoomed" is a logical scalar specifying the zoom state of the
        %   image. When TRUE, the some zoom has been applied to the image.
        isZoomed


        %----------------
        %   Deprecated
        %----------------

        % Deprecated image property
        %
        %   "image" is deprecated. Use "value" instead
        image
        
        % Deprecated image dimension property
        %
        %   "imageSize" is deprecated. Use "dimSize" instead
        imageSize

    end

    properties (SetObservable,Hidden)

        % Meta-data to display
        %
        %   A cell array of meta-data fields or image properties (e.g., "format"
        %   or "wwMode") to display when images are visualized using the "show"
        %   method. For each of the m rows, a new line is displayed using the
        %   data from each of the n meta-data fields specified. For each escape
        %   character in the "dispFormat" property, a corresponding display
        %   field must exist, otherwise display errors will occur
        %
        %       Example
        %       -------
        %
        %       obj.dispFields = {'FlipAngle','RepetitionTime'};
        %       obj.dispFormat = {'FA (deg): %d';'TR (ms): %4.2f'};
        %
        %   Note: fields that do not exist in the meta-data or as qt_image
        %   properties are ignored and removed automatically from this property
        dispFields = {};

        % Meta-data display format
        %
        %   An m-by-1 cell of format strings with m lines to be dispayed using
        %   the meta-data fields defined in the "dispFields" proprety
        dispFormat = {};

        % Image processing pipeline
        %
        %   "pipeline" is a cell array of valid filters that perform a some
        %   level of processing when the "image" property is requested.
        %   Operations are performed sequentially starting from the first array
        %   position and moving linearly to the end.
        pipeline = {};

        % Debug mode flag
        %
        %   "isDebug" is a logical value specifying the state of the qt_image
        %   debugging mode. When true, debugging notifications are displayed
        %   during operation
        isDebug = false;

    end

    properties (Access='private',Hidden,SetObservable)

        % Image object
        %
        %   "imgObj" is the image object (e.g., image2d) that contains the image
        %   data that QT_IMAGE encapsulates
        imgObj = image2d;
        %TODO: how to more generally determine what class should be stored in
        %this object?

        % Image view object storage
        %
        %   "imgViewObj" stores an array of IMGVIEW objects. These objects
        %   handle all events associated with displaying the QT_IMAGE data
        imgViewObj = imgview.empty(0,0);

        % ROI object storage
        %
        %   "roiObj" stores an array of QT_ROI objects. These objects are shown
        %   with the images and used to extract voxel values from the image
        roiObj = qt_roi.empty(1,0);

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_image(varargin)
        %qt_image  Constructs an instance of the qt_image class
        %
        %   OBJ = qt_image(FILE) creates a QT_IMAGE object OBJ by reading the
        %   image data stored in file(s) specifeid by the string FILE. FILE can
        %   also specify a directory of images, creating an array of QT_IMAGE
        %   objects OBJ for all valid image files in the directory; any sub-
        %   directories are ignored. FILE can also be a cell array containing
        %   any strings for any combination of directories and files.
        %
        %   OBJ = qt_image(I) creates a QT_IMAGE object OBJ from the single 2-
        %   or 3-D numeric array I. Several properties necessary for display
        %   purposes are automatically set (e.g. WW and WL).
        %
        %   OBJ = qt_image(...,'PROP1',VAL1,...) creates OBJ as described above,
        %   setting the specified property values before performing other
        %   operations.
        %
        %   OBJ = qt_image creates an empty QUATTRO image object using defaults
        %   were possible. Object properties such as "image", "metaData", etc.
        %   can be set after constructing the object. While the original design
        %   goals of this class were based on the needs of QUATTRO, this class
        %   performs equally as well outside of QUATTRO.

            % Attach the properties' listeners
            addlistener(obj,'color',     'PostSet',@obj.color_postset);
            addlistener(obj,'dispFields','PostSet',@obj.newdisp);
            addlistener(obj,'dispFormat','PostSet',@obj.newdisp);
            addlistener(obj,'imgObj',    'PostSet',@obj.imgObj_postset);
            addlistener(obj,'wwwlMode',  'PostSet',@obj.wwwlMode_postset);

            % Do nothing with zero inputs...this is required by MATLAB for
            % smooth operation
            if ~nargin
                return
            end

            % Parse the inputs
            [imgReq,props,vals] = parse_inputs(varargin{:});

            % "guiDialogs" must be initialized here...
            guiDialogsIdx = strcmpi(props,'guiDialogs');
            if any(guiDialogsIdx)
                obj.guiDialogs = vals{guiDialogsIdx};
            end

            %--------------------------------
            % Deal image data or file name(s)
            %--------------------------------

            % Construct the necessary image objects
            if ~iscell(imgReq)
                imgReq = {imgReq};
            end

            % Set filenames for object and initialize the wait bar and output
            % objects
            nf        = numel(imgReq);
            hWait     = []; %initialize waitbar variable
            if obj.guiDialogs && (nf>1)
                hWait = waitbar(0,'0% Complete','Name','Loading images...');
            end
            obj       = qt_image.empty(nf,0); %initialize PostSet will fire
            nInvalid  = 0;
            for inIdx = 1:nf

                % Waitbar functionality
                if ~isempty(hWait) && ishandle(hWait)
                    pct = inIdx/nf;
                    waitbar(pct,hWait,sprintf('%d%% Complete',round(pct*100)));
                elseif ~isempty(hWait) && ~ishandle(hWait) %user cancelled
                    obj.delete;
                    break
                end

                % Construct an image object and assign it if valid
                %TODO: how to handle images of other dimensions
                imObj = image2d(imgReq{inIdx});
                nInvalid = nInvalid + ~imObj.isvalid;
                if imObj.isvalid
                    obj(inIdx-nInvalid).imgObj = imObj;
                end

            end

            % Delete the waitbar if it still exists
            if ishandle(hWait)
                delete(hWait);
            end

            % Some post-set events attempt to read files that appear to be
            % images. In some cases, these files (e.g., OSIRIX DICOMs) contain
            % no actual image data and are deleted during the attempted
            % initialization and must be removed before returning the array of
            % objects
            obj(~obj.isvalid) = [];


            %----------------------
            % Deal other properties
            %----------------------

            % Deal user-specified properties (i.e., optional inputs)
            if ~isempty(obj) && all(obj.isvalid)
                for idx = 1:length(props)
                    [obj(:).(props{idx})] = deal(vals{idx});
                end
            end

        end %qt_image.qt_image

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.fileName(obj)
            val = obj.imgObj.fileName;
        end %qt_image.get.fileName

        function val = get.format(obj)
            val = obj.imgObj.format;
        end %qt_image.get.format

        function val = get.hAxes(obj)
        %hAxes  Array of axes used to display image data
        %
        %   H = obj.hAxes returns the array of all axis handles that are being
        %   used currently to display the qt_image object's image data

            val = unique([obj.imgViewObj.hAxes]);

        end %qt_image.get.hAxes

        function val = get.image(obj)
            %TODO: remove 1/1/2016
            warning('qt_image:imagePropDeprecated',...
                    ['The "image" property is deprecated and will be removed ',...
                     'in a future release. Use "value" instead']);
            val = obj.value;
        end %qt_image.get.image

        function val = get.imageSize(obj)
            %TODO: remove 1/1/2016
            warning('qt_image:imagePropDeprecated',...
                    ['The "imageSize" property is deprecated and will be ',...
                     'removed in a future release. Use "dimSize" instead']);
                 val = obj.dimSize;
        end %qt_image.get.imageSize

        function val = get.value(obj)
        %image  Image property of qt_image object
        %
        %   im = obj.value returns the image property of the qt_image object
        %   obj. If memorySaver is enabled, the image is first read and is
        %   then passed as output, but not stored

            % Initialize some aliases
            val = obj.imgObj.value;
            m   = obj.imgObj.dimSize;

            % Process the image
            n = numel(m);
            if (obj.scale~=1)
                % Get the ndgrid vectors
                [xc,xcs] = deal( cell(1,n) );
                for dimIdx = 1:n
                    xc{dimIdx}  = 0:m(dimIdx)-1;
                    xcs{dimIdx} = (0:m(dimIdx)-1)*obj.scale;
                end

                % Get the grids and resample the image
                [x{1:n}]  = deal( ndgrid(xc{:}) );
                [xs{1:n}] = deal( ndgrid(xcs{:}) );
                val       = interpn(x{:},double(im),xs{:});
            end

            % Now that the image is available, perform all pipeline processing
            % steps
            pipe = obj.pipeline;
            if ~isempty(pipe)
                for pipeIdx = 1:length(pipe)
                    val = pipe{pipeIdx}(val);
                end
            end

            % Checks image bounds
%             val = enforce_im_bounds(val,obj.windowBounds);

        end %qt_image.get.value

        function val = get.dimSize(obj)
        %dimSize  Size of image
        %
        %   M = OBJ.dimSize returns a row vector containing the number of voxels
        %   M for each dimension of the image data stored in the qt_image object
        %   OBJ.
            val = obj.imgObj.dimSize;
        end %qt_image.get.dimSize

        function val = get.imageValues(obj)

            val = [];
            if ~isempty(obj.roiObj)
                val = obj.roiObj.mask(obj.value);
            end

        end %qt_image.get.imageValues

        function val = get.isZoomed(obj)
            val = false; %initialize

            viewObj = obj.imgViewObj;
            if ~isempty(viewObj)
                val = viewObj.isZoomed;
            end
        end %qt_image.get.isZoomed

        function val = get.memorySaver(obj)
            val = obj.imgObj.memorySaver;
        end %qt_image.get.memorySaver

        function val = get.metaData(obj)
            val = obj.imgObj.metaData;
        end %qt_image.get.metaData

        function val = get.roiObj(obj)
            % Get the only the valid qt_roi objects and update the "roiObj"
            % property with those
            val = obj.roiObj;
            val        = val(val.validaterois);
            obj.roiObj = val;
        end %qt_image.get.roiObj

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.color(obj,val)

            % Validate the input using validatestring to partial match
            try
                obj.color = validatestring(val,{'bone','copper','cool',...
                                                'gray','hsv','hot','jet',...
                                                'pink','prism','prism'});
            catch ME
                if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
                    rethrow(ME)
                elseif ~ischar(val)
                    warning([mfilename ':wwwlMode:nonChar'],...
                            ['Non-character value detected. No changes were ',...
                             'made to the property "color".']);
                elseif ~any( strcmpi(val,{'internal','axis',}) )
                    warning([mfilename ':wwwlMode:invalidMode'],...
                            ['''%s'' does not match any valid WW/WL mode. ',...
                             'No changes were made to the property "color".'],...
                             val);
                end
            end

        end

        function set.dispFields(obj,val)

            % Store the fields. Note that validation is performed in the PostSet
            % event
            if ischar(val)
                val = {val};
            end

            % Store input and notify of change
            obj.dispFields = val;
                    
        end %qt_image.set.dispFields

        function set.dispFormat(obj,val)

            if (~ischar(val) && ~iscell(val)) ||...
                                     (iscell(val) && any(~cellfun(@ischar,val)))
                warning([mfilename ':dispFormat:invalidValue'],...
                        ['Non-character value detected. No changes were ',...
                         'made to the property ''dispFormat''.']);
            else

                % Store the fields. Note that validation is performed in the
                % dispFields get method
                if ischar(val)
                    val = {val};
                end
                val = val(:)'; %put into row format

                % Store input and notify of change
                obj.dispFormat = val;
            end

        end %qt_image.set.dispFormat

        function set.fileName(obj,val)
            obj.imgObj.fileName = val;
        end %qt_image.set.fileName

        function set.format(obj,val)
            obj.imgObj.format = val;
        end %qt_image.set.format

        function set.imgViewObj(obj,val)

            % Validate the input
            if ~strcmpi( class(val), 'imgview' )
                warning([mfilename ':imgViewObj:invalidObject'],...
                        'Input was of class "%s", expected "imgview".',...
                        class(val));
                return
            end

            % Since the "imgViewObj" property is a stack that is appended during
            % each call to the "set" method, check that the inputs do not match
            % any of the imgview objects stored in the "imgViewObj" property.
            stack = obj.imgViewObj;
            stack = stack(stack.isvalid);
            for viewIdx = numel(val):-1:1

                % Check for duplicate imgview objects
                if any(stack==val(viewIdx)) || ~val(viewIdx).isvalid
                    val(viewIdx) = [];
                    continue
                end

                % All new, incoming imgview objects need to have a qt_image
                % specific method attached to listen for changes to the "hAxes"
                % property of the view object.
                addlistener(val(viewIdx),'hAxes','PostSet',...
                                                    @obj.imgview_hAxes_postset);
            end

            % Add the object to the stack
            obj.imgViewObj = [stack(:);val(:)];

        end %qt_image.set.imgViewObj

        function set.memorySaver(obj,val)
            obj.imgObj.memorySaver = val;
        end %qt_image.set.memorySaver

        function set.metaData(obj,val)
            obj.imgObj.metaData = val;
        end

        function set.units(obj,val)

            % Validate the input against the unit class
            if ischar(val)

                % Convert 'arb' to an empty string
                if strcmpi(val,'arb')
                    val = '';
                end

                % Attempt to construct a unit object. If successful, store the
                % new value
                try
                    unit(val);
                    obj.units = val;
                catch ME
                    if ~strcmpi(ME.message(1:15),'Unit known as "')
                        rethrow(ME);
                    end
                    warning([mfilename ':units:invalidUnit'],...
                            ['"%s" is an invalid unit string. No changes ',...
                             'were made to the property "unit".'],val);
                end
            else
                warning([mfilename ':units:nonCharValue'],...
                        ['The qt_image property "units" only accepts ',...
                         'character inputs. No change was applied.']);
            end
                
        end %qt_image.set.units

        function set.wl(obj,val)

            % Do nothing with empty values
            if isempty(val)
                return
            end

            % Validate/store input
            if (numel(val)>1)
                warning([mfilename ':wl:nonScalarValue'],...
                        ['Non-scalar value detected. No changes were made ',...
                         'to the property ''wl''.']);
            elseif isempty(val) || ~isnumeric(val) || isnan(val) || isinf(val)
                warning([mfilename ':wl:invalidValue'],...
                        ['Non-numeric, NaN, or infinite value detected. ',...
                         'No changes were made to the property ''wl''.']);
            else
                obj.wl = double(val);
            end
            
        end %qt_image.set.wl

        function set.ww(obj,val)

            % Do nothing with empty values
            if isempty(val)
                return
            end

            % Validate/store input
            if (numel(val)>1)
                warning([mfilename ':ww:nonScalarValue'],...
                        ['Non-scalar value detected. No changes were made ',...
                         'to the property ''ww''.']);
            elseif ~isnumeric(val) || isnan(val) || isinf(val) || (val<0)
                warning([mfilename ':ww:invalidValue'],...
                        ['Non-numeric, NaN, or infinite value detected. ',...
                         'No changers were made to the property ''ww''.']);
            else
                obj.ww = double(val);
            end
            
        end %qt_image.set.ww

        function set.wwwlMode(obj,val)

            % Validate the input using validatestring to partial match
            try
                val = validatestring(val,{'axis','immean','internal'});
            catch ME
                if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
                    rethrow(ME)
                elseif ~ischar(val)
                    warning([mfilename ':wwwlMode:nonChar'],...
                            ['Non-character value detected. No changes ',...
                             'were made to the property ''wwwlMode''.']);
                elseif ~any( strcmpi(val,{'internal','axis',}) )
                    warning([mfilename ':wwwlMode:invalidMode'],...
                            ['''%s'' does not match any valid WW/WL mode. ',...
                             'No changes were made to the property ',...
                             '''wwwlMode''.'],val);
                end
            end

            % Update the value
            obj.wwwlMode = val;

        end %qt_image.set.wwwlMode

    end


    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

        function deconstruct(obj,src,~)
        %deconstruct  Dissociates IMGVIEW object data from an axis
        %
        %   deconstruct(OBJ,SRC,EVENT) removes all image data links by deleting
        %   the imgview object that notified the "deconstructView" event (i.e.
        %   SRC). This event also notifies the imagebase (or sub-class) object
        %   that image caches should be flushed. EVENT is unused but required
        %   for MATLAB event syntax

            % Delete the IMGVIEW (includes the text and image) object that fired
            % this event. This must be done first to ensure that the following
            % checks can determine how many IMGVIEW objects remain for the
            % current QT_IMAGE object.
            src.delete;

            % Destroy raw image data if memory saver is on
            notify(obj.imgObj,'flushCache');

            % Remove any ROIs
            %TODO: change this to "isempty" when the qt_roi method "isempty" is
            %no longer overloaded
            if (numel(obj.roiObj)>0)
                notify(obj.roiObj,'newRoiData')
            end

        end %qt_image.deconstruct

        function delete(obj)

            % Before deconstructing the image objects, delete any existing
            % displayed images in the imgview objects. Normally, the IMGVIEW
            % objects would delete these images during a call to the destructor,
            % but as a convenience to ensure that the axis doesn't "flicker"
            % when changing image displays only destruction of the QT_IMAGE
            % object will delete these data. This is accomplished by updating
            % the existing CData of associated images when a new axis is set in
            % the QT_IMAGE object's properties instead of calling imshow every
            % time an image is displayed
            hIm     = [];
            if ~isempty(obj.imgViewObj) && any(obj.imgViewObj.isvalid)
                hIm = [obj.imgViewObj.hImg];
                obj.imgViewObj.delete;
            end
            if ~isempty(hIm)
                % Grab only the valid image axes and the handle "Tag" property
                hIm    = hIm(ishandle(hIm));
                if ~iscell(hIm)
                    hIm = num2cell(hIm);
                end
                hAx    = cellfun(@(x) get(x,'Parent'),hIm,...
                                                       'UniformOutput',false);
                axTags = cellfun(@(x) get(x,'Tag'),hAx,'UniformOutput',false);

                % Delete the images
                cellfun(@delete,hIm);

                % Revert these axis properties to their default values, keeping
                % the current axis tag
                cellfun(@reset, hAx);
                cellfun(@(x) axis(x,'off'),hAx);
                cellfun(@(x,t) set(x,'Tag',t), hAx, axTags);
            end

        end %qt_image.delete

        function remove_view(obj,viewObj)
        %remove_view  Removes an imgview object from storage
        %
        %   remove_view(OBJ,VIEWOBJ) removes the imgview object, VIEWOBJ, from
        %   the qt_image object's storage property "imgViewObj"

            % Get the imgview current objects
            viewObjs = obj.imgViewObj;
            rmMask   = (viewObjs==viewObj);
            if any(rmMask)
                obj.imgViewObj = viewObjs(~rmMask);
            end

        end %qt_image.remove_view

    end


    %------------------------------ Static Methods -----------------------------
    methods (Static)

        % Creates a constant image
        %
        %   Type "help qt_image.makeconstant" for more information
        obj = makeconstant(m,a);

    end

end %qt_image


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Construct the parser
    parser = inputParser;

    % Parse the first input; this is most easily handled separately from any
    % additional user-specified options. Determine if the user is using the file
    % or image input syntax. For the former, validate all file/directory names.
    if isnumeric(varargin{1}) %image specified
        parser.addRequired('imageInput');
    elseif (ischar(varargin{1}) && exist(varargin{1},'file')) ||...
                                                             iscell(varargin{1})

        % Determine which of the inputs are directories and parse the file names
        if ~iscell(varargin{1})
            varargin{1} = varargin(1);
        end
        isDir = cellfun(@(x) (exist(x,'dir')==7),varargin{1});
        if any(isDir)
            % Parse the file names for the specified directories
            fNames = parse_filenames(varargin{1}(isDir));

            % Update the input cell array to reflect the new file names
            varargin{1} = [varargin{1}(~isDir) fNames(:)];
        end

        parser.addRequired('imageInput');
        if iscell(varargin{1}) %cell array of string specified
            cellfun(@validate_files,varargin{1});
        end
    else
        error('qt_image:parse_inputs:invalidImageOrFileName',...
             ['The first QT_IMAGE input must be a valid file/directory ',...
              'name (or cell containing such names) or an image.']);
    end

    % Validate each of the user-specified options and add the param/value parser
    % components to the input parser. In lieu of using the defined defaults,
    % simply use an empty array as properties that are not specified will need
    % to be removed from the inputs; there is no need to set those properties
    % that have defaults defined by the class
    if (nargin>1)
        qtProps = sort( properties(mfilename) ); %sort for easy remove of field 
                                                 %from "results" below
        cellfun(@(x) parser.addParamValue(x,[]),qtProps);
    end

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % Handle the image class inputs here. Because qt_image wraps a number of
    % properties (using dependent properties) those properties that should be
    % passed to the image object constructor need to be parsed here
    varargout{1} = results.imageInput;
    results      = rmfield(results,'imageInput');

    % Remove parsed values that were not specified by the user, but were defined
    % by the parser defaults
    isRemove = cellfun(@isempty,struct2cell(results));
    %TODO: this if exists statement is a temporary patch. If only a single file
    %name is specified, then nargin will be 1 (meaning qtProps doesn't get
    %defined). Write better code...
    if exist('qtProps','var')
        results  = rmfield(results,qtProps(isRemove));
    end

    % Store the remaining outputs
    varargout(2:3) = {fieldnames(results),struct2cell(results)};

end

%---------------------------------------
function fList = parse_filenames(fNames)

    % Determine which of the file/directory name inputs is a file/directory name
    if ~iscell(fNames)
        fNames = {fNames};
    end
    isFile = cellfun(@(x) (exist(x,'file')==2),fNames);

    % At this point, each of the file names has already been validated. Remove
    % the files from the cell array, "fNames", and store in the output since
    % nothing else needs to be done with these strings
    fList  = fNames(isFile);
    fNames = fNames(~isFile);

    % Check each of the directories for images
    fNames = cellfun(@dir2files,fNames, 'UniformOutput',false);

    % Combine the outputs
    fList = [fList(:);fNames{:}];

end %parse_filenames

%--------------------------------
function fList = dir2files(dirIn)

    % Grab the directory constiuents, removing the usual suspects ("." and "..")
    % and directories
    fList = gendirfiles(dirIn);

    % The directory should contain files. Otherwise inform the user
    if isempty(fList)
        warning([mfilename ':emptyDirectory'],...
                ['"%s" contained no files. This directory''s contents ',...
                 'will be omitted from the import operation.'],dirIn);
    end

end %dir2files

%-----------------------------
function validate_files(fName)

    if ~ischar(fName)
        error('qt_image:invalidFileInput',...
             ['The first qt_image input must be a file/directory name ',...
              '(or cell containing such names) or an image.']);
    elseif all(exist(fName,'file')~=[2 7])
        error('qt_image:invalidFileOrDir',...
              '"%s" is not a valid file or directory. ',fName);
    end

end %validate_files