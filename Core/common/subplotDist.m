function [nR,nC] = subplotDist(nTotal,aspectRatio)
%subplotDist  Determines the optimal number of subplot rows/columns
%
%   subplotDist(N) determines the number of rows and columns, given the total
%   number of plots needed, to achieve an aspect ratio closest to 4:3.
%
%   subplotDist(N,R) determines the number of rows and columns, given the total
%   number of plots needed, to achieve an aspect ratio closest to the value
%   specified in R.

if nargin==1
    aspectRatio = 4/3;
end

% An even number is needed
if mod(nTotal,2)
    nTotal = nTotal+1;
end

% Determine all prime factors
facs = [1 factor(nTotal) nTotal];

% Estimate the aspect ratio and find the value closest to the desired ratio
[~,idx] = min( abs( facs.^2/nTotal-aspectRatio ) );

% Deal the outputs (note that idx(1) is used just in case there were multiple
% values found, which means there are redundant factors)
nC = facs(idx(1));
nR = nTotal/nC;