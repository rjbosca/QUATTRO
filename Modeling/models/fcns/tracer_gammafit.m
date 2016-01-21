function x = tracer_gammafit(c,t,t0,tf,x0)
%tracer_gammafit  Fits a gamma variate
%
%   X0 = tracer_gammafit(C,T,T0) attempts to fit a gamma variate to the tracer
%   time course specified by C, with time vector T and the number of baseline
%   (i.e., pre-contrast) time frames
%
%   X0 = tracer_gammafit(...,TF) performs the fitting operation as described
%   above, ignoring all data occuring after the time frame index specified by
%   TF.
%
%   X0 = tracer_gammafit(...,TF,X0) performs the fitting operation as described
%   above, using the vector of gammar variate parameters (X0) as the initial
%   guess for the non-linear fitting algorithm

    % Validate the inputs
    narginchk(2,5);

    % Get some necessary parameters
    t = t'; %enforce column vector
    c = reshape(c,size(t));

    if ~exist('tf','var') || isempty(tf)
        maxT  = find(c==max(c));
        maxT  = maxT(end);
        [~,tf] = min( abs(c(maxT:end)-c(maxT)/2) );
        tf     = tf+maxT;
    end
    if (tf>length(c))
        tf = length(c);
    end

    if (nargin<5)
        x0 = [max(c)/2,3.26,1.02,t(t0)];
    end

    % Store function handle and options
    fcn = @(x,t) gamma_var(x,t);
    opts = statset('FunValCheck','off');

    % Fit data
    if ~isempty(x0)
        x = x0;
    else
        x = nlinfit(t(1:tf), c(1:tf), fcn, x0, opts);
    end
    if isempty(x0) && (any( imag(x) ) || any( isnan(x) ) || any( isinf(x) ) ||...
                                         all(x0==x) || any(x>10000) || any(x<0))
        wgtFcns = {'Bisquare','Andrews','Cauchy','Fair','Huber',...
                                             'Logistic','Talwar','Welsch'};
        for fcnIdx = wgtFcns(:)'
            opts = statset('Robust','on','WgtFun',fcnIdx{1},...
                           'MaxIter',2000,'FunValCheck','off');
            x = nlinfit(t(1:tf), c(1:tf), fcn, x0, opts);
            if ~any( imag(x) ) && all(x>0)
                break
            end
        end
    end
    try
        x = lsqcurvefit(fcn, x, t(1:tf), c(1:tf), zeros(1,4), inf(1,4));
    catch ME
        x = x0;
    end
    % Plot final data and fit
    % t_int = linspace(t(1),t(end),1000);
    % figure; plot(t,vif,'xr', t_int,fcn(x,t_int),'-b')

end %tracer_gammafit