function d = ncc(im1,im2)
%ncc  Normalized cross correlation
%
%   D = ncc(I1,I2) calculates the normalized cross correlation of the two images
%   I1 and I2 where the normalized cross-correlation is given by
%
%                 <I1,I2>
%       NCC = ---------------
%             ||I1|| * ||I2||

% Initialize the output and validate the input images
d = [];
if isempty(im1) || isempty(im2)
    return
end

% Remove 'ignore' values
ignoreMask = (im2<0 | im1<0 | isnan(im1) | isnan(im2)); % mask for ignore values
im1(ignoreMask) = []; im2(ignoreMask) = [];
if ~any(im1(:)) || ~any(im2(:))
    d = inf;
    return
end

% Calculation
d = 1 - (im1(:)'*im2(:)/norm(im2(:)))^2 / (im1(:)'*im1(:));