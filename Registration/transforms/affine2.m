function xi = affine2(w,x,ttype)
%affine2  Performs a 2D affine transformation
%
%   [XI,YI] = affine2(W,X) performs a 2D affine transformation on the image
%   coordinates specified by the 1-by-2 cell X and the transformation vector W
%   given by
%
%       W = [M11 M12 M21 M22 T1 T2]
%
%   where the M's refer to the scale matrix and the T's refer to the translation
%   component of the affine transformation. The outputs XI and YI are the
%   transformed coordinates.
%
%   [...] = affine2(...,DIR) performs the operations defined previously where
%   DIR specifies the transformation direction and is either 'inv' (default) or
%   'fwd'.

% Validate transformation direction
if nargin==3
    ttype = validatestring(ttype,{'fwd','inv'});
else
    ttype = 'inv';
end

% Reshape the transformation vector for use in maketform
w = [reshape(w(1:4),2,2)'; w(5:6)];

% Get the transformation structure
if strcmpi(ttype,'inv')
    tform = fliptform( maketform('affine',w) ); %make the transform matrix
else
    tform = maketform('affine',w);
end

% Perform transformation
[xi{1:2}] = tforminv(tform,x{:});