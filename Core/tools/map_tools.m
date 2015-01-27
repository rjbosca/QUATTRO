function map_tools(hQt)
%map_tools  Builds QUATTRO parameter map tools
%
%   map_tools(H) creates the parameter map tools, namely a UI panel containing
%   the selection pop-up menu for the instance of QUATTRO specified by the
%   handle H

    % Verify input
    if isempty(hQt) || ~ishandle(hQt) || ~strcmpi(get(hQt,'Name'),qt_name)
        error(['QUATTRO:' mfilename 'qtHandleChk'],...
                                            'Invalid handle to QUATTRO figure');
    end

    % Prepare UI panel display
    hUip = uipanel('Parent',hQt,...
                   'Position',[135 20 115 50],...
                   'Tag','uipanel_maps',...
                   'Title','Parameter Maps',...
                   'Visible','off');

    % Prepare tools
    uicontrol('Parent',hUip,...
              'Callback',@parameter_maps_Callback,...
              'Position',[10 10 95 20],...
              'BackgroundColor',[1 1 1],...
              'ForegroundColor',[0 0 0],...
              'String',{''},...
              'Style','popupmenu',...
              'Tag','popupmenu_maps',...
              'Value',1);

end %maps_tools


%-----------------------Callback/Ancillary Functions----------------------------

function parameter_maps_Callback(hObj,eventdata) %#ok<*INUSD>

    % Validate that the value has been changed
    val = get(hObj,'Value');
    if getappdata(hObj,'currentvalue')==val
        return
    end

    % Get exams object and update the "mapIdx" property with the new value
    obj        = getappdata(gcbf,'qtExamObject');
    obj.mapIdx = val-1; %reduce by 1 to account for the empty string (val==1)

    % Determine the requested map already exists. If so, bring the figure into
    % focus; there is no need to construct a new overlay viewer. Otherwise,
    % create a new qmaptool figure
    isExtFig = false; %initialize
    if ~isempty(obj.hExtFig)
        % Since the handle "get" method will return a string if only one handled
        % is provided, also include the QUATTRO handle to ensure a cell is
        % returned. Since the 
        hFigs    = [obj.hFig;obj.hExtFig];
        isExtFig = arrayfun(@(x) ~isempty(findobj(x,'Tag',obj.map.tag)),hFigs);
    end
    if any(isExtFig(:))
        figure( hFigs(isExtFig) );
    else
        qmaptool(obj);
    end

end %parameter_maps_Callback