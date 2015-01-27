function varargout = ordinalMLE(data,K,link)
%ordinalMLE  Computes the MLE for ordinal regression of N on X.
%
%   Beta = ordinalMLE(X,K,link) computes the regression coefficients and cut-off
%   parameters Beta for the combined response/covariate matrix X of the form
%   [y x], where y is the ordinal response (1,2,...) and x is the covariate
%   matrix. The model is fitted to K categories using the link function
%   specified by the string link ('logit' or 'probit').
%
%   [Beta,COV,DEV,devRes,FIT] = ordinalMLE(...) also returns the covariance
%   matrix COV, the deviance statistic DEV, the individual components of the
%   individual components' deviance, and the fitted probabilites FIT.


%	Notation and algorithm based on Jansen, 91, 
%       Biometrical Journal, vol 33, 807-815.
%
%	N:	The count vector.  Assumed to have IxK rows, where I is the number of
%       treatments, and K is the number of categories.  The elements of the i^th
%       row contain the category counts for treatment combination i. Ji denotes
%       the number of observations in row i.
%	X:	Design matrix for linear regression of cumulative probabilities.  In
%       this parameterization, a column of 1's is likely required since the
%       first category cutoff is assumed to be 0.  X*mle is the MLE linear
%       predictor.  It does not contain category-cutoff indicators.

% Updates by Ryan Bosca
%~~~~~~~~~~~~~~~~~~~~~~
%
%   2014/01/18 - updated invLogit to calculate 1/(1+exp(-x)) instaed of
%                exp(x)/(1+exp(x)) to avoid issues with overflow
%
%   2014/01/19 - updated the computation of pi0. The calculations have been
%                vectorized in lieu of a for loop. This requires slightly more
%                memory because an array, jj, must be stored and is K times the
%                size of J

% Initialize output
[varargout{1:nargout}] = deal([]);

[N,X]=reformdata(data,K);

if ~any(strcmpi(link,{'logit','probit'}))
    error('invalid link specification in ordinalMLE') %#ok<*ERTAG>
end

[I,K] = size(N);
[I0,p] = size(X);

if I0~=I
    error('N and X are not compatibly sized')
end

J = sum(N,2); %(I x 1) vector
C = diag(ones(K-1,1))+diag(-1*ones(K-2,1),-1); C = [C;[zeros(1,K-2), -1]];
Zt = diag(ones(K-1,1));
Zmult = Zt; Zmult(1,1) = 0;  % used to form gammas in loop 
Zt = Zt(:,2:(K-1)); % left part of Z - get rid of first column since
    % theta_1 == 0.


% Initialize parameter vectors for iteratively reweighted least squares
mu = (J*ones(1,K)).*(N+0.5)./(J*ones(1,K)+K/2);
pi0 = ones(I,K);

sumMu        = cumsum(N+0.5,2);
sumMu(:,end) = []; %this would provide a column of ones, but is omitted to make
                   %the code conform to the original algorithm
jj           = repmat(J,[1 K-1]);
if strcmp(link,'logit')
    gam = log( (sumMu./(jj+K/2)) ./ (1-sumMu./(jj+K/2)) );
    pi0 = diff([zeros(size(J,1),1) invLogit(gam) ones(size(J,1),1)],1,2);
elseif strcmp(link,'probit')
    gam = Phiinv(sumMu./(jj+K/2));
    pi0 = diff([zeros(size(J,1),1) Phi(gam) ones(size(J,1),1)],1,2);
end
% add other link functions here if needed


% Initialize parameter vector; assume regression parameter is 0
alpha = zeros(K-2+p,1);
alpha(1:(K-2)) = (mean( gam(:,2:(K-1) ) ))';


logLike0 = 0;
change = 1;
iter = 0;

