function val = mean_sq_err(x,y,f)
%mean_sq_err  Calculates the mean squared error
%
%   MSE = mean_sq_err(X,Y,F) calculates the mean squared error of fitted
%   experimental data given by the explanatory data array X, response array Y,
%   and fitted data F. F can be provided as an array (must be the same size as
%   Y) or as a function handle. Evaluated function handles should return a
%   single output array the same size as Y.

% Determine the input type
if strcmpi(class(f),'function_handle')
    f = f(x);
end

% Calculate the model residuals
r   = (y(:)-f(:)); %model residuals

% Calculate the mean square error
val = sum(r'*r)/numel(y);