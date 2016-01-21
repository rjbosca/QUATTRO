function checkCalcReady_event(obj,src,eventdata)
%checkCalcReady_event  "checkCalcReady" qt_models event
%
%   checkCalcReady_event(OBJ,SRC,EVENT)

    % Define the pk specific readiness criteria
    obj.isReady.pk = ~isempty(obj.vif);

end %pk.checkCalcReady_event