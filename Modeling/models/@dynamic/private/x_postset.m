function x_postset(obj,src,eventdata)
%x_postset  PostSet event for modelbase "x" property
%
%   x_postset(OBJ,SRC,EVENT)

    % Update the integration start time using the "injectionTime" if the value
    % has not been defined previously
    if isempty(obj.tIntStart) && ~isempty(obj.injectionTime)
        obj.tIntStart = obj.injectionTime;
    end

    % Update the integration start time using the "injectionTime" if the value
    % has not been defined previously
    if isempty(obj.recircTime)
        obj.recircTime = obj.x(end);
    end

    % Initialize some of the caches
    [obj.preIndsCache,obj.firstPassIndsCache] = deal( false(size(obj.x)) );

end %dynamic.x_postset