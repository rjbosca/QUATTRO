function y = parallelize(varargin)
%parallelize  Slices arrays for parallel computation
%
%   A = parallelize(A,N) reshapes and NaN fills the array A by partitioning
%   along the first non-singleton dimension into N slices, resulting in
%   size(A,1)==N. The second 
%   non-singleton dimension is reformatted and zero-filled to such that
%   numel(A)==prod(size(A)). All other array dimensions are unchanged.
%
%   A = parallelize(A,N,DIM) specifies the dimension, DIM, used to create the
%   sliced output array. The input N can be specified as an empty array
%
%   See also parallelize_cell

    % Parse the inputs
    [y,d,np] = parse_inputs(varargin{:});

    % Initialize some array info
    nY = numel(y);
    mY = size(y);
    if (mY(d)<np)
        error(['QUATTRO:' mfilename ':dimToSmall'],...
                'The number of slices must not exceed the dimension to slice.');
    end

    % For slicing dimensions other than 1, create a vector for permuting the
    % dimensions according to the slicing dimension d
    permIdx        = 1:ndims(y);
    permIdx([1 d]) = [d 1];
    y              = permute(y,permIdx);
    mY             = mY(permIdx);

    % Check for a 2D array. For 2D arrays, the dimension (dim=2) to slice must
    % be moved to the third dimension
    if (numel(mY)==2)
        mY(2:3) = [1 mY(2)];
        y       = permute(y,[1 3 2]);
    end

    modN = np*prod(mY(3:end));
    n    = mod(nY,modN);
    if n~=0
        n = modN-n;
    end

    % Pad the array with NaNs and reshape to the original (permuted) size
    if (n>size(y,1)) && issparse(y)
        y(end+1:end+n)   = spalloc(1,n,0);
    elseif (n>size(y,1))
        y(end+1:end+n,:) = nan;
    end
    y = reshape(y,mY);

    % Reshapes for parallel computation
    newM = [(nY+n)/(np*prod(mY(3:end))) np mY(3:end)];
    y    = permute( reshape(y,newM), [2 1 3:numel(mY)] );

    % Permute the array according to the dimension that was used for slicing
    y    = permute(y, [1 d+1 d 4:numel(mY)]);

end %parallelize

%------------------------------------------
function varargout = parse_inputs(varargin)

    % Create the parser
    parser = inputParser;
    parser.addRequired('array',@(x) isnumeric(x) && (numel(x)>1));
    parser.addOptional('np', 1,@(x) isnumeric(x) && (numel(x)<=1) && x>0);
    parser.addOptional('dim',1,@(x) isnumeric(x) && (numel(x)==1));

    % Parse and deal the inputs
    parser.parse(varargin{:});
    varargout = struct2cell(parser.Results);

end %parse_inputs