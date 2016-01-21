classdef qt_exam < examevents & generalopts
%Exam storage class
%
%   Type "doc qt_exam" for a summary of all properties and methods.
%
%   Methods
%   -------
%   Type "methods qt_exam" to see a list of methods
%
%   Controlling data look-up: the properties "sliceIdx", "seriesIdx", "roiIdx",
%   and "roiTag" act as the user interface for accessing data in the exam
%   object. During normal GUI operation, these properties are updated
%   automatically by events in the GUI (e.g. changing the slice slider),
%   providing access to the "locked" storage properties of the exam object. By
%   manually specifying indices, the user is allowed utilize exam methods, which
%   grab data according to these indices to perform operations on the various
%   data (i.e. scripting).

    properties (SetObservable,AbortSet)

        % File name of the current exam
        %
        %   "fileName" is a string containing the full path file name of the
        %   current exam. This is the file from which a QUATTRO exam was loaded
        %   or last saved.
        fileName

        % Exam object type
        %
        %   "type" is a string specifying the exam type of the current object.
        %   This is any package contained in the nested packages within the
        %   qt_models package. The following strings are currently supported for
        %   "type":
        %
        %       Exam Type       Description
        %       --------------------------------
        %       dce             3- or 4-D dynamic-contrast enhanced exam. Serial
        %                       acquisition of T1-, T2-, or T2*-weighted images
        %                       following injection of a contrast agent. A
        %                       number of models, including the general kinetic
        %                       model and perfusion models such as the indicator
        %                       dilution theory.
        %
        %       dwi             Diffusion weighted imaging exam. Using the
        %                       serially acquired DW images with varying
        %                       b-values and few than six encoding directions,
        %                       allows computation of ADC and IVIM model
        %                       parameters
        %
        %       generic         Standard exam type for simple display and ROI
        %                       analysis. Custom models can be defined for
        %                       quantification.
        %
        %       multiflip       Variable flip angle T1 relaxometry technique.
        %                       Allows computation of T1
        %
        %       multite         Variable echo time T2 relaxometry technique.
        %                       Allows computation of T2
        %
        %       multiti         Variable inversion time T1 technique. Allows
        %                       computation of T1
        %
        %       multitr         Variable repetition time (or saturation
        %                       recovery) T1 technique. Allows computation of T1
        type = '';

        % Exam object name
        %
        %   "name" is a user-specified string that provides a custom (not
        %   unique) name specifying the QT_EXAM object in QUATTRO.
        name = '';

        % Indices for accessing data
        %----------------------------

        % Current exam position
        %
        %   "examIdx" is a numeric scalar that determines which exam is accessed
        %   when property updates occur internally (e.g. ROIs or images)
        examIdx = 1;

        % Current ROI tag selection
        %
        %   "roiTag" is a string specifying the currently activated ROI tag used
        %   to determine the output of the "roi" property. Tags must match one
        %   of the tags for the current ROIs in the QT_EXAM object.
        roiTag = 'roi';
 
        % Current ROI selection
        %
        %   "roiIdx" is a structure containing the indices used to determine the
        %   the output of the "roi" property. Fields of this property are based
        %   on the "tag" property of the ROIs stored in the QT_EXAM property
        %   "rois"
        roiIdx = struct('roi',0);

        % Current slice position
        %
        %   "sliceIdx" is a numeric scalar that determines which slice is
        %   accessed when property updates occur internally (e.g. ROIs or
        %   images)
        sliceIdx = 1;

        % Current series position
        %
        %   "seriesIdx" is a numeric scalar that determines which series is
        %   accessed when property updates occur internally (e.g. ROIs or
        %   images)
        seriesIdx = 1;

        % Current in-plane voxel position
        %
        %   "voxelIdx" is a 1-by-2 numeric vector that specifies the in-plane
        %   position of the exam. The vector will be empty until a position is
        %   specified manually or via the data cursor mode.
        voxelIdx

        % Current map selection
        %
        %   mapIdx determines which map is accessed when property updates occur
        %   internally or the user access the "map" property. **IMPORTANT** This
        %   particular index uses the value 0 to specify no map selection.
        mapIdx = 0;

        % Flag for using ROI tags
        %
        %   "useRoiFlags" is a logical flag specifying the use of ROI tags. When
        %   false (default), all ROIs are collapsed to single tag, "roi", with
        %   no distinction being made between ROIs with different flags. This
        %   flag is used primarily when switching between exams that utilize
        %   different sets of flags.
        useRoiFlags = false;

        %TODO: determine a better way to handle this. "modelXValsCahce" should
        %likely be a transient property...
        % Model x-value cache
        %
        %   "modelXValCache" stores the model x-values for the current QT_EXAM
        %   object. This saves on the number of computations per call to
        %   "modelXVals" and allows the user to sotre values in the dependent
        %   variable "modelXVals"
        modelXValsCache

    end

    properties (Dependent)

        % Current image being displayed in QUATTRO.
        %
        % "image" is a numeric 2D or 3D array of the data from the QT_IMAGE
        % object being displayed in QUATTRO. By default, this image is taken
        % from the general image storage with no alterations. If image
        % registrations are loaded and being applied, this image will be the
        % transformed image
        image

        % Meta data of the current image displayed in QUATTRO
        %
        %   "metaData" is a structure of meta data for the current image. If no
        %   meta data exist, this property will be empty
        metaData

        % Current parameter map
        %
        %   "map" returns the current QT_IMAGE object storing the specified map
        %   data property based on the current selection parameters of QUATTRO
        %   (i.e. slice and map selection)
        map

        % Current available map names
        %
        %   "mapNames" returns the name of all available maps for the given
        %   selection of slice/series
        mapNames

        % Current model x-values
        %
        %   "modelXVals" returns the vector of x-values (time, flip angle, TR,
        %   etc.) for the current exam type.
        modelXVals

        % Position of QUATTRO in physical space coordinates
        %
        %   "ras" is a 1-by-3 vector representing the current location of QUATTRO
        %   in the physical spaced defined by information in the meta data (i.e.
        %   pixel dimensions and pixel offsets) and the size of the image(s)
        ras

        % Current ROI
        %
        %   "roi" is an array of qt_roi objects being displayed currently by
        %   QUATTRO.
        roi

        % Current available ROI names
        %
        %   "roiNames" returns the name of all available ROIs for the QT_EXAM
        %   object
        roiNames

    end

    properties (Hidden,SetObservable)

        % Image object storage
        %
        %   "imgs" is a 2D array of QT_IMAGE objects stored in the QT_EXAM
        %   object. The array indices correspond to, in order, the slice
        %   location and series location of the image objects.
        imgs = qt_image.empty(1,0);

        % Current exam flag
        %
        %   "isCurrent" is a logical scalar specifying the selection state
        %   of the current exam object. When TRUE, this flag denotes that
        %   the exam object is currently selected (only in the context of
        %   the QUATTRO GUI).
        %
        %   When running an exam object (or objects) in a standalone mode
        %   of operation, this flag is not utilized
        isCurrent = true;

        % Parameter maps object storage
        %
        %   Array of QT_IMAGE objects representing parametric maps stored in the
        %   QT_EXAM object
        maps = struct([]);

        % QUATTRO options object
        %
        %   qt_options object initialized during the first call to QUATTRO
        opts
        %TODO: figure out what to do with "opts" when using QT_EXAM objects at
        %the command prompt

        im_temp; %%%%registered img functionality ~~will change in future~~

        wcs  %%%%registered img transformation ~~functionality will change~~

    end

    %FIXME: this should have 'protected' set access... It was left open to
    %accommodate adding large numbers of ROIs
    properties (Hidden,SetObservable)

        % Data existence structure
        %
        %   Structure containing internally modified tags specifying the
        %   existence of specified data within the QT_EXAM object. Some fields
        %   within the structure are, in fact, other structures.
        exists = struct('any',false,...
                        'images',struct('any',false,'copy',false,'is3D',false),...
                        'maps',struct('any',false,'copy',false,'current',false),...
                        'rois',struct('any',false,'copy',false,'current',false,...
                                      'roi',false,'selected',false,'undo',false));

        % Computation readiness structure
        %
        %   Structure containing internally modified logical flags specifying
        %   the readiness of certain computations (e.g., maps)
        isReady = struct('maps',false);

        % Parameter map modeling object
        %
        %   "mapModel" is a scalar modeling object that is used for computing
        %   maps. All creation operations are handled internally within the
        %   QT_EXAM object in conjunction with the qt_options object
        mapModel

        % Array of modeling object
        %
        %   "models" is a cell array of modeling objects that are used to
        %   investigate the data set through the quantitative imaging tool
        %   (QIMTOOL) or manually at the command prompt.
        %
        %   See also qt_exam.createmodel
        models = {};

        % ROI object storage
        %
        %   "rois" is a 4D array of qt_roi objects stored in the QT_EXAM object.
        %   The corresponding indices of the array represent, in order, the ROI
        %   label, slice location, series location, and ROI number.
        %
        %   When storing ROI data, the properties of the qt_roi object instruct
        %   the QT_EXAM object where to store the object. The name of the
        %   incoming ROI object is forced to be the name of all other ROIs at
        %   the corresponding ROI index. A similar operation is performed for
        %   the "tag" property
        rois = struct('roi',qt_roi.empty(1,0));

        % Copied ROI data
        %
        %   "roiCopy" is a structure containing all copied ROI properties
        %   necessary for recreating an ROI during a paste operation
        roiCopy = qt_roi.empty(1,0);

        % ROI undo data
        %
        %   "roiUndo" is an array of structures containing cloned qt_roi ROI
        %   objects that have been modified in some fashion (deleted, moved,
        %   resized, etc.) the structure also contains the modification method
        %   (one of 'deleted' or 'moved') and the QT_EXAM position where the
        %   modification occured
        roiUndo

        % Vascular input function cache
        %
        %   "vifCache" is a temporary cache for storing the vascular input
        %   function after the time-intensive computations performed by the
        %   QT_EXAM method "calculatevif".
        vifCache = [];

        dicom_trafo;  %transformation matrix to DICOM coordinates

        % QUATTRO figure handle
        %
        %   "hFig" is the scalar figure handle that references the QUATTRO GUI
        hFig

        % HGOs storage for external GUIs that interact w/ exam object
        hExtFig

    end

    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_exam(varargin)
        %qt_exam  Constructs a qt_exam object
        %
        %   OBJ = qt_exam(FIG) constructs an empty instance of an exam class
        %   object without images, headers, or ROIs, storing only the figure
        %   handle specified by FIG, and returning the QT_EXAM object. During
        %   this process, the figure application data is populated with a number
        %   of objects on which QT_EXAM operation relies. All object properties,
        %   such as images and ROIs are set after object construction either
        %   directly or through the methods (most efficient)
        %
        %   Nominally, FIG can be the handle to any figure. This provides direct
        %   access to using QT_EXAM as an API for new applications. When QUATTRO
        %   is being used, FIG should be the figure handle for the QUATTRO GUI.
        %
        %   The following list of application data are used when operating
        %   QT_EXAM in a graphical mode. Modifying or deleting these data can
        %   cause QUATTRO to perform unexpectedly
        %
        %       App Data            Description
        %       -------------------------------
        %       'qtExamObject'      QT_EXAM object being used currently by the
        %                           figure specified by FIG
        %
        %       'qtWorkspace'       Array of QT_EXAM objects that contain all
        %                           loaded data to be accessed by the figure.
        %                           The object stored in 'qtExamObject' can be
        %                           accessed from this array using the property
        %                           "examIdx"
        %
        %       'qtOptsObject'      qt_options object that provides support for
        %                           the current figure. All QT_EXAM objects in
        %                           memory rely on this single qt_options object
        %
        %
        %   OBJ = qt_exam(OBJ) creates a new QT_EXAM object to be stacked with
        %   another QT_EXAM object OBJ. This syntax is primarily used by the
        %   QUATTRO, but can be useful when loading numerous objects.
        %
        %   OBJ = qt_exam(FILE) loads all data in the QUATTRO save file
        %   specified by the file name FILE.

            % Attach the properties' PreSet listeners
            addlistener(obj,'roiIdx',   'PreSet',@roiIdx_preset);
            addlistener(obj,'roiTag',   'PreSet',@obj.roiTag_preset);
            
            % Attach the properties' PostSet listeners
            addlistener(obj,'examIdx',  'PostSet',@examIdx_postset);
            addlistener(obj,'hFig',     'PostSet',@obj.hFig_postset);
            addlistener(obj,'imgs',     'PostSet',@obj.imgs_postset);
            addlistener(obj,'maps',     'PostSet',@obj.maps_postset);
            addlistener(obj,'roiIdx',   'PostSet',@roiIdx_postset);
            addlistener(obj,'rois',     'PostSet',@obj.rois_postset);
            addlistener(obj,'roiTag',   'PostSet',@obj.roiTag_postset);
            addlistener(obj,'seriesIdx','PostSet',@obj.seriesIdx_postset);
            addlistener(obj,'sliceIdx', 'PostSet',@obj.sliceIdx_postset);
            addlistener(obj,'type',     'PostSet',@type_postset);
            addlistener(obj,'voxelIdx', 'PostSet',@voxelIdx_postset);

            % Attach event listeners
            addlistener(obj,'imgDeleted',    @obj.imgsdeleted);
            addlistener(obj,'initializeExam',@initialize);
            addlistener(obj,'newModel',      @obj.newModel_event);
            addlistener(obj,'roiDeleted',    @obj.roiDeleted_event);

            if nargin && ischar(varargin{1}) && exist(varargin{1},'file')

                % Send the file and data type to addexam
                obj = obj.addexam('loadqsave','','auto',varargin{:});

            elseif (nargin==1) && ishandle(varargin{1}) %base constructor

                % Set the figure
                obj.hFig       = varargin{1};
                obj.guiDialogs = true;

            elseif (nargin==1) && strcmpi( class(varargin{1}), 'qt_exam' )

                % Copy the figure and the "guiDialgos" flag
                obj.hFig       = varargin{1}.hFig;
                obj.guiDialogs = varargin{1}.guiDialogs;

            else %no load request was made and no QUATTRO handle was passed so
                 %load the options and return the QT_EXAM object

                obj.opts = qt_options;

            end

        end %exam

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.hExtFig(obj)
            val = obj.hExtFig;
            if ~isempty(val)
                val(~ishandle(val)) = [];
            end
        end %get.hExtFig

        function val = get.image(obj)

            val = qt_image.empty(1,0); %initialize output

            % Grab the actual image if possible
            mIm = size(obj.imgs);
            if (mIm(1)>=obj.sliceIdx) && (mIm(2)>=obj.seriesIdx)
                val = obj.imgs(obj.sliceIdx,obj.seriesIdx);
            end

        end %get.image

        function val = get.map(obj)

            % Initialize the QT_IMAGE output
            val = qt_image.empty(1,0);

            % Get the requested map
            if (obj.mapIdx>0)
                try
                    mapTags = fieldnames(obj.maps);
                    val     = obj.maps.(mapTags{obj.mapIdx})(obj.sliceIdx);
                catch ME
                    rethrow(ME)
                end
            end

        end %get.map

        function val = get.mapNames(obj)

            val = {}; %initialize
            if ~isstruct(obj.maps)
                return
            end

            % Get the names
            try
                ms  = struct2cell(obj.maps);
                ms  = ms( ~cellfun(@isempty,ms) ); %remove non-existent maps
                val = cellfun(@(x) x.tag,ms, 'UniformOutput',false);
            catch ME
                if ~strcmpi(ME.identifier,'MATLAB:badsubscript')
                    rethrow(ME);
                end
            end

        end %get.mapNames

        function val = get.metaData(obj)
        %get.metaData  Gets meta data for the current image
        %
        %   obj.metaData returns the meta data structure stored in the exam
        %   property imgs for the current QUATTRO exam, slice and series 
        %   location.
        %
        %   obj.metaData.FLD returns only the field specified by FLD for the
        %   current QUATTRO location

            val = []; %initialize output
            if ~isempty(obj.imgs)
                val = obj.imgs(obj.sliceIdx,obj.seriesIdx).metaData;
            end

        end %get.metaData

        function val = get.models(obj)
            val = obj.models;
            if ~isempty(val)
                val        = val(cellfun(@isvalid,val));
                val        = val(cellfun(@(x) ~isempty(x.hFig) &&...
                                               ishandle(x.hFig),val));
                obj.models = val;
            end
        end %qt_exam.get.models

        function val = get.modelXVals(obj)
        %get.modelXVals  Gets the series independent variable value
        %
        %   obj.modelXVals returns the x-values (independent variable) for the
        %   current "examType" property value.


            % When the value has already been determined for the QT_EXAM object,
            % use that value
            %FIXME: determine how to perform the computations if needed after
            %the cache has already been populated
            val = obj.modelXValsCache;
            if ~isempty(val)
                return
            end

            % Grab all of the headers
            hdrs = reshape( [obj.imgs.metaData], size(obj.imgs) );

            switch obj.type
                case {'dce','dsc'}

                    % Determine the time between acquisitions of different
                    % frames. The two tags that are queried below are the tags
                    % used for time series on GE MRI units
                    flds = {dicomlookup('0018','1060'),...
                            dicomlookup('0008','0032')};
                    for fld = flds
                        if ~isfield(hdrs,fld{1})
                            continue
                        end

                        if ischar(hdrs(1,1).(fld{1}))
                            val = cellfun(@str2double,{hdrs(1,:).(fld{1})});
                        else
                            val = cell2mat( {hdrs(1,:).(fld{1})} );
                        end
                        val = (val-val(1)); %remove temporal offset
                        if (val(2)>=500) %attempt to convert ms to sec.
                            val = val/1000;
                        end
                        if numel( unique(val) ) > 1
                            break
                        end
                    end

                    % Convert from seconds to minutes
                    val = unit(val,'seconds');

                case 'dw'

                    % Grab the b-values
                    val = calc_diffusion(hdrs);

                case 'edwi'

