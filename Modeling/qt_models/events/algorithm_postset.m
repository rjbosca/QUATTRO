function algorithm_postset(src,eventdata)
%algorithm_postset  PostSet event for qt_models property "algorithm"
%
%   algorithm_postset(SRC,EVENT)

    % Grab the modeling object
    obj = eventdata.AffectedObject;

    % Fit/show the data (the latter is handled by the "results" PostSet event)
    if obj.autoFit
        obj.fit;
    end

end %qt_models.algorithm_postset