function qim_listbox_rois_value_postset(src,eventdata)
%qim_listbox_rois_value_postset  PostSet event for QUATTRO's ROI listbox "Value" property
%
%   qim_listbox_rois_value_postset(SRC,EVENT) handles changes to the "Value"
%   property of QUATTRO's ROI listbox UI using the listbox handle object (SRC)
%   and associated event data object (EVENT).

    % Get UI control handle and validate the event call
    hList = eventdata.AffectedObject;
    if ~strcmpi( hList.Style, 'listbox' )
        warning(['QUATTRO:' mfilename ':invalidHandleStyle'],...
                 'Event calls to %s must originate from a listbox UI control',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'value')
        warning(['QUATTRO:' mfilename ':invalidListboxEvent'],...
                 'Event calls to %s must originate from a "Value" PostSet event.',...
                 mfilename);
        return
    end

    % Get the QUATTRO figure handle and the current modeling objects
    hFig    = guifigure(eventdata.AffectedObject);
    obj     = getappdata(hFig,'modelsObject');

    % Grab only those modeling objects that have modeling GUIs
    obj     = obj( ~isempty(obj(:).hFig) );
    if isempty(obj)
        return
    end

    % Set the new value. Since listboxes can have multiple values selected, use
    % only the first
    hPop     = findobj(obj.hFig,'Tag','popupmenu_roi');
    newValue = hList.Value;
    if ~isempty(newValue)
        set(hPop,'Value',newValue(1));
    end

end %qim_listbox_rois_value_postset