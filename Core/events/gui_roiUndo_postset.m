function gui_roiUndo_postset(src,eventdata)
%gui_roiUndo_postset  GUI PostSet event for qt_exam property "roiUndo"
%
%   gui_roiUndo_postset(SRC,EVENT) changes the "Enable" property of all UI
%   controls in QUATTRO which depend on the existence of ROI undo data.

    % qt_exam object alias
    obj = eventdata.AffectedObject;

    % Update the appropriate buttons
    enableStr = 'off';
    if ~isempty(obj.roiUndo)
        enableStr = 'on';
    end
    set( findobj(obj.hFig,'Tag','pushbutton_undo'), 'Enable', enableStr );

end %gui_roiUndo_postset