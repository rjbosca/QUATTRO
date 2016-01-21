function updateModel_event(obj,~,~)
%updateModel_event  Event for MODELBASE "updateModel" event
%
%   updateModel_event(OBJ,SRC,EVENT) performs fitting and show operations (in
%   that order) using data stored currently in the sub-classed MODELBASE object
%   OBJ. SRC and EVENT are unused source and event data objects

    % The update event is notified when a change has occured within one of the
    % modeling object's properties (among other circumstances). The results
    % structure must be reset to ensure that all fitting/display operations are
    % performed appropriately
    obj.results = struct([]);
    obj.isShown = false;

    if obj.autoFit %Fire the fitting operation, which will also show the data
        obj.fit;
    end

    % Although the "fit" method will indirectly show data through the
    % "newResults" event, model data that are unsuccessfully fitted will skip
    % this event. This ensures that all data will be shown appropriately.
    if ~obj.isShown
        obj.show;
    end

end %modelbase.updateModel_event