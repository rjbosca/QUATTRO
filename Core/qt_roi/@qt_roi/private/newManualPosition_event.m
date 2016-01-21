function newManualPosition_event(obj,~,~)
%newManualPosition_event  Manual "position" change event
%
%   newManualPosition_event(OBJ,SRC,EVENT) forces updates to imroi sub-classes
%   (e.g., imrect, impoly, etc.) to update the position manually. This event
%   should be notified when manual modifications are made to the qt_roi object
%   property "position", but should not be assigned to any of the associated
%   properties as a PostSet event. By doing the latter, ROI position
%   modifications result in double computations.

    % Grab the roiview object(s)
    viewObj = obj.roiViewObj;
    if isempty(viewObj) || ~any(viewObj.isvalid)
        return
    end

    % Apply the new position to the underlying imroi sub-class ROI objects
    arrayfun(@(x) set_position(x.hRoi,obj.scaledPosition),viewObj);

end %qt_roi.newManualPosition_event

function set_position(roi,pos)

    if ~isempty(roi) && isvalid(roi)
        roi.setPosition(pos)
    end

end %qt_roi.newManualPosition_event.set_position