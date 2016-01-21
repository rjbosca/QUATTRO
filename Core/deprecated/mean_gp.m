function f_star = mean_gp(K,K_star,y)

Ny = length(y); Nstar = length(K_star);
if numel(y) ~= Ny
    error('GaussianProcess:invalidVar',...
                         'The dependent variable must be a column vector');
end
if (size(y,2) ~= 1)
    y = transpose(y);
end
if numel(K_star) ~= Nstar
    error('GaussianProcess:invalidVar',...
                            'The dependent variable must be a row vector');
end
if (size(K_star,1) ~= 1)
    K_star = transpose(K_star);
end

f_star = K_star*(inv(K)*y);