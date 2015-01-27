function varargout = predict(obj,newX,varargin)
%predict  Perform predictions on a trained qt_response object
%
%   predict(X) performs classification on the array X based on a trained data
%   (i.e., training was performed on the data stored in the property "x"). This
%   array must contain the same number of columns as the property "x" and be 
%   amenable to the operations of the property "model"
%
%   predict(X,G,B) performs ordinal classification on the array X based on the
%   threshold indices G and regression parameters B. G will be a K-by-1 array
%   and B will be an N-by-1 vector, where K is the number of categories and N is
%   the number of covariates plus one.
%
%   score = predict(...) returns the individual category probabilities. If an
%   output is not requested, the scores are stored under the "results" property
%   of the qt_response object.
%
%   Note: if thresholds are present, predict attempts to apply them to the input
%   data set. Set the thresholds to empty if this is undesired functionality.

if nargin==1
    error('qt_response:noX','%s\n%s','At least on input is required.',...
                    'Please supply an array of data for creating predictions.');
elseif nargin>2
    [g,B] = deal(varargin{:});
    B     = B(:); %force column vector
    g     = g(:);
end

% Prediction inputs should be an m-by-n array where m is an arbitrary number of
% observations and n=size(obj.x,2)
nx = size(obj.x);
nX = size(newX);
if (nX(2)~=nx(2)) && (nx(2)==nX(1))
    newX  = newX';
elseif (nX(2)~=nx(2))
    error('qt_response:invalidY','Incommesurate Y');
end
    
% Remove any columns of x that are flagged by user, are NaNs, or are
% outside of the thresholds
newX(any(isnan(newX),2),:) = NaN;

% Apply the user specified indices and model and perform thresholding
newX                            = obj.model(newX);
newX(obj.processThresh(newX),:) = NaN;
newX(:,~obj.covIdx)             = [];

% Perform standardization (i.e. (X-<X>)/<X^2>)
if obj.standardize
    ind  = all(~isnan(newX),2);
    nInd = sum(ind);
    newX(ind,:) = (newX(ind,:)-repmat(obj.sampleMean(obj.covIdx),nInd,1))./...
                                       repmat(obj.sampleStd(obj.covIdx),nInd,1);
end

% Perform the fitting
switch obj.algorithm
    case 'ordinal'
        % Set NaN values to zero, these will be tracked and removed later
        nanMask = any(isnan(newX),2);
        newX(nanMask,:) = 0;

        % Initialize the training variables
        if nargin<=2 && ~isempty(obj.training)
            g     = obj.training.indVar;
            B     = obj.training.B;
        end
        n = size(newX,1);
        z = nan(n,obj.k-1);

        % Create the predictions
        for idx = 1:obj.k-1
            z(:,idx) = g(idx)-B(1)-B(2:end)'*newX';
        end
        p = obj.invLinkFcn(z); %apply model to the z value
        p = diff([zeros(n,1) p ones(n,1)],1,2);

        % Reapply the NaN values
        p(nanMask,:) = NaN;
        [~,obj.results.y] = max(p,[],2);
        obj.results.y(nanMask) = NaN;
    case 'trees'
        [obj.results.y,p] = obj.training.b.predict(newX);
end

% Store the results
obj.results.score = p;

% Deal output
if nargout==1
    varargout{1} = p;
end