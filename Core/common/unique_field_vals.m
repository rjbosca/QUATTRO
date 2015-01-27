function n = unique_field_vals(s,fld)
%unique_field_vals  Determines the number of unique field values in a structure
%
%   n = unique_field_vals(S,fld) determines the number of unique values for
%   the specified field, fld, in the structure S.

% Stores all values in the field, fld
vals = {s.(fld)};
if ~ischar(vals{1})
    vals = cell2mat(vals);
end

% Finds the total number of unique values
n = numel( unique(vals) );