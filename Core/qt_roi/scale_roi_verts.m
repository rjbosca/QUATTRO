function verts = scale_roi_verts(verts,t,m)
%scale_roi_verts  Scales ROI vertices
%
%   V = scale_roi_verts(V,T,M) scales vertices, V, according to the ROI type
%   specified by T and the coordinate space size (usually image size) M, where
%   M(1) specifies the x extent and M(2) the y extent, and M(3) the z extent.
%   Higher dimensional data sets are not currently supported

    if any( strcmpi(t,{'imellipse','imrect'}) )
        verts(1:2:end) = m(2) * verts(1:2:end);
        verts(2:2:end) = m(1) * verts(2:2:end);
    elseif strcmpi(t,'impoint')
        verts = m.*verts;
    else
        verts(:,1) = m(1) * verts(:,1);
        verts(:,2) = m(2) * verts(:,2);
    end

    if ndims(verts)>2
        verts(:,3) = m(3) * verts(:,3);
    end

end %scale_roi_verts