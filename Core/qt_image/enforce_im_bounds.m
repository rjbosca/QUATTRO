function im = enforce_im_bounds(im,varargin)
%enforce_im_bounds  Imposes lower/upper limits on pixel values
%
%   IM = enforce_im_bounds(IM,REF) uses the minimum and maximum values of the
%   reference image REF to force a second image IM to conform to the range of
%   pixel values in REF
%
%   IM = enforce_im_bounds(IM,BOUNDS) uses BOUNDS (i.e., [imMin imMax]) to
%   enforce minimum and maximum IM values
%
%   This function performs no validation on REF or IM.

    if numel(varargin{1})==2
        B = varargin{1};
    else %find the image bounds from a reference image
        B = [min(varargin{1}(:)) max(varargin{1}(:))];
    end

    % Imposes bounds
    im(im < B(1)) = B(1);
    im(im > B(2)) = B(2);

end %enforce_im_bounds