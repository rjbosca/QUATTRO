function varargout = mask2imellipse(I,normFlag)
%mask2imellipse  Convert a binary image to an ellipse
%
%   POS = mask2imellipse(I) attempts to convert the binary 2D image I to a
%   position vector [XMIN YMIN WIDTH HEIGTH] that can be used to create an
%   imellipse ROI. The input image, I, can also be a label image, in which case
%   POS will be an N-by-4 array of position vectors (where N is the number of
%   labels in I).
%
%   POS = mask2imellipse(I,FLG) calculates the position vectors as above in
%   addition to normalizing the values with respect to the image size if FLG is
%   TRUE. When FLG is FALSE, the above syntax is achieved.
%
%   [POS,STATS] = mask2imellipse(...) returns the position vector, POS, in
%   addition to the region statistics structure
%
%   See also IMELLIPSE and BWLABEL

    % Validate the normalization flag input
    if (nargin==1) || ~islogical(normFlag)
        normFlag = false;
    end

    % Validate image input
    validateattributes(I,{'numeric'},{'2d','nonnegative','nonsparse','real'});

    % Get the statistics
    s = regionprops(I,{'Centroid','EquivDiameter','PixelIdxList'});

    % Use centroid and diameter to generate position vector
    n   = length(s);
    pos = zeros(n,4);
    for idx = n:-1:1
        if any(isnan(s(idx).Centroid))
            pos(idx,:) = []; %removes bad ellipse estimates
            continue
        end
        pos(idx,:) = [s(idx).Centroid-s(idx).EquivDiameter/2,...
                                     s(idx).EquivDiameter s(idx).EquivDiameter];
    end

    % Normalize, if requested
    if normFlag
        pos(:,1:2) = pos(:,1:2) ./ size(I,2);
        pos(:,3:4) = pos(:,3:4) ./ size(I,1);
    end

    % Deal the outputs
    varargout = {pos};
    if (nargout>1)
        varargout{2} = s;
    end

end %mask2imellipse