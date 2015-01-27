f = @(x) -GPobjFctn(y,t,x);
opts = optimset('MaxFunEvals',1000,'MaxIter',1000,...
              'PlotFcns',{@optimplotx,@optimplotfval,@optimplotfunccount});
f_min = fminsearch(f,[8 1 1],opts);

K = cov_gp(t,t,f_min);
t_new = linspace(t(1),t(end),1000);
for i = 1:length(t_new)
    K_star = cov_gp(t_new(i),t,f_min);
    y_new(i) = gpr(K,K_star,y);
end

figure; plot(t,y,'xr',t_new,y_new,'b');