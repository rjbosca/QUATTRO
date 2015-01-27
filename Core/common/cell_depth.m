function n = cell_depth(c)
%cell_depth  Determine the level of cell nesting
%
%   N = cell_depth(C) determines the number, N, of nested cells in the cell
%   array specified by C. Empty cells return a depth of 0.

    if iscell(c)
        n = cellfun(@cell_depth,c,'UniformOutput',false);
        n = n(~cellfun(@isempty,n));
        n = cell2mat(n);
        n = max(n(:))+1;
    else
        n = 0;
    end

end %cell_depth