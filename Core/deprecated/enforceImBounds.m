function im = enforceImBounds(im,varargin)
%enforceImBounds  Imposes pixel value bounds.
%
%   IM = enforceImBounds(IM,REF) uses the minimum and maximum values of a
%   reference image REF to force a second image IM to conform to the bounds
%   of REF.
%
%   IM = enforceImBounds(IM,BOUNDS) uses BOUNDS (i.e., [imMin imMax]) to enforce
%   minimum and maximum IM values
%
%   This function performs no validation on REF or IM.

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
             '"%s" is deprecated and will be removed in a future release. ',...
             mfilename);

if numel(varargin{1})==2
    B = varargin{1};
else %find the image bounds from a reference image
    B = [min(varargin{1}(:)) max(varargin{1}(:))];
end

% Imposes bounds
im(im < B(1)) = B(1);
im(im > B(2)) = B(2);