function options_key_press_Callback(hObj,eventdata)
%options_key_press_Callback  Callback for handling 'esc' and 'enter' key events

switch eventdata.Key
    case 'escape'
        delete(hObj);
    case 'enter'
        hs = guihandles(hObj);
        accept_options_Callback(hs.pushbutton_accept);
        delete(hObj);
end