function windowbtndown_postset(src,eventdata)
%windowbtndown_postset  PostSet event for figure property "WindowButtonDownFcn"
%
%   windowbtndown_postset(SRC,EVENT)

    warning(['qt_image:',mfilename  ':btnDownNotification'],...
             'The function handle for ''WindowButtonDownFcn'' has changed');

end %qt_image.windowbtndown_postset