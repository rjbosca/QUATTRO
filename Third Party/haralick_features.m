function varargout = haralick_features(I,varargin)
%haralick_features  Calculate image texture features
%
%   F = haralick_features(I) calculates the gray level co-occurance (GCLM)
%   texture features (see description below) of the 2D image I using an
%   inter-voxel distance of one. A 19-by-1 vector of features, F, is returned.
%
%   F = haralick_features(I,d) calculates the GCLM texture features for all
%   inter-voxel distances between one and d, where d must be an integer greater
%   than one, returning a 19-by-d array of features.
%
%   Texture Features (number corresponds to the row index)
%   ----------------
%
%       1.  Energy [1,2]
%       2.  Entropy [1,2]
%       3.  Dissimilarity [2]
%       4.  Contrast [1,2]
%       5.  Inverse Difference [1]
%       6.  Correlation [1,2]
%       7.  Homogeneity [2]
%       8.  Autocorrelation [2]
%       9.  Maximum Probability [2]
%       10. Sum of Squares [1]
%       11. Sum Average [1]
%       12. Sum Varience [1]
%       13. Sum Entropy [1]
%       14. Difference Varience [1]
%       15. Difference Entropy [1]
%       16. Information Measure 1 [1]
%       17. Information Measure 2 [1]
%       18. Cluster Shade [2,3]
%       19. Cluster Prominence [2,3]
%
%
%   References
%   -----------
% 
%   [1] R. M. Haralick, K. Shanmugam, and I. Dinstein, Textural Features of
%       Image Classification, IEEE Transactions on Systems, Man and Cybernetics,
%       vol. SMC-3, no. 6, Nov. 1973
%
%   [2] L. Soh and C. Tsatsoulis, Texture Analysis of SAR Sea Ice Imagery
%       Using Gray Level Co-Occurrence Matrices, IEEE Transactions on Geoscience
%       and Remote Sensing, vol. 37, no. 2, March 1999.
%
%   [3] D A. Clausi, An analysis of co-occurrence texture statistics as a
%       function of grey level quantization, Can. J. Remote Sensing, vol. 28,
%       no. 1, pp. 45-62, 2002

%   This function was written based on GLCM_Features4.m available on the
%   Matlab file exchange.

% Parse the inputs
[d,I] = parse_inputs([{I},varargin{:}]);

minNg = min(I(I>0));
I(I==0) = NaN;
I(I>0)= I(I>0)-(minNg-1);
maxNg = max(max(I));

% Calculate the GLCM for 0, 45, 90, and 135 deg.
glcm(:,:,1) = graycomatrix(I, 'Offset', [0 d],...
                              'NumLevels',  maxNg/2,...
                              'G', [],...
                              'Symmetric', true);
glcm(:,:,2) = graycomatrix(I, 'Offset', [-d d],...
                              'NumLevels',  maxNg/2,...
                              'G', [],...
                              'Symmetric', true);
glcm(:,:,3) = graycomatrix(I, 'Offset', [-d 0],...
                              'NumLevels',  maxNg/2,....
                              'G', [],...
                              'Symmetric', true);
glcm(:,:,4) = graycomatrix(I, 'Offset', [-d -d],...
                              'NumLevels',  maxNg/2,...
                              'G', [],...
                              'Symmetric', true);

% Haralick, et al. says that the GLCM used for analysis should be an
% average of the four angles.
glcm = squeeze(mean(glcm,3));
Ng = size(glcm,1);

p_x       = zeros(Ng,1);
p_y       = zeros(Ng,1);
p_xplusy  = zeros((Ng*2),1);
p_xminusy = zeros(Ng,1);

% Normalize the glcm to 1 to make them probabilities
glcm_sum = sum(sum(glcm(:,:)));
glcm = glcm./glcm_sum;
disp('should be 1');
disp(sum(sum(glcm(:,:))));

