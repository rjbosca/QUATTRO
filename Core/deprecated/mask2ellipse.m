function varargout = mask2ellipse(varargin)
%mask2ellipse  Convert a binary image to an ellipse
%
%   POS = mask2ellipse(I) attempts to convert the binary 2D image I to a
%   a position vector [XMIN YMIN WIDTH HEIGTH] that can be used to create
%   an imellipse ROI. I can also be a label image in which case POS will be
%   an N-by-4 array of position vectors.
%
%   POS = mask2ellipse(I,FLG) calculates the position vectors as above in
%   addition to normalizing the values with respect to the image size if
%   FLG is true. Default: false
%
%   See also imellipse, bwlabel

    warning(['QUATTRO:' mfilename ':deprecatedFun'],...
             '%s is deprecated. Use MASK2IMELLIPSE instead...',mfilename);

    % Wrap MASK2IMELLIPSE
    [varargout{:}] = mask2imellipse(varargin{:});

end %mask2ellipse