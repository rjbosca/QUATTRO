function y_postset(obj,~,~)
%y_postset  Post-set event for the MODELBASE property "y"
%
%   y_postset(OBJ,SRC,EVEVT) performs various validation steps on the property
%   "y". When setting new data for the "y" property the results structure is
%   reset and, fitting of the new data is performed.

    % Gather some information about the properties of the current modeling
    % object
    mY = size(obj.y);
    nX = numel(obj.x);

    % Ensure that the data dimension of "y" lines up with that of "x" (which is
    % a column vector)
    idxDim = (mY==nX);
    if ~any(idxDim)
        error('QUATTRO:modelbase:incommensurateXYData',...
              ['Y data must be same length as X data or satisfy ',...
               'SIZE(Y,1)==LENGTH(X).']);
    else
        fIdx  = find(idxDim);
        lIdx  = find(~idxDim);
        obj.y = permute(obj.y,[fIdx lIdx]);
        mY    = size(obj.y); %update since it might be used below
    end

    % Update the "results" and "isShown" properties to reflect the new data
    obj.results = struct([]);
    obj.isShown = false;

    % Update the "isSingle" and "subset" properties only if the value of "y" is
    % non-empty
    if ~isempty(obj.y)
        obj.isSingle = (prod(mY)==nX);

        if (numel(obj.y)==numel(obj.subset))
            obj.subset( isnan(obj.y) | isinf(obj.y) ) = false;
        end
    end

    % Update the "mapSubset" property
    if ~obj.isSingle
        obj.mapSubset = true(mY(2:end));
    end

    % Reset the "paramGuessCache" property
    obj.paramGuessCache = struct([]);

    % Check computation readiness and notify the model updaters (if any)
    notify(obj,'checkCalcReady');
    notify(obj,'updateModel');

end %modelbase.y_postset