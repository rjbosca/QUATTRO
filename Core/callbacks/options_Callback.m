function options_Callback(hObj,eventdata)
%options_Callback  Callback for handling option requests
%
%   options_Callback(H,EVENT) callback for the various option menus of QUATTRO,
%   where H is the menu handle and EVENT is the event data object associated
%   with the user interaction (currently unused).

    % Get the options object
    obj = getappdata(gcbf,'qtExamObject');

    switch get(hObj,'Tag')
        case 'menu_exam_options'
            % Displays exam specific options for user
            h = eval([obj.type 'optsgui(obj)']);

        case 'menu_map_options'
            % Run parameter option GUI
            h = mapoptsgui( obj );

        case 'menu_preferences'
            % Run option GUI
            h = useroptsgui( obj );

    end

    % Wait for GUI to close
    uiwait(h);

end %options_Callback