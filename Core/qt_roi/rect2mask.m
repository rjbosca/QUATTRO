function mask = rect2mask(pos,s)
%rect2mask  Creates a rectangular mask
%
%   MASK = rect2mask(POS,S) returns a mask of size S created from the rectangle
%   position vector [XMIN YMIN WIDTH HEIGTH].

% Convert position to verticies
verts = rect2verts(pos);

% Convert x-y coordinates to a mask
mask = poly2mask(verts(:,1), verts(:,2), s(1), s(2));