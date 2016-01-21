function cT = gamma_var(x,t)
%gamma_var  Gamma-variate function for DSC first tracer kinetics
%
%   Ct = gamma_var(X,T) returns the concentration of contrast parameterized by a
%   gamma-variate function where X is a vector of model parameters and T is the
%   time vector for the VIF. Model parameters are:
%
%       Input       Parameter       Description
%       ---------------------------------------
%       X(1)           K            Scaling factor
%
%       X(2)         alpha          Alpha parameter of the gamma distribution
%
%       X(3)          beta          Beta paramterer of the gamma distribution
%
%       X(4)           t0           Bolus arrival time

    % Initialize
    cT = zeros(size(t));

    % Pre-contrast indices
    tBase = (t>=x(4));

    % Post-contrast
    cT(tBase) = x(1)*(t(tBase)-x(4)).^x(2).*exp(-(t(tBase)-x(4))/x(3));

end %gamma_var