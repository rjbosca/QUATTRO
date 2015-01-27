function pasteroi(obj)
%pasteroi  Pastes the copied qt_roi object
%
%   pasteroi(OBJ) pastes the current copied qt_roi object, stored in the qt_exam
%   property "roiCopy", to the current location of the qt_exam user indices.

    % Grab the ROI to determine where it is to be stored
    [rInds,seIdx] = deal(obj.roiIdx,obj.seriesIdx);

    % Loop through the selected ROIs and store the copied ROI
    for rIdx = rInds.(obj.roiCopy.tag)

        % Determine the name of the current ROI selection
        roiSub = obj.rois(rIdx,:);
        name   = unique( {roiSub(roiSub.validaterois).name} );
        name   = name{1};

        % Create a clone
        roiClone       = obj.roiCopy.clone;
        roiClone.name  = name;

        % Set the ROI/series index and add the ROI
        obj.addroi(roiClone,'series',seIdx);

    end

end %qt_exam.pasteroi