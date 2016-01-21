function s = empty_nested_struct(s)
%empty_nested_struct  Stores empty data in all fields of a nested structure
%
%   S = empty_nested_struct(S) finds all non-structure data in the structure S,
%   replacing that data with a null value of the same type. S must be a scalar
%   stucture array

    % Only scalar inputs are valid
    if (numel(s)>1)
        error(['QUATTRO:' mfilename ':nonScalarStruct'],...
              '%s only supports scalar structure arrays.',mfilename);
    end

    % Determine all fields that must be searched
    flds = fieldnames(s)';

    % Loop through the fields to determine if nested structures exist
    for fld = flds

        % Recursively call empty_nested_struct to search nested fields
        if isstruct( s.(fld{1}) )
            s.(fld{1}) = empty_nested_struct(s.(fld{1}));
        else
            fldClass   = class(s.(fld{1}));
            s.(fld{1}) = eval([fldClass '([])']);
        end

    end

end %empty_nested_struct