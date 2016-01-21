function x_postset(obj,~,~)
%x_postset  Post-set event for MODELBASE property "x"
%
%   x_postset(OBJ,SRC,EVEVT) performs various validation steps on the property
%   "x" in addition to initializing the "subset" property if necessary. Finally,
%   when setting new data for the "y" property the results structure is reset.
%   In both cases, fitting of the new data is performed.

    % Gather some information about the properties of the current QT_MODEL
    % object
    nIndex = numel(obj.subset);
    nX     = numel(obj.x);

    % Validate/update the "subset" property according to the new "x" data
    nNeeded = nX-nIndex;
    if ~any(nIndex) || nNeeded
        obj.subset = [obj.subset true(1,nNeeded)];
    end

    % Reset the "paramGuessCache" property
    obj.paramGuessCache = struct([]);

    % Check computation readiness and notify the model updaters (if any)
    notify(obj,'checkCalcReady');
    notify(obj,'updateModel');

end %modelbase.x_postset