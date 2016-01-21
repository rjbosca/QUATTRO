function checkCalcReady_event(obj,~,~)
%checkCalcReady_event  "checkCalcReady" qt_models event
%
%   checkCalcReady_event(OBJ,SRC,EVENT)

    % Define the t2w specific readiness criteria
    obj.isReady.t2w = ~isempty(obj.te);

end %t2w.checkCalcReady_event