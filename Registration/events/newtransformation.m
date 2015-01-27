function newtransformation(src,eventdata)
%newtransformation  PostSet event for qt_reg property "transformation"
%
%   newtransformation(SRC,EVENT)

    % Grab the qt_reg object
    obj = eventdata.AffectedObject;

    % Validate the input string
    try
        validatestring(obj.transformation,{'rigid','affine'});
    catch ME
        if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
            warning(['qt_reg:' src.Name ':invalidDir'],'%s %s\n%s\n',...
                    obj.transformation,'is an invalid transformation setting.',...
                    'Default setting restored: ''rigid''');
            obj.transformation = 'rigid';
        else
            rethrow(ME)
        end
    end

end %qt_reg.newtranformation