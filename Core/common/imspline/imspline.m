%IMSPLINE Create draggable spline ROI.
%   H = IMSPLINE(HPARENT,POSITION) creates a draggable spline ROI on the
%   object specified by HPARENT. POSITION is an N-by-2 array that specifies
%   the initial position of the vertices of the polygon. POSITION has the
%   form [X1,Y1;...;XN,YN].
%
%   H = IMSPLINE(...,PARAM1,VAL1,PARAM2,VAL2,...) creates a draggable spline
%   ROI, specifying parameters and corresponding values that control the 
%   behavior of the spline. Parameter names can be abbreviated, and case
%   does not matter.
%    
%   Parameters include:
%    
%   'PositionConstraintFcn'   Function handle fcn that is called whenever
%                             the spline ROI is dragged using the mouse.
%                             Type "help imspline/setPositionConstraintFcn"
%                             for information on valid function
%                             handles.
%
%   Methods
%   -------
%   Type "methods imspline" to see a list of the methods.
%
%   For more information about a particular method, type 
%   "help imspline/methodname" at the command line.
%       
%   Remarks
%   -------    
%   If you use IMSPLINE with an axis that contains an image object, and do
%   not specify a position constraint function, users can drag the spline
%   outside the extent of the image and lose the ROI.  When used with an
%   axis created by the PLOT function, the axis limits automatically expand
%   to accommodate the movement of the spline.
%    
%   Example 1
%   ---------    
%   Display updated position in the title. Specify a position constraint function
%   using makeConstainToRectFcn to keep the ROI inside the original xlim
%   and ylim ranges.
% 
%   figure, imshow('gantrycrane.png');
%   h = imspline(gca, [188,30; 189,142; 93,141; 13,41; 14,29]);
%   setColor(h,'yellow');    
%   addNewPositionCallback(h,@(p) title(mat2str(p,3)));
%   fcn = makeConstrainToRectFcn('impoly',get(gca,'XLim'),get(gca,'YLim'));
%   setPositionConstraintFcn(h,fcn);
%
%   See also  IMPOLY, IMFREEHAND, IMLINE, IMRECT, IMPOINT, IMELLIPSE, IPTGETAPI, makeConstrainToRectFcn.

%   Adopted from IMPOLY, Copyright 2007-2008 The MathWorks, Inc.
%   Author: Ryan Bosca; Created: 3/15/2012


classdef imspline < imroi
    
    methods

        function obj = imspline(varargin)
            %imspline  Constructor for imspline.

            [h_group,draw_api] = imsplineAPI(varargin{:});

            obj = obj@imroi(h_group,draw_api);
        end

        function pos = getPosition(obj)
            %getPosition  Return current position of spline ROI.
            %
            %   pos = getPosition(h) returns the current position of the
            %   spline h. The returned position, pos, is an N-by-2 array
            %   [X1 Y1;...;XN YN].

            pos = obj.api.getPosition();

        end
        
        function setPosition(obj,pos)
            %setPosition  Set spline to new position.
            %
            %   setPosition(h,pos) sets the spline h to a new position.
            %   The new position, pos, has the form [X1 Y1;...;XN YN].
            
            invalidPosition = ndims(pos) ~=2 || size(pos,2) ~=2 || ~isnumeric(pos);
            if invalidPosition
                error_id = sprintf('Images:%s:setPosition:invalidPosition',mfilename);
                error(error_id,...
                      'Invalid position specified. Position has the form [X1 Y1;...;XN YN].');
            end
            
            obj.api.setPosition(pos);
           
        end
       
        function setMode(obj)
            %setMode  Sets the operation mode of buttonDown events
            obj.api.setMode;
        end

    end

    methods (Access = 'protected')

        function cmenu = getContextMenu(obj)

            cmenu = obj.api.getContextMenu();

        end

    end

end


function [h_group,draw_api] = imsplineAPI(varargin)

[commonArgs] = roiParseInputs(0,2,varargin,mfilename,{'Closed'});

xy_position_vectors_specified = (nargin > 2) && ...
                              isnumeric(varargin{2}) && ...
                              isnumeric(varargin{3});

if xy_position_vectors_specified
  error(sprintf('Images:%s:invalidPosition',mfilename),...
        'Position must be specified in the form [X1,Y1;...;XN,YN].');
end

position        = commonArgs.Position;
h_parent        = commonArgs.Parent;
h_fig           = commonArgs.Fig;

positionConstraintFcn = commonArgs.PositionConstraintFcn;
if isempty(positionConstraintFcn)
    % constraint_function is used by dragMotion() to give a client the
    % opportunity to constrain where the point can be dragged.
    positionConstraintFcn = identityFcn;
end

try
    h_group = hggroup('Parent', h_parent,'Tag','imspline');
catch ME
    error(sprintf('Images:%s:noAxesAncestor',mfilename), ...
          'HPARENT must be able to have an hggroup object as a child.');
end

draw_api = splineSymbol();

basicSplineAPI = basicSpline(h_group,draw_api,positionConstraintFcn);

% Alias functions defined in basicSplineAPI to shorten calling syntax in
% imspline.
setPosition               = basicSplineAPI.setPosition;
setConstrainedPosition    = basicSplineAPI.setConstrainedPosition;
getPosition               = basicSplineAPI.getPosition;
setVisible                = basicSplineAPI.setVisible;
updateView                = basicSplineAPI.updateView;
addNewPositionCallback    = basicSplineAPI.addNewPositionCallback;
deleteSpline              = basicSplineAPI.delete;

% Create vertices in initial locations specified by user.    
setPosition(position);
setVisible(true);
draw_api.pointerManagePolygon(true);

% Fires figure pointer manager (updates cursor when over the ROI)
iptPointerManager(h_fig,'Enable');

% Create context menu for spline body once initial placement of spline is
% complete.

% setColor called within createROIContextMenu requires that cmenu_spline is
% an initialized variable.
cmenu_spline =[];

cmenu_spline = createROIContextMenu(h_fig,getPosition,@setColor);
setContextMenu(cmenu_spline);

% Define API
api.setPosition               = basicSplineAPI.setPosition;
api.setConstrainedPosition    = setConstrainedPosition;
api.getPosition               = basicSplineAPI.getPosition;
api.addNewPositionCallback    = addNewPositionCallback;
api.delete                    = deleteSpline;
api.removeNewPositionCallback = basicSplineAPI.removeNewPositionCallback;
api.getPositionConstraintFcn  = basicSplineAPI.getPositionConstraintFcn;
api.setPositionConstraintFcn  = basicSplineAPI.setPositionConstraintFcn;
api.setColor                  = draw_api.setColor;

% Undocumented API methods.
api.setContextMenu            = @setContextMenu;
api.getContextMenu            = @getContextMenu;

iptsetapi(h_group,api);

updateView(getPosition());


    %-----------------------
    function setColor(color)
        if ishandle(getContextMenu())
            updateColorContextMenu(getContextMenu(),color);
        end
        draw_api.setColor(color);
    end


    %----------------------------- 
    function setContextMenu(cmenu_new)
      
       cmenu_obj = findobj(h_group,'Type','line','-or','Type','patch');  
       set(cmenu_obj,'uicontextmenu',cmenu_new);
       
       cmenu_spline = cmenu_new;
        
    end

    
    %-------------------------------------
    function context_menu = getContextMenu
       
        context_menu = cmenu_spline;
    
    end

end