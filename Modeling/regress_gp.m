function varargout = regress_gp(t,y,n,hyp)
%regress_gp  Performs Gaussian process regression
%
%   f* = regress_gp(t,y) performs Gaussian process regression given the
%   dependent/independent variables t/y.
%
%   [t* f*] = regress_gp(t,y,n,hyp) performs Gaussian process regression on
%   the data, y, with independent variable t, using n points. Hyperparameters
%   are determined by maximizing the marginal log likelihood.
%
%   [t* f* hyp] = regress_gp(...) performs Gaussian process regression
%   returning the optimized hyperparameters.

if ~exist('hyp','var')
    hyp = [];
end

% opts = optimset('MaxFunEvals',3000,'MaxIter',3000,...
%               'PlotFcns',{@optimplotx,@optimplotfval,@optimplotfunccount});
opts = optimset('MaxFunEvals',3000,'MaxIter',3000);
if isempty(hyp)
    f = @(x) -GPobjFctn(y,t,x,'ad');
    f_min = fminsearch(f,[16 1 1],opts);
elseif length(hyp)==1 && all(~isinf(hyp))
    f = @(x) -GPobjFctn(y,t,[hyp x],'se');
    f_min = fminsearch(f,[5 50],opts);
    f_min = [hyp f_min];
elseif length(hyp)==2 && all(~isinf(hyp))
    f = @(x) -GPobjFctn(y,t,[hyp x]);
    f_min = fminsearch(f,1,opts);
    f_min = [hyp f_min];
elseif length(hyp)==2 && any(isinf(hyp))
    f = @(x) -GPobjFctn(y,t,[x(1) hyp(2) x(2)]);
    f_min = fminsearch(f,[16 1],opts);
    f_min = [f_min(1) hyp(2) f_min(2)];
elseif length(hyp)==3 && any(isinf(hyp))
    f = @(x) -GPobjFctn(y,t,[x hyp(3)]);
    f_min = fminsearch(f,[16 1],opts);
    f_min = [f_min hyp(3)];
else
    f_min = hyp;
end

K = cov_gp(t,t,f_min,'se');
if exist('n','var') && ~isempty(n)
    t_new = linspace(t(1),t(end),n);
else
    t_new = t;
end

for i = 1:length(t_new)
    K_star = cov_gp(t_new(i),t,f_min,'se');
    y_new(i) = gpr(K,K_star,y);
end

if nargout==1
    varargout{1} = y_new;
else
    [varargout{1:2}] = deal(t_new,y_new);
end
if nargout>2
    varargout{3} = f_min;
end