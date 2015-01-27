function K = cov_gp(tr,tc,x,cov_fcn)
%cov_gp  Calculates covariance matrix
%
%   K = cov_gp(t,t_star,x) calculates the covariance function using a
%   squared exponential kernel where t is the independent variable, t_star
%   is the unknown independent, and x is the set of hyperparameters
%       x(1) - signal variance
%       x(2) - characteristic length scale
%       x(3) - noise variance
%
%   The independent variable should be a column vector. To produce K(T,T)
%   set t_star to t.

Nr = length(tr); Nc = length(tc);
if numel(tr) ~= Nr
    error('GaussianProcess:invalidVar',...
                       'The independent variable must be a column vector');
end
if (size(tr,2) ~= 1)
    tr = transpose(tr);
end
if numel(tc) ~= Nc
    error('GaussianProcess:invalidVar',...
                          'The independent variable must be a row vector');
end
if (size(tc,1) ~= 1)
    tc = transpose(tc);
end

% Get covariance function to use
f = get_cov_fcn(cov_fcn,x(1:2));

% Calculate the covariance matrix
K = zeros( Nr, Nc );
if Nc < Nr
    for i = 1:Nc
        K(:,i) = f(tr,tc(i));
    end
else
    for i = 1:Nr
        K(i,:) = f(tr(i),tc);
    end
end

if size(K,1)==size(K,2)
    K = K + eye(Nr)*x(3)^2;
end

function f = get_cov_fcn(f_str,x0)

switch lower(f_str)
    case 'se'
        f = @(tr,tc) x0(1)^2 * exp( -(tr-tc).^2/(2*x0(2)^2) );
    case 'ad'
        f = @(tr,tc) x0(1)^2 * exp(-abs(tr-tc)*x0(2)^2);
end