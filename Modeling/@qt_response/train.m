function varargout = train(obj)
%train  Trains a qt_reponse classification algorithm
%
%   train performs model traning on response/predictor variables using the
%   model, if any, specified by the "model" property. Results of the model are
%   stored in the property "training"
%
%   s = train performs the above tasks without storing the results. Instead,
%   these data are returned in the structure s.

% Validate readiness
if ~obj.calcsReady
    return
end

% Get the processed x-data and ensure y is properly formatted
x = obj.xProc;
y = obj.yProc;

switch obj.algorithm
    case 'ordinal'

        % Data common to R and MATLAB computations
        N = obj.countMat;

        % Perform the fits
        if ~obj.useR

            % On occasion, the covariance matrix becomes singular within the
            % ordinalMLE. To combat this, I've programmed that function to
            % return a logical array specifying which indices should be removed.
            % This while loop performs the parameter estimation, removing bad
            % data points and updating the property "subset" accordingly.
            [B,cv,~,dvR,pi0]      = ordinalMLE([y x],obj.k,obj.link);
            [BNull,~,~,~,pi0Null] = ordinalMLE(y,obj.k,obj.link);
            while islogical(B)
                % Remove bad indices if needed
                obj.subset = obj.subset & ~B;
                x = obj.xProc;
                y = obj.yProc;

                [B,cv,~,dvR,pi0] = ordinalMLE([y x],obj.k,obj.link);
            end
            [~,pC] = max(pi0,[],2);
            [~,pCNull] = max(pi0Null,[],2);
            d1 = [];
        else
            % Prepare the link data
            names = obj.names(obj.covIdx); %#ok<*NASGU>
            order = obj.catNames;
            linkF = {obj.link};
            y     = arrayfun(@(x) order{x},y,'UniformOutput',false);

            % Write the R script
            obj.create_r_link;

            % The model string is a formatted string used by R to specify the
            % model inputs
            modelStr         = {['Response~' sprintf('%s+',names{:})]};
            modelStr{1}(end) = '';

            % Generate an evaluable statement for creating the data frame
            frameStr = sprintf('%s=x[,%%d],',names{:});
            frameStr = {['data.frame(Response=y,',...
                                       sprintf(frameStr,1:length(names)) ');']};
            frameStr{1}(end-2) = '';

            % Write the necessary data for R
            fid = fopen(fullfile(obj.appDir,[obj.rLinkFile '.dat']),'w');
            saveR(fullfile(obj.appDir,[obj.rLinkFile '.R']),...
                                         'frameStr','order','linkF','modelStr');
            for lIdx = 1:length(y)
                fprintf(fid,['"%s"\t' repmat('%f\t',[1 size(x,2)]) '\n'],...
                                                             y{lIdx},x(lIdx,:));
            end
            fclose(fid);

            % Run the script
            rStr = r_link(fullfile(obj.appDir,[obj.rLinkFile 'Script.R']));

            % Get the coefficients
            load(fullfile(obj.appDir,[obj.rLinkFile '.mat']));

            % Transform the fitted categories of strings into an array of
            % integers
            pC     = obj.response2mat(pC.fit);
            pCNull = obj.response2mat(pCNull.fit);

            % Edit the parameters. This is done because the implementation of
            % CLM in MATLAB fixes g0 to be 0 and instead estimates a B0.
            % However, the R implementation generates no B0 and applies a shift
            % to all indicator variables (i.e. the g's)
            B        = [B(1:obj.k-1)-B(1); -B(1); B(obj.k:end)]; %#ok<*NODEF>
            B(1)     = []; %this value is fixed to zero and appended later in this fcn
            BNull    = [BNull(1:obj.k-1)-BNull(1); -BNull(1); BNull(obj.k:end)]; %#ok<*NODEF>
            BNull(1) = [];
            BNull(end+1:length(B)) = 0; %needed to conform to the computation of pi in "predict"

            % Calculate the deviance residuals since this is not done in the R
            % package 'ordinal'
            pi0     = obj.predict(obj.x,[0;B(1:obj.k-2)],B(obj.k-1:end));
            pi0     = pi0(~obj.rmIdx & obj.subset,:);
            pi0Null = obj.predict(obj.x,[0;BNull(1:obj.k-2)],BNull(obj.k-1:end));
            pi0Null = pi0Null(~obj.rmIdx & obj.subset,:);
            dvR  = 2*sum( N.*log((N+eps)./...
                                      ((sum(N,2)*ones(1,obj.k)).*pi0+eps)), 2 );

            % Calculate the probability ratio
            d1 = exp((d1(1)-d1(2:end))/2);

            % Perform the file clean up
            try
                delete( fullfile(obj.appDir,[obj.rLinkFile '.dat']) );     %R data
                delete( fullfile(obj.appDir,[obj.rLinkFile '.R']) );       %R commands
                delete( fullfile(obj.appDir,[obj.rLinkFile 'Script.R']) ); %R script
                delete( fullfile(obj.appDir,[obj.rLinkFile '.mat']) );     %Output
            catch ME
            end

        end

        % Calculate the log-likelihood
        ll     = sum(N(pi0>0).*log(pi0(pi0>0)));
        llNull = sum(N(pi0Null>0).*log(pi0Null(pi0Null>0)));

        % Store the regression results
        s = struct('indVar',    [0; B(1:obj.k-2)],...
                   'B',          B(obj.k-1:end),...
                   'indVarNull',[0; BNull(1:obj.k-2)],...
                   'BNull',      B(obj.k-1:end),...
                   'cov',        cv,...
                   'dev',        sum(dvR),...
                   'devRes',     dvR,...
                   'drop1',      d1,...
                   'fitCat',     pC,...
                   'fitCatNull', pCNull,...
                   'logLike',    ll,...
                   'logLikeNull',llNull);

    case 'trees'
        b = TreeBagger(obj.options.nTrees,x,y,...
                       'oobvarimp',obj.options.oobVarImp,...
                       'oobpred',  obj.options.oobPred,...
                       'NPrint',   obj.options.nPrint);

        % Calculate the category predictions
        pC = b.predict(obj.xProc);

        % Store the results
        s = struct('b',b,...
                   'fitCat',obj.response2mat(pC));
end

% Determine what to do with the data
if nargout
    varargout = {s};
else
    obj.training = s;
end