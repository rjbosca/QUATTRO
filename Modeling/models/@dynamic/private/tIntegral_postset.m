function tIntegral_postset(obj,src,eventdata)
%tIntegral_postset  PostSet event for dynmic property "tIntegral"
%
%   tIntegral_postset(OBJ,SRC,EVENT) updates the protected dynamic object, OBJ,
%   property "iaucParams". SRC and EVENT are unused.

    % Update the parameter names in the "iaucParams" property
    obj.iaucParams = arrayfun(@(x) sprintf('IAUC%.0f',x),obj.tIntegral,...
                                                         'UniformOutput',false);

    % Update the units. Since old IAUC parameter names might exist in the
    % "paramUnits" property, remove those values first
    flds           = fieldnames(obj.paramUnits);
    rmIdx          = cellfun(@(x) ~isempty(x) && (x==1),strfind(flds,'IAUC'));
    obj.paramUnits = rmfield(obj.paramUnits,flds(rmIdx));
    for p = obj.iaucParams
        obj.paramUnits.(p{1}) = '';
    end

end %dynamic.tIntegral_postset