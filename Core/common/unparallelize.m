function y = unparallelize(y,m,d)
%unparallelize  Reverses data organization performed by parallelize
%
%   A = unparallelize(A,M) reverts the array A from a parallel compatable
%   array to the original size M.
%
%   A = unparallelize(A,M,DIM) reverts the array A from a parallel compatable
%   array to the original size reording the dimensions according to the input
%   DIM. This input should correspond to the value used with parallelize.
%
%   See also parallelize

if nargin==2
    d = 1;
end

% Determine the number of NaN values that were used for filling
nY     = numel(y);
nYOrig = prod(m);
nRm    = nY - nYOrig;

% Permute to the size dimensionality specified by the user
permIdx          = 1:ndims(y);
permIdx(1+[1 d]) = 1+[d 1];
y = permute(y,permIdx);

% Permute the slice index (dim 1) and the sliced dimension (dim 2), remove
% null-padding
y = permute(y,[2 1 3:ndims(y)]);
y = y(:);
y(end-nRm+1:end) = [];

% Reshapes array to original size
y = reshape(y,m);