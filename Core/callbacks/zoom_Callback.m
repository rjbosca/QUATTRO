function zoom_Callback(hObj,eventdata) %#ok
%zoom_Callback  Handles QUATTRO zoom UI toggle button events
%
%   zoom_Callback(H,EVENT) enables or disables the figure zoom based on the
%   state of the zoom UI toggle buttons, where H is the handle one of these
%   buttons or supported HGO belonging to any suppored QUATTRO specific
%   application. Event data specified by the second input, EVENT, is currently
%   unused
%
%   See also pan_Callback

    % Validate caller
    hs = guidata(hObj);
    if ~strcmpi(get(hs.figure_main,'Tag'),'figure_main')
        warning('QUATTRO:zoomHandleChk',['Invalid zoom_Callback caller.\n',...
                                         'No further action will be taken.']);
        return
    end

    % Get figure zoom handle
    hAx   = hs.axes_main;
    hZoom = zoom(hs.figure_main);

    % Disable when unchecked
    if strcmpi( get(hObj,'State'), 'off' )
        set(hZoom,'Enable','off');
        return
    end

    % Zoom direction
    drct = regexp(get(hObj,'Tag'),'zoom_(\w*)','tokens'); drct = drct{1}{1};

    % Set zoom object properties
    setAllowAxesZoom(hZoom,hAx,false);
    if ~isempty( findobj(hAx(1),'Tag','image') )
        setAllowAxesZoom(hZoom,hAx(1),true);
    end
    if length(hAx) > 1 && isvisible(hAx(2))
        setAllowAxesZoom(hZoom,hAx(2),true);
    end
    set(hZoom,'Enable','on','Direction',drct);

    % Disable other controls that might conflict with the zoom functionality
    if strcmpi(drct,'in')
        hOff = hs.uitoggletool_zoom_out;
    else
        hOff = hs.uitoggletool_zoom_in;
    end
    set([hOff
         hs.uitoggletool_drag
         hs.uitoggletool_data_cursor],'State','off');

end %zoom_Callback