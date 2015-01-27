function varargout = preprocess_dce_images(varargin)
%preprocess_dce_images  Pre-processes DCE (DSC) images for a variety of tasks
%
%   [output1 ...] = preprocess_dce_images(IMS,PARAM1,...) processes the stack of
%   images, IMS, of a DCE or DSC exam according to the value PARAM1, which can
%   be one of the following:
%
%       'tc'        Time course averaged over all voxels
%
%       'tca'       Time course of all identified voxels
%
%       'mask'      mask of "reasonable" voxel time courses
%
%   IMS should be an array of images from a single slice and should have
%   dimensions T-M1-M2, where T is the number of time points in the series, and
%   M1/M2 represent the image matrix size.

%# AUTHOR    : Ryan Bosca
%# $DATE     : 14-Apr-2013 20:18:17 $
%# $Revision : 1.01 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : preprocess_dce_images.m

im          = varargin{1};
varargin(1) = [];
m           = size(im);

% Find the peak and minimum S.I. locations and values, which are used to enforce
% certain assumptions about the signal intensity time course (e.g. in enhancing
% voxels, the peak enhancement should occur after the minimum signal intensity
% time frame and should be greater than or equal to the peak enhancement)
[siPeak,maxFr] = max(im);
[siMin, minFr] = min(im);

% Enforce assumptions for an enhancing voxel: (1) the peak signal intensity
% should be greater than the minimum signal intensity of the time course, (2)
% the frame at which the peak signal intensity occurs should be greater than the
% frame at which the corresponding minimum occurs, and (3) the frame of peak
% signal intensity should occur on any frame beyond the first.
maxFr(siPeak<=siMin | maxFr<=minFr | maxFr==1) = 0;

% Calculate the enhancement ratio (ypeak/ymin-1)
ser                          = (double(siPeak)./double(siMin)-1);
ser(isinf(ser) | isnan(ser)) = -inf;

% Using the signal enhancement ratio, deterine the top 5% of enhancing voxels,
% removing all other voxels by replacing the SER value with a NaN
nVox                    = round( 0.05*prod(m(2:end)) );
[~,voxIdx]              = sort(ser(:));
ser(voxIdx(1:end-nVox)) = -inf;
ser(isinf(ser))         = NaN;

% Remove the islands
ser( bwmorph( squeeze(~isnan(ser)), 'remove' ) ) = NaN;

% Calculate uptake curves for the voxels of interest
tuc = double( im(:, squeeze( ~isnan(ser) )) );

% Deal the outputs
varargout = cell(1,nargout);
for frIdx = 1:nargout
    switch lower(varargin{frIdx})
        case 'tc'
            varargout{frIdx} = mean(tuc,2);
        case 'tca'
            varargout{frIdx} = tuc;
        case 'mask'
            varargout{frIdx} = logical(maxFr);
    end
end