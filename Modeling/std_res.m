function val = std_res(x,y,f)
%std_res  Calculates the standardized residuals
%
%   SRES = std_res(X,Y,F) calculates the standardized residuals of fitted
%   experimental data given by the explanatory data array X, response array Y,
%   and fitted data F. F can be provided as an array (must be the same size as
%   Y) or as a function handle. Evaluated function handles should return a
%   single output array the same size as Y.

% Determine the input type
if strcmpi(class(f),'function_handle')
    f = f(x);
end

% Calculate the design and hat matrices, residuals
dMat = [ones(numel(x),1) x(:)]; %design matrix
h    = dMat/(dMat'*dMat)*dMat'; %hat matrix
r    = (y(:)-f(:)); %model residuals

% Calculate the standardized residuals
val  = r./sqrt( mean_sq_err(x,y,f).*(1-diag(h)) );