function varargout = mask2imellipse(I,normFlag)
%mask2imellipse  Convert a binary image to an ellipse
%
%   POS = mask2imellipse(I) attempts to convert the binary 2D image I to a
%   a position vector [XMIN YMIN WIDTH HEIGTH] that can be used to create
%   an imellipse ROI. I can also be a label image in which case POS will be
%   an N-by-4 array of position vectors.
%
%   POS = mask2imellipse(I,FLG) calculates the position vectors as above in
%   addition to normalizing the values with respect to the image size if
%   FLG is true (the default is false).
%
%   [POS,STATS] = mask2imellipse(...) returns the position vector in addition to
%   the region statistics performing the operations described previously
%
%   See also imellipse and bwlabel

    if (nargin==1) || ~islogical(normFlag)
        normFlag = false;
    end

    % Validate image input
    validateattributes(I,{'numeric','logical'},{'2d','nonempty','real'});

    % n = numel( unique( bwlabel(I) ) );
    % if n~=2
    %     error([mfilename ':regionChk'],'I must contain only one region');
    % end

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
        if normFlag
            pos(idx,:) = scale_roi_verts(pos(idx,:),'imellipse',size(I));
        end
    end

    % Deal the outputs
    varargout = {pos};
    if (nargout>1)
        varargout{2} = s;
    end

end %mask2imellipse