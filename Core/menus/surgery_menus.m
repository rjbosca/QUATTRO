function surgery_menus(h)
%surgery_menus  Creates menus associated with surgery tools
%
%   surgery_menus(h) creates the "Drop Target" context menu and associates that 
%   with the pushbutton specified by the handle h.

% Verify input
if ~ishandle(h) || ~strcmpi(get(h,'Style'),'pushbutton')
    error(['QUATTRO:' mfilename ':handleChk'],...
        'An invalid handle or handle to an incorrect UI control was provided.');
end

% Find QUATTRO figure
hQt = get(get(h,'Parent'),'Parent');

% Create parent menus
h_cmenu = uicontextmenu('Parent',hQt,...
                        'Tag','uicontextmenu_surgery');
uimenu(h_cmenu,'Callback',@drop_target_Callback,...
               'Label','Drop Target',...
               'Tag','context_drop_target');

% Associate menu
set(h,'UIContextMenu',h_cmenu);


%------------------------------Callback Functions-------------------------------

    function drop_target_Callback(hObj,eventdata,varargin) %#ok

        % Get GUI position
        obj = getappdata(hQt,'qtExamObject');
        pos = obj.sl_index; m = obj.scale;
        pos(3) = m(3) - pos(3)+1; pos = pos./m;
        obj.create('regions',struct('coordinates',pos,'types','impoint',...
                                                             'colors',[1 0 0]));

        % Update UI controls
        update_controls(hQt,'enable');
        obj.show('rois','crosshairs');

    end %drop_target_Callback

end %surgery_exam