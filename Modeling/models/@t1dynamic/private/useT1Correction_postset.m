function useT1Correction_postset(obj,src,~)
%useT1Correction_postset  Post-set event for T1DYNAMIC property "useT1Correction"
%
%   useT1Correction_postset(OBJ,SRC,EVENT)

    % Update the y-axis label
    isCorrected = obj.(src.Name);
    if isCorrected
        obj.yLabel  = '[Gd] (mM)';
    else
        obj.yLabel = '\Delta S.I. (a.u.)';
    end

    % Disable T1 correction when using relative signal intensity
    if obj.useRSI && obj.useT1Correction
        obj.useRSI = false;
        warning(['t1Dynamic:' mfilename ':gdCalcConflict'],...
                 ['"useRSI" and "%s" cannot be enabled at the same time. ',...
                  'Disabling "useRSI"...'],src.Name);
    end

end %t1dynamic.useT1Correction_postset