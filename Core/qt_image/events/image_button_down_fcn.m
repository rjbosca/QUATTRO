function image_button_down_fcn(hObj,eventdata) %#ok
%image_button_down_fcn  Handles button down events in figures with images
%
%   image_button_down_fcn(H,EVENT) is a generic callback for handling WW/WL
%   functionality for figures, specified by the handle H. Simply add this
%   function to the figure property 'WindowButtonDownFcn' in addition to
%   setting image_button_motion_fcn and image_button_up_fcn to their respective
%   figure properties. To ensure proper functionality, the image in the figure
%   must have the property 'Type' set to 'image'. EVENT is currently unused.
%
%   See also image_button_motion_fcn and image_button_up_fcn

    % Determine which object was hit by the button up event
    currentPoint = get(hObj,'CurrentPoint');
    if verLessThan('matlab','8.4.0')
        hitObj   = hittest(hObj,currentPoint);
    else
        hitObj   = hittest(hObj);
    end
    objTag       = get(hitObj,'Type');
    if isempty(objTag) || ~isempty(strfind(objTag,'axes'))
        objTag = get(hitObj,'Type');
    end

    % Mouse selection type
    clickType = get(hObj,'SelectionType');

    % Determines if the image was hit
    hitImage       = strcmpi(objTag,'image');
    isMiddleButton = strcmpi(clickType,'extend');
    if hitImage && isMiddleButton
        % Stores current mouse position for ww/wl
        setappdata(hitObj,'cachedWwWlPosition',currentPoint);
    end

end %qt_image.image_button_down_fcn