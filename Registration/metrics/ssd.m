function varargout = ssd(im1,im2,varargin)
%ssd  Computes the sum of squared differences between two images
%
%   D = ssd(I1,I2) computes the sum of squared differences (D) between two
%   images, I1 and I2. Both images must be the same size. Pixel values less than
%   0 or NaNs are ignored.

% Deal the outputs and validate the input images
[varargout{1:nargout}] = deal([]);
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

varargout{1} = sum( (im1(:)-im2(:)).^2 );