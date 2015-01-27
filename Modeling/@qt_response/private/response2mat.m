function val = response2mat(obj,y)
%response2mat  Converts a non-numeric model response to a numeric array
%
%   val = response(Y) converts the cell array of response Y to a numeric array
%   using the "catNames" property

% Do nothing for numeric arrays
val = y;
if isnumeric(y)
    return
end

% Loop through all of the category names
for cIdx = 1:obj.k
    [val{strcmpi(obj.catNames{cIdx},val)}] = deal(cIdx);
end

% Convert the cell containing numbers to an array
val = cell2mat(val);