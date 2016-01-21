function roiIdx_postset(~,eventdata)
%roiIdx_postset  Post-set event for QT_EXAM "roiIdx" property
%
%   roiIdx_postset(SRC,EVENT) performs operations that modify the ROI display
%   based on the current state of the qt_exam object

    % Grab the current ROIs using the dependent property "roi" (since this
    % property will return ROIs at the current QT_EXAM position) and update the
    % state to "on" 
    roi = eventdata.AffectedObject.roi;
    if any(roi(:).validaterois)
        [roi(:).state] = deal('on');

        % Clear the "vifCache" property of DCE/DSC exams
        if strcmpi( roi(1).tag, 'vif' )
            eventdata.AffectedObject.vifCache = [];
        end

    end

end %qt_exam.roiIdx_postset