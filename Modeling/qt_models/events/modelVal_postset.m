function modelVal_postset(src,eventdata)
%modelVal_postset  PostSet event for qt_models property "modelVal"
%
%   modelVal_postset(SRC,EVENTDATA) performs validation on the qt_models
%   property "modelVal"

    % Grab the modeling object, the new value, and the number of selectable
    % models
    obj         = eventdata.AffectedObject;
    val         = obj.(src.Name);
    nModelNames = numel(obj.modelNames);

    % Determine if value is within range
    if (val < 1)
        obj.modelVal = 1;
        warning('qt_models:invalidModelVal',...
                ['%s must be an integer greater than or equal to 1.\n',...
                 'The value has been reset to 1.\n'],src.Name);
    elseif (val > nModelNames)
        obj.modelVal = nModelNames;
        warning('qt_models:invalidModelVal',...
               ['%s must be an integer less than or equal to %d.\n',...
                'The value has been reset to 1.'],src.Name,nModelNames);
    end

    % Validate that the input is an integer
    if mod(val,round(val))
        obj.modelVal = round(val);
        warning('qt_models:nonIntModelVal','%s %s\n%s %d.',...
                                    src.Name,'must be a positive integer.',...
                                    'The value has been reset to',obj.modelVal);
    end

    % All validation has occured at this point, so update the model if necessary
    %TODO: do we really need to have this if statement? Can't I just use the
    %"update" method?
    if obj.autoFit
        obj.update;
    else
        obj.show;
    end

end %qt_models.modelVal_postset