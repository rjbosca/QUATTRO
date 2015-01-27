function newmetric(src,eventdata)
%newmetric  PostSet event for qt_reg property "metric"
%
%   newmetric(SRC,EVENT)

    % Grab the qt_reg object
    obj = eventdata.AffectedObject;

    % Validate the input string
    try
        validatestring(obj.metric,{'mmi','ncc','mi'});
    catch ME
        if strcmpi(ME.identifier,'MATLAB:unrecognizedStringChoice')
            warning(['qt_reg:' src.Name ':invalidDir'],'%s %s\n%s\n',...
                    obj.metric,'is an invalid similarity metric setting.',...
                    'Default setting restored: ''mmi''');
            obj.metric = 'mmi';
        else
            rethrow(ME)
        end
    end

end %qt_reg.newmetric