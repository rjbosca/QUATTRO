function windowbtnmotion_postset(src,eventdata)
%windowbtnmotion_postset  PostSet event for figure property "WindowButtonMotionFcn"
%
%   windowbtnmotion_postset(SRC,EVENT)

    warning(['qt_image:' mfilename ':btnMotionNotification'],...
             'The function handle for ''WindowButtonMotionFcn'' has changed');

end %qt_image.windowbtnmotion_postset