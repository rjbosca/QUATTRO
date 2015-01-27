classdef (ConstructOnLoad) roiview < handle

    properties (SetObservable=true,AbortSet=true)

        % Associated qt_roi object
        %
        %   "roiObj" is the qt_roi object that instantiated the current roiview
        %   object
        roiObj

        % Displayed ROI axes handle
        %
        %   "hAxes" is the handle to the axes on which the qt_roi object is
        %   displayed
        hAxes

        % Displayed ROI handle
        %
        %   "hRoi" is the handle to the current ROI graphics object
        hRoi

        % Image scale
        %
        %   "imageScale" is a numeric row vector with three elements
        %   representing the x, y, and z ROI scaling components. This property
        %   is update when changes to the "hAxes" propertry occur.
        imageScale

        % Event listeners
        %
        %   "eventListeners" stores an array of event listeners that are deleted
        %   during object destruction. The deletion ensures that additional
        %   error checking and/or numerous outdated calls to the listeners are
        %   prevented
        eventListeners = event.proplistener.empty(1,0);

        % Handle listeners
        %
        %   "handleListeners" stores an array of handle listeners that are
        %   deleted during object destruction. The deletion ensures that
        %   additional error checking and/or numerous outdated calls to the 
        %   listeners are prevented
        handleListeners

        % Auto-display flag
        %
        %   "render" is a logical flag specifying whether an ROI is render on
        %   the current image
        render = true;

        % ROI extent
        %
        %   "roiExtent" is an 2-by-2 array specifying the minimum and maximum
        %   ROI extent in the x and y direction. The first column defines the x
        %   extent and the second column defines the y extent
        roiExtent

    end

    properties (Dependent)

        % Displayed ROI figure handle
        %
        %   "hFig" is the handle to the figure (axis parent) on which ROI the
        %   current roiview object is displayed
        hFig

        % ROI on image flag
        %
        %   "isOnImage" is a logical value that assumes true if the currently
        %   displayed ROI is within the bounds of the current axis and false
        %   otherwise
        isOnImage

        % ROI position scaled by "imageScale" property
        %
        %   "roiPosition" is an array containing the ROI position specification
        %   (see qt_roi.position for more information) scaled to the current
        %   image on which the ROI is to be displayed.
        %
        %   Although this can be calculated from the qt_roi object, there is no
        %   reasonable expectation that that an roiview and qt_roi object will
        %   necessarily have the same scale. This means that "roiPosition" may
        %   not correspond to the qt_roi object property "scaledPosition"
        roiPosition

    end


    %---------------------------- Class Constructor ----------------------------
    methods
	
        function obj = roiview(qtObj)
		%roiview  Creates a qt_roi view object
		%
		%	obj = roiview(ROI) creates an ROI view object for the specified 
		%	qt_roi object, ROI. ROI view objects handle all events associated
		%	with the display of qt_roi data.
        %
        %   roiview objects are used to handle all of the display operations of
        %   qt_roi objects. Interactions with MATLAB functionality such as
        %   data cursor, pan, and zoom modes are handled automatically.

			% Validate input
			if ~nargin
                return
            elseif ~strcmpi(class(qtObj),'qt_roi')
				error(['qt_roi:' mfilename ':invalidInput'],...
                                 'Invalid input or number of inputs detected.');
			end

			% Store the qt_roi object for interal references
            obj.roiObj = qtObj;

            % Attach the properties' listeners
            addlistener(obj,'hAxes',     'PostSet',@obj.hAxes_postset);
            addlistener(obj,'imageScale','PostSet',@imageScale_postset);
            addlistener(obj,'render',    'PostSet',@obj.render_postset);

            % Attach external properties' listeners
            obj.eventListeners = addlistener(qtObj,'position','PostSet',...
                                                   @obj.qtroi_position_postset);

            % Render is determined by the qt_roi object's "state" property
            obj.render = strcmpi(obj.roiObj.state,'on');

        end

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.hFig(obj)
            val = []; %initialize
            hAx = obj.hAxes;
            if ~isempty(hAx)
                val = guifigure(hAx);
            end
        end %get.hFig

        function val = get.hRoi(obj)
            val = obj.hRoi;
            if isempty(val) || ~val.isvalid
                val = [];
            end
        end %get.hRoi

        function val = get.isOnImage(obj)

            val = true; %initialize default

            % Grab the current axis and ROI extents
            axExtent = reshape(cell2mat(get(obj.hAxes,{'XLim','YLim'}) ),2,[]);
            rExtent  = obj.roiExtent;
            if isempty(axExtent) || isempty(rExtent)
                return
            end

            % Determine if the ROI is within the axis extent
            val = ~(all(rExtent(:,1)<axExtent(1,1)) ||...
                    all(rExtent(:,2)<axExtent(1,2)) ||...
                    all(rExtent(:,1)>axExtent(2,1)) ||...
                    all(rExtent(:,2)>axExtent(2,2)));

            % Automatically update the "render" property assuming the parent
            % control provided by the qt_roi object is in the 'on' state
            if strcmpi(obj.roiObj.state,'on')
                obj.render = val;
            end
        end %get.isOnImage

        function val = get.roiPosition(obj)

            % Get the ROI type/position from the qt_roi object
            s   = obj.roiObj.type;
            val = obj.roiObj.position;

            % Scale the position vector
            val = scale_roi_verts(val,['im' s],obj.imageScale);

        end %get.roiPosition

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.hAxes(obj,val)

            % Validate the input
            if ~ishandle(val) || ~strcmpi(get(val,'Type'),'axes')
                warning('qt_roi:roiview:invalidAxHandle',...
                          'Attempted to store invalid handle data in "hAxes".');
                return
            end

            % Set the new value. The PostSet event will display the ROI
            obj.hAxes = val;

        end %set.hAxes

        function set.eventListeners(obj,val)
            obj.eventListeners(end+1) = val;
        end %set.eventListeners

        function set.handleListeners(obj,val)
            if isempty(obj.handleListeners)
                obj.handleListeners = val;
            else
                obj.handleListeners(end+1) = val;
            end
        end %set.handleListeners

    end


    %---------------------------- Overloaded Methods ---------------------------
    methods

        function delete(obj)

            % Delete any ROI objects
            delete(obj.hRoi);

            % Delete the listener handles
            delete(obj.eventListeners);
            delete(obj.handleListeners);

        end %roiview.delete

        function sObj = saveobj(obj)
            sObj = [];
        end %roiview.saveobj
    end
    methods (Static)

        function obj = loadobj(sObj)
            obj = qt_roi.empty(1,0);
        end %roiview.loadobj

    end

end