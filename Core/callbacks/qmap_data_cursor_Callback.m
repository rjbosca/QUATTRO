function qmap_data_cursor_Callback(hObj,eventdata)
%qmap_data_cursor_Callback  Callback for handling qmaptool data cursor calls
%
%   qmap_data_cursor_Callback(H,EVENT) handles the data cursor UI push tool in
%   the qmaptool figure specified by the handle H. This callback is only used
%   when qmaptool is being utilized in a stand-alone capacity. The event data
%   specified by EVENT is unused; this may change in a future release.

    % Get handles structure
    hs   = guidata(hObj);

    % Disable other UI toggle tools
    set([hs.uitoggletool_zoom_in
         hs.uitoggletool_zoom_out
         hs.uitoggletool_drag],'State','off');

    % Grab the data cursor mode object. On 2-D plots with stack HGOs, make sure
    % that the data cursor is on the top of the heap by setting the property
    % "ZStackMinimum"
    hData = datacursormode(hs.figure_main);
    set(hData,'ZStackMinimum',0);

    % Determine the current data cursor state
    isOn  = strcmpi( get(hData,'Enable'),'on' );

    % Perform data cursor toggling
    if isOn %disable previously enabled data cursor

        set(hData,'Enable','off');
        hData.removeAllDataCursors;

    else %enable new data cursor

        % Disable the listbox, and enable the data cursor mode.
        set(hData,'Enable','on');

        % Apply the update function to the data cursor mode
        set(hData,'UpdateFcn',@update_data_cursor);

    end

end %data_cursor_Callback