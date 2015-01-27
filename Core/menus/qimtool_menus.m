function qimtool_menus(hQim)
%qimtool_menus  Builds quantitative image modeling tool (QIM) menus
%
%   qimtool_menus(H) attaches QIM specific menus to the QIM GUI specified by the
%   figure handle H

% Validate the handle input
if isempty(hQim) || ~ishandle(hQim) ||...
                              ~strcmpi(get(hQim,'Name'),'QUATTRO:: Modeling ::')
    error(['QUATTRO:' mfilename ':invalidQimHandle'],...
                                         'Invalid handle to a qimtool figure.');
end

% Determine if there is a linked figure handle to QUATTRO. This determines (at
% least for now) the menu visibility
hQt    = getappdata(hQim,'linkedfigure');
if ~isempty(hQt)
    visStr = 'on';
end

% Options menu
hOpts = uimenu(hQim, 'Label','Options',...
                     'Tag',  'menu_options',...
                     'Visible',visStr);
        uimenu(hOpts,'Callback',@menu_link_quattro,...
                     'Checked','on',...
                     'Label','Link to QUATTRO',...
                     'Tag','menu_link_quattro');

end %qimtool_menus


%-----------------------Callback/Ancillary Functions----------------------------

function menu_link_quattro(hObj,eventdata)

    
end %menu_link_quattro