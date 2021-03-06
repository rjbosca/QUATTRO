function verts = rect2verts(pos)
%rect2verts  Calculates x-y verticies of a rectangle
%
%   V = rect2verts(P) returns the x-y coordinates, V, calculated from the imrect
%   position matrix P (i.e. [XMIN YMIN WIDTH HEIGTH])
verts = [pos(1)        pos(2);...
         pos(1)        pos(2)+pos(4);...
         pos(1)+pos(3) pos(2)+pos(4);...
         pos(1)+pos(3) pos(2);...
         pos(1)        pos(2)];