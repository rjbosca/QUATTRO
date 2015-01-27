function roiIdx_postset(src,eventdata)
%roiIdx_postset  PostSet event for qt_exam "roiIdx" property
%
%   roiIdx_postset(SRC,EVENT) performs operations that modify the ROI display
%   based on the current state of the qt_exam object

    % Grab the current ROIs using the dependent property "roi" (since will use
    % the current qt_exam position) and update the state to "on"
    roi = eventdata.AffectedObject.roi;
    if any(roi(:).validaterois)
        [roi(:).state] = deal('on');

        % Clear the "vifCache" property of DCE/DSC exams
        if strcmpi( roi(1).tag, 'vif' )
            eventdata.AffectedObject.vifCache = [];
        end

    end

end %qt_exam.roiIdx_postset