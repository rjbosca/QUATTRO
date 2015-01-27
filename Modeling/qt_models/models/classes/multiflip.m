classdef multiflip < qt_models

    properties %general model properties

        % MR imaging repetition time in milliseconds
        tr

    end

    properties (Dependent = true)

        % Function used for model fitting
        %
        %   Function handle to the current VFA model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   flip angle).
        modelFcn

        % Function used for plotting the model
        %
        %   Calls the modelFcn property and is only here for code conformity.
        plotFcn

        % Flag for computation readiness
        %
        %   This flag is defined in all sub-classes of qt_models. However,
        %   because the "calcsReady" property of qt_models checks the x/y data
        %   of the object, no checks need be performed here.
        isReady

    end

    properties (Constant,Hidden = true)

        % Model names
        %
        %   A string cell array containing the names of the models. The location
        %   of each string specifies the index that should be used to access the
        %   actual model using the model property.
        %
        %   The qt_models GUI uses this property to populate the "Models" pop-up
        %   menu.
        modelNames = {'FSPGR'};

        % Semi-quantitative parameters
        %
        %   "otherParams" is a cell array of strings containing the specifier
        %   for all model parameters that can be computed without a non-linear
        %   fitting algorithm. These parameters are computed during the call to
        %   the "processFit" method. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'R1'            Longitudinal relaxation rate (units: 1/s)
        otherParams = {'R1'};

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell array of strings containing the specifier for
        %   each model parameter. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'S0'            Equilibrium magnetization (units: a.u.)
        %
        %       'T1'            Longitudinal relaxation time (units: ms)
        nlinParams = {{'S0','T1'}};

        % Parameter units
        %
        %   "paramUnits" is a cell array of strings specifying the units each of
        %   the parameters in the properties "nlinParams" and "otherParams"
        paramUnits = struct('S0','',...
                            'T1','milliseconds',...
                            'R1','1/second');

    end

    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = multiflip(varargin)
        %multiflip  Class for performing quantitative VFA T1 modeling
        %
        %   OBJ = multiflip(FA,Y,TR) creates a multiflip model object from the
        %   vector of data acquisition flip angles FA and flip angle dependent
        %   signal intensities (Y), returning the multiflip object, OBJ.
        %
        %   OBJ = multiflip(QTEXAM) creates a multiflip modeling object from the
        %   data stored in the qt_exam object QTEXAM. Associated QUATTRO links
        %   are generated if available.
        %
        %   OBJ = multiflip(...,'PROP1',VAL1,...) creates a multiflip modeling
        %   object as above, initializing the class properties specified by the
        %   properties 'PROP1' to the value VAL1
        %
        %
        %       Example
        %       =======
        %
        %       % Synthesize some noisy data
        %       S0 = 5000;   %proton density
        %       T1 = 250;    %relaxation time in ms
        %       tr = 5;      %repetition time in ms
        %       fa = 2:2:30; %flip angles
        %       SI = multi_flip([S0 T1],fa,tr);
        %       SInoisy = SI+5*rand(1,length(fa));
        %
        %       % Create a modeling object
        %       h = multiflip(fa,SInoisy,'tr',tr);
        %
        %       % Fit the model and show the results
        %       h.fit;
        %       fprintf('S0: %f\nEst. T1 (ms): %f\n\n',h.results.Params);
        %       figure; ezplot(h.results.Fcn,[0 30]);
        %       title('Results'); xlabel('Flip Angle'); ylabel('S.I.');
        %       hold on; plot(h.x,h.y,'xr');
        %       legend(gca,{'Fitted Model','Noisy Data'});

            % Construct VFA specific defaults
            obj.bounds = [0  inf
                          0 20000];
            obj.guess  = [1000 200];
            obj.xLabel = 'Flip Angle (deg.)';
            obj.yLabel = 'S.I. (a.u.)';

            % Parse the inputs
            if isempty(varargin)
                return
            end
            [props,vals] = parse_inputs(varargin{:});

            % Apply user-specified options
            for prpIdx = 1:length(props)
                obj.(props{prpIdx}) = vals{prpIdx};
            end

        end

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.isReady(obj)
            val = ~isempty(obj.tr);
        end %get.isReady

        function val = get.modelFcn(obj)

            % Cache the TR value so the function handle does not envoke the
            % "get" method for the property "tr"
            trVal = obj.tr;

            if obj.modelVal==1
                val = @(x,xdata) multi_flip(x(:),xdata,trVal);
            else
                error('qt_models:invalidModel',...
                                 'An invalid model name or value is specified');
            end

        end %get.modelFcn

        function val = get.plotFcn(obj)
            val = obj.modelFcn;
        end %get.plotFcn

    end %methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden = true)

        function val = process(obj,val) %#ok
            %proccess  Performs pre-processing on data to be fitted
            %
            %   process calculates signal inensity conversion for various
            %   qt_models sub-classes during calls to the "yProc" property of
            %   qt_models.
            %
            %   This method performs no processing for multiflip modeling
            %   objects and is here for code conformity as the "yProc" property
            %   of qt_models calls this method.
        end %process

        function val = processFit(obj,val)
            %processFit  Performs post-processing on fitted data
            %
            %   processFit(OBJ,VAL) constructs the "results" structure and
            %   calculates additional model parameters that are not otherwise
            %   computed by the "fit" method based on the estimated parameter
            %   array VAL. For VFA objects, the relaxation rate (R1) is
            %   calculated.

            % Determine if maps are being computed or if the user is performing
            % single data analysis
            isSingle = (numel(obj.x)==numel(obj.y));
            results  = obj.results;

            % Replace the map arrays with image objects for each map (and R^2)
            paramNames = [obj.modelParams(:);'RSq'];
            for mIdx = 1:numel(paramNames)
                switch paramNames{mIdx}
                    case 'R1' %process the R1 map
                        pData                      = 1000./val(2,:,:);
                        metaData.SeriesDescription = 'R1 relaxation rate map';
                    case 'S0'
                        pData                      = val(1,:,:);
                        metaData.SeriesDescription = 'Estimated therm. equil. map';
                    case 'T1'
                        pData                      = val(2,:,:);
                        metaData.SeriesDescription = 'T1 relaxation time map';
                    case 'RSq'
                        pData                      = val(end,:,:);
                        metaData.SeriesDescription = 'R Squared';
                end

                % Deal the data appropriately
                pUnits = ''; %default units
                if isfield(obj.paramUnits,paramNames{mIdx})
                    pUnits = obj.paramUnits.(paramNames{mIdx});
                end
                if ~isSingle

                    % Compute the window width and window center. These meta
                    % data fields are used to update the WW/WL when the qt_image
                    % object is constructed
                    pDataMin              = min( pData(~isnan(pData)) );
                    pDataMax              = max( pData(~isnan(pData)) );
                    metaData.WindowWidth  = (pDataMax-pDataMin);
                    metaData.WindowCenter = pDataMin + (pDataMax-pDataMin)/2;

                    results.(paramNames{mIdx}) =...
                                            qt_image(squeeze(pData),...
                                                     'metaData',metaData,...
                                                     'tag',paramNames{mIdx},...
                                                     'units',pUnits);
                else
                    results.(paramNames{mIdx}) = unit(pData,pUnits);
                end
            end

            % Store the results
            obj.results = results;

        end %processFit

        function val = processGuess(obj,val)

            % Only continue if autoGuess is enabled and y data exist
            if ~obj.autoGuess || isempty(obj.y)
                return
            end

            % Initialize the regressor and regressand for linear regression
            mY      = size(obj.yProc);
            [xi,yi] = deal(zeros(mY(1),prod(mY(2:end))));
            for idx = 1:mY(1)
                yi(idx,:) = obj.yProc(idx,:)./tand(obj.xProc(idx));
                xi(idx,:) = obj.yProc(idx,:)./sind(obj.xProc(idx));
            end

            % Estimate S0 and T1 from ordinary least squares using the
            % linearization proposed by R Gupta (J Magn Reson 1977;25:231-235).
            % Namely, y=mx+b where y=SI/sin(FA) and x=SI/tan(FA). The values m
            % and b are defined as exp^(-TR/T1) and S0*(1-m), respectively
            val = nan(2,prod(mY(2:end)));
            for idx = 1:prod(mY(2:end))
                if all( xi(:,idx) & yi(:,idx) )
                    val(:,idx) = ols(yi(:,idx),xi(:,idx));
                end
            end

            % Transform the model estimates from the linearized form to S0 and
            % T1 using the inverse of the relationships defined above.
            val = [val(1,:)./(1-val(2,:));-obj.tr./log(val(2,:))];

            % Reshape the initial guess according to the orignal size of the
            % processed data
            val = reshape(val,[2 mY(2:end)]);

        end %processGuess

        function val = processShow(obj,val) %#ok
        %processShow  Perform sub-class specific "show" operations
        %
        %   processShow(OBJ) performs display operations specific to the
        %   multifilp object OBJ following a call to the qt_models method "show"
        %
        %   This method performs no additional show operations for multiflip
        %   modeling objects and is here for code conformity as the "show"
        %   method of qt_models calls this method
        end %processShow

    end %methods (Access = 'private', Hidden = true)

