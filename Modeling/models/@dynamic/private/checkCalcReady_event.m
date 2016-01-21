function checkCalcReady_event(obj,~,~)
%checkCalcReady_event  "checkCalcReady" MODELBASE event for dynamic class
%
%   checkCalcReady_event(OBJ,SRC,EVENT)

    % Define the dynamic class readiness criteria
    obj.isReady.dynamic = true;
    if (isprop(obj,'calcSemiQ') && obj.calcSemiQ) || ~isprop(obj,'calcSemiQ')
        obj.isReady.dynamic = ~isempty(obj.tIntStep) &&...
                              ~isempty(obj.tIntStart) &&...
                              ~isempty(obj.injectionTime) &&...
                              ~isempty(obj.recircTime);
    end

end %dynamic.checkCalcReady_event