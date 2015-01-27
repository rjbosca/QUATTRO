function windowbtnup_postset(src,eventdata)
%windowbtnup_postset  PostSet event for figure property "WindowButtonUpFcn"
%
%   windowbtnup_postset(SRC,EVENT)

    warning(['qt_image:' mfilename ':btnUpNotification'],...
             'The function handle for ''WindowButtonUpFcn'' has changed');

end %qt_image.windowbtnup_postset