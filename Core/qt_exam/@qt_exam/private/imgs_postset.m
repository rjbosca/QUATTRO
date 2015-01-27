function imgs_postset(obj,src,eventdata)
%imgs_postset  PostSet event for qt_exam "imgs" property
%
%   imgs_postset(OBJ,SRC,EVENT)

    % Set basic existence properties
    [obj.exists.images.any,obj.exists.any] = deal(~isempty(obj.image));

    % Register the ROIs with their respective image objects if they exist
    if obj.exists.rois.any && obj.exists.images.any
        notify(obj,'registerRois');
    end

end %qt_exam.imgs_postset