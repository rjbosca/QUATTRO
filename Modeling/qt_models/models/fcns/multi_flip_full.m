function ydata = multi_flip_full(s0,t1,fa,tr)
%multi_flip_full  Theoretical FSPGR signal intensity model
%
%   Y = multi_flip_full(S0,T1,FA,TR) calculates the signal intensity Y from the
%   flip angles (in degrees) specified by FA, repetition time (TR in ms),
%   intrinsic signal intensity S0, and T1 in milliseconds. This function was
%   parameterized for simulating signal intnesities based on a multiple imaging
%   and system parameters.
%
%   Any one of the inputs, S0, T1, FA, or TR can be vector-valued, while all
%   other inputs must be scalar. An error will likely occur if multiple inputs
%   are vectors
%
%   See also multi_flip

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:07:54 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : multi_flip.m

    % Exponential relaxation term
    E1 = exp(-tr./t1);

    ydata = s0.*(sind(fa).*(1-E1))./(1-cosd(fa).*E1);

end %multi_flip_full