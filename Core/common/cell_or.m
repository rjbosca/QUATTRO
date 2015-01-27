function x_out = cell_or(x,dim)
%cell_or  Combines logical arrays stored in different cells
%
%   x = cell_or(x) performs a logical OR operation on the first
%   non-singleton dimension of the cell array x
%
%   x = cell_or(x,dim) performs a logical OR operation along the specified
%   dimension

% Initialize output and check input
x_out = [];
if ~iscell(x)
    x_out = x;
    return
elseif isempty(x)
    return
end

if nargin==1
    dim = 1;
end

num_ns = sum( size(x) ~= 1 );
if (ndims(x)==2 && num_ns == 1) || numel(x)==1
    x_out = x{1};
    for i = 2:length(x)
        x_out = x_out | x{i};
    end
elseif ndims(x)>1 && num_ns>1
    for i = 1:size(x,dim)
        x_out{i} = cell_or(x(i,:));
    end
end