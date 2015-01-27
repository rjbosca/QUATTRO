function varargout = smi(im1,im2,varargin)
%smi  Computes the spatial mutual information of two images
%
%   D = smi(I1,I2) computes the spatial mutual information, D, of the two input
%   images (I1 and I2). Additional details of this method can be found in the
%   paper by Rusakoff and Tomasi (Computer Vision 2004)
%
%   [D,C] = mutual_info_rusakoff(im1,im2) computes the mutual information
%   as described previously, returning the mutual information and the covariance
%   matrix.

% Deal outputs and validate the input images
[varargout{1:nargout}] = deal([]);
if isempty(im1) || isempty(im2)
    return
end

% Evaluate options
if nargin>2
    for i = 3:2:length(varargin)
        if ischar(varargin{i})
            eval([varargin{i} '=varargin{i+1};']);
        end
    end
end
m = size(im1);

r = 1; %radius of MI region
d = 2*(2*r+1)^2; %dimension size
if isempty(m) || prod(m)~=numel(im1)
    m = size(im1);
end
if ndims(im1) ~= numel(m) || any(m~=size(im1))
    im1 = reshape(im1,m); im2 = reshape(im2,m);
end

if ndims(im1)==2
    P = zeros(d,(m(1)-2)*(m(2)-2));
    for i = 2:size(im1,1)-1
        for j = 2:size(im1,2)-1
            p_ij_a = im1(i-1:i+1,j-1:j+1)';
            p_ij_b = im2(i-1:i+1,j-1:j+1)';
            P(:,(i-1)*(j-1)+(i-2)*m(1)) = [p_ij_a(:);p_ij_b(:)];
        end
    end
else
    P = zeros(d,(m(1)-2)*(m(3)-2)*m(3)); n = 1;
    for i = 2:size(im1,1)-1
        for j = 1:size(im1,2)
            for k = 2:size(im1,3)-1
                p_ij_a = squeeze(im1(i-1:i+1,j,k-1:k+1));
                p_ij_b = squeeze(im2(i-1:i+1,j,k-1:k+1));
                P(:,n) = [p_ij_a(:);p_ij_b(:)]; n = n+1;
            end
        end
    end
end

% Subtract mean to get P0
for i = 1:size(P,1)
    P(i,:) = P(i,:) - mean(P(i,:));
end

% Calculate covariance
C = 1/numel(im1) * P * P.';
if nargout>1
    varargout{2} = C;
end

% Entropy
Hg = log((2*pi*exp(1))^(d/2)*det(C)^0.5);
Hg_im1 = log((2*pi*exp(1))^(d/2)*det(C(1:d/2,1:d/2))^0.5);
Hg_im2 = log((2*pi*exp(1))^(d/2)*det(C(end-d/2+1:end,end-d/2+1:end))^0.5);

% Final MI calc
varargout{1} = -(Hg_im1 + Hg_im2 - Hg);