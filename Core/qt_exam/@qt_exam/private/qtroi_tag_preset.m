function qtroi_tag_preset(obj,src,eventdata)
%qtroi_tag_preset  PreSet event for qt_roi property "tag"
%
%   qtroi_tag_preset(OBJ,SRC,EVENT) disables the display or qt_roi objects for
%   which the "tag" property iss equivalent to the current value of the qt_exam
%   object (OBJ) propoerty "roiTag". SRC and EVENT are unused.

    % Disable the display for all ROIs with the property "tag" set to the
    % current value of the qt_exam property "roiTag"
    if any(obj.rois.(obj.roiTag)(:).validaterois)
        [obj.rois.(obj.roiTag)(:).state] = deal('off');
    end

end %qt_exam.qtroi_tag_preset