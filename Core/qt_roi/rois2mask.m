function mask = rois2mask(v,t,m)
%rois2mask  Create an image mask from the ROI verticies
%
%   MASK = rois2mask(VERTS,TYPE,M) generates MASK, a binary image of size M,
%   using the verticies specified by VERTS from one of the ROI constructors
%   (imrect, impoly, etc.) as specified by the string TYPE.

    switch t
        case 'imrect'
            mask = rect2mask(v,m);
        case 'imellipse'
            mask = ellipse2mask(v,m);
        otherwise
            mask = poly2mask(v(:,1),v(:,2),m(1),m(2));
    end

end %rois2mask