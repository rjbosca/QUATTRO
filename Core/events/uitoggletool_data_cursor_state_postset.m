function uitoggletool_data_cursor_state_postset(src,eventdata)
%uitoggletool_data_cursor_state_postset  PostSet event for QUATTRO data cursor button
%
%   uitoggletool_data_cursor_state_postset(SRC,EVENT)

    % Get the UI control handle and validate the action
    hData  = eventdata.AffectedObject;
    if ~strcmpi( get(hData,'Type'), 'uitoggletool' )
        warning(['QUATTRO:' mfilename ':invalidDataButtonHandle'],...
                 'Event calls to %s must originate from a data cursor UI toggle tool.',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'state')
        warning(['QUATTRO:' mfilename ':invalidListEvent'],...
                 'Event calls to %s must originate from a "%s" PostSet event.',...
                 mfilename,src.Name);
        return
    end

    % Determine the new state of the toggle button and grab the current QUATTRO
    % environment
    state = get(hData,'State');
    hs    = guidata(hData);
    obj   = getappdata(hs.figure_main,'qtExamObject');
    rois  = obj.rois.(obj.roiTag);

    % Grab the data cursor mode object and determine the state
    hData = datacursormode(hs.figure_main);
    isOn  = strcmpi( get(hData,'Enable'),'on' );

    % Perform data cursor toggling
    if strcmpi(state,'on') && ~isOn

        % Disable other UI toggle tools
        set([hs.uitoggletool_zoom_in
             hs.uitoggletool_zoom_out
             hs.uitoggletool_drag],'State','off');

        % Surpress the ROI display. Since the pop-up menu for changing ROI tags
        % is disabled, only the ROIs of the current tag need to have the "state"
        % property set to 'off'
        if any(rois(:).validaterois)
            [rois(:).state] = deal('off'); %#ok - handle based object
        end

        % Disable the listbox, and enable the data cursor mode.
        set([hs.listbox_rois hs.popupmenu_roi_tag],'Enable','off');
        set(hData,'Enable','on');

        % Apply the update function to the data cursor mode
        set(hData,'UpdateFcn',@update_data_cursor);
        
    elseif strcmpi(state,'off') && isOn

        % Remove all previous data cursors
        set(hData,'Enable','off');
        hData.removeAllDataCursors;

        % Enable prviously disabled controls and ROIs
        set([hs.listbox_rois hs.popupmenu_roi_tag],'Enable','on');
        if any(rois(:).validaterois)
            [obj.roi.state] = deal('on');
        end

    end

end %uitoggletool_data_cursor_state_postset