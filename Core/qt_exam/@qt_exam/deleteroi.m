function deleteroi(obj,roi)
%deleteroi
%
%   deleteroi(OBJ,ROI) deletes the QT_ROI object ROI, updating the corresponding
%   QT_EXAM object OBJ. A clone of the deleted ROI is placed on the undo stack

    % Validate the ROI input
    roi = roi(roi.validaterois);
    if (numel(roi)<1)
        return
    end

    % Fire the "delete" function
    arrayfun(@(x) remove_roi(obj,x),roi);

    % Notify the exam object that ROIs have been deleted
    notify(obj,'roiDeleted');

end %qt_exam.deleteroi


%---------------------------
function remove_roi(obj,roi)
%remove_roi  Deletes an ROI
%
%   remove_roi(OBJ,ROI) is a helper function that allows the use of arrayfun in
%   the QT_EXAM method "deleteroi" to delete all ROIs in an array of QT_ROI
%   objects

    % Add the ROI to the undo stack
    obj.addroiundo(roi,'deleted');

    % Delete the QT_ROI object
    roi.delete;

end %remove_roi