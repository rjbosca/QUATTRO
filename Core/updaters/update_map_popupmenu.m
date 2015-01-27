function update_map_popupmenu(hFig,obj)
%update_map_popupmenu  Modifies map pop-up menu properties
%
%   update_map_popupmenu(H) updates the "Maps" pop-up menu according to the
%   current GUI state. H is the QUATTRO figure handle.
%
%   update_map_popupmenu(H,OBJ) is a shortcut to the previous syntax where OBJ
%   is the qt_exam object for the current exam

    % Get some handles
    if nargin==1
        obj = getappdata(hFig,'qtExamObject');
    end
    hPop    = findobj(hFig,'Tag','popupmenu_maps');

    % Modify properties as necessary
    names  = [{''};obj.mapNames];
    nNames = numel(names);
    if get(hPop,'Value')>nNames
        set(hPop,'Value',1);
    end
    set(hPop,'String',names,'Max',nNames,'Enable','on')
    if numel(names)==1 %no maps
        set(hPop,'String',names,'Enable','off');
    end

end %update_map_popupmenu