function newoptimizer(src,eventdata)
%newoptimizer  PostSet event for qt_reg property "optimizer"
%
%   newoptimizer(SRC,EVENT)

    % Grab the qt_reg object
    obj = eventdata.AffectedObject;

    % Validate the input string
    try
        validatestring(obj.interpolation,{'reg-grad-step'});
    catch ME
        if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
            obj.optimizer = 'reg-grad-step';
            warning(['qt_reg:' src.Name ':invalidDir'],'%s %s\n%s\n',...
                    obj.interpolation,'is an invalid optimizer setting.',...
                    'Default setting restored: ''reg-grad-step''');
        else
            rethrow(ME)
        end
    end

end %qt_reg.newoptimizer