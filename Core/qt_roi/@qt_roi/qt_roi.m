classdef (ConstructOnLoad) qt_roi < handle
%QUATTRO ROI class
%
%   Type "doc qt_roi" for a summary of all properties and methods. For property
%   and method specific help type "help qt_roi.<name>", where name is specific
%   method or property name. For a list of properties or methods, type
%   "properties qt_roi" or "methods qt_roi", respectively.

    properties (Dependent=true)

        % ROI vertices
        %
        %   "verticies" contains the normalized (x,y) coordinate pairs for each
        %   vertex in the ROI. For polygons and splines, the rows are simply
        %   reveresed, but for ellipses and rectangles, the actually vertices
        %   are given (or approximated in the case of the former)
        vertices

    end

    properties (SetObservable=true,AbortSet=true)

        % ROI color
        %
        %   "color" is a 1-by-3 vector specifying the RGB values to be used when
        %   displaying the ROI. RGB values must be a number between 0 and 1.
        color = [1 0 0];

        % ROI name
        %
        %   "name" is a string specifying the ROI name
        name = '';

        % Scale for the ROI vertices
        %
        %   "scale" is a 1-by-3 array corresponding to the x, y, and z scales,
        %   respectively. This property is used to scale the ROI vertices
        %   accordingly.
        %
        %   When showing a qt_roi object on a new axis (see property h), the
        %   scale is set according to the size of the CData if the property has
        %   not been set otherwise
        scale

        % ROI value statistics
        %
        %   "roiStats" is a structure of various data statistics calculated from
        %   voxels within the ROI using the associated image values (if any). 
        roiStats

        % Full file name of the ROI
        %
        %   "fileName" is a string specifying the full file name used for ROI
        %   read/write operations.
        fileName = '';

        % ROI read/write format
        %
        %   "format" is a user-specified string specifying the ROI storage
        %   format and is used to determine the appropriate method of import and
        %   export for the ROI.
        %
        %       Supported Formats
        %       -----------------
        %       'qt'
        %       'nordicice'
        %       'imagej'
        %       'nrrd'
        format = 'unknown';

        % Memory saver flag
        %
        %   "memorySaver" is a logical flag specifying on-the-fly computations
        %   or cached storage of image values. When true (default), computations
        %   are performed any time voxel data are requested from the qt_roi
        %   object. In circumstances that permit temporary storage of ROI
        %   values, set "memorySaver" to false to speed up data computations.
        memorySaver = true;

        % ROI enable state
        %
        %   "state" is a string ('on' or 'off') specifying the current state of
        %   the qt_roi object. When 'on' (default), ROIs are automatically
        %   displayed and appropriate statistics are updated. When 'off', ROIs
        %   are not rendered
        state = 'on';

        % ROI application type
        %
        %   "tag" is a string specifying an application specific ROI type; the
        %   default value is 'roi'. For example, QUATTRO uses the tags 'vif'
        %   and 'noise' to denote ROIs used for the specific purposes of
        %   calculating vascular input functions (VIF) and signal-to-noise
        %   ratios. The intent of this property is to assist developers in
        %   providing additional information that might be useful in the
        %   utilization of the qt_roi class.
        tag = 'roi';

    end

    properties (SetObservable=true,Hidden=true)

        % Normalized position array
        %
        %   "position" is the position array of the current qt_roi object with
        %   each element taking a value between 0 and 1. This array has a
        %   different construction based on the "type" that was used in the
        %   original object construction as follows:
        %
        %       "type"          "position" data
        %       ================================
        %       rect/ellipse    [xmin ymin width height]
        %
        %       poly/spline     [y1 x1; y2 x2;...;yn xn];
        %
        %
        %   Note: the y and x are reversed from normal x-y coordinate pairs
        %   because of the way that images are displayed
        %
        %   See also scaledPosition, vertices, and scaledVertices
        position

    end

    properties (SetAccess='private',SetObservable=true)

        % ROI geometric type
        %
        %   "type" is a string specifing the type of ROI represented by the
        %   qt_roi object. Note that this property is set during object
        %   construction and cannot be changed afterward. Valid strings are:
        %   'rect', 'ellipse', 'poly', or 'spline'
        %
        %   See also imrect, imellipse, impoly, imfreehand, and impoint
        type

    end

    properties (Access='private',Hidden=true,Transient=true)

        % ROI view object storage
        %
        %   "roiViewObj" is an array of roiview objects. These objects handle
        %   all events associated with displaying qt_roi data
        roiViewObj = roiview.empty(0,0);

    end

    properties (Dependent=true,Hidden=true)

        % Position array scaled to associated image data
        %
        %   "scaledPosition" scales the "position" property based on the "scale"
        %   property. The latter is usually update when displaying the ROI.
        %   Scaled vertices and position arrays are useful for quickly assessing
        %   ROI location within an image and are computed on the fly.
        scaledPosition

        % ROI vertex array scaled to the associated image data
        %
        %   "scaledVertices" is an N-by-2 array of (x,y) coordinate pairs for
        %   each vertex in the ROI. For polygons and splines, the rows of the
        %   "scaledPosition" array are simply reveresed, but for ellipses and 
        %   rectangles, the actually vertices are calculated (or approximated in
        %   the case of the former)
        scaledVertices

        % Associated qt_roi object figure
        %
        %   "hFig" is an array of handles to the figures on which the specified
        %   qt_roi object is displayed
        hFig

        % Logical display flag
        %
        %   "isShown" returns true when the current qt_roi object is displayed
        %   on a valid axis, and false otherwise
        isShown

    end

    properties (SetAccess='private',Hidden=true,SetObservable=true,Transient=true)

        % Image values
        %
        %   "imgVals" is an array of values extracted from any image associated
        %   with the current roiview object. These values serve as a quick
        %   reference for computing statistics and are updated when changes to
        %   the ROI are made.
        imgVals

        % ROI existence flag
        %
        %   "isEmpty" is a logical flag that specifies the existence of any ROI
        %   data (true). When no ROI data is present, the value is false.
        isEmpty = true;

    end


    events

        % newAxisLimits  Updates the ROI display for new limits
        newAxisLimits

        % newRoiData  Updates the image display
        newRoiData

        % newManualPosition  Updates the displayed ROI's position
        newManualPosition

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        % Class constructor
        function obj = qt_roi(varargin)
        %qt_roi  Class for creating and storing ROI information
        %
        %   H = qt_roi(HAX,TYPE) creates interactive placement of an ROI on the
        %   axis specified by the handle HAX using the specified ROI TYPE.
        %   Equivalently, HAX can also specify a qt_image object with which to
        %   associate the new ROI. For seamless execution, the latter is
        %   preferred.
        %
        %       Valid TYPE strings
        %       ------------------
        %       'rect', 'ellipse', 'poly', or 'spline'
        %
        %
        %   H = qt_roi(POS,TYPE) creates an ROI of the specified TYPE using the
        %   position vector POS. If the POS is not normalized, also specify the
        %   property 'scale' to ensure proper display. See also impoly, imrect,
        %   imellipse, and  imfreehand for information regarding the position
        %   vector.
        %
        %   H = qt_roi(FILE) attempts to load the ROIs stored in the QUATTRO
        %   save file specified by FILE. If more than one ROI exists, H will be
        %   an array ROI objects
        %
        %   H = qt_roi(...,'Property1',PropertyValue1,...) creates a QUATTRO ROI
        %   object using one of the above syntaxes in addition to setting the
        %   specified properties.

            % Attach the properties' listeners