% Compute marginal probabilities
for ii = 1:Ng
    for jj = 1:Ng
        p_x(ii) = p_x(ii) + glcm(ii,jj);
        p_y(ii) = p_y(ii) + glcm(jj,ii);
        p_xplusy((ii+jj)) = p_xplusy((ii+jj)) + glcm(ii,jj);
        p_xminusy((abs(ii-jj))+1) = p_xminusy((abs(ii-jj))+1)+glcm(ii,jj);
    end
end

%This is here just for reference.
% feature_names = {'Energy'; 'Entropy'; 'Dissimilarity'; 'Contrast'; 'Inverse Difference'; 'Correlation'; 'Homogeneity'; 'Autocorrelation'; 'Maximum Probability'; 'Sum of Squares'; 'Sum Average'; 'Sum Varience'; 'Sum Entropy'; 'Difference Varience';'Difference Entropy'; 'Information Measure 1';'Information Measure 2';'Cluster Shade';'Cluster Prominence'};

% Calculate the various features
feature_vector(1,1)  = compute_energy(glcm);
feature_vector(2,1)  = compute_entropy(glcm);
feature_vector(3,1)  = compute_dissimilarity(glcm);
feature_vector(4,1)  = compute_contrast(glcm);
feature_vector(5,1)  = compute_invDiff(glcm);
feature_vector(6,1)  = compute_correlation(glcm);
feature_vector(7,1)  = compute_homogeneity(glcm);
feature_vector(8,1)  = compute_autocorr(glcm);
feature_vector(9,1)  = compute_maxProb(glcm);
feature_vector(10,1) = compute_sumOfSquares(glcm);
feature_vector(11,1) = compute_sumAverage(p_xplusy);
feature_vector(12,1) =  compute_sumVariance(p_xplusy);
feature_vector(13,1) = compute_sumEntropy(p_xplusy);
feature_vector(14,1) = compute_diffVarience(p_xminusy);
feature_vector(15,1) = compute_diffEntropy(p_xminusy);
[out, out2] = compute_informationMeasures(glcm);
feature_vector(16,1) = out;
feature_vector(17,1) = out2;
feature_vector(18,1) = compute_clusterShade(glcm);
feature_vector(19,1) = compute_clusterProm(glcm);


function [energy] = compute_energy(glcm)
energy = sum(sum(glcm.^2));

function [entropy] = compute_entropy(glcm)
eps = 0.000001;
entropy = -sum(sum((glcm.*log10(glcm+eps))));

function [dissimilarity] = compute_dissimilarity(glcm)
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat(1:Ng,Ng,1);
mul_dissi = abs(i_matrix - j_matrix);
dissimilarity = sum(sum(mul_dissi.*glcm));

function [contrast] = compute_contrast(glcm)
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat([1:Ng],Ng,1);
mul_contr = abs(i_matrix - j_matrix).^2;
contrast = sum(sum(mul_contr.*glcm));

function [invDiff] = compute_invDiff(glcm)
%inverse difference normalized
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat([1:Ng],Ng,1);
mul_dissi = abs(i_matrix - j_matrix);
invDiff = sum(sum(glcm./(1 + mul_dissi./Ng)));

function [coorelation] = compute_correlation(glcm)
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat([1:Ng],Ng,1);
cor = sum(sum(i_matrix.*j_matrix.*glcm));
mean_x= sum(sum(i_matrix.*glcm)); 
mean_y= sum(sum(j_matrix.*glcm)); 
s_x = sum(sum(((i_matrix - mean_x).^2.*glcm)))^.5;
s_y = sum(sum(((j_matrix - mean_y).^2.*glcm)))^.5;
coorelation = (cor -mean_x*mean_y)/(s_x*s_y);

function [homogeneity] = compute_homogeneity(glcm)
%inverse difference moment normilized
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat([1:Ng],Ng,1);
mul_contr = (i_matrix - j_matrix).^2;
homogeneity = sum(sum(glcm./(1+ mul_contr)));

function [autocorrelation] = compute_autocorr(glcm)
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat([1:Ng],Ng,1);
autocorrelation = sum(sum(i_matrix.*j_matrix.*glcm));

