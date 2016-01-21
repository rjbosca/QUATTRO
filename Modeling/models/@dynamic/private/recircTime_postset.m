function recircTime_postset(obj,~,~)
%recircTime_postset  PostSet event for dynamic "recircTime" property
%
%   recircTime_postset(SRC,EVENT)

    % Validate the recirculation index. Warn the user and update the value if it
    % is less than (or equal) to the number of pre-enhancement images
    isResetRecirc = ~isempty(obj.recircTime) && ~isempty(obj.injectionTime) &&...
                                            (obj.recircTime<=obj.injectionTime);
    if  isResetRecirc && ~isempty(obj.x)
        warning(['dynamic:' mfilename ':incompatibleInjectionRecircIndex'],...
                ['The recirculation time is less than or the same as the ',...
                 'injection time. Resetting "injectionTime" to %.0fs and ',...
                 '"recircTime" to %.0fs.'],obj.x(2),obj.x(end));
        obj.recircTime    = obj.x(end);
        obj.injectionTime = obj.x(2);
    elseif isResetRecirc && isempty(obj.x)
        %TODO: define the warning
    end

    % Reset "firstPassIndsCache"
    obj.firstPassIndsCache = false( size(obj.x) );

    % Notify any model updaters
    notify(obj,'updateModel');

end %dynamic.recircTime_postset