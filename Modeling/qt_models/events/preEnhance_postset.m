function preEnhance_postset(src,eventdata)
%preEnhance_postset  PostSet event for dce "preEnhance" property
%
%   preEnhance_postset(SRC,EVENT)

    % dce object alias
    obj = eventdata.AffectedObject;

    % Validate the recirculation index. Warn the user and update the value if it
    % is less than (or equal) to the number of pre-enhancement images
    if ~isempty(obj.recirc) && (obj.recirc <= obj.preEnhance)
        warning(['dce:' mfilename ':invalidRecirculationIndex'],...
                ['The recirculation index is less than or the same as the\n',...
                 'pre-enhancement index. Resetting "recirc" to\n',...
                 '%s+1 (or %u).'],src.name,obj.preEnhance+1);
        obj.recirc = obj.preEnhance+1;
    end

    % Update using the new data
    obj.update;

end %preEnhance_postset