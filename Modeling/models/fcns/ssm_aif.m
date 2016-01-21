function vif = ssm_aif(x,t)
%ssm_aif  Shutter-speed model AIF
%
%   AIF = ssm_aif(X0,T) generates the arterial input function (AIF) using the
%   time vector T and the model parameters X0

    vif = x(1)*( (x(2)*x(3).^t.*exp(-x(4)*t)) + (x(5)*(1-exp(-x(6)*t))+x(7)));

end %ssm_aif