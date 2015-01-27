function c_t = exp_model(x,xdata,c_a,hf,p)
%EXP_MODEL  Generates the tissue uptake from a DSC exam using a first pass model
%
%   Ct = exp_model(x,t,Cp,hf,p) calculates the concentration of contrast agent
%   in tissue using a decaying mono-exponential residue function. The vascular
%   input function (Cp) should represent only the first pass of tracer in the
%   blood (i.e. exclude reperfusion effects). Model parameters, including units,
%   defined as follows:
%
%       Input       Parameter       Description
%       ---------------------------------------
%       x(1)          rCBF          Regional cerebral blood flow (units: mL/100g/min)
%
%       x(2)          MTT           Mean transit time (units: s)
%
%        t            time          Time vector of data collection (units: s)
%
%        Cp           VIF           Concentration of Gd in blood (units: mM)
%
%        hf         hematocrit      Ratio between the hematocrit of large and
%                   fraction        small blood vessels defined as (1-ha)/(1-hc)
%                                   where ha and hc are the hematocrits of
%                                   arterial vessels and capillaries,
%                                   respectively (units: unitless)
%
%        p          density         Tissue density (units: g/mL)
%
%
%   ~Note: no error checking is performed. This function assumes the
%   aforementioned quantities are in the proper units
%
%   See also gamma_var, exp_model_plot

%# AUTHOR    : Ryan Bosca
%# $DATE     : 27-May-2012 18:13:35 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.7.0.471 (R2008b)
%# FILENAME  : exp_model.m

% Determine time increment
deltaT = mean(diff(xdata));

% Convert units
p     = p/100;     %g/mL to 100g/mL
xdata = xdata/60;  %s to min
x(2)  = x(2)/60;   %s to min


% See A. Jackson, pg. 55, eq. 2 or Ostergaard et al 1996a. Note that the factor
% in front of the convolution comes from the need to normalize the time
% increments
c_t = (p/hf) * x(1) * deltaT * conv(c_a, exp(-xdata./x(2)));
c_t = c_t(1:length(xdata));