function c = pix2phys(c,sp)
%pix2phys  Converts pixel to physical coordinates
%
%   c = pix2phys(xyz,spacing) converts the coordinates of xyz (n-by-2 or
%   n-by-3) from pixel locations to physical coordinate locations using the
%   voxel dimesions specified by spacing (1-by-2 or 1-by-3) corresponding
%   to the dimensions of xyz

% Convert coordinates
c(:,1) = sp(1) * (c(:,1)-1);
if size(c,2) > 1
    c(:,2) = sp(2) * (c(:,2)-1);
end
if size(c,2) > 2
    c(:,3) = sp(3) * (c(:,3)-1);
end