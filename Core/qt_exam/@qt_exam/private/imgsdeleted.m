function imgsdeleted(obj,src,eventdata)
%imgsdeleted  qt_exam 'imgDeleted' event handler
%
%   imgsdeleted(OBJ,SRC,EVENT) updates image existence field and collapses the
%   qt_exam image storage property - "imgs".

    % Validate the event
    if ~strcmpi(eventdata.EventName,'imgDeleted')
        warning(['qt_exam:' mfilename ':invalidEvent'],...
                 '%s is only defined for the qt_exam event "imgDeleted"',...
                                                                     mfilename);
        return
    end

    % Get the image array and a mask of valid imgs
    imgs = src.imgs;

    % Update the existence field
    obj.exists.images.any = any( imgs(:).isvalid );
    obj.exists.any        = obj.exists.images.any || obj.exists.rois.any;
    if ~obj.exists.images.any
        src.imgs = qt_image.empty(1,0);
        return
    end

    %TODO: at the time I wrote this code, there was no way for users to delete
    %individual images. In the future, I should address this...

end %qt_exam.imgsdeleted