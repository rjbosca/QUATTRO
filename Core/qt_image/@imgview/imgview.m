classdef imgview < handle

    properties (SetObservable=true)

        % Associated qt_image object
        imgObj

        % Notification display falg
        %
        %   Logical flag specifying the display of event notifications (true) or
        %   suppresion (false - default)
        dispNotify = false;

        % Displayed image axes handle
        %
        %   Handle specifying the axes on which the image object is displayed.
        hAxes

        % Displayed image handle
        %
        %   Handle to the current image graphics object
        hImg

        % Real color flag
        %
        %   Logical flag specifying conversion of indexed images to true color.
        %   Default: false
        isRgb = false;

        % Displayed image text handle
        %
        %   Vector of handles specifying the text objects displayed currently
        %   displayed. "hFig", "hAxes", and "hText" must be the same length with
        %   corresponding entries
        hText

        % Linked ROI handle(s)
        %
        %   Vector of qt_roi objects specifying the ROI objects attached to the
        %   image view. This property mainly serves the purpose of destroying
        %   those objects when deconstructing imgview objects
        hRoi = qt_roi.empty(1,0);

        % Flag for displaying on-image text
        %
        %   A logical flag specifying whether to display the on-image text as
        %   defined by the "dispFields" property. Default: true
        isDispText = true;

        % Zoom state of the image
        %
        %   A logical scalar specifying the zoom state of the image.
        isZoomed = false;

        % Event listeners
        %
        %   "listeners" stores an array of event listeners that are deleted
        %   during object destruction
        listeners = {};

        % Button event function handle positions
        %
        %   "btnFcnIdx" is a three element row vector containing the identifier
        %   of the function handles (see iptremovecallback) for the
        %   'WindowButtonDownFcn', 'WindowButtonMotionFcn', and
        %   'WindowButtonUpFcn', respectively.
        btnFcnIdx

        % Delete event function handle position
        %
        %   "deleteFcnIdx" is a scalar index containing the identifier of the
        %   function handle (see iptremovecallback) for the "DeleteFcn" axis
        %   property
        deleteFcnIdx

        % Text size
        %
        %   Font size of on image text
        textSize  = 8;

        % Text color
        %
        %   Color string (e.g., 'k', 'b', etc.) or RGB vector defining the color
        %   of the on image text.
        textColor = 'y';

    end

    properties (Dependent, Hidden=true)

        % Window display bounds
        %
        %   A 1-by-2 array defining the minimum and maximum allowable values for
        %   the display window. For example, when displaying MRI images, values
        %   will be greater than or equal to zero (unless processing has been
        %   performed).
        windowBounds

        % Zoom status
        %
        %   "zoomStatus" is a logical scalar specifying the current zoom state
        %   (zoomed-true; not zoomed-false)of the current imgview object.
        zoomStatus

        % Displayed image figure handle
        %
        %   Handle specifying the figures on which image objects are displayed.
        hFig
        
    end

    events

        % Deconstructs an imgview object
        %
        %   "deconstructView" is an event that destroys an image view without
        %   deleting the associated qt_image object. This event should be
        %   notified when the current view is being replaced by a new view
        deconstructView

        % New on-image text
        %
        %   New text events are fired when new axis handles are provided or
        %   changes are made to the "dispFields" property of the parent qt_image
        %   object
        newText

    end


    %---------------------------- Class Constructor ----------------------------
    methods
	
        function obj = imgview(qtObj)
		%imgview  Creates a qt_image view object
		%
		%	obj = imgview(IMOBJ) creates an image view object for the specified 
		%	qt_image object, IMOBJ. Image view objects handle all events
		%	associated with the display of qt_image data.
        %
        %   imgview objects are used to handle all of the display operations of
        %   qt_image objects. Interactions with MATLAB functionality such as
        %   data cursor, pan, and zoom modes are handled automatically.

			% Validate input
			if ~nargin || ~strcmpi(class(qtObj),'qt_image')
				error(['qt_image:' mfilename ':invalidInput'],...
                                 'Invalid input or number of inputs detected.');
			end

			% Store the qt_image object for interal references
            obj.imgObj = qtObj;

            % Attach the properties' listeners
            addlistener(obj,'isDispText','PostSet',@isDispText_postset);

            % Register the events
            addlistener(obj,'newText',        @obj.updatetext);
            addlistener(obj,'deconstructView',@qtObj.deconstruct);

            % Attach external properties' listeners
            obj.listeners = addlistener(qtObj,'transparency','PostSet',...
                                             @obj.qtimage_transparency_postset);

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

        function val = get.hImg(obj)
            val = obj.hImg;
            if ~ishandle(val)
                val = [];
            end
        end %get.hImg

        function val = get.hText(obj)
            val = obj.hText;
            if ~ishandle(val)
                val = [];
            end
        end %get.hText

        function val = get.zoomStatus(obj)

            % Get the axes/image limits
            axM = [diff( get(obj.hAxes,'XLim') ) diff( get(obj.hAxes,'YLim') )];
            imM = obj.imgObj.imageSize;

            % Determine the zoom stats
            val = any(axM~=imM(1:2)); %1:2 is needed for RGB images

        end %get.zoomStatus

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.hAxes(obj,val)

            % Validate the input
            if ~ishandle(val) || ~strcmpi(get(val,'Type'),'axes')
                warning('qt_image:imgview:invalidAxHandle',...
                          'Attempted to store invalid handle data in "hAxes".');
                return
            end

            % Set the new value and display the image
            obj.hAxes = val;

        end %set.hAxes

        function set.listeners(obj,val)
            obj.listeners{end+1} = val;
        end %set.listeners

    end


    %---------------------------- Overloaded Methods ---------------------------
    methods

        function delete(obj)

            % Delete the text objects
            delete(obj.hText);

            % Note that qt_image objects will still exist. This is a convenience
            % to avoid clearing the image children of the axis for new views.
            % Eventually, these HGOs are destroyed when the parent qt_image
            % object is deconstructed

            % Delete the listener handles
            cellfun(@delete,obj.listeners);

            % Remove the function callbacks for the window/button interactions
            % after deleteing all listeners. Doing so before trying to remove
            % these callbacks might trigger other listeners changes to the
            % following callback functions. These callbacks are reset every time
            % a new image is shown (via the imgview object events for display).
            if ~isempty(obj.btnFcnIdx)
                iptremovecallback(obj.hFig,...
                                      'WindowButtonDownFcn',obj.btnFcnIdx(1));
                iptremovecallback(obj.hFig,...
                                      'WindowButtonMotionFcn',obj.btnFcnIdx(2));
                iptremovecallback(obj.hFig,...
                                      'WindowButtonUpFcn',obj.btnFcnIdx(3));
            end

            % Remove the function callbacks for the axis "DeleteFcn" property.
            % If this callback is not removed, during deletion of the image
            % axes, numerous warnings will occur
            if ~isempty(obj.deleteFcnIdx)
                iptremovecallback(obj.hAxes,'DeleteFcn',obj.deleteFcnIdx);
            end

            % Finally, remove the imgview object from the associated storage in
            % the qt_image object
            if obj.imgObj.isvalid
                obj.imgObj.remove_view(obj);
            end

        end %delete

    end

end