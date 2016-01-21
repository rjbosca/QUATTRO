function mouseButtonDown_event(obj,~,~)
%mouseButtonDown_event  Mouse button down event
%
%   mouseButtonDown_event(OBJ,SRC,EVENT) caches the current ROI current contents
%   of the "position" property to be used in creating ROI "undo" clones

    % Update the "roiPositionCache"
    obj.roiPositionCache = obj.position;

end %qt_roi.mouseButtonDown_event