function ydata = GKM(x,xdata,vif,hct)
%GKM  Calculates tissue uptake cureve from the general kinetic model
%
%   Ct = GKM(x,t,Cp,hct) returns the tissue uptake curve using the general
%   kinetic model, where t is a vector of representing the time of acquisition
%   at each frame of the DCE series, Cp is the vascular input function, hct is
%   the hematocrit, and x is a 1-by-3 array of model parameters. 
%
%       Input       Parameter       Description
%       ---------------------------------------
%       x(1)         Ktrans         Forward rate constant of [Gd] from the
%                                   vascular compartment to the extracellular
%                                   extravascular space (EES) in units of time
%                                   (see note below).
%
%       x(2)           ve           Fractional EES volume (unitless)
%
%       x(3)           vp           Fraction plasma volume (unitless)
%
%   A note on units: Parameter units will depend on those specified by the time
%   vector. For example, if the time vector is specified with units of minutes,
%   the resulting units for Ktrans will be min^-1. By definition, ve and vp are
%   unitless and should be between 0 and 1.
% 
%   Because this implementation is optimized for curve fitting, little error
%   checking is performed and the time vector and VIF are assumed to be sampled
%   uniformly.
%
%   The commonly used two parameter version of this model can be recovered by
%   setting x(3) to zero.
%
%   See also GKM_plot

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 22:54:33 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : GKM.m

    % Impulse function (see A. Jackson, pg. 83). Note that the factor (i.e.,
    % diff(...)) in front of the convolution comes from the need to normalize
    % the discrete convolution operation by the potentially non-unity time
    % increments
    H = diff(xdata(1:2)) * conv(vif, x(1)*exp(-x(1)./x(2) * xdata));

    % equation (9)
    ydata = (x(3)*vif + H(1:length(xdata)))/(1-hct);

end %GKM