function roiIdx_preset(~,eventdata)
%roiIdx_preset  Pre-set event for QT_EXAM "roiIdx" property
%
%   roiIdx_preset(SRC,EVENT) performs operations that modify the ROI display
%   based on the current "roiIdx" and "roiTag" properties of the QT_EXAM object.

    % Grab the QT_EXAM object ROI index and the current ROIs
    idx  = eventdata.AffectedObject.roiIdx;

    % Since the index is a structure with (potentially) multiple fields, grab the
    % fields and evaluate on a case-by-case basis
    flds = fieldnames(idx);
    rois = eventdata.AffectedObject.rois;
    cellfun(@set_state,flds)

    %----------------------
    function set_state(fld)

        % When the index is updated to a 0, perform no operations
        roiId = idx.(fld);
        if ~roiId
            return
        end

        % Ensure the index for this particular field is within bounds
        roi = rois.(fld);
        if any(roiId>size(roi,1)) || (numel(roi)==0)
            return
        end

        % Determine if there are any valid/non-empty ROIs and set the state to
        % 'off'
        if any(roiId) && any(roi(:).validaterois)
            [roi(roiId,:).state] = deal('off'); %#ok<*NASGU>
        end

    end

end %qt_exam.roiIdx_preset