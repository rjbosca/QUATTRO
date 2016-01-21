function format_postset(obj,source,eventdata)
%format_postset  Post-set event for qt_rerport property "format"
%
%   format_postset(OBJ,SRC,EVENT)

    % Validate the new value
    try
        s = validatestring(obj.format,{'html','pdf'});
    catch ME
        warning(['qt_report:' mfilename ':errorSettingFormat'],...
                ['An error occured while setting the property "format":',...
                 '\n\n%s\n\nThe default, ''%s'', has been restored.'],...
                                                ME.message,source.DefaultValue);
    end

    % Update all the report parts
    obj.plots  = cellfun(@(x) update_format(x,s),obj.plots,...
                                                         'UniformOutput',false);
    obj.tables = cellfun(@(x) update_format(x,s),obj.tables,...
                                                         'UniformOutput',false);

end %qt_report.format_postset


%------------------------------------
function objs = update_format(objs,s)
    if (numel(objs)>0)
        [objs.format] = deal(s);
    end
end %update_format