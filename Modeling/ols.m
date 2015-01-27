function b = ols(x,data)
%ols  Ordinary least squares solver
%
%   B = ols(X,Y) solves the overdetermined system of linear equations by finding
%   the least squares estimate for:
%
%       Y = B0 + BX = B0 + B1*x + B2*x^2 + ... + B2*x^n
%
%   where X = [x11 x12 ... x1n; x21 x22 ... x2n; ...; xm1 xm2 ... xmn] and the
%   data, Y = [y1 y2 ... yn]. The regression coefficient, B, are returned. Since
%   B0 (constant offset) is included in the model, there is no need to append a
%   column of ones in X.

% Create the column of ones. Since most users don't read the help section
% carefully, check to ensure there isn't already a column of ones
if any( x(:,1)~= 1 )
    x = [ones(size(x,1),1) x];
end

% Solve the system with uniform weighting
b = (x'*x)\x'*data(:);