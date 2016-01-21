function hFig_postset(~,eventdata)
%hFig_postset  PostSet event for the qt_models property "hFig"
%
%   hFig_postset(SRC,EVENT)

    % When the GUI is displayed, the modeling object should automatically fit
    % new data; change that property now. When toggling "autoFit" from FALSE to
    % TRUE, the "updateModel" event will be notified in the set method of the
    % "autoFit" property
    if ~eventdata.AffectedObject.autoFit
        eventdata.AffectedObject.autoFit = true;
    else
        % Notify the model updaters (if any)
        notify(obj,'updateModel');
    end

end %qt_models.hFig_postset