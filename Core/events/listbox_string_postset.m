function listbox_string_postset(src,eventdata)
%listbox_string_postset  PostSet event handler for QUATTRO listbox UI controls
%
%   listbox_string_postset(SRC,EVENT) updates the UI controls' properties
%   "Visible" and "Enable" based on the current data state of QUATTRO using the
%   source and event objects SRC and EVENT, respectively.

    % Get the UI control handle and the associated parent, then validate the
    % action
    hList  = eventdata.AffectedObject;
    if ~strcmpi( get(hList,'Style'), 'listbox' )
        warning(['QUATTRO:' mfilename ':invalidListHandle'],...
                 'Event calls to %s must originate from a listbox UI control.',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'string')
        warning(['QUATTRO:' mfilename ':invalidListHandle'],...
                 'Event calls to %s must originate from a "%s" PostSet event.',...
                 mfilename,src.Name);
        return
    end

    % Get the new value
    strs = hList.String;

    % Update the properties appropriately
    set(hList,'Visible','off');
    if ~isempty(strs)
        set(hList,'Visible','on');
    end

    % Only enable the "Order" UI context menu when there are multiple ROIs
    hContext = get(hList,'UIContextMenu');
    hOrder   = findobj(hContext,'Tag','context_order');
    if numel(strs)>1
        set(hOrder,'Enable','on');
    else
        set(hOrder,'Enable','off');
    end

end %listbox_string_postset