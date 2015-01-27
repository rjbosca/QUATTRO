function qtroi_position_postset(obj,src,eventdata)
%qtroi_position_postset  PostSet event for qt_roi "position" property
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

end %qt_exam.qtroi_position_postset