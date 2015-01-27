function xi = affine3(w,x,ttype)
%affine3  Performs a 3D affine transformation
%
%   [XI,YI,ZI] = affine3(W,X) performs a 3D affine transformation on the image
%   the X, Y, and Z, coordinates specified as a 1-by-3 cell X and transformation
%   vector W given by 
%
%       W = [M11 M12 M31 M21 M22 M23 M31 M32 M33 T1 T2 T3]
%
%   where the M's refer to the scale matrix and the T's refer to the translation
%   component of the affine transformation. The outputs XI, YI, and ZI are the
%   transformed coordinates.
%
%   [...] = affine3(...,DIR) performs the operations defined previously where
%   DIR specifies the transformation direction and is either 'inv' (default) or
%   'fwd'.

% Validate transformation direction
if nargin==3
    ttype = validatestring(ttype,{'fwd','inv'});
else
    ttype = 'inv';
end

% Reshape the vector for use in maketform
w = [reshape(w(1:9),3,3)'; w(10:12)];

% Get the transformation structure
if strcmpi(ttype,'inv')
    tform = fliptform( maketform('affine',w) ); %make the transform matrix
else
    tform = maketform('affine',w);
end

% Perform transformation
[xi{1:3}] = tforminv(tform,x{:});