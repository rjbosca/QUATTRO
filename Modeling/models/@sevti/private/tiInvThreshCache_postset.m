function tiInvThreshCache_postset(obj,~,~)
%tiInvThreshCache_postset  Post-set event for SEVTI property "tiInvThreshCache"
%
%   tiInvThreshCache_postset(OBJ,SRC,EVENT) updates the SEVTI "inversionMask"
%   property. When "autoGuess" is TRUE, the "internal" TI inversion threshold is
%   used, otherwise the user-specified threshold is used.

    if isempty(obj.x)
        return
    end

    % Initialize the workspace
    mask = obj.inversionMask;
    if isempty(mask)
        mask = false(size(obj.x));
    end
    
    % Update the appropriate property
    if obj.autoGuess

        % Cache the new mask
        obj.inversionMask = (obj.x<obj.tiInvThreshCache.internal);

        % Update the modeling object if needed
        if any(mask~=obj.inversionMask)
            notify(obj,'updateModel');
        end

    else

        % Cache the new mask
        obj.inversionMask = (obj.x<obj.tiInvThreshCache.user);

        % Update the modeling object if needed. Unlike the case above, when the
        % user specifies a null TI, the T1 guess should also be updated. This
        % also notifies the "updateModel" event via post-set listeners.
        if any(mask~=obj.inversionMask)
            obj.paramGuess.T1 = obj.tiInvThreshCache.user/log(2);
        end
        
    end

end %tiInvThreshCache_postset