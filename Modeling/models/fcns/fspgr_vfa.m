function ydata = fspgr_vfa(x,xdata,tr)
%fspgr_vfa  Theoretical fspgr_vfa signal intensity model
%
%   y = fspgr_vfa(x,xdata,tr) calculates the signal intensity y from the flip
%   angles (in degrees) specified by xdata, repetition time (tr in ms),
%   intrinsic signal intensity S0, and T1 in ms. This function was parameterized
%   for fitting data acquired with multiple flip angles to estimate T1.
%
%       Input       Parameter       Description
%       ----------------------------------------
%       x(1)           S0           Intrinsic signal intensity
%
%       x(2)           T1           T1 relaxtion time in milliseconds
%
%   This fast spoiled gradient echo model assumes perfect spoiling and that T2*
%   effects are negligible (i.e. TE<<T2* and TE=const.)
%
%   See also fspgr_vfa_full

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:07:54 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : fspgr_vfa.m

    % Exponential relaxation term
    E1 = exp(-tr/x(2));

    ydata = x(1)*(sind(xdata)*(1-E1))./(1-cosd(xdata)*E1);

end %fspgr_vfa