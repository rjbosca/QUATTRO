function b = olsfi(x,data,intcpt)
%olsfi  Ordinary least squares through a fixed intercept solver
%
%   B = olsfi(X,Y,INT) solves the overdetermined system of linear equations by
%   finding the least squares estimate for:
%
%       Y = YINT + BX = INT + B1*x + B2*x^2 + ... + B2*x^n
%
%   where X = [x11 x12 ... x1n; x21 x22 ... x2n; ...; xm1 xm2 ... xmn], the
%   data, Y = [y1 y2 ... yn], and the forced y-intercept (normally B0) is YINT.
%   The regression coefficient, B, is returned.

    % Solve the system with uniform weighting
    b = (x'*x)\x'*(data(:)-intcpt);

end %olsfi