end %classdef


function varargout = parse_inputs(varargin)

    % Determine input syntax (either qt_exam object or FA/signal)
    parser = inputParser;
    if strcmpi(class(varargin{1}),'qt_exam')
        parser.addRequired('hExam',@(x) x.isvalid);
        opts = varargin(2:2:end);
    elseif nargin==1
        error(['qt_models:' mfilename ':invalidExamObj'],...
                        'Single input syntax requires a valid qt_exam object.');
    else
        parser.addRequired('x', @isnumeric);
        parser.addRequired('y', @isnumeric);
        parser.addRequired('tr',@(x) isnumeric(x) && (numel(x)==1));
        opts = varargin(4:2:end);
    end

    % Add additional options to the parser
    if ~isempty(opts)

        % Validate the options
        obj   = eval( mfilename );
        props = properties(obj);
        opts  = cellfun(@(x) validatestring(x,props),opts,...
                                                         'UniformOutput',false);

        % Assign the options to the parser
        for prop = opts(:)'
            parser.addParamValue(prop{1},obj.(prop{1}));
        end

    end

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % When using the qt_exam syntax, populate the properties/values for the
    % qt_exam-derived data
    if ~isempty(results.hExam) && results.hExam.isvalid
        props = {'x','tr','guiDialogs'};
        for prop = props

            % The field is already populated. Since no defaults are used in
            % parsing the inputs and since user-specified options override exam
            % options, skip the current property if data exist in the parser
            % results
            if isfield(results,prop{1}) && ~isempty(results.(prop{1}))
                continue
            end

            switch prop{1}
                case 'guiDialogs'
                    results.(prop{1}) = results.hExam.guiDialogs;
                case 'tr'
                    results.(prop{1}) = results.hExam.metaData.RepetitionTime;
                case 'x'
                    results.(prop{1}) = results.hExam.modelXVals;
            end
            
        end
    end

    % Validate the units of the "x" property, assume degrees
    if isfield(results,'x') && ~strcmpi( class(results.x), 'unit' )
        warning(['qt_models:' mfilename ':nonUnitInput'],...
                ['For more robust operation, the flip angle vector should be',...
                 'of class "unit". Assuming angles have units of degrees...']);
        results.x = unit(results.x,'degrees');
        results.x = results.x.convert('degrees').value;
    elseif isfield(results,'x')
        try
            results.x = results.x.convert('degrees').value;
        catch ME
            rethrow(ME);
        end
    end

    % Deal the outputs
    varargout{1} = fieldnames(results);
    varargout{2} = struct2cell(results);

end