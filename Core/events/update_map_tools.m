function update_map_tools(src,eventdata)
%update_map_tools  Updates the QUATTRO GUI following changes to the map data
%
%   update_map_tools(SRC,EVENT)

    % Validate the event source
    if ~strcmpi(src.Name,'maps')
        error(['QUATTRO:' mfilename ':invalidEventSrc'],...
                                    'Only "maps" post-set events are allowed.');
    end

    % Grab the exam object, the rois, and some handles
    obj     = eventdata.AffectedObject;
    mapObjs = obj.maps;
    if isempty(mapObjs)
        return
    end
    maps = struct2cell( obj.maps );
    hs   = guihandles(obj.hFig);

    % Update the map panel
    if any( ~cellfun(@isempty,maps) )
        set([hs.uipanel_maps
             hs.popupmenu_maps],'Visible','on');
    else %maps do not exist; disable/hide
        set(hs.uipanel_maps,'Visible','off');
    end
    update_map_popupmenu(obj.hFig,obj);

end %update_map_tools