function [cluster_shade] = compute_clusterShade(glcm)
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat([1:Ng],Ng,1);
mean_x= sum(sum(i_matrix.*glcm)); 
mean_y= sum(sum(j_matrix.*glcm));
cluster_shade = sum(sum(((i_matrix + j_matrix - mean_x - mean_y).^3).*glcm));

function [ cluster_prominence] = compute_clusterProm(glcm)
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
j_matrix = repmat([1:Ng],Ng,1);
mean_x= sum(sum(i_matrix.*glcm)); 
mean_y= sum(sum(j_matrix.*glcm));
cluster_prominence = sum(sum(((i_matrix + j_matrix - mean_x - mean_y).^4).*glcm));

function [max_prob] = compute_maxProb(glcm)
max_prob = max(max(glcm));

function [sumOfSquares] = compute_sumOfSquares(glcm)
Ng = size(glcm,1);
i_matrix = repmat([1:Ng]',1,Ng);
mean_x= sum(sum(i_matrix.*glcm));
sumOfSquares = sum(sum(glcm.*(i_matrix - mean_x).^2));

function [sumAverage] = compute_sumAverage(p_xplusy)
Ng = size(p_xplusy,1);
ii = [2:Ng+1]';
sumAverage = sum(ii.*p_xplusy);

function [sumVariance] = compute_sumVariance(p_xplusy)
Ng = size(p_xplusy,1);
ii = [2:Ng+1]'; eps = 0.00000001;
sumEntropy = -sum(p_xplusy+ log(p_xplusy+eps));
sumVariance = sum( (ii-sumEntropy).^2 .*p_xplusy);

function [sumEntropy] = compute_sumEntropy(p_xplusy)
Ng = size(p_xplusy,1);
ii = [2:Ng+1]'; eps = 0.00000001;
sumEntropy = -sum(p_xplusy+ log(p_xplusy+eps));

function[diffVarience] = compute_diffVarience(p_xminusy)
Ng = size(p_xminusy,1);
ii = [2:Ng+1]';
diffVarience = sum((ii.^2).*p_xminusy);

function [diffEntropy] = compute_diffEntropy(p_xminusy)
    diffEntropy = sum(p_xminusy.*log(p_xminusy+eps));

function [inf1, inf2] = compute_informationMeasures(glcm)
    eps = 0.00001;
    px= sum(glcm,2);
    py = sum(glcm,1);
    HX = -sum(px.*log(px+eps));
    HY = - sum(py.*log(py+eps));
    HXY1 = - sum(sum(glcm.*[log(px*py+eps)]));
    HXY2 = - sum(sum(px*py.*log(px*py+eps)));
    HXY = -sum(sum(glcm.*log(glcm+eps)));

    inf1 = (HXY-HXY1)/max([HX, HY]);
    inf2 = (1- exp(-2.0*(HXY2-HXY)))^0.5;


%-------------------------------- Input Parsing --------------------------------

% Input parser
function varargout = parse_inputs(varargin)

    % Setup the parser
    parser = inputParser;
    parser.addRequired('I',@validateImage);
    parser.addOptional('d',1,@(x) isnumeric(x) && (x>1));

    % Parse the inputs
    parser.parse(varargin{:});

    % Deal the restuls
    varargout = struct2cell(parser.Results);

    % Enforce double precision image and integer
    varargout{2} = double(varargout{2});
    varargout{1} = int32(varargout{1});


% Image validator
function tf = validateImage(I)

    tf = true;

    % Many of the images will have a large gap in gray levels between 0 and the
    % next highest gray level.  0 means background, unimportant to the image,
    % so it is set to NaN, which will not be considered by graycomatrix().
    % Then, I set the next highest gray level to 1, to make the glcm as small
    % as possible.
    if ndims(I)~=2
        error([mfilename ':invalidImage'],'Input image must be 2D');
    elseif (max(I(:))<1)
        error([mfilename ':invalidImage'],...
                         'Invalid image range. Max(I) must be greater than 1.');
    end