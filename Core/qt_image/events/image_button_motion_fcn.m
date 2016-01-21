function image_button_motion_fcn(hObj,~)
%image_button_motion_fcn  Handles mouse motion events in figures with images
%
%   image_button_motion_fcn(H,EVENTDATA) is a generic callback for handling
%   WW/WL functionality for figures, specified by the handle H. Simply add this
%   function to the figure property 'WindowButtonMotionFcn' in addition to
%   setting image_button_down_fcn and image_button_up_fcn to their respective
%   figure properties. To ensure proper functionality, the image displayed in
%   the figure must have the property 'Type' set to 'image'. EVENTDATA is
%   currently unused. 
%
%   See also image_button_down_Callback and image_button_up_Callback

    % Determine which object was hit by the button up event
    currentPoint = get(hObj,'CurrentPoint');
    if verLessThan('matlab','8.4.0')
        hitObj   = hittest(hObj,currentPoint);
    else
        hitObj   = hittest(hObj);
    end
    objType      = get(hitObj,'Type');
    if ~strcmpi('image',objType)
        return
    end

    % Determines the mouse selection type
    selection = get(hObj,'SelectionType');
    if ~strcmpi(selection,'extend')
        return
    end

    % Calculate the distance from old position
    cachedPos = getappdata(hitObj,'cachedWwWlPosition');
    if isempty(cachedPos)
        return
    end
    setappdata(hitObj,'cachedWwWlPosition',currentPoint);
    posDiff = currentPoint - cachedPos;

    % Get the axes
    hAx = get(hitObj,'Parent');
    if isempty(hAx) || ~ishandle(hAx)
        return
    end

    % Adjusts the WW/WL and store
    clim      = get(hAx,'CLim');
    currentWw = diff(clim);
    currentWl = currentWw/2+min(clim);
    posDiff   = posDiff*(currentWl+currentWw/2)/300;
    newWw     = currentWw + posDiff(1)/2;
    newWl     = currentWl + posDiff(2);
    if newWl<newWw/2 && -newWl<newWw/2
        set(hAx,'CLim',[0 newWl+newWw/2]);
    elseif newWw/2 < 1e-6
        disp(2)
        return
    else
        set(hAx,'CLim',[newWl-newWw/2 newWl+newWw/2]);
    end

end %qt_image.image_button_motion_fcn