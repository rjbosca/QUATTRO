function checkCalcReady_event(obj,~,~)
%checkCalcReady_event  "checkCalcReady" modeling event for t1dynamic class
%
%   checkCalcReady_event(OBJ,SRC,EVENT)

    % Define the T1 correction specific readiness criteria
    obj.isReady.t1dynamic = ~obj.useT1Correction ||...T1 correction off
                            (obj.useT1Correction && ~isempty(obj.tr) && ~isempty(obj.fa));

end %t1dynamic.checkCalcReady_event