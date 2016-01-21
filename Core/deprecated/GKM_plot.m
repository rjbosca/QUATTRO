function ydata = GKM_plot(varargin)
%GKM_plot  Generates the tissue uptake from the general kinetic model
%
%   Ct = GKM_plot(X,T,CP,HCT) returns the tissue uptake curve using the GKM
%   where are inputs are equivalent to those for GKM, but the time vector and
%   VIF need not represent equally spaced data samples. This function is a more
%   robust version of GKM, which interpolates the vascular input function to
%   equally spaced data samples according to the time vector, which is
%   particularly helpful when using ezplot or fitting data that is missing time
%   points.
%
%   The use of GKM_plot is deprecated; it will be removed in a future release.
%   Use GKM_PLOT_VE instead.

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:00:49 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : GKM_plot.m

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use "gkm_plot_ve" instead.'],mfilename);

    % Calculate update
    ydata = gkm_plot_ve(varargin{:});

end %GKM_plot