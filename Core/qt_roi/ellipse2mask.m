function mask = ellipse2mask(pos,s)
%ellipse2mask  Creates a mask from an imellipse position vector
%
%   MASK = ellipse2mask(POS,S) returns a mask of size S created from the
%   ellipse position vector [XMIN YMIN WIDTH HEIGTH].

% Approximate polygon
verts = ellipse2verts(pos);

% Converts vertices to mask
mask = poly2mask(verts(:,1),verts(:,2),s(1),s(2));