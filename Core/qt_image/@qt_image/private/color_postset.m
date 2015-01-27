function color_postset(obj,src,event)
%color_postset  PostSet event for qt_image "color" property
%
%   color_postset(OBJ,SRC,EVENT)

    % Determine if any of the images are being displayed currently. In that
    % case, update the display to ensure proper display of the image using the
    % (potentially) new color map 
    if ~isempty(obj.imgViewObj)
        obj.show;
    end

end %qt_image.color_postset