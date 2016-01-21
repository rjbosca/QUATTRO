function rois_postset(obj,~,~)
%rois_postset  Post-set event for QT_EXAM property "rois"
%
%   rois_postset(OBJ,SRC,EVENT) updates ROI existence information based on the
%   current state of the qt_exam object OBJ.

    % Determine if specific ROIs and an associated tag-specific index exist
    rois    = obj.rois;
    roiFlds = fieldnames(rois)';
    roiIdx  = obj.roiIdx;
    for fld = roiFlds

        % Validate the tag-specific index
        if ~isfield( roiIdx, fld{1} )
            roiIdx.(fld{1}) = 1;
        end

        % Update the "exists" structure and the ROI index. The latter should be
        % zero if the given tag no longer exists
        obj.exists.rois.(fld{1}) = any( rois.(fld{1})(:).validaterois );
        if ~obj.exists.rois.(fld{1})
            roiIdx.(fld{1}) = 0;
        end

        % Ensure that the ROI index is still within the bounds defined by the
        % ROI stack. While error checking is performed in the "roiIdx" set
        % property, events (such as "roiDeleted") can remove ROI label. This can
        % cause the "roiIdx" to exceed the number of ROIs within the ROI stack
        nRoi = size(rois.(fld{1}),1);
        if (roiIdx.(fld{1})>nRoi)
            roiIdx.(fld{1}) = nRoi;
        end

    end

    % Define the logical flag for the existence of any ROI
    obj.exists.rois.any = any( cellfun(@(x) obj.exists.rois.(x),roiFlds) );

    % Store the "roiIdx" property in case any changes have been made
    obj.roiIdx = roiIdx;

end %qt_exam.rois_postset