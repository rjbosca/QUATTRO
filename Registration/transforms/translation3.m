function I = translation3(w,I,R)
%translation3  Performs a 3D translation transformation
%
%   translation3(w,I,R) performs a 3D translation transformation on the image I
%   using the resampler R and transformation vector w where the entries of w are
%   as follows:
%
%       Postion     Description
%       -----------------------
%         w(1)      Translation in the x direction
%
%         w(2)      Translation in the y direction
%
%         w(3)      Translation in the z direction

% Get transformation
h = makehgtform('translate',w);
tform = fliptform( maketform('affine',h') );

% Perform transformation
I = tformarray(I,tform,R,1:3,1:3,size(I),[],-100);