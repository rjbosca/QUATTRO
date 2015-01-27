function roiTag_preset(obj,src,eventdata)
%roiTag_preset  PreSet event for qt_exam property "roiTag"
%
%   roiTag_preset(OBJ,SRC,EVENT) disables the display of qt_roi objects for
%   which the "tag" property is equivalent to the current value of the qt_exam
%   object (OBJ) property "roiTag". SRC and EVENT are unused.

    % Disable the display for all ROIs with the property "tag" set to the
    % current value of the qt_exam property "roiTag"
    rois = obj.rois.(obj.roiTag)(:);
    if any(rois(:).validaterois)
        [rois.state] = deal('off');
    end

end %qt_exam.roiTag_preset