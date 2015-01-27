function show_latentres(obj)
%show_latentres  Construct normal probability plot for latent residuals

% Remove any columns of x that are flagged by user
x = obj.xProc;
y = obj.yNum;

% Append a column of ones (i.e. the zeroth order term) to the front of
% the predictors if needed
if ~all(x(:,1)==1)
    x = [ones(size(x,1),1) x];
end

% Ordinal modeling can't handle NaNs. Remove them.
n               = size(x,2);
nanMask         = repmat(obj.rmIdx,[1 n]);
x(nanMask)      = [];
x               = reshape(x,[],n);
y(nanMask(:,1)) = [];

m = 2000;
coeff = [obj.training.indVar(2:end);obj.training.B(:)];
if any( isnan(coeff) )
    warning('Unable to compute latent residuals')
    return
end
[sampleBeta,lat_resid,accept] = sampleOrdProb([y x],obj.k,coeff,m);

figure; norm_plot(lat_resid);