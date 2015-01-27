function strct = rmfields(strct,flds)
%rmfields  Removes fields from a structure array
%
%   S = rmfields(S,FIELD) removes the field name specified by the string FIELD
%   from the structure S, returning the new structure. S is otherwise preserved.
%   This is the same functionality as the built-in function "rmfield", but the
%   field name is validated before attempting to remove it.
%
%   S = rmfields(S,FIELDS) performs the above operations for each field name
%   string specified in the cell array FIELDS.
%
%   See also rmfield

    if ~iscell(flds) && ischar(flds)
        flds = {flds};
    end

    for fldIdx = flds(:)'
        if isfield(strct,flds{1})
            strct = rmfield(strct,flds{1});
        end
    end

end %rmfields