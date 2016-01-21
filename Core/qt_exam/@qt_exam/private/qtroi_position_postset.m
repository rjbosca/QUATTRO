function qtroi_position_postset(obj,~,eventdata)
%qtroi_position_postset  Post-set event for QT_ROI "position" property
%
%   qtroi_position_postset(OBJ,SRC,EVENT)

    % Remove the "series" field from the "roiStats" property. This ensures that
    % code elsewhere will know to recalculate the series data
    if isfield(eventdata.AffectedObject.roiStats,'series')
        eventdata.AffectedObject.roiStats =...
                            rmfield(eventdata.AffectedObject.roiStats,'series');
    end

    % Because this listener is called frequently, the computation of the updated
    % series information should be housed elsewhere.

    % When updating the models based on an ROI that has been moved, the event
    % "newModelData" should only be fired when the QT_EXAM object is driving a
    % QUATTRO GUI. Otherwise, on-the-fly ROI and modeling computations can
    % become overly 

    % Determine if any of the modeling objects and update those models that are
    % using the "current pixel" mode
    if ~isempty(obj.models)
        notify(obj,'newModelData',newModelData_eventdata('roi','otf'));
    end

end %qt_exam.qtroi_position_postset