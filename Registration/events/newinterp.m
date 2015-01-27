function newinterp(src,eventdata)
%newinterp  PostSet event for qt_reg property "interpolation"
%
%   newinterp(SRC,EVENT)

    % Grab the qt_reg object
    obj = eventdata.AffectedObject;

    % Validate the input string
    try
        validatestring(obj.interpolation,{'nearest','linear','cubic','spline'});
    catch ME
        if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
            warning(['qt_reg:' src.Name ':invalidDir'],'%s %s\n%s\n',...
                    obj.interpolation,'is an invalid interpolator setting.',...
                    'Default setting restored: ''linear''');
            obj.interpolation = 'linear';
        else
            rethrow(ME)
        end
    end

end %qt_reg.newinterp