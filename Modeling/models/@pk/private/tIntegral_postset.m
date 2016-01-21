function tIntegral_postset(obj,src,eventdata)
%tIntegral_postset  PostSet event for pk_model property "tIntegral"
%
%   tIntegral_postset(OBJ,SRC,EVENT) updates the protected pk object, OBJ,
%   property "bniaucParams". SRC and EVENT are unused

    % Update the parameter names in the "bniaucParams" property
    obj.bniaucParams = arrayfun(@(x) sprintf('BNIAUC%.0f',x),obj.tIntegral,...
                                                         'UniformOutput',false);

    % Update the units. Since old IAUC parameter names might exist in the
    % "paramUnits" property, remove those values first
    flds           = fieldnames(obj.paramUnits);
    rmIdx          = cellfun(@(x) ~isempty(x) && (x==1),strfind(flds,'BNIAUC'));
    obj.paramUnits = rmfield(obj.paramUnits,flds(rmIdx));
    for p = obj.bniaucParams
        obj.paramUnits.(p{1}) = '';
    end

end %pk.tIntegral_postset