function DI = calcDiffImage(I1, I2)
%DIFFIMAGE  Calculate the difference of two images.
%
%   DI = calcDiffImage(I1,I2) calculates the difference between images I1
%   and I2.

is_image = (isnumeric(I1) && isnumeric(I2)) ||...
           (ndims(I1)==2 || ndims(I2)==2);
if ~is_image
    DI = [];
    return;
end

% Converts I1 and I2 to double
I1 = double(I1);
I2 = double(I2);

% Ensures the minimums of IMAGE1 and IMAGE2 are zero
I1 = I1 - min(I1(:));
I2 = I2 - min(I2(:));

% Normalizes IMAGE2 to the pixel range of IMAGE1
I2 = I2 * max(I1(:))/max(I2(:));

% Calculates the difference 
DI = I1 - I2;