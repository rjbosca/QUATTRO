function I = rotation2(w,I,R)
%rotation2  Performs a 2D rotation transformation
%
%   rotation2(w,I,R) performs a 2D rotation transformation on the image I using
%   the resampler R and transformation vector w where the entries of w are as
%   follows: 
%
%       Postion     Description
%       -----------------------
%         w(1)      Rotation about the z axis in degrees
%
%   See also rotation3 rigid2 rigid3 makeresampler

% Get transformation
h = makehgtform('zrotate',pi/180*w);
h(3,:) = []; h(:,3) = []; %remove z component of transform
tform = fliptform( maketform('affine',h') );

% Perform transformation
I = tformarray(I,tform,R,1:2,1:2,size(I),[],-100);