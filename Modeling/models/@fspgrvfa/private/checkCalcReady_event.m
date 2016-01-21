function checkCalcReady_event(obj,~,~)
%checkCalcReady_event  "checkCalcReady" event for FSPGRVFA class
%
%   checkCalcReady_event(OBJ,SRC,EVENT)

    % Define the FSPGRVFA readiness criteria
    obj.isReady.fspgrvfa = ~isempty(obj.tr);

end %fspgrvfa.checkCalcReady_event