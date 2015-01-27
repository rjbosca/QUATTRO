function qtroi_position_postset(obj,src,eventdata)
%qtroi_position_postset  PostSet event for qt_roi property "position"
%
%   qtroi_position_postset(OBJ,SRC,EVENT) is an event listener added to the
%   qt_roi object by the roiview object (OBJ) constructor that updates the ROI
%   extent (type 'help roiview.roiExtent for more information)

    % Validate the event source
    if ~strcmpi(src.Name,'position')
        error('qt_roi:roiview:invalidEventCall','%s\n%s',...
              'Only "position" PostSet qt_roi event calls',...
              'to "getroiextent" are allowed');
    end

    % Get the scaled vertices and store in the "roiExtent" property
    obj.calcroiextent;

end %roiview.qtroi_new_position