function hFig_postset(src,eventdata)
%hFig_postset  PostSet event for the qt_models property "hFig"
%
%   hFig_postset(SRC,EVENT)

    % Grab the object
    obj = eventdata.AffectedObject;

    % When the GUI is displayed, the modeling object should automatically fit
    % new data; change that property now. When toggling "autoFit" from false to
    % true, the data will be displayed automatically, so there is no need to
    % explicitly call "show"
    if ~obj.autoFit
        obj.autoFit = true;
    end

    % The remaining actions require an exams object
    if ~isempty(obj.hExam)
        % Register the GUI with the qt_exam object
        obj.hExam.register(obj.hFig);

        % Attach some listeners
    end

end %qt_models.hFig_postset