function checkCalcReady_event(obj,~,~)
%checkCalcReady_event  "checkCalcReady" modeling event for modelbase class
%
%   checkCalcReady_event(OBJ,SRC,EVENT)

    % Define the modelbase readiness criteria
    obj.isReady.modelbase = ~isempty(obj.x) && ~isempty(obj.y);

end %modelbase.checkCalcReady_event