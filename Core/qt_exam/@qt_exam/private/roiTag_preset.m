function roiTag_preset(obj,~,~)
%roiTag_preset  Pre-set event for the QT_EXAM property "roiTag"
%
%   roiTag_preset(OBJ,SRC,EVENT) disables the display of QT_ROI objects for
%   which the "tag" property is equivalent to the current value of the QT_EXAM
%   object (OBJ) property "roiTag". SRC and EVENT are unused.

    % Disable the display for all ROIs with the property "tag" set to the
    % current value of the qt_exam property "roiTag"
    rois = obj.rois.(obj.roiTag)(:);
    if any(rois(:).validaterois)
        [rois.state] = deal('off');
    end

end %qt_exam.roiTag_preset