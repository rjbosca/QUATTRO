function ll = marg_ll(K,y)

N = length(y);
if numel(y) ~= N
end
if size(y,2)~=1
    y = transpose(y);
end

ll = -1/2*transpose(y)*inv(K)*y +...
     -1/2*log(det(K)) +...
     -N/2*log(2*pi);