function makeTransparent(h_axes,child_type)
%MAKETRANSPARENT  Sets the image AlphaMap to 100% transparent.
%   mkaeTransparent(H,TYPE) finds all children of H with either a 'Tag' or
%   'Type' property specified by the string TYPE and sets the AlphaMap, if
%   available to 100% transparent. Multiple inputs can be specified using a
%   cell array of strings.

% Converts single input
if ~iscell(child_type) && ischar(child_type)
    child_type = {child_type};
end

% Gets handles of objects to delete
hgos = [];
for i = 1:length(child_type)
    hgos = [hgos; findobj(h_axes,'Tag',child_type{i})];
    hgos = [hgos; findobj(h_axes,'Type',child_type{i})];
end

% Deletes all other children
for i = 1:length(hgos)
    try
        alpha_map = get(hgos,'AlphaData');
        alpha_map(:) = 0;
    catch ME
        continue
    end
    set(hgos(i),'AlphaData',alpha_map);
end