function I = translation2(w,I,R)
%translation2  Performs a 2D translation transformation
%
%   translation2(w,I,R) performs a 2D translation transformation on the image I
%   using the resampler R and transformation vector w where the entries of w are
%   as follows:
%
%       Postion     Description
%       -----------------------
%         w(1)      Translation in the x direction
%
%         w(2)      Translation in the y direction
%
%
%   See also translation3

% Get transformation
h = makehgtform('translate',[w 0]);
h(3,:) = []; h(:,3) = []; %remove z component of transform
tform = fliptform( maketform('affine',h') );

% Perform transformation
I = tformarray(I,tform,R,1:2,1:2,size(I),[],-100);