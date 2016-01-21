function im = dicom2map(im,m,b,mapRange)
%dicom2map  Converts a DICOM image (uint16) to a floating-point image
%
%   MAP = dicom2map(IM,M,B,RANGE) converts DICOM image data, IM, to a floating
%   point image, MAP, using a linear transformation such that image values are
%   mapped to:
%
%       MAP = M*IM + B
%
%   IMRANGE is a two element array specifying the minimum allowable value in the
%   first element and the maximum allowable value in the second. Image values
%   falling out side of this range will be mapped to NaNs. The transformed IM
%   values, MAP, will be a double array the same size as IM.
%
%   Any values can be used for the linear transformation (i.e., M, B, and IM),
%   but these inputs were intended originally to come from the following DICOM
%   meta-data tags:
%
%       Tag             Description
%       =======================
%       (0028,1052)     Rescale slope
%
%       (0028,1053)     Rescale slope
%
%       (0040,9216)     Real world first value mapped
%
%       (0040,9211)     Real world last value mapped

    % Type cast and add the NaN values
    im = double(im);
    im( im<mapRange(1) | im>mapRange(2) ) = NaN;

    % Rescale the image values
    im = im*m + b;

end %dicom2map