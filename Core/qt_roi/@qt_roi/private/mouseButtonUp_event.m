function mouseButtonUp_event(obj,~,~)
%mouseButtonUp_event  Mouse button down event
%
%   mouseButtonUp_event(OBJ,SRC,EVENT) clears the cached ROI position

    % Update the "roiPositionCache"
    obj.roiPositionCache = [];

end %qt_roi.mouseButtonUp_event