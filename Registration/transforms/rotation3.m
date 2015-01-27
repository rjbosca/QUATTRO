function I = rotation3(w,I,R)
%rotation3  Performs a 3D rotation transformation
%
%   rotation3(w,I,R) performs a 3D rotation transformation on the image I using
%   the resampler R and transformation vector w where the entries of w are as
%   follows: 
%
%       Postion     Description
%       -----------------------
%         w(1)      Rotation about the z axis in degrees
%
%         w(2)      Rotation about the y axis in degrees
%
%         w(3)      Rotation about the z axis in degrees
%
%   See also rotation2 rigid2 rigid3 makeresampler

% Determine center of image
c = (size(I)+1)/2;

% Get transformation
h = makehgtform('translate',c,...        translate center of image to the origin
                'zrotate',pi/180*w(1),...perform rotation about z-axis
                'yrotate',pi/180*w(2),...perform rotation about y-axis
                'xrotate',pi/180*w(3),...perform rotation about x-axis
                'translate',-c);        %bottom left corner of the image back to
                                        %the origin
tform = fliptform( maketform('affine',h') );

% Perform transformation
I = tformarray(I,tform,R,1:3,1:3,size(I),[],-100);