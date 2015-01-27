function ll = GPobjFctn(y,t,hyp,cov_f)

% Get self covariance
K = cov_gp(t,t,hyp,cov_f);

% Calculate log marginal likelihood
ll = marg_ll(K,y);