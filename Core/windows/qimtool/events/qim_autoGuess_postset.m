function qim_autoGuess_postset(~,eventdata)
%qim_autoGuess_postset  Post-set event for MODELBASE property "autoGuess"
%
%   qim_autoGuess_postset(SRC,EVENT)

    % Get the current modeling object
    mObj = eventdata.AffectedObject;

    % Update the "Auto-Guess" checkbox
    if ~isempty(mObj.hFig) && ishandle(mObj.hFig)
        hs = guidata(mObj.hFig);
        set(hs.checkbox_auto_guess,'Value',mObj.autoGuess);
    end

end %qim_autoGuess_postset