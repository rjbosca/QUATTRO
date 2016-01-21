function ydata = GKM(varargin)
%GKM  Calculates tissue uptake cureve from the general kinetic model
%
%   Ct = GKM(x,t,Cp,hct) returns the tissue uptake curve using the general
%   kinetic model, where t is a vector of representing the time of acquisition
%   at each frame of the DCE series, Cp is the vascular input function, hct is
%   the hematocrit, and x is a 1-by-3 array of model parameters. 
%
%   The use of GKM is deprecated; it will be removed in a future release. Use
%   GKM_VE instead.

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 22:54:33 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : GKM.m

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use "gkm_ve" instead.'],mfilename);

    ydata = gkm_ve(varargin{:});

end %GKM