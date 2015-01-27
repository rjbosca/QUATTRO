function results_postset(src,eventdata)
%results_postset  PostSet event for qt_models "results" property
%
%   results_postset(SRC,EVENT)

    % Get the modeling object
    obj = eventdata.AffectedObject;

    % Determine what to do with the new results
    if ~isempty(obj.hFig) && ishandle(obj.hFig)
        obj.show; %show the new data
    end

end %qt_models.results_postset