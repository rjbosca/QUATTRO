function rois_postset(obj,src,eventdata)
%rois_postset  PostSet event for qt_exam property "rois"
%
%   rois_postset(OBJ,SRC,EVENT) updates ROI existence information based on the
%   current state of the qt_exam object OBJ.

    % Determine if specific ROIs and an associated tag-specific index exist
    rois       = obj.rois;
    roiFlds    = fieldnames(rois)';
    roiIdx     = obj.roiIdx;
    for fld = roiFlds

        % Validate the tag-specific index
        if ~isfield( roiIdx, fld{1} )
            roiIdx.(fld{1}) = 1;
        end

        % Update the "exists" structure and the ROI index. The latter should be
        % zero ROIs of the given tag no longer exist
        obj.exists.rois.(fld{1}) = any( rois.(fld{1})(:).validaterois );
        if ~obj.exists.rois.(fld{1})
            obj.roiIdx.(fld{1}) = 0;
        end

    end

    % Define the logical flag for the existence of any ROI
    obj.exists.rois.any = any( cellfun(@(x) obj.exists.rois.(x),roiFlds) );

    % Store the "roiIdx" property in case any changes have been made
    obj.roiIdx = roiIdx;

end %qt_exam.rois_postset