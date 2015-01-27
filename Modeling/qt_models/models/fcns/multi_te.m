function ydata = multi_te(x,xdata)
%multi_te  Theoretical spin echo signal intensity model (TR>>T1)
%
%   y = multi_te(x,xdata) calculates the signal intensity y from the echo times
%   (in milliseconds) specified by xdata. This function was paramerterized for
%   fitting multiple echo spin echo data to calculate T2.
%
%       Input       Parameter       Description
%       ----------------------------------------
%       x(1)           S0           Iintrinsic signal intensity
%
%       x(2)           T2           T2 relaxation time
%
%   See also multi_te_r2

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:19:48 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : multi_te.m

ydata = x(1).*exp(-xdata./x(2));