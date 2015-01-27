function gui_roiCopy_postset(src,eventdata)
%gui_roiCopy_postset  GUI PostSet event for qt_exam property "roiCopy"
%
%   gui_roiCopy_postset(SRC,EVENT) changes the "Enable" property of all UI
%   controls in QUATTRO which depend on the existence of copied ROI data.

    % qt_exam object alias
    obj = eventdata.AffectedObject;

    % Determine the appropriate action
    enableStr = 'off';
    if obj.roiCopy.validaterois
        enableStr = 'on';
    end

    % Update the tools
    set([findobj(obj.hFig,'Tag','pushbutton_paste'),...
         findobj(obj.hFig,'Tag','pushbutton_paste_to_all')],'Enable',enableStr);

end %gui_roiCopy_postset