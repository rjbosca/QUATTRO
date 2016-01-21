function ydata = fse_vti(x,xdata)
%fse_vti  Theoretical inversion recovery spin echo signal intensity model
%
%   Y = fse_vti(X,XDATA) calculates the signal intensity Y from the inversion
%   times (in milliseconds) specified by XDATA. This function was parameterized
%   for fitting multiple TI inversion recovery data to calculate T1.
%
%       Input       Parameter       Description
%       ---------------------------------------
%       X(1)           S0           Intrinsic signal intensity
%
%       X(2)           T1           T1 relaxation time in ms
%
%       X(3)          theta         Inversion RF pulse flip angle in degress
%
%   Setting the the inversion RF pulse flip angle to 180 will recover a
%   simplified version of the VTI signal intensity equation, but can cause poor
%   fits due to RF imperfections.
%
%   Additionally, this model assumes that signal intensity can take a negative
%   value. Since most modeling is performed on magnitude images, the signal
%   intensity polarity must be restored. This has advantages in terms of data
%   noise characteristic. See for example, Quantitative MRI of the Brain (Tofts,
%   2003).
%
%   See also restore_ir

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:32:00 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : fse_vti.m

    ydata = x(1).*(1-(1-cosd(x(3)))*exp(-xdata./x(2)));

end %fse_vti