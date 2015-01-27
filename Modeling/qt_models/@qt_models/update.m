function update(obj,varargin)
%update  Performs an update operation on the display and fitting data
%
%   update(OBJ) performs fitting and show operations (in that order) using data
%   stored currently in the sub-classed qt_models object OBJ.

    if obj.autoFit %Fire the fitting operation, which will also show the data
        obj.fit;
    end

    % Although the "fit" method will indirectly show data through the
    % "results_postset" event, model data that are unsuccessfully fitted will
    % skip this event. This ensures that all data will be shown appropriately.
    obj.show;

end %qt_models.update