function rho = ccorr(x,y)
%ccorr  Calculates the concordance correlation coefficient
%
%   RHO = ccorr(X,Y) calculates the concordance correlation coefficient for the
%   vectors X and Y.
%
%
%       References
%       ----------
%       [1] Lin LI, Biometrics, Vol 45 (1), pp. 255-268, 1989

    % Convert to double
    x = double(x(:)); y = double(y(:));

    % Calculate the variances
    vx = var(x);
    vy = var(y);

    % Compute the CCC
    rho = (2*corr(x,y)*vx*vy) / (vx^2 + vy^2 + (mean(x)-mean(y))^2);

end %ccorr