function varargout = msd(im1,im2,varargin)
%msd  Computes the mean sum of squared differences
%
%   D = msd(I1,I2) computes the mean sum of squared differences between two
%   images, I1 and I2. Both images must have the same size. Pixels having a
%   value less than 0 or NaN are ignored in the computation.

% Initialize the output and validate the input images
if isempty(im1) || isempty(im2)
    return
end

% Remove 'ignore' values
ignoreMask = (im2<0 | im1<0 | isnan(im1) | isnan(im2)); % mask for ignore values
im1(ignoreMask) = []; im2(ignoreMask) = [];
if ~any(im1(:)) || ~any(im2(:))
    varargout{1} = inf;
    return
end

varargout{1} = 1/numel(im1(:)) * sum( (im1(:)-im2(:)).^2 );