function varargout = mi(im1,im2,varargin)
% mi  Computes the mutual information of two images
%
%   D = mi(I1,I2) computes the mutual information of the two images (I1 and I2),
%   returning the value as the sole output.
%
%   [D,HIST] = mi(...) computes the mutual information of the two input images,
%   returning the mutual information and the joint histogram.
%
%   [...] = mi(...,'PropertyName1',PropertyValue1,...) performs the operations
%   described previously using the options specified by the property string,
%   'PropertyName1', and the corresponding value, PropertyValue1.
%
%       Option String       Description
%       -------------------------------
%
%       nBins               Number of bins for the joint density (default: 256)
%
%       maxImVal            Maximum assumed image intensity (default: 255)

% Initialize the output and validate the images
[varargout{1:nargout}] = deal([]);
if isempty(im1) || isempty(im2)
    return
end

% Define some default values
nBins = 256;
maxImVal = 255;

% Evaluate options
if nargin>2
    for idx = 3:2:length(varargin)
        if ischar(varargin{idx})
            eval([varargin{idx} '=varargin{i+1};']);
        end
    end
end

% Remove 'ignore' values
ignoreMask = (im2<0 | im1<0 | isnan(im1) | isnan(im2)); % mask for ignore values
im1(ignoreMask) = []; im2(ignoreMask) = [];
if ~any(im1(:)) || ~any(im2(:))
    varargout{1} = inf;
    return
end

% Convert to double
if ~isa(im1,'double')
    warning(['QUATTRO:' mfilename ':dataConversion'],'%\n%s\n',...
                                                'Converting image 1 to double');
end
if ~isa(im2,'double')
    warning(['QUATTRO:' mfilename ':dataConversion'],'%\n%s\n',...
                                                'Converting image 2 to double');
end

% Rescale images
im1 = floor(im1(:)/max(im1(:))*nBins)+1; n = numel(im1);
im2 = floor(im2(:)/max(im2(:))*nBins)+1;


%---------------------------Determine joint histogram---------------------------

% Loop through all unique coordinates and find the number of occurances
pHist = zeros(nBins+1); % preallocate memory
for idx = 1:n
    pHist(im1(idx),im2(idx)) = pHist(im1(idx),im2(idx)) + 1;
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
varargout{1} = -(HpHist1 + HpHist2 - HpHist);