function varargout = nmi(im1,im2,varargin)
%nmi  Computes the normalized mutual information of two images
%
%   D = nmi(I1,I2) computes the normalized mutual information, D, of the two
%   input images (I1 and I2). Both images must be the same size. Pixel values
%   less than 0 or NaNs are ignored.
%
%   [D,HIST] = nmi(I1,I2) computes the normalized mutual information of the two
%   input images (I1 and I2), returning the mutual information, D, and the
%   joint, HIST, histogram.
%
%   [...] = nmi(...,'PropertyName1',PropertyValue1,...) computes the normalized
%   mutual information of two images, using the options as specified.
%
%       Option String       Description
%       -------------------------------
%
%       nBins               Number of bins for the joint density (default: 256)

% Deal outputs and validate the input images
[varargout{1:nargout}] = deal([]);
if isempty(im1) || isempty(im2)
    return
end

% Define the default option values
nBins = 255;

% Remove 'ignore' values
ignore_mask = (im2<0 | im1<0 | isnan(im1) | isnan(im2)); % mask for ignore values
im1(ignore_mask) = []; im2(ignore_mask) = [];
if ~any(im1(:)) || ~any(im2(:))
    varargout{1} = inf;
    return
end

% Rescale images
im1 = floor(im1(:)/max(im1(:))*nBins)+1; n = numel(im1);
im2 = floor(im2(:)/max(im2(:))*nBins)+1;


%---------------------------Determine joint histogram---------------------------

% Loop through all unique coordinates and find the number of occurances
pHist = zeros(nBins+1); % preallocate memory
for i = 1:n
    pHist(im1(i),im2(i)) = pHist(im1(i),im2(i)) + 1;
end

pHist = pHist/n;
if nargout>1
    varargout{2} = pHist;
end

% Marginal densities
pHist1 = sum(pHist,2);
pHist2 = sum(pHist,1);

% Enforce 0*log(0) == 0
pHist  = pHist(pHist~=0);
pHist1 = pHist1(pHist1~=0);
pHist2 = pHist2(pHist2~=0);

% Calculates entropy
HpHist = sum( -pHist.*log2(pHist) );
HpHist1 = sum( -pHist1.*log2(pHist1) );
HpHist2 = sum( -pHist2.*log2(pHist2) );

% Calculates MI
varargout{1} = -(HpHist1 + HpHist2) / HpHist;