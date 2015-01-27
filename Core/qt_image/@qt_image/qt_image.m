classdef qt_image < handle
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
%       windowBounds    Minimum and maximum allowable image window display range
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
        %   Processed image (i.e. scaling, transformations, etc. are applied) to
        %   this property before returning the array.
        %
        %   NOTE: for DICOM images, which nominally only support 2D storage, a
        %   volume must be represented by an arry of N image objects, where N is
        %   the number of images in the third dimension.
        image

    end

    properties (SetObservable = true)

        % Basic image properties
        %-----------------------

        % Full file name of the image
        %
        %   This property specifies the full file name from which image data are
        %   read and the file to which image data are written.
        fileName = '';

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

        % Image format
        %
        %   "format" is a string specifying the image file format (see supported
        %   formats below) to be used during read/write operations. Many methods
        %   perform specific operations based on "format". While all attempts
        %   are made to automatically determine this property, the user is
        %   ultimately responsible for ensuring that an appropriate value is
        %   specified. Inappropriate values can result in errors...
        %
        %       Supported Types
        %       ---------------
        %
        %      'dicom'
        %      'metaimage'
        %      'unknown'
        format = 'unknown'; %image type used to perform operations

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

        % Flag for reading images on the fly.
        %
        %   A logical flag specifying whether to read images as their data are
        %   requested by the user (default) or to read all image data into
        %   memory. If true (default) images, are read on the fly.
        memorySaver = true;

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

        % Window display bounds
        %
        %   A 1-by-2 array defining the minimum and maximum allowable values for
        %   the display window. For example, when displaying MRI images, values
        %   should be greater than or equal to zero (unless processing has been
        %   performed). Default: [-inf inf]
        windowBounds = [-inf inf];

        % Window level
        %
        %   "wl" is a numeric scalar specifying the window level to be used when
        %   displaying the image
        wl

        % Window width
        %
        %   "ww" is a numeric scalar specifying the total window width to be
        %   used when displaying the image
        ww

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

        % GUI mode flag
        %
        %   "guiDialogs" is a logical flag that enables (true) or disables
        %   (false) the use of graphical notifications, such as the image load
        %   dialog, when using a qt_image object.
        guiDialogs = true;

    end

    properties(Dependent,Hidden=true)

        % Handle(s) of axis used to dislpay the image.
        %
        %   "hAxes" is an array of axis handles that are currently displaying
        %   the qt_image object's image data
        hAxes

        % Image size
        %
        %   Vector of the size of each dimension of the "image" property
        imageSize

        % Image ROI values
        %
        %   Voxel values conatined within linked ROIs, and empty otherwise
        imageValues

        % Zoom state of the image
        %
        %   A logical scalar specifying the zoom state of the image.
        isZoomed

    end

    properties (SetObservable=true,Hidden=true)

        % Meta-data to display
        %
        %   A cell array of meta-data fields or image properties (e.g.,
        %   "imageSize" or "format") to display when images are visualized using
        %   the "show" method. For each of the m rows, a new line is displayed
        %   using the data from each of the n meta-data fields specified. For
        %   each escape character in the "dispFormat" property, a corresponding
        %   display field must exist, otherwise display errors will occur
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

    properties (Access='private',Hidden=true)

        % Image view object storage
        %
        %   Stores an array of image view objects. These objects handle all
        %   events associated with displaying qt_image data
        imgViewObj = imgview.empty(0,0);

        % ROI object storage
        %
        %   Stores an array of qt_roi objects. These objects are shown with the
        %   images
        roiObj = qt_roi.empty(1,0);

        % Raw image storage
        %
        %   Non-dependent storage for the original image data
        imageRaw

        % Flag for tracking image and meta data edits
        isEdited = false;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_image(varargin)
        %qt_image  Constructs an instance of a qt_image object
        %
        %   OBJ = qt_image creates an empty QUATTRO image object using defaults
        %   were possible. Object properties such as "image", "metaData", etc.
        %   can be set after constructing the object. While the original design
        %   goals of this class were based on the needs of QUATTRO, this class
        %   performs equally as well outside of QUATTRO.
        %
        %   OBJ = qt_image(FILE) creates a qt_image object H by reading the
        %   image data stored in file specifeid by the string FILE. FILE can
        %   also specify a directory of images, creating an array of qt_image
        %   objects OBJ by searching for all image files in the directory
        %   (sub-directories are ignored). FILE can also be a cell array
        %   containing any strings for any combination of directories and files.
        %
        %   OBJ = qt_image(I) creates a qt_image object H from the single 2- or
        %   3-D numeric array I. Several properties necessary for display
        %   purposes are automatically set (e.g. WW and WL).
        %
        %   OBJ = qt_image(...,'PROP1',VAL1,...) creates OBJ as described above,
        %   setting the specified property values before performing other
        %   operations.

            % Attach the properties' listeners
            addlistener(obj,'color',     'PostSet',@obj.color_postset);
            addlistener(obj,'dispFields','PostSet',@obj.newdisp);
            addlistener(obj,'dispFormat','PostSet',@obj.newdisp);
            addlistener(obj,'fileName',  'PostSet',@fileName_postset);
            addlistener(obj,'metaData',  'PostSet',@metaData_postset);
            addlistener(obj,'wwwlMode',  'PostSet',@obj.wwwlMode_postset);

            % Do nothing with zero inputs...this is required by MATLAB for
            % smooth operation
            if (nargin==0)
                return
            end

            % Parse the inputs
            [fNames,img,props,vals] = parse_inputs(varargin{:});

            % Set the image property
            if ~isempty(img)
                obj.image       = img;
                obj.memorySaver = false;
            end

            % File names have been specified (or derived from a directory)
            % perform the load operation
            if ~isempty(fNames)
                % Set filenames for object and initialize the wait bar and
                % output objects
                nf        = numel(fNames);
                hWait     = []; %initialize waitbar variable
                if obj.guiDialogs && (nf>1)
                    hWait = waitbar(0,'0% Complete','Name','Loading images...');
                end
                obj       = qt_image.empty(nf,0); %initialize PostSet will fire
                for fIdx = 1:nf

                    % Waitbar functionality
                    if ~isempty(hWait) && ishandle(hWait)
                        pct = fIdx/nf;
                        waitbar(pct,hWait,sprintf('%d%% Complete',round(pct*100)));
                    elseif ~isempty(hWait) && ~ishandle(hWait) %user cancelled
                        obj = qt_image.empty(1,0);
                        break
                    end

                    % Assign file name (fires header reading utility)
                    obj(fIdx).fileName = fNames{fIdx};
                end

                % Delete the waitbar if it still exists
                if ishandle(hWait)
                    delete(hWait);
                end

                % Some PostSet events attempt to read files that appear to be
                % images. In some cases, these files (e.g., OSIRIX DICOMs) can
                % contain no actual image data and are deleted during the
                % attempted initialization and must be removed before returning
                % the array of objects
                obj( ~obj.isvalid ) = [];

                % Remove unsupported image files
                supportFrmt = {'dicom','jpg','tif'};
                isSupported = cellfun(@(x) any(strcmpi(x,supportFrmt)),...
                                                                  {obj.format});
                obj(~isSupported) = [];

            end

            % Deal user-specified properties (i.e., optional inputs) qt_image
            if ~isempty(obj) && all(obj.isvalid)
                for idx = 1:length(props)
                    [obj(:).(props{idx})] = deal(vals{idx});
                end
            end

        end

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.hAxes(obj)
        %hAxes  Array of axes used to display image data
        %
        %   H = obj.hAxes returns the array of all axis handles that are being
        %   used currently to display the qt_image object's image data

            val = unique([obj.imgViewObj.hAxes]);

        end %qt_image.get.hAxes

        function val = get.image(obj)
        %image  Image property of qt_image object
        %
        %   im = obj.image returns the image property of the qt_image object
        %   obj. If memorySaver is enabled, the image is first read and is
        %   then passed as output, but not stored

            % Determine where the data is stored
            if isempty(obj.imageRaw) && obj.memorySaver %read on-the-fly
                [tf,val] = obj.read;
                if ~obj.memorySaver && tf %store the image
                    obj.imageRaw = val;
                end
            else %data already in memory
                val = obj.imageRaw;
            end

            % Process the image
            m = size(val);
            n = numel(m);
            if obj.scale~=1
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
            val = enforce_im_bounds(val,obj.windowBounds);

        end %get.image

        function val = get.imageSize(obj)
        %imageSize  Size of image
        %
        %   m = obj.imageSize returns a row vector containing the number of
        %   voxels for each dimension of the image data stored in the
        %   qt_image object.

            val = size(obj.image);
            
        end %get.imageSize

        function val = get.imageValues(obj)

            val = [];
            if ~isempty(obj.roiObj)
                val = obj.roiObj.mask(obj.image);
            end

        end %get.imageValues

        function val = get.isZoomed(obj)
            val = false; %initialize

            viewObj = obj.imgViewObj;
            if ~isempty(viewObj)
                val = viewObj.isZoomed;
            end
        end %get.isZoomed

        function val = get.roiObj(obj)
            % Get the only the valid qt_roi objects and update the "roiObj"
            % property with those
            val = obj.roiObj;
            val        = val(val.validaterois);
            obj.roiObj = val;
        end %get.roiObj

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.color(obj,val)

            % Validate the input using validatestring to partial match
            try
                val = validatestring(val,{'hsv','hot','cool','bone','jet',...
                                              'copper','pink','prism','prism'});
            catch ME
                if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
                    rethrow(ME)
                elseif ~ischar(val)
                    warning('qt_image:wwwlMode:nonChar',...
                            ['Non-character value detected.\n',...
                             'No changes were made to the property "color".']);
                elseif ~any( strcmpi(val,{'internal','axis',}) )
                    warning('qt_image:wwwlMode:invalidMode',...
                            ['''%s'' does not match any valid WW/WL mode.\n',...
                             'No changes were made to the property "color".']);
                end
            end

            % Update the value
            obj.color = val;
        end

        function set.dispFields(obj,val)

            % Store the fields. Note that validation is performed in the PostSet
            % event
            if ischar(val)
                val = {val};
            end

            % Store input and notify of change
            obj.dispFields = val;
                    
        end %set.dispFields

        function set.dispFormat(obj,val)

            if (~ischar(val) && ~iscell(val)) ||...
                                     (iscell(val) && any(~cellfun(@ischar,val)))
                warning('qt_image:dispFormat:invalidValue','%s\n%s',...
                        'Non-character value detected.',...
                        'No changes were made to the property ''dispFormat''.');
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

        end %set.dispFormat

        function set.image(obj,val)
        %set.image  Sets the qt_image "image" property
        %
        %   OBJ.image = IM sets the "image" property of the qt_image object OBJ
        %   to the value of IM. This operation automatically calculates other
        %   properties such as the "wl", "ww", "windowBounds". When storing
        %   image data in this manner, the memory saver flag is automatically
        %   disabled.

            % "image" is a dependent property, instead store the data in
            % "imageRaw" for later calls.
            obj.imageRaw = val;

            % Certain properties should be initialized when setting the "image"
            % property; other methods/properties depend on these data
            obj.windowBounds = [min( val( ~isnan(val(:)) & ~isinf(val(:))) ),...
                                max( val( ~isnan(val(:)) & ~isinf(val(:))) )];
            obj.wl           = abs( diff(obj.windowBounds)/2 );
            obj.ww           = 2*obj.wl;

            % Disable the memory saver flag
            obj.memorySaver = false;

        end %set.image

        function set.imgViewObj(obj,val)

            % Validate the input
            if ~strcmpi( class(val), 'imgview' )
                warning('qt_image:imgViewObj:invalidObject',...
                        'Input was of class "%s", expected "imgview".\n',...
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

        end %set.imgViewObj

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
                    warning('qt_image:units:invalidUnit',...
                           ['"%s" is an invalid unit string. No changes\n',...
                            'were made to the property "unit".\n'],val);
                end
            else
                warning('qt_image:units:nonCharValue',...
                       ['The qt_image property "units" only accepts\n',...
                        'character inputs. No change was applied.\n']);
            end
                
        end %set.units

        function set.wl(obj,val)

            % Do nothing with empty values
            if isempty(val)
                return
            end

            % Validate/store input
            if (numel(val)>1)
                warning('qt_image:wl:nonScalarValue','%s\n%s',...
                        'Non-scalar value detected.',...
                        'No changes were made to the property ''wl''.');
            elseif isempty(val) || ~isnumeric(val) || isnan(val) || isinf(val)
                warning('qt_image:wl:invalidValue','%s\n%s',...
                        'Non-numeric, NaN, or infinite value detected.',...
                        'No changes were made to the property ''wl''.');
            else
                obj.wl = double(val);
            end
            
        end %set.wl

        function set.ww(obj,val)

            % Do nothing with empty values
            if isempty(val)
                return
            end

            % Validate/store input
            if (numel(val)>1)
                warning('qt_image:ww:nonScalarValue','%s\n%s',...
                        'Non-scalar value detected.',...
                        'No changes were made to the property ''ww''.');
            elseif ~isnumeric(val) || isnan(val) || isinf(val) || (val<0)
                warning('qt_image:ww:invalidValue','%s\n%s',...
                        'Non-numeric, NaN, or infinite value detected.',...
                        'No changers were made to the property ''ww''.');
            else
                obj.ww = double(val);
            end
            
        end %set.ww

        function set.wwwlMode(obj,val)

            % Validate the input using validatestring to partial match
            try
                val = validatestring(val,{'axis','immean','internal'});
            catch ME
                if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
                    rethrow(ME)
                elseif ~ischar(val)
                    warning('qt_image:wwwlMode:nonChar','%s\n%s',...
                            'Non-character value detected.',...
                            'No changes were made to the property ''wwwlMode''.');
                elseif ~any( strcmpi(val,{'internal','axis',}) )
                    warning('qt_image:wwwlMode:invalidMode','''%s'' %s\n%s',...
                            val,'does not match any valid WW/WL mode.',...
                            'No changes were made to the property ''wwwlMode''.');
                end
            end

            % Update the value
            obj.wwwlMode = val;

        end %set.wwwlMode

    end


    %------------------------------ Other Methods ------------------------------
    methods (Hidden=true)

        function deconstruct(obj,src,eventdata)
        %deconstruct  Dissociates imgview object data from an axis
        %
        %   deconstruct(OBJ,SRC,EVENT) removes all image data links by deleting
        %   the imgview object that notified the "deconstructView" event (i.e.
        %   SRC). This event also clears the temporary storage of the qt_image
        %   object OBJ, such as the raw image cache.

            % Delete the imgview (includes the text and image) object that fired
            % this event. This must be done first to ensure that the following
            % checks can determine how many imgview objects remain for the
            % current qt_image object.
            src.delete;

            % Destroy raw image data if memory saver is on
            if obj.memorySaver && isempty(obj.imgViewObj)
                obj.imageRaw = [];
            end

            % Remove any ROIs
            %TODO: change this to "isempty" when the qt_roi method "isempty" is
            %no longer overloaded
            if (numel(obj.roiObj)>0)
                notify(obj.roiObj,'newRoiData')
            end

        end %qt_image.deconstruct

        function delete(obj)

            % Before deconstructing the image objects, delete any existing
            % displayed images in the imgview objects. Normally, the imgview
            % objects would delete these images during a call to the destructor,
            % but as a convenience to ensure that the axis doesn't "flicker"
            % when changing image displays only destruction of the qt_image
            % object will delete these data. This is accomplished by updating
            % the existing CData of associated images when a new axis is set in
            % the qt_image object's properties instead of calling imshow every
            % time an image is displayed
            hIm     = [];
            if obj.isvalid && ~isempty(obj.imgViewObj) && obj.imgViewObj.isvalid
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

end %qt_image


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Parse the first input; this is most easily handled separately from the
    % options. Determine if the user is using the file or image input syntax.
    % For the former, validate all file/directory names.
    if ischar(varargin{1}) %convert single file/dirs names to cell for use below
        varargin{1} = varargin(1);
    end
    if iscell(varargin{1})
        cellfun(@validate_files,varargin{1});
        varargout{1} = parse_filenames(varargin{1});
    elseif isnumeric(varargin{1}) && (ndims(varargin{1})<4) &&...
                           (ndims(varargin{1})==2 && all( size(varargin{1})>1 ))
        varargout{2} = varargin{1};
    else
        error('qt_image:parse_inputs:invalidImageOrFileName',...
             ['The first qt_image input must be a valid file/directory\n',...
              'name (or cell containing such names) or an image.']);
    end
    varargin(1) = []; %remove the 1st input; only options need parsing now

    % Construct the parser
    parser = inputParser;

    % Validate each of the user-specified options and add the param/value parser
    % components to the input parser
    if (nargin>1)
        obj = qt_image; %needed for defining defaults and property names
        varargin(1:2:end) = cellfun(@(x) validatestring(x,properties(obj)),...
                                       varargin(1:2:end),'UniformOutput',false);
        cellfun(@(x) parser.addParamValue(x,obj.(x)),varargin(1:2:end));
    end

    % Parse the inputs
    parser.parse(varargin{:});

    % Deal the outputs
    varargout(3:4) = {fieldnames(parser.Results),struct2cell(parser.Results)};

end


%---------------------------------------
function fList = parse_filenames(fNames)

    % Determine which of the file/directory name inputs is a file/directory name
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
    fList = parse_dir_files(dirIn);

    % The directory should contain files. Otherwise inform the user
    if isempty(fList)
        warning('qt_image:emptyDirectory',['"%s" contained no files.\n',...
                'Skipping this directories contents during import.\n'],dirIn);
    end

end %dir2files

%-----------------------------
function validate_files(fName)

    if ~ischar(fName)
        error('qt_image:invalidFileInput',...
             ['The first qt_image input must be a file/directory name\n',...
              '(or cell containing such names) or an image.']);
    elseif all(exist(fName,'file')~=[2 7])
        error('qt_image:invalidFileOrDir',...
              '"%s" is not a valid file or directory.\n',fName);
    end

end %validate_files