%             addlistener(obj,'fileName','PostSet',@fileName_postset);
            addlistener(obj,'position','PostSet',@obj.position_postset);
            addlistener(obj,'state',   'PostSet',@obj.state_postset);

            % Attach the events' listeners
            addlistener(obj,'newAxisLimits',    @obj.newlimits);
            addlistener(obj,'newRoiData',       @obj.deconstruct);
            addlistener(obj,'newManualPosition',@obj.newmanualposition);

            % Parse the inputs
            if nargin==0
                return
            end
            [props,vals,fName,hAx] = parse_inputs(varargin{:});

            % Load the requested file
            if ~isempty(fName)
                obj = obj.loadobj(fName);
            end

            % Deal the properties
            for pIdx = 1:numel(props)
                obj.(props{pIdx}) = vals{pIdx};
            end

            % Fire the interactive creation mode
            if ~isempty(hAx) && strcmpi(class(hAx),'qt_image')
                hAx.addroi(obj);
            elseif ~isempty(hAx)
                obj.show(hAx);
            end
        end

    end


    %--------------------------------Get Methods--------------------------------
    methods

        function val = get.hFig(obj)

            val = []; %initialize
            if ~isempty(obj.roiViewObj)
                val = guifigure(obj.roiViewObj.hAxes);
            end

        end %get.hFig

        function val = get.imgVals(obj)

            % Attempt to get cached image values
            val = obj.imgVals;

            % When using memory saver mode or during ROI initialization, this
            % property will be empty. Update the values from the current image,
            % if any.
            %TODO: what if the ROI is displayed on multiple images???
            if isempty(val)

                if numel(obj.roiViewObj)>1
                    error( 'qt_roi:imgVals:multipleImageDisplay',...
                          ['This ROI appears to be on multiple images.',...
                           'No support exists, yet...']);
                end

                % Find all associated views. If none are found, exit
                hIm = findobj(obj.roiViewObj.hAxes,'Type','image');
                if isempty(hIm)
                    return
                end

                % Grab the masked values
                val = obj.mask(hIm);
                if ~isempty(val) && ~obj.memorySaver
                    obj.imgVals = val; %store the new data
                end
            end

        end %get.imgVals

        function val = get.isShown(obj)

            % Grab associated axes and initialize the output
            hAxes = obj.roiViewObj.hAxes;
            val   = ~isempty(hAxes) && ~isempty(obj.roiViewObj.hRoi);
            if ~val
                return
            end

            % Grab the vertices
            verts = obj.scaledVertices;

            % Determine if any of the vertices are visible
            xl  = get(hAxes,'XLim');
            yl  = get(hAxes,'YLim');
            val = any( ((verts(:,1) > xl(1)) & (verts(:,1) < xl(2))) &...
                       ((verts(:,2) > yl(1)) & (verts(:,2) < yl(2))) );

        end %get.isShown

        function val = get.roiViewObj(obj)
            val      = roiview.empty(1,0);
            viewObjs = obj.roiViewObj;
            if ~isempty(viewObjs) && any(viewObjs.isvalid)
                val = viewObjs( viewObjs.isvalid );
            end
        end %get.roiViewObj

        function val = get.scaledPosition(obj)

            % Initialize the output and check for minimum data
            val = obj.position;
            if ~isempty(obj.scale) && ~isempty(val)

                % Use current scale to get the ROI position array
                val = scale_roi_verts(val,['im' obj.type],obj.scale);
            end

        end %get.scaledPosition

        function val = get.scaledVertices(obj)

            % Get the unscaled vertices
            val = obj.scaledPosition;
            if ~isempty(val)
                switch obj.type
                    case 'ellipse'
                        val = ellipse2verts(val);
                    case 'rect'
                        val = rect2verts(val);
                end
            end
            
        end %get.scaledVertices

        function val = get.vertices(obj)

            val = obj.position; %initialize
            if ~isempty(val)
                switch obj.type
                    case 'ellipse'
                        val = ellipse2verts(val);
                    case 'rect'
                        val = rect2verts(val);
                end
            end

        end %get.vertices

    end


    %--------------------------------Set Methods--------------------------------
    methods

        function set.scaledPosition(obj,val)

            % Use the ROI scale to normalize the coordinate position
            obj.position = scale_roi_verts(val,['im' obj.type],1./obj.scale);

        end %set.scaledPosition

        function set.state(obj,val)

            % Validate the string
            obj.state = validatestring(val,{'off','on'});

        end %set.state

    end


    %-------------------------------Static Methods------------------------------
    methods (Static)

        % Static method for creating the ROI stats structure
        varargout = calcstats(varargin);

        function obj = loadobj(s)

            % Simple case: the data were loaded successfully as a qt_roi object
            % from a .mat file and no other action is needed
            if strcmpi( class(s), 'qt_roi' )
                obj = s;
                return
            elseif isstruct(s)
                warning('A structure was passed to the "loadobj" method. Why?');
                return
            end

            % Validate that the input is, in fact, a usable file name
            if exist(s,'file')~=2
                error('qt_roi:loadobj:invalidInput',...
                      '"loadobj" input must be a qt_roi object or valid file.');
            end

            % Use the qt_exam static method "load" to import the data
            [s,fName,fPath] = qt_exam.load(s,'rois');

            % Create the full file name of the data that were loaded and append
            % this to each valid, non-empty qt_roi object
            fullFileName = fullfile(fPath,fName);
            nExams       = numel(s);
            for exIdx = 1:nExams
                validMask = s(exIdx).rois.validaterois;
                [s(exIdx).rois(validMask).fileName] = deal(fullFileName);
            end

            % Deal the output
            obj = s.rois;
            if (nExams>1)
                obj = {s.rois};
            end

        end %qt_roi.loadobj

    end


    %----------------------------Overloaded Methods-----------------------------
    methods

        function delete(obj)

            % Delete any remaining ROI objects
            if ~isempty(obj.roiViewObj) && any(obj.roiViewObj(:).isvalid)
                obj.roiViewObj.delete
            end

        end %delete

    end


