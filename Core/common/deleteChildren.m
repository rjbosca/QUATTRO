function deleteChildren(h_axes,child_type)
%DELETECHILDREN  Removes children from specified axes.
%   deleteChildren(H,TYPE) finds all children of H with either a 'Tag' or
%   'Type' property specified by the string TYPE and deletes them. Multiple
%   inputs can be specified using a cell array of strings.

% Converts single input
if ~iscell(child_type) && ischar(child_type)
    child_type = {child_type};
end

% Gets children of h_axes
ind = strcmpi('ROI',child_type);
if any(ind)
    child_type(ind) = [];
    child_type(end+1:end+5) = {'imellipse','imspline','impoly','impoint','imrect'};
end

% Gets handles of objects to delete
hgos = [];
for i = 1:length(child_type)
    hgos = [hgos; findobj(h_axes,'Tag',child_type{i})];
    hgos = [hgos; findobj(h_axes,'Type',child_type{i})];
end

% Deletes all other children
for i = 1:length(hgos)
    delete(hgos(i));
end