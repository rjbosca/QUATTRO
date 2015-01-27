function pan_Callback(hObj,eventdata) %#ok
%pan_Callback  Handles QUATTRO pan UI toggle button events
%
%   pan_Callback(H) enables or disables the figure pan based on the state of the
%   pan UI toggle buttons, where H is the handle one of these buttons or
%   supported HGO belonging to any suppored QUATTRO specific application
%
%   See also zoom_Callback

% Validate caller
hs = guidata(hObj);
if ~strcmpi(get(hs.figure_main,'Tag'),'figure_main')
    warning('QUATTRO:zoomHandleChk',...
                                ['Invalid zoom_Callback caller.\n',...
                                 'No further action will be taken.']);
    return
end

% Get figure's pan mode object
hPan = pan(hs.figure_main);

% Disable when unchecked
if strcmpi(get(hObj,'State'),'off')
    set(hPan,'Enable','off');
    return
end

% Set pan object properties
setAllowAxesPan(hPan,hs.axes_main,false);
hIm = findobj(hs.axes_main,'Type','image');
if ~isempty( hIm )
    setAllowAxesPan(hPan,hs.axes_main,true);
    set(hPan,'Enable','on');
end

% Disable other controls
set([hs.uitoggletool_zoom_in
     hs.uitoggletool_zoom_out
     hs.uitoggletool_data_cursor],'State','off');