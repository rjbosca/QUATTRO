function scale_postset(obj,~,~)
%scale_postset  Post-set event for QT_ROI "scale" property
%
%   scale_postset(OBJ,SRC,EVENT)

    % Determine if any of the position values are less than 1 (an indication
    % that the ROI's position is not normalized)
    pos = obj.position;
    if ~all(pos(:)<1)
        obj.position = scale_roi_verts(pos,['im' obj.type],1./obj.scale);
    end

end %qt_roi.scale_postset