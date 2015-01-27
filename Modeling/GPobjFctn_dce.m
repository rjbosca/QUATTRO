function ll = GPobjFctn_dce(S,t,t0,hyp)

% Necessary info
if isscalar(t0)
    t0 = 1:t0; %baseline image vector
end
if length(t0) ~= length(t)
    t = t(t0);
end

% Get self covariance
K = cov_gp(t,t,hyp,'ad');

% Calculate the mean for baseline pixels
mu_si = mean(S,2);
n = numel(S(:,1));

% Calculate log marginal likelihood
ll = 0;
for i = 1:size(S,1)
    x = squeeze((S(i,t0)-mu_si(i)))';
    ll = ll + -0.5*x'*K*x;
end

ll = ll + log( det(K)^(-n/2) );