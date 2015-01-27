function x = tracer_gammafit(f,c,t,t0,x0)

% Get some necessary parameters
t = t';
if exist('c','var')
    vif = c; vif = reshape(vif,size(t));
end

if ~exist('f','var') || isempty(f)
    max_t = find(vif==max(vif)); max_t = max_t(end);
    [dump f] = min( abs(vif(max_t:end)-vif(max_t)/2) ); f = f+max_t;
end
if f>length(vif)
    f = length(vif);
end

if ~exist('x0','var')
    x0 = [max(vif)/2,3.26,1.02,t(t0)];
end

% Store function handle and options
fcn = @(x,t) gamma_var(x,t);
opts = statset('FunValCheck','off');

% Fit data
x = nlinfit(t(1:f), vif(1:f), fcn, x0, opts);
if any( imag(x) ) || any( isnan(x) ) || any( isinf(x) ) ||...
                                 all(x0==x) || any(x>10000) || any(x<0)
    wgt_fcns = {'Bisquare','Andrews','Cauchy','Fair','Huber',...
                                         'Logistic','Talwar','Welsch'};
    for i = 1:length(wgt_fcns)
        opts = statset('Robust','on','WgtFun',lower(wgt_fcns{i}),...
                          'MaxIter',2000,'FunValCheck','off');
        x = nlinfit(t(1:f), vif(1:f), fcn, x0, opts);
        if ~any( imag(x) )
            break
        end
    end
end
try
    [x ss_err, residual] = lsqcurvefit(fcn, x, t(1:f), vif(1:f));
catch ME
    x = x0;
end
% Plot final data and fit
% t_int = linspace(t(1),t(end),1000);
% figure; plot(t,vif,'xr', t_int,fcn(x,t_int),'-b')