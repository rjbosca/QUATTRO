function maps_postset(obj,src,eventdata)
%maps_postset  PostSet event for qt_exam "maps" property
%
%   maps_postset(OBJ,SRC,EVENT)

    % Get the map value. This will be needed below
    val = obj.map;

    % Set basic existence properties
    obj.exists.maps.any     = ~isempty(obj.maps);
    obj.exists.maps.current = (iscell(val) && ~isempty(val)) ||...
                                                 strcmpi(class(val),'qt_image');

end %qt_exam.maps_postset