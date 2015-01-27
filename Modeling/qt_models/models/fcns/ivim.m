function ydata = ivim(x,xdata)
%ivim  Intravoxel incoherent motion diffusion model
%
%   si = ivim(x,bvalues) calculates the signal intentsity of a diffusion
%   weighted scan using the b-values specified in units of s/mm^2 (typical
%   values are on the order of 150 to 2000 s/mm^2) and model parameters x (see
%   below).
%
%   Some common variants of this model can be calculated by setting various
%   parameters to zero. For example, simple mono-exponential decay can be
%   calculated by setting x(3:5) to zero. Kurtosis modeling (i.e. ignoring
%   pseudo-diffusion) is acheived by setting x(3) to zero.
%
%       Input    Parameter     Description
%       ----------------------------------
%        x(1)       S0         Thermal equilibrium signal intensity
%
%        x(2)       D          Diffusion coefficient
%
%        x(3)       D*         Pseudo-diffusion coefficient
%
%        x(4)       f          Perfusion fraction
%
%        x(5)       K          Diffusion kurtosis

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:54:57 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : ivim.m

alpha = xdata*x(2)-(x(2)*xdata).^2*x(5)/6; beta = xdata*x(3);

ydata = x(1)*( (1-x(4))*exp(-alpha) + x(4)*exp(-alpha-beta) );