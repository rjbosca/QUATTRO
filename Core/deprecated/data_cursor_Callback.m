function data_cursor_Callback(hObj,~)
%data_cursor_Callback  Callback for handling QUATTRO data cursor calls
%
%   data_cursor_Callback(H,EVENT) handles the data cursor UI push tool in the
%   QUATTRO figure specified by the handle H. The event data specified by EVENT
%   is unused; this may change in a future release.

    % Get handles structure, qt_exam object and ROI objects
    hs   = guidata(hObj);
    obj  = getappdata(hs.figure_main,'qtExamObject');
    rois = obj.rois.(obj.roiTag);

    % Disable other UI toggle tools
    set([hs.uitoggletool_zoom_in
         hs.uitoggletool_zoom_out
         hs.uitoggletool_drag],'State','off');

    % Grab the data cursor mode object
    hData = datacursormode(hs.figure_main);

    % Determine the current data cursor state
    isOn  = strcmpi( get(hData,'Enable'),'on' );

    % Perform data cursor toggling
    if isOn %disable previously enabled data cursor
        set(hData,'Enable','off');
        hData.removeAllDataCursors;

        % Enable prviously disabled controls and ROIs
        set([hs.listbox_rois hs.popupmenu_roi_tag],'Enable','on');
        if any(rois(:).validaterois)
            [rois(:).state] = deal('on'); %#ok<*NASGU>
        end

    else %enable new data cursor

        % Surpress the ROI display. Since the pop-up menu for changing ROI tags
        % is disabled, only the ROIs of the current tag need to have the "state"
        % property set to 'off'
        if any(rois(:).validaterois)
            [rois(:).state] = deal('off');
        end

        % Disable the listbox, and enable the data cursor mode.
        set([hs.listbox_rois hs.popupmenu_roi_tag],'Enable','off');
        set(hData,'Enable','on');

        % Apply the update function to the data cursor mode
        iptaddcallback(hData,'UpdateFcn',@update_data_cursor);

    end

end %data_cursor_Callback