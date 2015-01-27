function overwrite_gui_data(hFig)
%overwrite_gui_data  Overwrites all current data in QUATTRO
%
%   overwrite_gui_data(H) clears all data stored in the QUATTRO figure specified
%   by the handle H. This includes resetting all QUATTRO UI controls and
%   deleting the current qt_exam objects.

    % Get handles and the full QUATTRO workspace qt_exam object
    hs  = guihandles(hFig);
    obj = getappdata(hFig,'qtWorkspace');

    % Only proceed with the overwrite operation if a valid qt_exam object exists
    if ~isempty(obj) && obj.exists.any

        % Sets initial values and app data for UI controls
        set_ui_current_value(hFig);

        % Delete exam specific tools
        delete(findobj(hFig,'Tag','uipanel_surgical_planning')); %surgery tools

        % Clear the "Go to ROI"-> "On slice" context menus so QUATTRO will know
        % to update them next time ROIs are created/loaded
        hContext = get(hs.listbox_rois,'UIContextMenu');
        delete( get(findobj(hContext,'Tag','context_go2roi_slice'),'Children') )

        % Update handles structure
        guidata(hFig,guihandles(hFig));

        % Delete all current exam objects
        obj.delete;

    end

end %overwrite_gui_data