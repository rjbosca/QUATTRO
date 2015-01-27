function qtroi_tag_postset(obj,src,eventdata)
%qtroi_tag_postset  PostSet event for qt_roi property "tag"
%
%   qtroi_tag_postset(OBJ,SRC,EVENT)

    % Grab the modified ROI that triggered the event and the qt_exam stack of
    % ROIs
    roi  = eventdata.AffectedObject;
    rois = obj.rois;

    % The "tag" property of a qt_roi object was changed. Because the only
    % information that exists comes from the default source and event data the
    % stack of ROIs (including all fields) must be searched to find the ROI
    % object that was modified
    flds = fieldnames(rois);
    flds = flds( ~strcmpi(roi.tag,flds) ); %remove the tag of the same name
    for fldIdx = 1:numel(flds)

        % Grab the previous tag and test if any ROIs in that storage unit are
        % equal to the ROI that fired the qtroi_tag_postset event. Once the
        % qt_roi object is found, exit the loop so that fldIdx represents the
        % current field in which the modified ROI resides
        oldTag  = flds{fldIdx};
        roiMask = (rois.(flds{fldIdx})==roi);
        if any( roiMask(:) )
            break
        end

    end

    % Since MATLAB will not retain a non-single third dimension (i.e., all ROIs
    % are on the first series), the case of 2- and 3-D "roiMaks" must be split
    if (ndims(roiMask)>2)
        [rIdx,slIdx,seIdx] = ind2sub(size(roiMask),find(roiMask));
    else
        [rIdx,slIdx] = ind2sub(size(roiMask),find(roiMask));
        seIdx        = 1;
    end

    % Determine which ROI indices are being moved. To ensure that ROIs existing
    % in the new location are not overwritten, determine which indices, if any,
    % are shared.
    mNewRoi = zeros(1,3);
    if isfield(rois,roi.tag)
        mNewRoi = [size(rois.(roi.tag),1),...
                   size(rois.(roi.tag),2),...
                   size(rois.(roi.tag),3)];
    else %initialize the storage array so it can be indexed
        rois.(roi.tag) = qt_roi.empty(rIdx,slIdx,0);
    end
    roiExistAtLoc = any(mNewRoi) && all(mNewRoi>=[rIdx,slIdx,seIdx]) &&...
                                 ~rois.(roi.tag)(rIdx,slIdx,seIdx).validaterois;
    if ~roiExistAtLoc
        % Since no ROIs were found within the new tag, copy the old tag and
        % remove ROIs that should not be copied (i.e. ~roiMask) by storing an
        % empty qt_roi object. Squeeze out any empty data postions
        rois.(roi.tag)(rIdx,slIdx,seIdx) = roi;
        rois.(roi.tag)                   = obj.squeeze_roi_stack(rois.(roi.tag));
    else
        %FIXME: this code works fine if the ROIs are being moved to a
        %non-existent tag, but if ROIs exist at the same location in the new
        %tag, they will be overwritten. FIX THIS!!!
        error(['qt_exam:' mfilename ':notProgrammed'],...
              ['ROIs exist at the "new" location.\n',...
               'This case has not been programmed']);
    end

    % Use the mask, derived above, to replace the previous storage spot under
    % the old tag with an empty qt_roi object
    rois.(oldTag)(roiMask)  = qt_roi;
    rois.(oldTag)           = obj.squeeze_roi_stack(rois.(oldTag));
    if all( ~rois(:).(oldTag).validaterois )
        rois.(oldTag)       = qt_roi.empty(1,0);
    end

    % Now that all changes to the ROI stack have been made, store the ROIs. This
    % also updates the "roiIdx" property to reflect the new state of the ROI
    % stack
    obj.rois = rois;

    % Now that all qt_exam object updates have completed, grab the current ROI
    % and update the display
    roi = obj.roi;
    if any(roi(:).validaterois)
        [roi(:).state] = deal('on');
    end

end %qt_exam.qtroi_tag_postset