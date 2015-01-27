function [splines s_type] = detect_vials(im,n)

%% AUTHOR    : Ryan Bosca
%% $DATE     : 12-Jan-2012 01:31:49 $
%% $Revision : 1.02 $
%% DEVELOPED : 7.7.0.471 (R2008b)
%% FILENAME  : detect_vials.m

if ~iscell(im)
    im = {im};
end

% Loops throug all images
for i = 1:length(im)
    % Store image
    im_thresh = double(im{i});

    % Converts the image to a black and white image
    bw = im2bw(im_thresh, graythresh(im_thresh));

    % Fills background
    bw = imfill(bw,[1 1]);

    % Find edges and fill interiors
    im_thresh(bw) = 0;
    bw = imfill(logical(im_thresh),'holes');
    bw = bwareaopen(bw,300);

    % Labels regions
    [labels n_labels] = bwlabeln(bw);
    if nargin>1 && n~=n_labels
        figure; imshow(bw);
    end

    % Find centroids
    c = struct2cell( regionprops(labels,'centroid') );
    c = cellfun(@round, c, 'UniformOutput', false);
    b = bwboundaries(bw);

    % Ensures the centroids are properly ordered and stores coordinates
    for j = 1:length(c)
        if j~=labels(c{j}(2),c{j}(1))
            error('oh shit');
        end
        splines{j,1}{i,1}{1} = scale_roi_verts(b{j}(:,2:-1:1),...
                                                'imspline',1./size(im{1}));
        s_type{j,1}{i,1}{1} = 'imspline';
    end

end