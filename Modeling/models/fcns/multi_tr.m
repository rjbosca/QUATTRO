function ydata = multi_tr(x,xdata,te)
%multi_tr  Theoretical spin echo signal intensity model
%
%   y = multi_ti(x,xdata) calculates the signal intensity y from the repetition
%   times (in milliseconds) specified by xdata and echo time te (in
%   milliseconds). This function was parameterized for fitting multiple TR spin
%   echo data to calculate T1.
%
%       Input       Parameter       Description
%       ---------------------------------------
%       x(1)            S0          Intrinsic signal intensity
%
%       x(2)            T1          T1 relaxation time in ms
%
%   See also multi_tr_r1

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:49:19 $
%# $Revision : 1.01 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : multi_tr.m

ydata = x(1).*(1 - 2*exp(-(xdata-te/2)./x(2)) + exp(-xdata./x(2)));