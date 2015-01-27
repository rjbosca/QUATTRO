function api = basicSpline(h_group,draw_api,positionConstraintFcn)
%basicSpline  Creates the API structure used by imspline.
%   API = basicSpline(H_GROUP,DRAW_API) creates a base API for use in
%   defining a draggable spline ROI. H_GROUP specifies the hggroup that
%   contains the spline ROI and DRAW_API is the associated renderer
%   structure used by an ROI.

%   Adopted from basicPolygon, Copyright 2007-2008 The MathWorks, Inc.

%   Created by: Ryan Bosca
%   Date: 3/14/2011
%   email: rjbosca@mdanderson.org

% Stores figure and axes handles
h_fig = ancestor(h_group,'figure');
h_axes = ancestor(h_group,'axes');

% Initialize position storage
position = [];

% Pattern for set associated with callbacks that get called as a
% result of the set.
insideSetPosition = false;

% Create API for dispatching/adding/removing callback functions
dispatchAPI = roiCallbackDispatcher(@getPosition);

% Sets the Button Down callback and listener
setappdata(h_group,'buttonDown',@startDrag);

setappdata(h_group,'ButtonDownListener',...
    handle.listener(handle(h_fig),...
    'WindowButtonDownEvent',@cacheCurentPoint));
current_mouse_pos = [];

% Initialize ROI
draw_api.initialize(h_group);

% In the other ROI tools, the initial color is defined in
% createROIContextMenu. It is necessary to create the context menu after
% interactive placement for impoly/imfreehand, so we need to initialize color here.
color_choices = iptui.getColorChoices();
draw_api.setColor(color_choices(1).Color);

% Alias updateView.
updateView = draw_api.updateView;

% Store API structure
api.startDrag                 = @startDrag;
api.addNewPositionCallback    = dispatchAPI.addNewPositionCallback;
api.removeNewPositionCallback = dispatchAPI.removeNewPositionCallback;
api.setPosition               = @setPosition;
api.setConstrainedPosition    = @setConstrainedPosition;
api.getPosition               = @getPosition;
api.delete                    = @deleteSpline;
api.getPositionConstraintFcn  = @getPositionConstraintFcn;
api.setPositionConstraintFcn  = @setPositionConstraintFcn;
api.updateView                = draw_api.updateView;
api.setVisible                = draw_api.setVisible;

    %-----------------------------------------
    function cacheCurentPoint(hObj,eventdata)
        % This function caches the CurrentPoint field of the event data of
        % the WindowButtonDownEvent at function scope. The current point
        % passed in the event data is guaranteed to always be in pixel
        % units. The current point cached at function scope is used in
        % ipthittest to ensure that the cursor affordance shown and the
        % button down action taken are consistent.

        % Stores mouse position at button down event
        current_mouse_pos = eventdata.CurrentPoint;

    end %cacheCurentPoint


    %-------------------------------
    function deleteSpline(varargin)

        if ishandle(h_group)
            delete(h_group)
        end

    end %deleteSpline


    %-------------------------
    function pos = getPosition

        pos = position;    

    end %getPosition


    %------------------------
    function setPosition(pos)
     
        % Pattern to break recursion
        if insideSetPosition
            return
        else
            insideSetPosition = true;
        end

        % Function-scoped dummy variable used by GetPosition
        position = pos;

        % Renders ROI at new position
        updateView(pos);

        % User defined newPositionCallbacks may be invalid. Wrap
        % newPositionCallback dispatches inside try/catch to ensure that
        % insideSetPosition will be unset if newPositionCallback errors.
        try
            dispatchAPI.dispatchCallbacks('newPosition');
        catch ME
            insideSetPosition = false;
            rethrow(ME);
        end

        % Pattern to break recursion
        insideSetPosition = false;

    end %setPosition


    %-----------------------------------
    function setConstrainedPosition(pos)

        pos = positionConstraintFcn(pos);
        setPosition(pos);

    end %setConstrainedPosition


    %---------------------------------
    function setPositionConstraintFcn(fcn)

        positionConstraintFcn = fcn;

    end %setPositionConstraintFcn


    %---------------------------------
    function fh = getPositionConstraintFcn

        fh = positionConstraintFcn;

    end %getPositionConstraintFcn


    %---------------------------
    function startDrag(varargin)
  
        % Returns the object hit by button down event
        hit_obj = hittest(h_fig,current_mouse_pos);

        % Mouse click type and hit_obj logicals
        is_normal_click = strcmp(get(h_fig,'SelectionType'),'normal');
        is_spline_obj = any(hit_obj == get(h_group,'Children'));
        if ~is_normal_click || ~is_spline_obj
            return
        end

        % Verticies postion at buttonDown event
        start_position = getPosition();

        % Mouse position at buttonDown event
        [start_x,start_y] = getCurrentPoint(h_axes);

        % Disable the figure's pointer manager during the drag.
        iptPointerManager(h_fig, 'disable');

        drag_motion_callback_id = iptaddcallback(h_fig, ...
                                                 'WindowButtonMotionFcn', ...
                                                 @dragMotion);

        drag_up_callback_id = iptaddcallback(h_fig, ...
                                                 'WindowButtonUpFcn', ...
                                                 @stopDrag);

          %----------------------------
          function dragMotion(varargin)

              if ~ishandle(h_axes)
                  return;
              end

              [new_x,new_y] = getCurrentPoint(h_axes);      
              delta_x = new_x - start_x;
              delta_y = new_y - start_y;

              num_vert = length(start_position);

              candidate_position = start_position + repmat([delta_x delta_y],num_vert,1);
              new_position = positionConstraintFcn(candidate_position);

              % Only fire setPosition/callback dispatch machinery if position has
              % actually changed
              if ~isequal(new_position,getPosition())
                  setPosition(new_position)
              end

          end

          %--------------------------
          function stopDrag(varargin)

                dragMotion();

                iptremovecallback(h_fig, 'WindowButtonMotionFcn', ...
                                  drag_motion_callback_id);
                iptremovecallback(h_fig, 'WindowButtonUpFcn', ...
                                  drag_up_callback_id);

                % Enable the figure's pointer manager.
                iptPointerManager(h_fig, 'enable');

          end % stopDrag
      	
  end %startDrag

end