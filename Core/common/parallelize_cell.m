function y_cell = parallelize(y,dim)
%parallelize  Makes an array compatabile for parallel computations.
%   A = parallelize(A) converts the array A into a parallel compatable cell
%   array. The array is partitioned along the dimension (default: first
%   non-singleton dimension) for parallel computation, while the contents
%   of each cell are formatted for parallel computation. All other array 
%   dimensions retain their original sizes.

% Initialize
if ~exist('dim','var')
    dim = 1;
end
m = size(y);
% np = matlabpool('size');
np = 3;
div = floor(size(y,dim)/np);

% Create eval string
for i = 1:np
    str = 'y(';
    ind1 = div*(i-1)+1;
    if i==np
        ind2 = 'end';
    else
        ind2 = div*i;
    end
    for j = 1:length(m)
        if j==dim
            str = [str num2str(ind1) ':' num2str(ind2) ','];
        else
            str = [str ':,'];
        end
    end
    str(end) = ')'; y_cell{i} = eval(str);
end