while (change>0.0001 && iter<31) ||  iter<4
    A = zeros(K-2+p,K-2+p);
    bb = zeros(K-2+p,1); % will equal sum_i Zi'Hi Ci'Vi(ni-mu_i)

    for i=1:I
        % Form Hi matrix.  Only it and pi0 depend on link
        if strcmp(link,'logit')  % use logistic density
            Hi = diag( exp(gam(i,:)) ./ (1+exp(gam(i,:))).^2 );
        elseif strcmp(link,'probit')   % use standard normal density
            Hi = diag( pdfnorm(gam(i,:),0,1) );
        end

        % Compute Ci
        Ci = J(i)*C;
        % Compute Zi
        Zi = [ Zt -ones(K-1,1)*X(i,:) ];
        % Compute Vi
        Vi = diag(ones(1,K)./mu(i,:));

        % Validate Vi - often a bad input will create inf values in Vi, which
        % result in NaN values later on down the line
        if any(isinf(Vi(:)))
            varargout{1} = all(mu==repmat(mu(i,:),I,1),2);
            warning('ordinalMLE:badData',...
                                   'Unable to compute regression coefficients');
            return
        end

        % Increment A and bb
        A = A + Zi'*Hi*Ci'*Vi*Ci*Hi*Zi;
        bb = bb + Zi'*Hi*Ci'*Vi*(N(i,:)-mu(i,:))';
    end

    alpha = alpha + A\bb;


    % Now compute pi0, gam, mu
    for i=1:I
        % compute Zi*alpha = gamma(i,k)
        gam(i,:) = ([Zmult -ones(K-1,1)*X(i,:)]*[0; alpha])';
    end

    if strcmp(link,'logit')
        pi0 = diff([zeros(size(J,1),1) invLogit(gam) ones(size(J,1),1)],1,2);
    elseif strcmp(link,'probit')
        pi0 = diff([zeros(size(J,1),1) Phi(gam) ones(size(J,1),1)],1,2);
    end
    % add other link functions here if needed
    

    mu = (J*ones(1,K).*pi0);

    logLike1 = ordLog(N,pi0);
    if logLike0 == 0
        change = - logLike1;
    else
        change = logLike1 - logLike0;
    end
    logLike0 = logLike1;
    iter = iter + 1;

end  

if iter == 30
    disp('No convergence after 30 iterations');
end

% Deal the outptus
if nargout>0
    varargout{1} = alpha; %mle
end
if nargout>1
    varargout{2} = inv(A); %cov
end
if nargout>2
    [dev,devRes] = ordDev(N,pi0);
    varargout{3} = dev;
end
if nargout>3
    varargout{4} = devRes;
end
if nargout>4
    varargout{5} = mu; %fits
end


function val=Phiinv(x)
% Computes the standard normal quantile function of the vector x, 0<x<1.
%
val=sqrt(2)*erfinv(2*x-1);


function y = Phi(x)
% Phi computes the standard normal distribution function value at x
%
y = .5*(1+erf(x/sqrt(2)));


function [dev,devRes] = ordDev(N,pi0)
% ordDev computes the deviance of N for probability vector pi0.
%
%	Notation and algorithm based on Jansen, 91, 
%       Biometrical Journal, vol 33, 807-815.
%
%	N:	The count vector.  Assumed to have IxK rows, where
%		I is the number of treatments, and K is the number of
%		categories.  The elements of the i^th row contain the
%		category counts for treatment combination i.
%       pi0:	I x K probability vector. 
%       dev:    Deviance of model
%       devRes: (UNSIGNED,UNSQUARE-ROOTED) contribution to deviance
%               from each observation.    
%
%	For simplicity, log-probability is actually computed for
%               pi0+eps
	
	K = size(N,2);
	denom = sum(N,2)*ones(1,K);
	devRes = 2*sum( (N.*log((N+eps)./(denom.*pi0+eps))), 2 );
	dev = sum(devRes);
   
function val = ordLog(N,pi0)
% ordLog computes the log-likelihood of N for probability vector pi0.
%
%	Notation and algorithm based on Jansen, 91, 
%       Biometrical Journal, vol 33, 807-815.
%
%	N:	The count vector.  Assumed to have IxK rows, where
%		I is the number of treatments, and K is the number of
%		categories.  The elements of the i^th row contain the
%		category counts for treatment combination i.
%       pi0:	I x K probability vector.  
%
%	For simplicity, log-probability is actually computed for
%               pi0+eps
	
	val = sum(N(:).*log(pi0(:)+eps));

function y = invLogit(x)
% INVLOGIT computes exp(x) / (1+exp(x)).  Extreme values are set to 0 or 1.

% Instead of computing the inverse logit as stated above, consider multiplying
% by a factor of exp(-x)/exp(-x). This avoids many of the issues with numeric
% overflow
y = 1./(1+exp(-x));

function [N,X]=reformdata(data,k)

    % Append a column of ones (i.e. the zeroth order model term)
    if (size(data,2)==1) || ~all(data(:,2)==1)
        data = [data(:,1) ones(size(data,1),1) data(:,2:end)];
    end

    y = data(:,1);
    n = size(data,1);
    c=size(data,2);
    X=data(:,2:c);
    N=zeros(n,k);
    for i=1:n
       N(i,y(i))=1;
    end

function val=pdfnorm(x,mu,sigma)

% Default standard normal
if nargin==1
    mu=0; sigma=1;
end
val=1/sqrt(2*pi)./sigma.*exp(-.5./sigma.^2.*(x-mu).^2);