end %qt_roi


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Initialize the output
    [varargout{1:nargout},props] = deal([]);

    % Determine some information about the input
    inClass       = class(varargin{1});
    isFile         = ischar(varargin{1}) && exist(varargin{1},'file');
    isQtimgAndType = ~isFile && strcmpi(inClass,'qt_image');
    isHaxAndType   = ~isFile && strcmpi(inClass,'double') &&...
                                                  any(ishandle(varargin{1}(:)));

    % Grab the remaining inputs beyond the required input as property/value
    % pairs
    if (isFile && nargin>1) || (~isFile && nargin>2)
        imgProps = properties('qt_roi');
        props    = cellfun(@(x) validatestring(x,imgProps),...
                              varargin((3-isFile):2:end),'UniformOutput',false);
    end

    % Construct the parser. There are three possible syntaxes for the first
    % couple of inputs: (1) axis handle (or qt_image object) and ROI type, (2)
    % file name, (3) ROI position vector and ROI type. After the required syntax
    % is added to the parser, add the additional properties
    parser         = inputParser;
    if isHaxAndType
        parser.addRequired('hAx',@checkAx)
    elseif isQtimgAndType
        parser.addRequired('hAx',@(x) x.isvalid);
    elseif isFile
        parser.addRequired('file',@checkFile);
    else %position and ROI type specified
        parser.addRequired('position',@(x) isnumeric(x));
    end
    if nargin>1 && ~isFile % Grab the ROI type if specified
        varargin{2} = validatestring( strrep(varargin{2},'im',''),...
                                            {'rect','ellipse','poly','spline'});
        parser.addRequired('type',@ischar);
    end
    for idx = 1:numel(props)
        parser.addParamValue(props{idx},varargin{2*idx+(1-isFile)});
    end

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % When the "position" and "scale" properties are specified as inputs, ensure
    % that the position vector is normalized; normalize to "scale" if needed
    if all( isfield(results,{'position','scale'}) ) && any(results.position>1)
        results.position = scale_roi_verts(results.postion,...
                                             ['im' results.type],results.scale);
    end

    % Deal the outputs
    if isfield(results,'hAx')
        varargout{nargout} = results.hAx;
        results            = rmfield(results,'hAx');
    end
    if isfield(results,'file')
        varargout{3}       = results.file;
        results            = rmfield(results,'file');
    end
    varargout{1} = fieldnames(results);
    varargout{2} = struct2cell(results);

    % Special syntax if specifying an image: automatically populate properties
    if isQtimgAndType
        varargout{1}{end+1} = 'scale';
        varargout{2}{end+1} = varargout{nargout}.imageSize;
    end

end %parse_inputs

%-----------------------
function tf = checkAx(h)

    tf = true; %initalize the output

    % Validate the input
    if ~ishandle(h) || ~strcmpi( get(h,'Type'), 'axes')
        error('qt_image:invalidAxisHandle',...
                                       'An invalid axis handle was specified.');
    elseif isempty( findobj(h,'Type','image') )
        error('qt_image:invalidAxis',...
                                    'The specified axis must contain an image');
    end

end %checkAx

%-------------------------
function tf = checkFile(f)

    tf = true; %initalize the output

    %Validate the input
    if exist(f,'file')~=2
        error('qt_roi:invalidFile','Unable to locate the file:\n%s\n',f);
    end

end %checkFile