%                     % Calculates the b-value based on the eDWI flag (eDWI is a
%                     % GE specific acquisition
%                     tagEdwi  = dicomlookup('0043','107F');
%                     tagBVals = dicomlookup('0043','1039');
%                     if isfield(hdrs,tagEdwi)
% 
%                         % Prepares the eDWI offset
%                         offset = unique( cell2mat({hdrs(:).(tagEdwi)}) );
%                         offset(offset==0) = [];
%                         if numel(offset) > 1
%                             error(['QUATTRO:' mfilename ':offsetChk'],...
%                                    'The eDWI b-value offset number is not unique.');
%                         end
%                         [hdrs(:).(tagEdwi)] = deal(offset);

                        %TODO: determine how best to remove/store the offset
                        error(['QUATTRO:' mfilename ':offsetChk'],'Program this.')
%                     end

%                     % Determine the b-values
%                     val = cell2mat({hdrs.(tagBVals)});
%                     val = val(1,:);

                case 'multiflip'

                    % Determine the flip angles
                    val = unit(cell2mat({hdrs(1,:).FlipAngle}),'degrees');

                case 'multite'

                    % Determine the echo times
                    val = unit(cell2mat({hdrs(1,:).EchoTime}),'milliseconds');

                case 'multiti'

                    % Determine the inversion times
                    val = unit(cell2mat({hdrs(1,:).InversionTime}),...
                                                                'milliseconds');

                case 'multitr'

                    % Determine the repetition times
                    val = unit(cell2mat({hdrs(1,:).RepetitionTime}),...
                                                                'milliseconds');

                otherwise

                    % Default x-values
                    val = 1:size(hdrs,2);
            end

        end %get.modelXVals

        function val = get.opts(obj)
            %TODO: determine if this is the best way to handle to qt_options
            %initialization...
            if isempty(obj.opts)
                obj.opts = qt_options;
            end
            val = obj.opts;
        end %get.opts

        function val = get.ras(obj)
            %get.ras  Gets the current RAS coordinates
            %
            %   obj.ras returns the current location of QUATTRO in RAS
            %   coordinates, where negative values represent LPI.

            % dicom_trafo must exist and be non-empty
            if isempty(obj.dicom_trafo)
                return
            end

            % Get size of current image
            m = obj.image.dimSize;

            % Determine QUATTRO position
            ijk = obj.sl_index(:);
            ijk(3) = m(3)-ijk(3)+1; %converts I->S

            % Convert IJK to RAS
            val = obj.dicom_trafo * ([ijk-1;1]);
            val(end) = []; %this value is only used to allow matrix multiplication
            val(1:2) = -val(1:2); %convert from LP to RA

        end %get.ras

        function val = get.roi(obj)

            % Initialize the output and grab the tag
            val = qt_roi.empty(1,0);
            tag = obj.roiTag;

            % Attempt to access the ROI specified by the "roiIdx", "sliceIdx",
            % and "seriesIdx" properties
            try
                val = obj.rois.(tag)(obj.roiIdx.(tag),...
                                     obj.sliceIdx,...
                                     obj.seriesIdx);

            catch ME
                validErrors = {'MATLAB:nonExistentField','MATLAB:badsubscript'};
                if ~any( strcmpi(ME.identifier,validErrors) )
                    rethrow(ME)
                end
            end

            % Remove invalid or empty ROIs from the stack
            val = val(val.validaterois);

        end %get.roi

        function val = get.roiNames(obj)

            % Since there are potentially numerous fields that contain ROIs,
            % grab the field names of the "rois" structure
            flds  = fieldnames( obj.rois );
            nFlds = numel(flds);

            % Initialize the output and create an alias for the "rois" property
            c      = cell(1,nFlds);
            [c{:}] = deal({});
            val    = cell2struct(c,flds,2);
            rs     = obj.rois;

            % Loop through each field in the "rois" property and grab the names,
            % storing them in the appropriate field of the structure
            for fldIdx = 1:nFlds

                % Alias the current field for readability
                fld = flds{fldIdx};
                %TODO: "(numel(rs.(fld))<1)" should be changed to
                %"isempty(rs.(fld))" after the qt_roi method "isempty" is no
                %longer overloade
                if ~isfield(rs,fld) || all(~rs.(fld)(:).validaterois)
                    continue
                end

                % Loop through each ROI index
                nRoi = size(rs.(fld),1);
                for rIdx = 1:nRoi
                    rSub = rs.(fld)(rIdx,:,:,:);
                    str  = unique( {rSub(rSub.validaterois).name} );
                    if ~isempty(str)
                        val.(fld)(end+1) = str;
                    end
                end

            end

        end %get.roiNames

    end %get methods


    %------------------------------- Set Methods -------------------------------
    methods

        function set.examIdx(obj,val)

            % Validate the input
            if ~isnumeric(val) || (numel(val)>1) || val<1
                error('qt_exam:invalidExIdx',...
                      ['Attempted to set an invalid value for "examIdx" ',...
                       'No changes were made.']);
            end

            obj.examIdx = round(val); %round since it's an index

        end %set.examIdx

        function set.sliceIdx(obj,val)

            validateattributes(val,{'numeric'},{'nonempty','nonnan','positive'})
            % Validate the input
            if ~isnumeric(val) || (numel(val)>1) || val<1
                error('qt_exam:invalidSlcIdx',...
                      ['Attempted to set an invalid value for "sliceIdx" ',...
                       'No changes were made.']);
            end

            obj.sliceIdx = round(val); %round since it's an index

        end %set.sliceIdx

        function set.roiIdx(obj,val)

            % Validate the input
            if ~isstruct(val)
                error('qt_exam:invalidRoiIdx',...
                     ['"roiIdx" must be a structure containing fields that ',...
                      'correspond to the ROI tags and each field must ',...
                      'contain the respective ROI index.']);
            end

            %TODO: deconstruct the input structure and validate that the fields
            %correspond to the various ROI tags and that the values are integers
            obj.roiIdx = val;

        end %set.roiIdx

        function set.seriesIdx(obj,val)

            % Validate the input
            if ~isnumeric(val) || (numel(val)>1) || val<1
                error('qt_exam:invalidSerIdx','%s\n%s\n',...
                      'Attempted to set an invalid value for "seriesIdx"',...
                      'No changes were made.');
            end

            obj.seriesIdx = round(val); %round since it's an index

        end %set.seriesIdx

        function set.type(obj,val)

            % Grab the available exam types from the qt_models package and
            % validate the input
            mNames   = fieldnames( qt_models.model_info );
            obj.type = validatestring(val,mNames);

        end %set.type

        function set.voxelIdx(obj,val)
            validateattributes(val,{'numeric'},{'nonempty','vector','positive',...
                                                  'finite','nonnan','numel',2});
            obj.voxelIdx = val(:)'; %enforce row vector
        end %set.voxelIdx

    end %set methods


    %----------------------------- Other Methods -------------------------------
    methods (Static)

        % Image import method
        %
        %   Type "help qt_exam.import" for more information
        varargout = import(varargin);

        % Q-save load method
        %
        %   Type "help qt_exam.load" for more information
        varargout = load(varargin);

    end

    methods

        function delete(obj)

            %TODO: for some reason, this method is being called twice when the
            %QUATTRO figure is closed. Why???

            % Update the QUATTRO configuration file
            try
                if ~isempty(obj.opts)
                    obj.opts.save;
                end
            catch ME
                rethrow(ME);
            end

            % Delete all of the ROI objects
            rs      = obj.rois;
            roiFlds = fieldnames(rs);
            cellfun(@(x) rs.(x)(rs.(x).isvalid).delete,roiFlds);
            notify(obj,'roiDeleted');
            notify(obj,'roiChanged');

            % Delete all of the image objects
            ims = obj.imgs;
            ims(ims.isvalid).delete;
            notify(obj,'imgDeleted');

            % Delete external figures
            disp(obj.hExtFig)
            delete(obj.hExtFig);

        end %delete

    end %methods

end