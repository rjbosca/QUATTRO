function moveroi(obj,idx)
%moveroi  Moves ROIs within the QT_EXAM object ROI stack
%
%   moveroi(OBJ,IDX) moves the ROI stack according to the index vector IDX. IDX
%   is a numeric vector indicating the new position such that the stack of ROIs
%   is changed according to B = A(IDX).

    if any( [numel(idx) max(idx(:))] )>size(obj.rois,4)
        error(['qt_exam:' mfilename ':idxExceedsArray'],...
                             'The specified index exceeds the number of ROIs.');
    end

    % Perform the shuffle
    obj.rois.(obj.roiTag) = obj.rois.(obj.roiTag)(idx,:,:,:);
    if ~obj.roiIdx.(obj.roiTag)
        return
    end

    % Update the "roiIdx" property to reflect the new arrangement
    oldIdx = obj.roiIdx.(obj.roiTag);
    newIdx = zeros( size(oldIdx) );
    for idxer = 1:numel(oldIdx)
        newIdx(idxer) = find(idx==oldIdx(idxer));
    end
    obj.roiIdx.(obj.roiTag) = newIdx;

    % Notify the QT_EXAM object of the change
    notify(obj,'roiChanged');

end %qt_exam.moveroi