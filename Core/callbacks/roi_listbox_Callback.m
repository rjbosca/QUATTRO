function roi_listbox_Callback(hObj,eventdata) %#ok
%roi_listbox_Callback  Callback for handling ROI/VIF listbox events

    % Determine if any change was made to the selection
    val    = get(hObj,'Value');
    curVal = getappdata(hObj,'currentvalue');
    if (numel(val)==numel(curVal)) && all(val==curVal)
        return
    end

    % Update the application data and disable the user controls
    setappdata(hObj,'currentvalue',val);

    % Reset 'Go to ROI' context menu
    update_slice_context_menus(hObj);

    % Reset the 'Order' context menu
    update_order_context_menus(hObj);

end %roi_listbox_Callback