function newResults_event(obj,~,~)
%newResults_event  Event for MODELEVENTS "newResults" event
%
%   newResults_event(OBJ,SRC,EVENT)

    % Non-linear models must handle all model metrics and show operations
    % elsewhere...
    if isempty(obj.nlinParams)
        return
    end

    % Calculate model fitting figures of merit
    obj.isFitted = all( isfield(obj.results,obj.nlinParams) );
    if obj.isFitted
        if ~isfield(obj.results,'RSq')
            obj.addresults('RSq',obj.RSq);
        end
        if obj.isSingle && ~isfield(obj.results,'MSE')
            obj.addresults('MSE',obj.MSE);
        end
    end

    % Determine what to do with the new results
    if ~isempty(obj.hFig) && ishandle(obj.hFig) && ~obj.isShown
        obj.show; %show the new data
    end

end %modelbase.newResults_event