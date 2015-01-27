function position_postset(obj,src,eventdata)
%position_postset  PostSet event for the qt_roi "position" property
%
%   position_postset(OBJ,SRC,EVENT)

    % Update the data existence property, "isEmpty"
    obj.isEmpty = isempty( obj.position );

    % Grab the roiview object
    viewObj = obj.roiViewObj;
    if isempty(viewObj) || ~any(viewObj.isvalid)
        return
    end

    % Get the image values and store some statistics
    qt_roi.calcstats(obj);

end %qt_roi.position_postset