function x0 = fspgr_vfa_ols(x,y,tr)
%fspgr_vfa_ols  Estimates S0 and T1 from VFA FSPGR data
%
%   X0 = fspgr_vfa_ols(FA,SI,TR) estimates the FSPGR model parameters S0 and T1
%   from variable flip angle (FA) signal intensities (SI) using the MR imaging
%   repetition time (TR) specified in milliseconds. FA is a column vector of N
%   flip angles in degrees and SI is an N-by-M array, where M specifies the
%   numebr of measurements. The estimated model parameters are returned in the
%   2-by-M array X0 where the first row is the estimated S0 and the second is T1

    % Initialize the regressor and regressand for linear regression
    mY      = size(y);
    [xi,yi] = deal(zeros(mY(1),prod(mY(2:end))));
    for idx = 1:mY(1)
        yi(idx,:) = y(idx,:)./tand(x(idx));
        xi(idx,:) = y(idx,:)./sind(x(idx));
    end

    % Estimate S0 and T1 from ordinary least squares using the linearization
    % proposed by R Gupta (J Magn Reson 1977;25:231-235). Namely, y=mx+b where
    % y=SI/sin(FA) and x=SI/tan(FA). The values m and b are defined as
    % exp^(-TR/T1) and S0*(1-m), respectively
    x0 = nan(2,mY(2));
    for idx = 1:mY(2)
        if all( xi(:,idx) & yi(:,idx) )
            x0(:,idx) = ols(yi(:,idx),xi(:,idx));
        end
    end

    % Transform the model estimates from the linearized form to S0 and T1 using
    % the inverse of the relationships defined above.
    x0 = [x0(1,:)./(1-x0(2,:));-tr./log(x0(2,:))];

end %fspgr_vfa_ols