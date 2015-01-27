function hRoi = createroi(obj)
%createroi  Fires the interactive placement of an ROI
%
%   createroi(OBJ) allows the user to perform interactive placement of an ROI
%   (imrect, impoly, impoint, or imfreehand)

    % By way of the construction syntax, it is assumed that the specified axis
    % handle will be a scalar. This necessarily implies that the hRois property
    % can safely be overwritten and called using dot constructors without fear
    % of accessing an array of ROI objects

    % Get the associated figure, new ROI type, and constraint function
    hAx     = obj.hAxes;
    hFig    = guifigure(hAx);
    hIm     = findobj(hAx,'Type','image');
    roiType = ['im' strrep(obj.roiObj.type,'freehand','spline')];
    fcn     = make_constraint_fcn(hAx,[],roiType);

    % Disable pan/zoom/data cursor/UI controls during creation so the associated
    % callbacks do not interfere with creating the ROI
    pan(hFig,'off');
    zoom(hFig,'off');
    hData = datacursormode(hFig);
    set(hData,'Enable','off');
    if ~isempty(hData.getCursorInfo)
        hData.removeAllDataCursors;
    end

    % Cache figure mouse button event functions and set each callback to identity
    % the function. This prevents other callbacks from attempting to run during ROI
    % creation.
    btnDwnFcn    = get(hFig,'WindowButtonDownFcn');
    btnMotionFcn = get(hFig,'WindowButtonMotionFcn');
    btnUpFcn     = get(hFig,'WindowButtonUpFcn');
    set(hFig,'WindowButtonDownFcn',  @(varargin) identityFcn)
    set(hFig,'WindowButtonMotionFcn',@(varargin) identityFcn)
    set(hFig,'WindowButtonUpFcn',    @(varargin) identityFcn)

    % Let the user create the ROI
    hRoi = feval(roiType,hAx,'PositionConstraintFcn',fcn);

    % Determine if the new ROI is valid. This is heuristic, but the main idea is
    % that polygons should have at least 3 points, freehand ROIs should have at
    % least 9 points, and ellipses/rectangles should have a non-zero mask
    isInvalidRoi =  isempty(hRoi) ||...
                   (strcmpi(roiType,'impoly') &&...
                    numel(hRoi.getPosition)<=3) ||...
                   (strcmpi(roiType,'imspline') &&...
                    numel(hRoi.getPosition)<9) ||...
                   (any(strcmpi(roiType,{'imellipse','imrect'})) &&...
                    sum(sum(hRoi.createMask(hIm)))==0);
    if isInvalidRoi
        obj.delete;
        return
    end

    % Get the ROI verticies and handle special cases
    obj.roiObj.scaledPosition = hRoi.getPosition;
    if ~strcmpi(roiType,'impoint')
        %TODO: figure out what to do with this
    end

    % Update the color and new position callback for the ROI
    hRoi.addNewPositionCallback( @obj.newposition_Callback );
    hRoi.setColor(obj.roiObj.color);

    % Store the ROI in the roiview object
    obj.hRoi = hRoi;

    % Restore the figure button callbacks
    set(hFig,'WindowButtonDownFcn',  btnDwnFcn);
    set(hFig,'WindowButtonMotionFcn',btnMotionFcn);
    set(hFig,'WindowButtonUpFcn',    btnUpFcn);

end %roiview.createroi