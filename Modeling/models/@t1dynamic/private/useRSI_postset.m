function useRSI_postset(obj,src,~)
%useRSI_postset  Post-set event for T1DYNAMIC class property "useRSI"
%
%   useRSI_postset(OBJ,SRC,EVENT)

    % Disable T1 correction when using relative signal intensity
    if obj.useRSI && obj.useT1Correction
        obj.useT1Correction = false;
        warning(['qt_models:' class(obj) ':gdCalcConflict'],...
                 ['"useT1Correction" and "%s" cannot be enabled at the same ',...
                  'time. Disabling "useT1Correction"...'],src.Name);
    end

end %t1dynamic.useRSI_postset