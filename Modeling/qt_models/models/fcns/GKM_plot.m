function ydata = GKM_plot(x,xdata,vif,hct)
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
% See also GKM

%# AUTHOR    : Ryan Bosca
%# $DATE     : 16-May-2013 23:00:49 $
%# $Revision : 1.02 $
%# DEVELOPED : 7.13.0.564 (R2011b)
%# FILENAME  : GKM_plot.m

    % Determine the size of the VIF and tissue uptake curves and ensure
    % comensurate data sizes
    nXdata = numel(xdata);
    nVif   = numel(vif);
    if nXdata > nVif
        xNew = linspace(min(xdata),max(xdata),nVif);
        vif  = interp1(xNew,vif,xdata,'spline');
    elseif nVif > nXdata
        xNew = linspace(min(xdata),max(xdata),nXdata);
        vif  = interp1(xNew,vif,xdata,'spline');
    end

    % Calculate update
    ydata = GKM(x,xdata,vif,hct);

end %GKM_plot