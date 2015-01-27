function val = r_squared(x,y,f)
%r_squared  Calculates the coefficient of determination
%
%   R2 = r_squared(X,Y,F) calculates the classical regression coefficient of
%   determination using the the explantory data X, response data Y, and fitted
%   data F. The fitted data can be provided as an array the same size as Y or as
%   a function handle. If the latter is provided, F(X) should provide evaluate
%   to an array the same size as Y

    % Dtermine the input type
    if strcmpi(class(f),'function_handle')
        f = f(x);
    end

    % Calculate the model residuals
    r  = (y(:)-f(:));    %model residuals
    ry = (y(:)-mean(y)); %average residuals

    % Calculate 1 minus the unexplained variance (SSres over SStot)
    val = 1-(r'*r)./(ry'*ry);

end %r_squared