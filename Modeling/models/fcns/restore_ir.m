function [tiThresh,x0] = restore_ir(data,nlsS)
%restore_ir  Restores the polarity of VTI data
%
%   [YRes,X0] = restore_ir(Y,S) restores the polarity of the magnitude variable
%   inversion time (VTI) data Y using the non-linear estimation structure S (see
%   getNLSStruct for additional information). 
%
%   The following code was adopted from rdNlsPr
%
%   See also getNLSStruct

    % Initialize the variables
    [aEstTmp,bEstTmp,T1EstTmp,resTmp] = deal(zeros(1,2));
    data = data(:); %enfore a column vector

    % Find the min of the data
    [~,minInd] = min(data);

    % Perform the fit
    for ii = 1:2

        if (ii==1)
            % First, we set all elements up to and including the smallest
            % element to minus
            dataTmp = data.*[-ones(minInd,1); ones(nlsS.N - minInd,1)];
        elseif (ii==2)
            % Second, we set all elements up to (not including) the smallest
            % element to minus
            dataTmp = data.*[-ones(minInd-1,1); ones(nlsS.N - (minInd-1),1)];
        end

        % The sum of the data
        ySum = sum(dataTmp);

        % Compute the vector of rho'*t for different rho, where rho=exp(-TI/T1)
        % and y = dataTmp
        rhoTyVec = (dataTmp.'*nlsS.theExp).' - 1/nlsS.N*sum(nlsS.theExp,1)'*ySum;

        % rhoNormVec is a vector containing the norm-squared of rho over TI,
        % where rho=exp(-TI/T1), for different T1's.
        rhoNormVec = nlsS.rhoNormVec;

        % Find the max of the maximizing criterion
        [~,ind] = max( abs(rhoTyVec).^2./rhoNormVec );

        % The estimated parameters
        T1EstTmp(ii) = nlsS.T1Vec(ind);
        bEstTmp(ii)  = rhoTyVec(ind)/rhoNormVec(ind);
        aEstTmp(ii)  = 1/nlsS.N*(ySum - bEstTmp(ii)*sum(nlsS.theExp(:,ind)));

        % Compute the residual
        modelValue = aEstTmp(ii) + bEstTmp(ii)*exp(-nlsS.tVec/T1EstTmp(ii));
        resTmp(ii) = 1/sqrt(nlsS.N) * norm(1 - modelValue./dataTmp);

    end % of for loop

    % Finally, we choose the point of sign shift as the point giving the best
    % fit to the data, i.e. the one with the smallest residual 
    [~,ind] = min(resTmp);
    aEst    = aEstTmp(ind);
    bEst    = bEstTmp(ind);
    T1Est   = T1EstTmp(ind);

    % The overparameterized model (|a+b*exp(-TI/T1)|) parameters (a and b) can
    % be solved to yield the thermal equilibrium signal intensity and inversion
    % flip angle, giving a=S0 and theta=acos(b/a-1).
    x0 = [aEst,T1Est,acos(bEst/aEst-1)];

    % The same model, can be solved to yield TI_null: T1*log(b/a)
    tiThresh = T1Est*log(-bEst/aEst);

end %restore_ir