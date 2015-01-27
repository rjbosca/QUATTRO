function newappdir(src,eventdata)
%newappdir  PostSet event for qt_reg property "appDir"
%
%   newappdir(SRC,EVENT)

    % Grab the qt_reg object
    obj = eventdata.AffectedObject;

    % Validate the directory
    if ~exist(obj.appDir,'dir')
        warning(['qt_reg:' src.Name ':invalidDir'],'%s %s\n%s: %s\n',...
                           obj.appDir,'is an invalid directory.',...
                           'Default setting restored',qt_path('appdata'));
        obj.appDir = qt_path('appdata');
    end

end %qt_reg.newappdir