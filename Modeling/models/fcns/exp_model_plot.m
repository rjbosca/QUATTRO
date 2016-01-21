function c_t = exp_model_plot(x,xdata,c_a,hf,p)
%EXP_MODEL  Generates the tissue uptake from a DSC exam using the AIF
%
%   Ct = exp_model_plot(x,t,Cp,hf,p) calculates the concentration of contrast
%   agent in the tissue using a decaying mono-exponential residue function. For
%   more details, see exp_model. The model parameters are:
%
%       Input       Parameter       Description
%       ---------------------------------------
%       x(1)          rCBF          Regional cerebral blood flow
%
%       x(2)          MTT           Mean transit time (seconds)
%
%   ~Note: no error checking is performed. This function assumes that units
%          of concentration are given in mM and time are given in seconds.
% 
%   See also gamma_var, exp_model

%# AUTHOR    : Ryan Bosca
%# $DATE     : 08-Aug-2013 16:37:23 $
%# $Revision : 1.03 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : exp_model_plot.m

% Ensure comensurate data sizes
n_xdata = numel(xdata); n_vif = numel(c_a);
if n_xdata > n_vif
    x1 = linspace(min(xdata),max(xdata),n_vif);
    c_a = interp1(x1,c_a,xdata,'spline');
elseif n_xdata < n_vif
    x1 = linspace(min(xdata),max(xdata),n_xdata);
    c_a = interp1(x1,c_a,xdata,'spline');
end

% Determine time increment
delta_t = mean(diff(xdata));

% See A. Jackson, pg. 55, eq. 2 or Ostergaard et al 1996a. Note that the factor
% in front of the convolution comes from the need to normalize the time
% increments
c_t = (p/hf) * x(1) * delta_t * conv(c_a, exp(-xdata./x(2)));

% Consider only the "good" part of the curve
c_t(length(xdata)+1:end) = [];