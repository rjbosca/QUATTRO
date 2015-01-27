function ydata = multi_flip(x,xdata,tr)
%multi_flip  Theoretical FSPGR signal intensity model
%
%   y = multi_flip(x,xdata,tr) calculates the signal intensity y from the flip
%   angles (in degrees) specified by xdata, repetition time (tr in
%   milliseconds), intrinsic signal intensity S0, and T1 in milliseconds. This
%   function was parameterized for fitting multiple flip angle data to calcaulte
%   T1.
%
%       Input       Parameter       Description
%       ----------------------------------------
%       x(1)           S0           Intrinsic signal intensity
%
%       x(2)           T1           T1 relaxtion time in milliseconds
%
%   See also multi_flip_full

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:07:54 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : multi_flip.m

    % Exponential relaxation term
    E1 = exp(-tr/x(2));

    ydata = x(1)*(sind(xdata)*(1-E1))./(1-cosd(xdata)*E1);

end %multi_flip