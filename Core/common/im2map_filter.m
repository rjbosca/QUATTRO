function a = im2map_filter(a,intercept,slope,mapRange)
%im2map_filter  Convert a DICOM image to a map
%
%   MAP = im2map_filter(IM,INTERCEPT,SLOPE,IMRANGE) rescales the DICOM image,
%   IM, using the SLOPE and INTERCEPT to transform image values to map values by
%
%       MAP = IM*INTERCEPT + SLOPE
%
%   IMRANGE is a two element array specifying the minimum allowable value in the
%   first element and the maximum allowable value in the second. Image values
%   falling out side of this range will be mapped to NaNs. The transformed IM
%   values, MAP, will be a double array the same size as IM.
%
%   Any values can be used for the slope, intercept, and image range, but these
%   inputs were intended originally to come from the following DICOM meta-data
%   tags:
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

    % Convert the input image to double to ensure that NaNs can be stored and
    % arithmetic can be performed
    a = double(a);

    % Apply the map value limits
    a( a<mapRange(1) | a>mapRange(2) ) = NaN;

    % Apply the rescale operation
    a = slope*a + intercept;

end %im2map_filter