classdef qt_response < handle
%Multi-parameteric reponse classification class
%
%   Type "doc qt_response" for a summary of all properties and methods. For
%   property and method specific help type "help qt_response.<name>", where name
%   is the name of the specific property or method. For a list of properties or
%   methods, type "properties qt_response" or "methods qt_response",
%   respectively.

    properties %general user accessible properties

        % Predictor matrix
        %
        %   An m-by-n double precision array of m observations on n parameters. 
        %   Note that NaNs are not handled by ordinal models and are removed 
        %   before modeling occurs. Properties "x" and "y" are updated
        %   accordingly.
        x

        % Response matrix
        %
        %   An m-by-1 vector of numbers or strings specifying the categories for
        %   each of the m observations. For ordinal modeling, the order of
        %   responses must be specified in the options property if strings
        %   are being used.
        y

        % Response names
        %
        %   A 1-by-n cell array of strings containing the names of the predictor
        %   variables. This means the names will simply be the names of the
        %   columns of model(x).
        names

        % Category names
        %
        %   A 1-by-k cell array of strings containing the names of the
        %   categories of "y". This property is unused when "y" is numeric. For
        %   ordinal models, this "catNames" is used to order the categories such
        %   that
        %
        %       catNames{1} < catNames{2} <...< catNames{k}
        %
        %   When using trees, this property is only used to convert between
        %   numeric and cell arrays.
        catNames;

        % Index of covariates to use in training
        %
        %   A logical array of size 1-by-k that specifies which covariates to
        %   use in modeling (default: true(1,k)), where k is the number of
        %   predictors after the MODEL property has been applied. This is
        %   particularly useful when comparing predictions with different
        %   predictor variable combinations
        covIdx

        % Subset of observations to use in training
        %
        %   A logical array of size m-by-1 that specifies which observations
        %   should be used when training the algorithm. True specifies values
        %   that should be used, and false otherwise.
        subset

        % Algorithm used for training/predicting
        %
        %   A string containing the name of the fitting algorithm to be used for
        %   training or making predictions - one of 'ordinal' (default) or
        %   'trees'. Note that 'trees' option requires the statistics toolbox
        algorithm = 'ordinal';

        % Options used for training/predicting algorithm
        %
        %   A structure containing various options for the specified algorithm.
        %
        %   See also ordinalMLE and TreeBagger
        options

        % Results obtained from training the algorithm
        %
        %   A structure (ordinal) or class (trees) containing the results of
        %   predictions made from training data
        results

        % Statistical model
        %
        %   A function handle relating the the columns of the predictor matrix
        %   to the respoonse matrix. For example, for ordinal models, link(y) =
        %   B*f(x), where B are the regression coefficients, f is the function
        %   handle, and link is the link function (x and y have the usual
        %   meaning).
        %
        %   A common non-linear model used for treatment response is a
        %   difference operator. For the case where two measurements were made,
        %   each stored in consecutive columns of x, the following function
        %   handle will produce a model that probes the differences:
        %
        %   f = @(x) x(:,1:2:end)-x(:,2:2:end);
        %
        %   If no model is specified, a linear model (y = Bx) is used for
        %   ordinal modeling or the default TreeBagger model.
        model = identityFcn;

        % Treshold values for response data
        %
        %   A 2-by-n' array of thresholds, where the n'=size(model(x),2) (i.e.
        %   the columns), the first row of values represents the lower bounds
        %   and the second row the upper limits. Thresholds are applied before
        %   any modeling occurs. Values falling outsied of these limits are
        %   ignored when training and are given a NaN value when making
        %   predictions 
        thresholds = [];

        % Link function to use for ordinal modeling
        %
        %   One of 'logit' or 'probit'
        link = 'logit';

        % Flag for standardizing the observations
        %
        %   Logical value specifying whether predictor data should be
        %   standardized (i.e. converted to a mean of zero and standard
        %   deviation of one) prior to modeling, but after applying the
        %   function specified in the "model" property
        standardize = false;

        % Sample mean
        %
        %   A 1-by-n array containing the sample mean of the property "x" used
        %   to standardize the data before performing ordinal modeling. If no
        %   values are provided, then these values are automatically calculated
        %
        %   See also sampleStd standardize
        sampleMean

        % Sample standard deviation
        %
        %   A 1-by-n array containing the sample standard deviation of the
        %   property "x" used to standardize the data before performing ordinal
        %   modeling. If no values are provided, then these values are
        %   automatically calculated
        %
        %   See also sampleMean standardize
        sampleStd

        % Flag for using R
        %
        %   Logical value specifying whether modeling will be performed in
        %   MATLAB or R. For the latter, R must be installed on the system and
        %   include "R.matlab", "ordinal" and all other libraries associated
        %   with those two. Currently, only ordinal modeling is supported.
        %   Default: false
        useR = false;
    end

    properties (Dependent = true)
        % Pseudo R Square statistic for ordinal models
        %
        %   Calculates the pseudo R square statistic proposed by Nagelkerke. For
        %   more details, see:
        %
        %   [1] Nagelkerke NJD, Biometrika, 78 (3), pp. 691-692, 1991
        r2

        % Number of observations in each category
        %
        %   A 1-by-k vector containing the number of observations in each
        %   category.
        catN

        % Model accuracy
        %
        %   A 1-by-k vector of accuracy based on the fitted model. That is, the
        %   percentage of the training data placed in the correct category
        modelAcc
    end

    properties (Dependent = true, Hidden = true)

        % Number of categories
        k;

        % Number of modeled predictors
        %
        %   Nnumber of predictor variables used in the modeling.
        np;

        % Degrees of freedom for ordinal models
        %
        %   Degrees of freedom for the generalized linear model
        dof;

        % Processed x data
        %
        %   Same as the property "x", except processing such as applying
        %   thresholds and custom models and standardizing is performed here
        xProc;

        % Sample mean
        %
        %   Calculates the mean value of each covariate
        xMean

        % Sample standard deviation
        %
        %   Calculates the standard deviation of each covariate
        xStd

        % Processed y data
        %
        %   Same as the property "y", except processing such as applying
        %   thresholds and custom models is performed here
        yProc;

        % Index of observations to remove
        %
        %   Determines the locations of the m observations to remove. Removal
        %   occurs if NaN values are present in any of the n predictors of the
        %   mth observation or if any value of the mth predictor falls outside
        %   of thresholds specified in the "threshold" property.
        rmIdx;

        % Count matrix used to compute the likelihood
        countMat;

        % Link function function handle
        linkFcn;

        % Inverse link function function handle
        invLinkFcn;

        % Flag for computation readiness
        calcsReady;

    end

    properties (Hidden = true)

        % Local system's application directory
        %
        %   String specifying the location in which to store application data
        %   for communications between R and MATLAB
        appDir = pwd;

    end

    properties (SetAccess = 'protected', Hidden = true)

        % QUATTRO handle
        %
        %   Handle to an instance of QUATTRO
        hQt

        % Structure containing training results
        training

        % R-Link file name
        %
        %   Unique temporary file name for data and script files linking the
        %   qt_respnse object to R
        rLinkFile
    end

    properties (Constant, Hidden = true)
        validAlgorithms = {'ordinal','trees'};
        treeOpts        = {'nTrees','oobVarImp','oobPred','nPrint'};
        ordOpts         = {'order'};
    end

    events

        % newModel  Updates properties dependent on "model"
        %
        %   Validates the input model and updates other properties such as
        %   "covIdx" and "names" that depend on the output of "model"
        newModel

        % newSample  Updates properties associated with new observations
        %
        %   
        newSample
    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_response(varargin)
            %qt_response  Class for performing quantitative response predictions
            %
            %   h = qt_response(X,Y,ALGO) creates a quantitative response class
            %   with predictor variables X, response variable Y, using the
            %   algorithm specified by the string ALGO.
            %
            %   h = qt_response(hq) creates a quantitative response class
            %   associated with the instance of QUATTRO specified by the
            %   handle hq

            % Attach response object updater
            response_updater(obj);

            if nargin==3
                [obj.x,obj.y,obj.algorithm] = deal(varargin{:});
            else
            end

            % Initialize the link file
            [~,obj.rLinkFile] = fileparts(tempname);

        end %qt_response

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.calcsReady(obj)

            val = false; %initialize

            % Validate x
            if isempty(obj.x) || (size(obj.x,1)~=size(obj.y,1))
                warning('qt_response:invalidX',...
                        'Missing "x" data or incommensurate "x" and "y"');
                return
            end

            % Validate y
            if isempty(obj.y) || (size(obj.y,1)~=size(obj.x,1))
                warning('qt_response:invalidY',...
                        'Missing "y" data or incommensurate "x" and "y"');
                return
            end

            % Check for NaNs 
            if strcmpi(obj.algorithm,'ordinal') && any( isnan(obj.x(:)) )
                warning('qt_response:invalidXvals',...
                        'NaNs detected. These observations will be ignored.');
            end

            % Verify the category names are available
            if iscell(obj.y) && ischar(obj.y{1}) && isempty(obj.catNames)
                warning('qt_response:missingCatNames',...
                        '"catNames" must be specified for string responses');
                return
            end

            % Validate the algorithm/computation selections
            if strcmpi(val,'trees') && obj.useR
                warning('qt_response:invalidOptCombo',...
                       ['TreeBagger computations are currently supported in R.\n',...
                        'Disabling R computations for this session.']);
                obj.useR = false;
                return
            end

            % Actual output
            val = true;

        end %get.calcsReady

        function val = get.catN(obj)

            val = zeros(1,obj.k);
            c   = obj.yProc;
            if iscell(c)
                c = obj.response2mat(c);
            end
            for cIdx = 1:obj.k
                val(cIdx) = sum(c==cIdx);
            end

        end %get.catN

        function val = get.countMat(obj)

            % Get the y data and prepare the output
            yData = obj.yProc;
            n     = numel(yData);
            val   = zeros(n,obj.k);

            % Distribute the counts
            for idx = 1:n
                val(idx,yData(idx)) = 1;
            end

        end %get.countMat

        function val = get.covIdx(obj)

            val = obj.covIdx;
            if isempty(val) && ~isempty(obj.x) %default
                val = true(1,size(obj.model(obj.x),2));
            end

        end %get.covIdx

        function val = get.dof(obj)
            val = sum(~obj.rmIdx & obj.subset)-(obj.np+obj.k-1);
        end %get.dof

        function val = get.invLinkFcn(obj)

            switch obj.link
                case 'logit'
                    val = @(x) 1./(1+exp(-x));
                case 'probit'
                    val = @(x) 1/2*(1+erf(x/sqrt(2)));
                otherwise
                    error('QUATTRO:qt_response:invalidLink',...
                                                     'Invalid link specified.');
            end

        end %get.invLinkFcn

        function val = get.k(obj)
            val = numel( unique(obj.y) );
        end %get.k

        function val = get.linkFcn(obj)

            switch obj.link
                case 'logit'
                    val = @(x) log(x/(1-x));
                case 'probit'
                    val = @(x) sqrt(2)*erfinv(2*x-1);
                otherwise
                    error('QUATTRO:qt_response:invalidLink',...
                                                     'Invalid link specified.');
            end

        end %get.linkFcn

        function val = get.modelAcc(obj)

            % Initialize
            val = [];
            if ~isfield(obj,'training') && ~isfield(obj.training','fitCat')
                return
            end

            % Perform the computation
            val  = nan(2,obj.k);
            c    = obj.yProc;
            if iscell(c)
                c = obj.response2mat(c);
            end
            pC       = obj.training.fitCat;
            if iscell(pC)
                pC = obj.response2mat(pC);
            end
            pred     = (c==pC); %correct predictions
            if strcmpi(obj.algorithm,'ordinal')
                pCNull   = obj.training.fitCatNull;
                predNull = (c==pCNull);
            end
            for cIdx = 1:obj.k
                nC = sum(c==cIdx); %number in category cIdx
                if nC~=0
                    val(1,cIdx) = sum(pC==cIdx & pred)/nC*100;
                    if strcmpi(obj.algorithm,'ordinal')
                        val(2,cIdx) = sum(pCNull==cIdx & predNull)/nC*100;
                    end
                end
            end
                                    
        end %get.modelAcc

        function val = get.np(obj)
            val = 0;
            if ~isempty(obj.x)
                xP  = obj.model(obj.x(1,:));
                val = numel( xP(obj.covIdx) );
            end
        end %get.np

        function val = get.options(obj)

            % Only return the options if they exist
            val = obj.options;
            if ~isempty(obj.options)
                return
            end

            % Initialize options if necessary
            obj.options = struct('nTrees',250,...
                                 'oobVarImp','on',...
                                 'oobPred','on',...
                                 'nPrint',1);

            % Remove algortihm type specific options
            switch obj.algorithm
                case 'trees'
                    val = rmfields(obj.options,obj.ordOpts);
                case 'ordinal'
                    val = rmfields(obj.options,obj.treeOpts);
                otherwise
            end

        end %get.options

        function val = get.r2(obj)
            val = [];
            if isempty(obj.training) || ~strcmpi(obj.algorithm,'ordinal')
                return
            end

            % Get the values needed for R2 computation
            n   = size(obj.x(obj.subset & ~obj.rmIdx,:),1);
            ll  = obj.training.logLike;
            ll0 = obj.training.logLikeNull;

            % Calculate Nagelkerke R square
            R2max = 1-exp(2/n*ll0);
            R2    = 1-exp(2/n*(ll0-ll)); %eq. (1b)
            val   = R2/R2max;

        end %get.r2

        function val = get.rmIdx(obj)

            % Initialize
            val = [];
            nP  = obj.np;
            if nP==0
                return
            end

            % Create a logical vector of columns of x that are already NaNs or
            % are outside of the thresholds
            xP  = obj.model(obj.x);
%             val = any(isnan(xP(:,obj.covIdx)),2) | obj.processThresh(xP);
            val = any(isnan(xP),2) | obj.processThresh(xP);

            % Update empty "subset" indices
            if isempty(obj.subset)
                obj.subset = true(size(val));
            end

        end %get.rmIdx

        function val = get.xMean(obj)

            % Only perform the computations if needed
            if ~isempty(obj.sampleMean) || isempty(obj.x)
                val = obj.sampleMean;
                return
            end

            % Remove NaNs and other user-specified values
            val = obj.x(~obj.rmIdx & obj.subset,:);
            if ~isempty(val)
                % Apply the model
                val = obj.model(val);

                % Calculate mean and store for later use
                val = mean(val);
                obj.sampleMean = val;
            end

        end %get.xMean

        function val = get.xStd(obj)

            % Only perform the computations if needed
            if ~isempty(obj.sampleStd) || isempty(obj.x)
                val = obj.sampleStd;
                return
            end

            % Remove NaNs and other user-specified values
            val = obj.x(~obj.rmIdx & obj.subset,:);
            if ~isempty(val)
                % Apply the model
                val = obj.model(val);

                % Calculate standard deviation and store for later use
                val = std(val);
                obj.sampleStd = val;
            end

        end %get.xStd

        function val = get.xProc(obj)

            % Validate data before trying anything
            val = obj.x;
            if isempty(obj.x)
                return
            end

            % Remove NaNs and other user-specified values
            val = val(~obj.rmIdx & obj.subset,:);
            if isempty(val)
                error('qt_response:invalidXdata',...
                     ['X contains all NaNs or the "threshold" ',...
                                                'property is improperly set.']);
            end

            % Apply the model
            val = obj.model(val);
            val = val(:,obj.covIdx); %apply the covIdx

            % Perform standardization
            if obj.standardize
                val = (val-repmat(obj.xMean(obj.covIdx),size(val,1),1))./...
                                     repmat(obj.xStd(obj.covIdx),size(val,1),1);
            end

        end %get.xProc

        function val = get.yProc(obj)

            % Validate the data before trying anything
            val = obj.y;
            if isempty(obj.y)
                return
            end

            % Remove NaNs
            val = val(~obj.rmIdx & obj.subset);

            % Make the string->number conversion
            if strcmpi(obj.algorithm,'ordinal') && ~isnumeric(obj.y)
                val    = obj.response2mat(val);
                valRef = obj.response2mat(obj.catNames);
            end

            % "y" should always start with 1; ensure that happens
            if ~iscell(val) && exist('valRef','var')
                val = val-min(valRef)+1;
            end

        end %get.yProc

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.algorithm(obj,val)

            % Validate the algorithm value
            val = validatestring(val,obj.validAlgorithms);
            if strcmpi(val,'trees') && isempty(ver('stats'))
                warning('qt_response:missingToolbox',...
                        'This analysis tool requires the Statistics toolbox.');
                return
            end

            % Update the property
            obj.algorithm = val;

        end %set.algorithm

        function set.model(obj,val)

            % Grab the original model and set the new value
            valOrig   = obj.model;
            obj.model = val;
            
            % Notify of the new model
            notify(obj,'newModel',event_orginal_value(valOrig));

        end %set.model

        function set.subset(obj,val)

            obj.subset = val;
%             notify(obj,'newSample');

        end %set.subset

        function set.useR(obj,val)

            % No need to validate the value of "false"
            if ~val
                obj.useR = val;
                return
            end

            % Attempt to use R
            strAttempt = evalc('!Rscript --version');
            if ~strcmpi(strAttempt(1:11),'R scripting')
                warning('qt_response:rlink:missingR',...
                       ['Unable to launch "Rscript.exe".\n',...
                        'Verify R is installed and ...\R_HOME\bin '...
                        'is on the system path.\n R will not be used.']);
                return
            end

            obj.useR = val;

        end %set.useR

        function set.x(obj,val)

            obj.x = val;
%             notify(obj,'newSample');

        end %set.x

    end
end