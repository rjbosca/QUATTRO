function newResults_event(obj,~,~)
%newResults_event  Performs post-processing on fitted data
%
%   newResults_event(OBJ,SRC,EVENT) updates the "results" structure by
%   calculating additional model parameters (either kep or ve and/or
%   semi-quantitative parameters) that are not otherwise computed by the
%   "fit"

    % Calculate the 'kep' or 've' map
    if isfield(obj.results,'ve')
        obj.addresults('kep',...
                        obj.results.Ktrans.value./obj.results.ve.value);
    else
        obj.addresults('ve',...
                       obj.results.Ktrans.value./obj.results.kep.value);
    end

    % Perform the semi-quantitative processing here
    if obj.calcSemiQ && obj.isReady.dynamic
        obj.calcbniauc; %this will also call "calciauc"
        obj.calcpeak;   %this will compute SER and TTP
    end

end %gkm.newResults_event