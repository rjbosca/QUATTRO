classdef modelbase < modelmetrics & modelevents & modelbaseopts &...
                                                           generalopts & depopts
%Quantitative data modeling class
%
%   Type "doc modelbase" for a summary of all properties and methods. For
%   property and method specific help type "help modelbase.<name>" where name is
%   the name of the property or method of interest. For a list of properties and
%   methods type "properties modelbase" or "methods modelbase"
%
%   Below is a brief description of the various models associated with each
%   exam type. All of these models require a non-linear fitting algorithm
%   to solve for the models' parameters. For more inforamtion on these models
%   type "help <model name>"
%
%
%   Modeling for certain data sets, such as those derived from DCE and DSC
%   exams, will require additional input parameters (e.g. VIF, TR, FA, etc.).
%   These modeling parameters are stored in the params property of modelbase,
%   which is exam specific. Before modeling can occur, all of this additional
%   information must be provided, either manually or in the context of modelbase
%   methods.
%   (see QUATTRO documentation).
%
%   Examples
%   --------
%
%   
%   See also QUATTRO

%# AUTHOR    : Ryan Bosca
%# $DATE     : 01-Aug-2013 20:24:48 $
%# $Revision : 1.01 $
%# DEVELOPED : 8.1.0.604 (R2013a)
%# FILENAME  : modelbase.m

    %------------------------------- Properties --------------------------------
    properties (SetObservable,AbortSet)

        % Map computation subset
        %
        %   "mapSubset" is a logical mask that is used to exclude data regions
        %   of a map during modeling with SIZE(MAPSUBSET)==[n1 n2...nm], where
        %   ni is the ith dimension of the response variable (i.e., "y").
        mapSubset

        % Model parameters bounds
        %
        %   "paramBounds" is a structure containing two-element row vectors of
        %   the form [LOW HIGH] corresponding to the non-linear parameters of
        %   the specified model. As with the "paramUnits" property, these bounds
        %   are usually initialized during construction of the super-class(es)
        %   of the specified model
        paramBounds = struct([]);

        % Model parameter units
        %
        %   "paramUnits" is a struture with fields specifying the model
        %   parameters and values corresponding to the the units of each
        %   parameter
        paramUnits = struct([]);

        % Dependent subset indices
        %
        %   "subset" is a column vector of array indices or a logical mask that
        %   is used to exclude data (e.g. outliers) during modeling, and must
        %   satisfy ALL(SIZE(SUBSET)==SIZE(X)). When a numeric array of indices
        %   is specified, the indicies are converted to a logical mask before
        %   updating the property.
        subset = true(0);

        % Predictor variable
        %
        %   "x" is a column vector of predictor (independent variable) values
        x

        % Response variable
        %
        %   "y" is an array containing the model's response (dependent variable)
        %   values with SIZE(Y)==[k n1 n2 ... nm], where ni is the ith dimension
        %   of the response variable and k=NUMEL(X).
        y

    end

    properties (Dependent)

        % Initial guess used for model fitting
        %
        %   "paramGuess" is a structure containing the numeric scalar to be used
        %   as the starting estimate corresponding to the non-linear parameters
        %   of the specified field
        paramGuess = struct([]);

    end

    properties (Transient,SetObservable,AbortSet)

        % Model fitting results
        %
        %   "results" is a structure containing field names corresponding to
        %   fitted model parameter in addition to fitting criteria. When
        %   computing parameter maps, each field will contain a QT_IMAGE object
        %   encapsulating the results. Otherwise the data will be stored in a
        %   UNIT object
        results = struct([]);

    end

    properties (Abstract)

        % Function used for model fitting
        %
        %   "modelFcn" is a function handle of the current model to be used in
        %   fitting data. The function handle is of the form @(X0,X) f(X0,X) 
        %   where X0 is a vector of model parameters and X is the dependent
        %   variable
        modelFcn

        % Function used for plotting the model
        %
        %   "plotFcn" a more robust function handle that supports non-uniform
        %   data spacing used for displaying the model results
        plotFcn

        % Processed y values
        %
        %   "yProc" is a dependent property that performs any pre-processing and
        %   applies the property "subset"
        yProc

    end

    properties (Abstract,Constant)

        % Name of defined model
        %
        %   "modelName" is a string containing a short description of the model
        %   implemented in the sub-class of modelbase
        modelName

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell a array of strings containing the name of
        %   each model parameter that must be fit using a non-linear fitting
        %   algorithm. This property is abstract to ensure that all sub-classes
        %   implement the property
        nlinParams

        % Physical units of the independent variable
        %
        %   "xUnits" is a string specifying the physical units of the depented
        %   variable property "x"
        xUnits

    end

    properties (Dependent,Hidden)

        % Deprecated model property
        %
        %   "bounds" is deprecated
        bounds

        % Deprecated model property
        %
        %   "guess" is deprecated
        guess

        % Deprecated model property
        %
        %   "modelVal" is deprecated.
        modelVal

        % Processed x values
        %
        %   "xProc" is the processed independent variable vector and is the same
        %   as OBJ.x(OBJ.subset), where OBJ is a modeling object
        xProc

        % x-axis label
        %
        %   String to be displayed as the x-axis label
        xLabel

        % y-axis label
        %
        %   String to be displayed as the y-axis label
        yLabel

        % Function handle to the fitting algorithm
        %
        %   "fitFcn" is a function handle that accepts input of the form:
        %
        %       p = @(x0,y) f(x0,y)
        %
        %   where x0 is the initial guess, y is the data vector, and p is a
        %   vector of estmiated model parameters. This function handle is used
        %   to encapsulate the fitting function, model function, independent
        %   variable, and parameter constraints within a single function handle.
        fitFcn

    end

    properties (SetObservable,Hidden,SetAccess='protected',Transient)

        % Structure of fitting options
        fitOpts

        % Modeling GUI figure handle
        %
        %   "hFig" stores the figure handle for the modeling GUI instance
        %   associated with the modeling object
        hFig

        % Automatic initial guess cache
        %
        %   "paramGuessCache" is a structure containing the numeric scalar to be
        %   used as the starting estimate corresponding to the non-linear
        %   parameters of the specified field. This property acts as a cache to
        %   store the auto-computed values, and is only internally accessible.
        %
        %   See also modelbase.paramGuess
        paramGuessCache = struct([]);

        % User-defined initial guess cache
        %
        %   "userParamGuessCache" is a structure containing the numeric scalar
        %   to be used as the starting estimate corresponding to the non-linear
        %   parameters of the specified field. This property acts as a cache to
        %   store the user-defined values, and is only internally accessible.
        %
        %   See also modelbase.paramGuess and modelbase.paramGuessCache
        userParamGuessCache = struct([]);

    end

    properties (SetObservable,Hidden)

        % Dependent variable data method tag
        %
        %   "dataMode" is a string specifying the method used to populate the
        %   "y" property. Valid modes are:
        %
        %       Mode        Description
        %       -----------------------
        %       'manual'    The default mode that is used when
        %                   the modeling object is operating in
        %                   a stand-alone
        %
        %       'pixel'     "y" is populated from the current
        %                   pixel of the associated exam object
        %
        %       'project'   "y" is populated from projecting the
        %                   current ROI through all series and
        %                   averaging the resulting image values
        %
        %       'label'     "y" is populated from the ROI-averaged
        %                   values at each series location. This
        %                   requires the current ROI to exist at
        %                   series location
        dataMode = 'manual';

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = modelbase
        %modelbase  Class for performing quantitative data modeling
        %
        %   OBJ = modelbase creates a quantitative modeling object. Note that
        %   instantiating an instance of a modelbase object is not possible.
        %   Instead use a MODELBASE sub-class.

            % Add the required post-set listeners
            addlistener(obj,'paramBounds','PostSet',@paramBounds_postset);
            addlistener(obj,'hFig',       'PostSet',@hFig_postset);
            addlistener(obj,'subset',     'PostSet',@obj.subset_postset);
            addlistener(obj,'mapSubset',  'PostSet',@mapSubset_postset);
            addlistener(obj,'x',          'PostSet',@obj.x_postset);
            addlistener(obj,'y',          'PostSet',@obj.y_postset);

            % Add the event listeners
            addlistener(obj,'checkCalcReady',@obj.checkCalcReady_event);
            addlistener(obj,'newResults',    @obj.newResults_event);
            addlistener(obj,'showModel',     @obj.showModel_event);
            addlistener(obj,'updateModel',   @obj.updateModel_event);

            % Initialize the "isReady" structure
            obj.isReady(1).(mfilename) = true;

        end %modelbase.modelbase

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.bounds(obj)
            %TODO: remove 1/1/2016
            warning([mfilename ':modelPropDeprecated'],...
                    ['The "bounds" property is deprecated and will be removed ',...
                     'in a future release. Use "paramBounds" instead.']);
            val = obj.paramBounds;
        end %modelbase.get.bounds

        function val = get.fitFcn(obj)

            % Initialize the output. The "fitFcn" property is only used for non-
            % linear fitting, so return the empty value if the "nlinParams"
            % property is empty
            val = [];
            if isempty(obj.nlinParams)
                return
            end

            % Get some properties for the function handle to avoid envoking the
            % "get" methods
            f      = obj.modelFcn;
            opts   = obj.fitOpts;
            xData  = obj.xProc;
            if strcmpi(obj.algorithm,'levenberg-marquardt')
                [limL,limU] = deal([]);
            else
                limL = cellfun(@(x) obj.paramBounds.(x)(1),obj.nlinParams);
                limU = cellfun(@(x) obj.paramBounds.(x)(2),obj.nlinParams);
            end

            switch obj.algorithm
                case {'levenberg-marquardt','trust-region-reflective'}
                    val = @(x0,y) lsqcurvefit(f,x0,xData(:),y(:),limL,limU,opts);
                case 'nelder-mead'
                    val = @(x0,y) fminsearch(@(hyp) sum( (f(hyp,xData)-y).^2 ),x0,opts);
                case 'robust'
                    val = @(x0,y) nlinfit(xData,y,f,x0,opts);
            end

        end %modelbase.get.fitFcn

        function val = get.fitOpts(obj)

            switch obj.algorithm
                case 'robust'
                    val = struct('Robust','on',...
                                 'WgtFun','cauchy');
                case 'nelder-mead'
                    val = struct('Display','off');
                otherwise
                    val = optimset('algorithm',obj.algorithm,...
                                   'Display','off',...
                                   'FunValCheck','off');
            end

        end %modelbase.get.fitOpts

        function val = get.guess(obj)
            %TODO: remove 1/1/2016
            warning([mfilename ':modelPropDeprecated'],...
                    ['The "guess" property is deprecated and will be removed ',...
                     'in a future release. Use "paramGuess" instead.']);
            val = obj.paramGuess;
        end %modelbase.get.guess

        function val = get.paramGuess(obj)

            % Get the user-defined/default value or perform the auto-guess
            % computation
            val = obj.userParamGuessCache;
            if obj.autoGuess && ~isempty(obj.y)
                % Only perform the computation if no previous auto-guess data
                % exists. This ensures that the initial starting guess is only
                % estimated once. The property "paramGuessCache" is reset with
                % new "x" or "y" data.
                if isempty(obj.paramGuessCache)
                    val                 = obj.processGuess(val);
                    obj.paramGuessCache = val;
                else
                    val                 = obj.paramGuessCache;
                end
            end

            % When computing maps, the guess must be converted from a structure
            % to an N-by-M array, where N is the number of non-linear parameters
            % and M is the number of image voxels
            %TODO: with the new cache strucutre, this will likely need to be
            %modified...
            if ~obj.isSingle

                % Structure to array
                val = cellfun(@(x) val.(x),obj.nlinParams,...
                                                         'UniformOutput',false);
                val = reshape( cell2mat(val), [], numel(obj.nlinParams) )';

                % When single-valued parameter guesses are specified, these must
                % be exapanded to match the expected N-by-M array
                if size(val,2)~=size(obj.y(:,:),2)
                    val = repmat(val,[1 size(obj.y(:,:),2)]);
                end

            end

        end %modelbase.get.paramGuess

        function val = get.mapSubset(obj)

            % Get the user-defined/default value
            val = obj.mapSubset;

            % Perform model-specific computations
            %TODO: this seems a little much. I think the framework for getting
            %and setting the mapSubset property needs some work
            if ~isempty(val) && (numel(val)>1)
                val = val & reshape(obj.processMapSubset,size(val));
            end
            
        end %modelbase.get.mapSubset

        function val = get.modelVal(obj)
            %TODO: remove 1/1/2016
            warning([mfilename ':modelPropDeprecated'],...
                    ['The "modelVal" property is deprecated and will be removed ',...
                     'in a future release. See "qt_models.model2val".']);
            val = qt_models.model2val( class(obj) );
        end %modelbase.get.modelVal

        function val = get.xLabel(obj)

            val = ''; %initialize the output

            if ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    val = get( get(hAx,'XLabel'), 'String' );
                end
            end

        end %modelbase.get.xLabel

        function val = get.xProc(obj)
            val = double( obj.x(obj.subset) );
        end %modelbase.get.xProc

        function val = get.yLabel(obj)

            val = ''; %initialize the output

            if ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    val = get( get(hAx,'YLabel'), 'String' );
                end
            end

        end %modelbase.get.yLabel

        function val = get.y(obj)
            val = obj.y;
            if ~isempty(val)
                val = double(val); %always convert to double for computations...
            end
        end %modelbase.get.y

    end %Get methods


    %------------------------------- Set Methods -------------------------------
    methods

        function set.bounds(obj,val)
            %TODO: remove 1/1/2016
            warning([mfilename ':modelPropDeprecated'],...
                    ['The "bounds" property is deprecated and will be removed ',...
                     'in a future release. Use "paramBounds" instead.']);
            nParams = numel(obj.nlinParams);
            dimIdx  = (size(val)==nParams);
            if ~any(dimIdx)
                error([mfilename ':invalidGuess'],...
                      ['Imporperly formatted "guess" input. Use the new ',...
                       'syntax and property - type "help modelbase.paramBounds" ',...
                       'for more information.'])
            end
            
            % Deal the parameters
            sVal = struct([]);
            for idx = 1:numel(obj.nlinParams)
                sVal(1).(obj.nlinParams{idx}) = val(:,idx)';
            end
            obj.paramBounds = sVal;

        end %modelbase.set.bounds

        function set.guess(obj,val)
            %TODO: remove 1/1/2016
            warning([mfilename ':modelPropDeprecated'],...
                    ['The "guess" property is deprecated and will be removed ',...
                     'in a future release. Use "paramGuess" instead.']);
            nParams = numel(obj.nlinParams);
            dimIdx  = (size(val)==nParams);
            if ~any(dimIdx)
                error([mfilename ':invalidGuess'],...
                      ['Imporperly formatted "guess" input. Use the new ',...
                       'syntax and property - type "help modelbase.paramGuess" ',...
                       'for more information.'])
            elseif ~dimIdx(1)
                fIdx = find(dimIdx);
                lIdx = find(~dimIdx);
                val  = permute(val,[fIdx lIdx]);
            end

            % Deal the parameters
            sVal = struct([]);
            for idx = 1:nParams
                sVal(1).(obj.nlinParams{idx}) = squeeze( val(idx,:,:,:) );
            end
            obj.paramGuess = sVal;

        end %modelbase.set.autoGuess

        function set.mapSubset(obj,val)
            validateattributes(val,{'logical'},{'2d','nonempty'});
            obj.mapSubset = val;
        end %modelbase.set.mapSubset

        function set.modelVal(~,~)
            warning([mfilename ':modelPropDeprecated'],...
                    ['The "modelVal" property is deprecated and will be removed ',...
                     'in a future release. Setting the property is not allowed ',...
                     'and will not result in any changes to the modeling object.']);
        end %modelbase.set.modelVal

        function set.paramBounds(obj,val)

            validateattributes(val,{'struct'},{'scalar'});

            % Verify that all fields contain only two elements only and are
            % increasing
            for fld = fieldnames(val)'
                try
                    validateattributes(val.(fld{1}),{'numeric'},...
                                  {'row','real','nonempty','nonnan','numel',2});
                    if all( sort(val.(fld{1}))~=val.(fld{1}) ) ||...
                                              (numel( unique(val.(fld{1})) )~=2)
                        error(['QUATTRO:' mfilename ':badBounds'],...
                              'Parameter bounds must be unique and increasing.');
                    end
                catch ME
                    error(['QUATTRO:' mfilename ':badBounds'],...
                          ['Invalid parameter bounds for "%s". Bounds must ',...
                           'be a two-element row vector with non-NaN, unique, ',...
                           'and increasing values.'],fld{1});
                end
            end

            % Store the value
            obj.paramBounds = val;

        end %modelbase.set.paramBounds

        function set.paramGuess(obj,val)

            % Perform the initial validation and grab the parameter bounds
            validateattributes(val,{'struct'},{'scalar'});
            pBounds = obj.paramBounds;

            % Verify that all fields contain only a scalar numeric value
            for fld = fieldnames(val)'

                % Ensure that the field in question is actually one of the
                % non-linear parameters
                if ~any( strcmpi(fld{1},obj.nlinParams) )
                    val = rmfield(val,fld{1});
                    continue
                end

                % Attempt to validate the specified value
                try
                    validateattributes(val.(fld{1}),{'numeric'},...
                                         {'scalar','real','nonempty','nonnan'});
                catch ME
                    warning(['QUATTRO:' mfilename ':badGuess'],...
                             'Invalid guess for the "%s" parameter. %s',...
                                                             fld{1},ME.message);
                    val = rmfield(val,fld{1});
                    continue
                end

                % Validate that the new parameter guess is within the specified
                % bounds
                if ~isfield(pBounds,fld{1}) || isempty(pBounds.(fld{1}))
                    val = rmfield(val,fld{1});
                    continue
                end
                if (val.(fld{1})<pBounds.(fld{1}))
                    warning(['qt_models:' mfilename ':guessTooLow'],...
                            ['The guess for "%s" exceeds the lower bound. ',...
                             'No change was made.\nCurrent value: %f'],...
                                    fld{1},obj.userParamGuessCache.(fld{1})(1));
                    val = rmfield(val,fld{1});
                    continue
                elseif (val.(fld{1})>pBounds.(fld{1}))
                    warning(['qt_models:' mfilename ':guessTooLow'],...
                            ['The guess for "%s" exceeds the upper bound. ',...
                             'No change was made.\nCurrent value: %f'],...
                                    fld{1},obj.userParamGuessCache.(fld{1})(1));
                    val = rmfield(val,fld{1});
                    continue
                end
                    
            end

            % Store the value
            obj.userParamGuessCache = val;
            notify(obj,'updateModel');

            % When the auto guess feature is enabled, setting the guess data
            % manually will disable this feature. Normally, the "updateModel"
            % event would be called here, but setting the "autoGuess" property
            % will result in that event being notified
            obj.autoGuess = false;

        end %modelbase.set.paramGuess

        function set.subset(obj,val)
            validateattributes(val,{'logical'},{'nonempty','vector'})
            if (sum(val)<2) && isempty( strfind(class(obj),'generic') )
                error(['QUATTRO:' mfilename ':subsetTooSmall'],...
                      ['At least two data points are required for modeling. ',...
                       'The "subset" property must have at least two true ',...
                       'elements.']);
            end
            obj.subset = val(:); %enforce column vector
            notify(obj,'updateModel');
        end %modelbase.set.subset

        function set.x(obj,val)

            % Attempt to validate the "x" property units. When a modeling class
            % has a non-empty unit, the user should be informed of better model
            % programming practices
            if ~strcmpi( class(val), 'unit' )
                if ~isempty(obj.xUnits)
                    warning(['qt_models:' mfilename ':nonUnitInput'],...
                            ['For more robust operation, the dependent variable ',...
                             '"x" should be of class "unit". Assuming a physical ',...
                             'unit of %s...'],obj.xUnits);
                end
                val = unit(val,obj.xUnits);
            end
            try
                val = val.convert(obj.xUnits).value(:); %enforce column vector
            catch ME
                rethrow(ME);
            end
                    
            validateattributes(val,{'numeric'},...
                                {'finite','nonempty','nonnan','real','vector'});
            obj.x = val;
        end %modelbase.set.x

        function set.y(obj,val)

            validateattributes(val,{'numeric'},{'nonempty'})

            % The user either specified a vector or an array. Enforce column
            % vectors when necessary
            if (numel(val)==length(val))
                val = val(:);
            end
            obj.y = val;

        end %modelbase.set.y

        function set.xLabel(obj,val)
            if ischar(val) && ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    xabel(hAx,obj.xLabel);
                end
            end
        end %modelbase.set.xLabel

        function set.yLabel(obj,val)
            if ischar(val) && ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    ylabel(hAx,obj.yLabel);
                end
            end
        end %modelbase.set.yLabel

    end %Set methods


    %---------------------------- Abstract Methods -----------------------------
    methods (Abstract)

        %processGuess  Performs sub-class specific estimates for "guess"
        %
        %   processGuess(OBJ,VAL)
        val = processGuess(obj,val)

    end %Abstract methods


    %----------------------------- Other Methods -------------------------------
    methods (Hidden)

        function delete(obj)

            % When there is a valid figure stored in "hFig", delete any
            % associated plots on the associated axis
            if ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Type','axes');
                if ~isempty(hAx)
                    delete( get(hAx,'Children') );
                end
            end

        end %modelbase.delete

    end


end %modelbase