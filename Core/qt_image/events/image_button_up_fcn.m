function image_button_up_fcn(hObj,eventdata)
%image_button_up_fcn  Handles button up events in figures with images
%
%   image_button_up_fcn(h,eventdata) is a generic callback for handling WW/WL
%   functionality for figures, specified by the handle H. Simply add this
%   function to the figure property 'WindowButtonDownFcn' in addition to
%   setting image_button_motion_fcn and image_button_down_fcn to their
%   respective figure properties. To ensure proper functionality, the image in
%   the figure must have the property 'Type' set to 'image'. EVENTDATA is
%   currently unused. 
%
%   See also image_button_motion_fcn, image_button_down_fcn

    % Selection type
    clickType = get(hObj,'SelectionType');

    % Updates WW/WL mouse update
    if strcmpi(clickType,'extend')

        % Determine which object was hit by the button
        currentPoint = get(hObj,'CurrentPoint');
        if verLessThan('matlab','8.4.0')
            hitObj   = hittest(hObj,currentPoint);
        else
            hitObj   = hittest(hObj);
        end
        objType      = get(hitObj,'Type');
        if isappdata(hitObj,'cachedWwWlPosition')
            rmappdata(hitObj,'cachedWwWlPosition');
        end
        if ~strcmpi('image',objType)
            return
        end

        % Get the parent axis of the image and grab the color limit
        hAx     = get(hitObj,'Parent');
        axCLims = get(hAx,'CLim');
        ww      = diff(axCLims);
        wl      = ww/2+min(axCLims);
        imObj = getappdata(hitObj,'imgObject');

        % Update the WW/WL data in the qt_image object
        if ~isempty(imObj) && imObj.isvalid
            imObj.ww = wl;
            imObj.wl = wl;
        end

    end

end %qt_image.image_buttom_motion_fcn