function wwwlMode_postset(obj,src,eventdata)
%wwwlMode_postset  PostSet event for qt_image "wwwlMode" property
%
%   wwwlMode_postset(OBJ,SRC,EVENT)

    % Determine if any of the images are being displayed currently. In that
    % case, update the display to ensure proper display of the image using a
    % (potentially) new WW/WL 
    if ~isempty(obj.imgViewObj)
        obj.show;
    end

end %qt_image.wwwlMode_postset