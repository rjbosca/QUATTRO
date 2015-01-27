function moveroi(obj,idx)
%moveroi  Moves ROIs within the qt_exam object
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

end %qt_exam.moveroi