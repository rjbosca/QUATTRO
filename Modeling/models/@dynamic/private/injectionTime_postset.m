function injectionTime_postset(obj,~,~)
%injectionTime_postset  Post-set event for DYNAMIC property "injectionTime"
%
%   injectionTime_postset(OBJ,SRC,EVENT)

    % Validate the recirculation index. Warn the user and update the value if it
    % is less than (or equal) to the number of pre-enhancement images
    isResetRecirc = ~isempty(obj.recircTime) && (obj.recircTime<=obj.injectionTime);
    if  isResetRecirc && ~isempty(obj.x)
        warning(['dce:' mfilename ':invalidRecirculationIndex'],...
                ['The recirculation time is less than or the same as the ',...
                 'injection time. Resetting "injectionTime" to %.0fs and ',...
                 '"recircTime" to %.0fs.'],obj.x(2),obj.x(end));
        obj.injectionTime = obj.x(2);
        obj.recircTime    = obj.x(end);
    elseif isResetRecirc && isempty(obj.x)
        %TODO: define the warning
    end

    % Update the integration start time
    if isempty(obj.tIntStart) && ~isempty(obj.injectionTime)
        obj.tIntStart = obj.injectionTime;
    end

    % Reset "preIndsCache"
    obj.preIndsCache = false( size(obj.x) );

    % Notify any model updaters
    notify(obj,'updateModel');

end %dynamic.injectionTime_postset