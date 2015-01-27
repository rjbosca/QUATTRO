function newstep(src,eventdata)
%newstep  PostSet event for qt_reg properties "stepSizeMin" and "stepSizeMax"
%
%   newstep(SRC,EVENT)

    % Grab the qt_reg object
    obj = eventdata.AffectedObject;

    % Check the new option against the optimizer. Not all optimizers use all qt_reg
    % properties. This notifies the user.
    % Validate the new value
    if ~strcmpi(obj.optimizer,'reg-grad-step')
        warning(['qt_reg:' src.Name ':unusedOption'],'%s %s\n',...
            src.Name, 'set but is an inconsistent optimizer option');
    end

    % Validate the input
    if strcmpi(src.Name,'stepSizeMin')

        % Validate the value according to the max
        if obj.stepSizeMin > obj.stepSizeMax
            obj.stepSizeMin = obj.stepSizeMax*10^-3;
            warning(['qt_reg:' src.Name ':invalidOption'],'%s %s\n %s %s %f\n',...
                    src.Name,'must be smaller than stepSizeMax.',...
                    src.Name,'reset to',obj.stepSizeMin);
        end

    elseif strcmpi(src.Name,'stepSizeMax')        

        % Validate the value according to the max
        if obj.stepSizeMax < obj.stepSizeMin
            obj.stepSizeMax = obj.stepSizeMin*10^3;
            warning(['qt_reg:' src.Name ':invalidOption'],'%s %s\n %s %s %f\n',...
                    src.Name,'must be greater than stepSizeMin.',...
                    src.Name,'reset to',obj.stepSizeMax);
        end

    else

    end

end %qt_reg.newstep