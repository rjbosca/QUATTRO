function imgs_postset(obj,~,~)
%imgs_postset  Post-set event for QT_EXAM "imgs" property
%
%   imgs_postset(OBJ,SRC,EVENT)

    % Set basic existence properties
    [obj.exists.images.any,obj.exists.any] = deal(~isempty(obj.image));


    %TODO: the call to a non-existent event "registerRois" was deleted and there
    %is currently no action performed in this post-set event callback. Determine
    %what to do with this function (i.e., keep or delete).
    if obj.exists.images.any && obj.exists.rois.any
    end

end %qt_exam.imgs_postset