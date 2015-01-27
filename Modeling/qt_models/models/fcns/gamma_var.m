function cT = gamma_var(x,t)
%gamma_var  Gamma-variate function for DSC first tracer kinetics
%
%   Ct = gamma_var(params,t) returns the concentration of contrast parameterized
%   by a gamma-variate function where x is a vector of model parameters and t is
%   the time vector for the VIF. Model parameters are:
%
%       Input       Parameter       Description
%       ---------------------------------------
%       x(1)           K            Scaling factor
%
%       x(2)         alpha          Alpha parameter of the gamma distribution
%
%       x(3)          beta          Beta paramterer of the gamma distribution
%
%       x(4)           t0           Bolus arrival time

% Initialize
cT = zeros(size(t));

% Pre-contrast indices
tBase = (t>=x(4));

% Post-contrast
cT(tBase) = x(1)*(t(tBase)-x(4)).^x(2).*exp(-(t(tBase)-x(4))/x(3));