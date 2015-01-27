function listbox_value_preset(src,eventdata)
%listbox_value_preset  PreSet event handler for QUATTRO listbox UI controls
%
%   listbox_value_preset(SRC,EVENT) clears the statistics display during a
%   PreSet property event for the listbox property "Value".

    % Get the UI control handle (since there are multiple listboxes that use
    % this event handler) and associated parent, validating the call
    hList = eventdata.AffectedObject;
    if ~strcmpi( get(hList,'Style'), 'listbox' )
        warning(['QUATTRO:' mfilename ':invalidListHandle'],...
                 'Event calls to %s must originate from a listbox UI control.',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'value')
        warning(['QUATTRO:' mfilename ':invalidListHandle'],...
                 'Event calls to %s must originate from a "%s" PostSet event.',...
                 mfilename,src.Name);
        return
    end

    % Get the handles and image values
    hFig = guifigure(hList);
    hs   = guihandles(hFig);
    set([hs.text_mean
         hs.text_area
         hs.text_median
         hs.text_nan_ratio
         hs.text_stddev
         hs.text_kurtosis
         hs.text_snr],'String','');

end %listbox_value_preset