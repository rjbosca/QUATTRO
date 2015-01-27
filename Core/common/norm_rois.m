function rois = norm_rois(rois,roiTypes,xVal,yVal)
%norm_rois  Test or normalizes ROIs to a given image size in pixels.
%
%   ROIS = norm_rois(ROIS,TYPE,X,Y) normalizes all ROIs in the cell array ROIS,
%   where ROIs are specifeid either by an n-by-2 array giving the x-y coordinate
%   pairs, respectively, or an imrect/imellipse position vector:
%
%       [xmin ymin width height]
%
%
%   tf = norm_rois(ROIS) determines if any of the ROI coordinates are greater
%   than 1 (i.e. not normalzied).

if nargin == 4
    rois = cellfun(@normfcnx,rois,roiTypes,'UniformOutput',false);
    rois = cellfun(@normfcny,rois,roiTypes,'UniformOutput',false);
else
    rois = all(cellfun(@isnormfcn,rois));
end

    % Function used with cellfun
    function x = normfcnx(x,x_type)

        if iscell(x)
            x = cellfun(@normfcnx,x,x_type,'UniformOutput',false);
            return
        elseif isempty(x)
            return
        end

        switch x_type
            case {'imellipse','imrect'}
                x(1:2:end) = x(1:2:end)/xVal;
            case {'imspline','impoly'}
                x(:,1) = x(:,1)/xVal;
        end

    end

    % Function used with cellfun
    function x = normfcny(x,x_type)

        if iscell(x)
            x = cellfun(@normfcny,x,x_type,'UniformOutput',false);
            return
        elseif isempty(x)
            return
        end

        switch x_type
            case {'imellipse','imrect'}
                x(2:2:end) = x(2:2:end)/yVal;
            case {'imspline','impoly'}
                x(:,2) = x(:,2)/yVal;
        end

    end

    % Function used with cellfun
    function tf = isnormfcn(x)
        if iscell(x)
            tf = cellfun(@isnormfcn,x);
            tf_emp = cellfun(@isempty,x);
            tf = all(tf(~tf_emp));
            return
        end

        tf = all(x(:)<=1);
    end

end