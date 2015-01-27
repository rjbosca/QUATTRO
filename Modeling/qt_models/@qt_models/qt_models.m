classdef qt_models < handle
%Quantitative data modeling class
%
%   Type "doc qt_models" for a summary of all properties and methods. For
%   property and method specific help type "help qt_models.<name>" where name is
%   the name of the property or method of interest. For a list of properties and
%   methods type "properties qt_models" or "methods qt_models"
%
%   Below is a brief description of the various models associated with each
%   exam type. All of these models require a non-linear fitting algorithm
%   to solve for the models' parameters. For more inforamtion on these models
%   type "help <model name>"
%
%
%   Modeling for certain data sets, such as those derived from DCE and DSC
%   exams, will require additional input parameters (e.g. VIF, TR, FA, etc.).
%   These modeling parameters are stored in the params property of qt_models,
%   which is exam specific. Before modeling can occur, all of this additional
%   information must be provided, either manually or in the context of qt_models
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
%# FILENAME  : qt_models.m

    properties (SetObservable=true,AbortSet=true)

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

        % x-axis limits
        xlims

        % y-axis limits
        ylims

        % Initial guess used for model fitting
        %
        %   "guess" is an array of initial guesses for the non-linear fitting
        %   routine such that SIZE(guess,i)==SIZE(y,i) for i=2:NDIMS(Y) and
        %   SIZE(guess,1) is equal to the number of model parameters
        guess

        % Flag for using an automatic initial vaule
        %
        %   When true (default), the initial value used in the non-linear
        %   fitting routine is either estimated from the response variable or
        %   from hard-coded values.
        autoGuess = true;

        % Flag for performing fits automatically
        %
        %   "autoFit" is a logical flag that enables (TRUE) automatic fitting of
        %   a given data set when all necessary object properties are populated.
        %   By default, this option is disabled (i.e., FALSE), but this is
        %   useful when linked to QUATTRO. This option is not advised when
        %   working with multidimensional y data
        %   (e.g., maps).
        autoFit = false;

        % Dependent subset indices
        %
        %   "subset" is a column vector of array indices or a logical mask that
        %   is used to exclude data (e.g. outliers) during modeling, and must
        %   satisfy ALL(SIZE(SUBSET)==SIZE(X)). When a numeric array of indices
        %   is specified, the indicies are converted to a logical mask before
        %   updating the property.
        subset

        % Map computation subset
        %
        %   "mapSubset" is a logical mask that is used to exclude data regions
        %   of a map during modeling with SIZE(MAPSUBSET)==[n1 n2...nm], where
        %   ni is the ith dimension of the response variable (i.e., "y").
        mapSubset

        % Built-in model number
        %
        %   "modelVal" is a numeric scalar specifying the built-in model to use
        %   when performing quantitation.
        modelVal = 1;

        % Model function handle used with ezplot
        %
        %   A function handle that allows interpolation of discretized data
        %   inputs. For example, consider the pair of functions GKM (DCE model)
        %   and GKM_plot. When fitting, the acquired tissue and vascular data
        %   are used. However, when plotting, it is desirable to interpolate the
        %   vascular data, allowing for a smoother curve. This interpolation
        %   step would bog down the fitting algorithm and so the two functions
        %   are separated.
        plotModel

        % Fitting results
        %
        %   A structure containing information regarding the fitting process.
        %
        %   Fields
        %   ------
        %   Fcn         a function handle to the fitted model used to produce
        %               plots of fitted data.
        %
        %   Names       a cell array containing the names of the fitted
        %               parameters
        %
        %   Params      a vector of the fitted model parameters
        %
        %   R2          coefficient of determination for the fitted model
        %
        %   Res         a vector of residuals for the fitted data (normalization
        %               is not performed)
        %
        %   Scale       a vector for producing the correct scaling of the
        %               corresponding parameter
        %
        %   Units       a cell array containing the units of the given model
        results

        % Bounds for model parameters
        %
        %   An N-by-2 array where the first column of values contains the lower
        %   parameter bounds and the second column contains the upper parameter
        %   bounds. These bounds are used to confine the fitting algorithms to a
        %   specific parameter space. A description of the parameter location
        %   within the array columns:
        %
        %   Model Type      Parameter index
        %   -------------------------------
        %      DCE          [Ktrans;ve;vp]
        %
        %      DSC          [rCBF;MTT;K;alpha;beta;t0]
        %
        %      DWI          [S0;ADC;D*;f;K]
        %
        %      T1           [S0;T1;FA] (Multiple TI only)
        %
        %      T1/T2        [S0;T1;T2]
        bounds

        % Fit criteria threshold
        %
        %   A scalar specifying the minimum allowable fit coefficient of
        %   determination. An attempt to recover values below this threshold is
        %   made in the "clean_maps" method. The lower the value, the more
        %   likely bad fits will be replaced by more appropriate fits, but the
        %   longer the cleaning operation will take.
        %
        %   Default: 0.5
        fitThresh = 0.5;

        % Algorithm used in fitting
        %
        %   A string containing the name of the fitting algorithm to be used. 
        %   One of 'levenberg-marquardt', 'trust-region-reflective' (default),
        %   'nelder-mead', or 'robust'. Note that the robust least-squares
        %   algorithm requires the statistics toolbox
        %
        %   See also lsqcurvefit, fminsearch, nlinfit, optimset, optimget
        algorithm = 'trust-region-reflective';

        % Flag controlling the use of graphical notifications
        %
        %   "guiDialogs" is a logical flag that enables (true) or disables
        %   (false) the use of graphical notifications (such as wait bars) when
        %   working with qt_models (or sub-class).
        guiDialogs = true;

    end

    properties (Dependent=true,Hidden=true)

        % Processed x values
        %
        %   Same as obj.x(obj.subset)
        xProc

        % Processed y values
        %
        %   Performs any pre-processing (using the model specific "process"
        %   method) and applies the property "subset"
        yProc

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
        %   A function handle that accepts input of the form @(x0,y) where x0 is
        %   the initial guess and y contains the data. All other data such as
        %   the model, x data, and model constraints are automatically
        %   encapsulated.
        fitFcn

        % Model parameter names
        %
        %   "paramNames" is a cell array of strings containing all model
        %   parameters used during quantitation (non-linear and otherwise).
        modelParams

        % Flag specifying the fitting readiness
        %
        %   This flag determines whether all necessary data are available to
        %   proceed with computations of the current model's parameters
        calcsReady

        % Slice/series position of QUATTRO
        %
        %   A 1-by-2 numeric array containing the QUATTRO slice and series
        %   location, respectively.
        qtPos

    end

    properties (SetObservable=true,SetAccess='protected',Hidden=true)

        % Modeling GUI figure handle
        %
        %   "hFig" stores the figure handle for the associated modeling GUI
        %   instance
        hFig

        % qt_exam object handle
        %
        %   "hExam" stores the qt_exam object for the qt_models sub-class
        %   associated modeling data
        hExam = qt_exam.empty(1,0);

        % Model single datum or map flag
        %
        %   "isSingle" is a logical flag specifying whether the data stored in
        %   the property "y" consist of a single datum (TRUE) or map data
        %   (FALSE) to be modeled. This property is updated by the y_postset
        %   method
        isSingle = true;

        % Model displayed currently flag
        %
        %   "isShown" is a logical flag specifying whether the data stored
        %   currently in the qt_models object (or sub-class) has been displayed
        %   (TURE). This property is updated by the "show" method and is reset
        %   by PostSet event associated with properties that might change the
        %   value of the modeling results or data.
        isShown = false;

    end

    properties (SetAccess = 'private')
        % Structure of fitting options
        fitOpts
    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_models(varargin)
            %qt_models  Class for performing quantitative data modeling
            %
            %   OBJ = qt_models creates a quantitative modeling object. Note
            %   that instantiating an instance of a qt_models object is not
            %   possible. Instead use a qt_models subclass.

            % Add the required PostSet listeners
            addlistener(obj,'algorithm','PostSet',@algorithm_postset);
            addlistener(obj,'autoFit',  'PostSet',@autofit_postset);
            addlistener(obj,'autoGuess','PostSet',@autoGuess_postset);
            addlistener(obj,'bounds',   'PostSet',@bounds_postset);
            addlistener(obj,'guess',    'PostSet',@guess_postset);
            addlistener(obj,'hFig',     'PostSet',@hFig_postset);
            addlistener(obj,'subset',   'PostSet',@obj.subset_postset);
            addlistener(obj,'mapSubset','PostSet',@mapSubset_postset);
            addlistener(obj,'modelVal', 'PostSet',@modelVal_postset);
            addlistener(obj,'results',  'PostSet',@results_postset);
            addlistener(obj,'x',        'PostSet',@obj.x_postset);
            addlistener(obj,'y',        'PostSet',@obj.y_postset);

        end %qt_models

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.calcsReady(obj)

            % Validate the x/y data
            %TODO: isReady is getting called a lot...For DCE/DSC exams, this
            %requires checking on the VIF, which can become time consuming.
            %Maybe a stoarge property is in order.
            val = (~isempty(obj.y) && ~isempty(obj.x) && obj.isReady);

        end %get.calcsReady

        function val = get.fitFcn(obj)

            % Get some properties for the function handle to avoid envoking the
            % "get" methods
            limLow = obj.bounds(:,1);
            limHi  = obj.bounds(:,2);
            f      = obj.modelFcn;
            opts   = obj.fitOpts;
            xData  = obj.xProc;
            if strcmpi(obj.algorithm,'levenberg-marquardt')
                [limLow,limHi] = deal([]);
            end

            switch obj.algorithm
                case {'levenberg-marquardt','trust-region-reflective'}
                    val = @(x0,y) lsqcurvefit(f,x0,xData(:),y(:),limLow,limHi,opts);
                case 'nelder-mead'
                    val = @(x0,y) fminsearch(@(hyp) sum( (f(hyp,xData)-y).^2 ),x0,opts);
                case 'robust'
                    val = @(x0,y) nlinfit(xData,y,f,x0,opts);
            end

        end %get.fitFcn

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

        end %get.fitOpts

        function val = get.guess(obj)

            % Get the user-defined/default value
            val = obj.guess;

            % Perform model-specific computations
            val = obj.processGuess(val);

        end %get.guess

        function val = get.mapSubset(obj)

            % Get the user-defined/default value
            val = obj.mapSubset;

            % Perform model-specific computations
            %TODO: this seems a little much. I think the framework for getting
            %and setting the mapSubset property needs some work
            if ~isempty(val) && (numel(val)>1)
                val = val & reshape(obj.processMapSubset,size(val));
            end
            
        end %get.mapSubset

        function val = get.modelParams(obj)
            val = [obj.nlinParams{obj.modelVal}(:)
                   obj.otherParams(:)];
        end %get.modelParams

        function val = get.qtPos(obj)

            % Initialize
            val = [];
            if isempty(obj.hFig) || ~ishandle(obj.hFig)
                return
            end

            % Get the qt_exam object from the QUATTRO figure
            eObj = getappdata(getappdata(obj.hFig,'linkedfigure'),'qtExamObject');

            % Get the slice/series information
            val = [eObj.sliderIdx eObj.seriesObj];

        end %get.qtPos

        function val = get.xLabel(obj)

            val = ''; %initialize the output

            if ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    val = get( get(hAx,'XLabel'), 'String' );
                end
            end

        end %get.xLabel

        function val = get.xProc(obj)
            val = double( obj.x(obj.subset) );
        end %get.xProc

        function val = get.yLabel(obj)

            val = ''; %initialize the output

            if ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    val = get( get(hAx,'YLabel'), 'String' );
                end
            end

        end %get.yLabel

        function val = get.y(obj)
            % Always convert to double
            val = obj.y;
            if ~isempty(val)
                val = double(val);
            end
        end %get.y

        function val = get.yProc(obj)

            % Get the values and size of the y data before processing
            val = obj.y;
            mY  = size(obj.y);

            % Perform the processing based on the "subset" property data
            val = val(obj.subset,:);            
            val = obj.process(val);

            % Reshape to preserve the data dimensionality
            val = reshape(val,[size(val,1) mY(2:end)]);

        end %get.yProc

    end %Get methods


    %------------------------------- Set Methods -------------------------------
    methods

        function set.algorithm(obj,val)

            % Validate the algorithm
            val = validatestring(val,{'levenberg-marquardt',...
                                      'robust',...
                                      'trust-region-reflective',...
                                      'nelder-mead'});
            if strcmpi(val,'robust') && isempty(ver('stats'))
                warning('qt_models:missingToolbox',...
                       'This fitting feature requires the Statistics toolbox.');
                return
            end

            % Set the value
            obj.algorithm = val;

        end %set.algorithm

        function set.autoFit(obj,val)

            val = logical(val);
            if numel(val)>1
                warning('qt_models:autoFit:invalidValue',...
                                   '"autoFit" values must be logical scalars.');
                return
            end

            % Store the value and fire the fitting routines
            obj.autoFit = val;
            if val
                obj.fit;
            end

        end %set.autoFit

        function set.bounds(obj,val)

            % Test the lower and upper bounds
            if any( val(:,1)>=val(:,2) )
                warning('qt_models:invalidBounds','%s\n%s\n',...
                        'Lower bounds must not exceed upper bounds.',...
                        'No changes were applied to the bounds.');
                return
            end
            
            obj.bounds = val;

        end %set.bounds

        function set.subset(obj,val)

            % Ignore empty inputs
            if isempty(val)
                warning('qt_models:subset:emptyArray',...
                        '"subset" must be a non-empty array.');
                return
            end

            % Detect array sub-indices
            if ~islogical(val) && any( (val~=0) & (val~=1) )
            else
                obj.subset = logical(val(:)); %enforce column vector
            end

        end %set.subset

        function set.mapSubset(obj,val)

            % Ignore empty inputs
            if isempty(val)
                warning('qt_models:mapSubset:emptyArray',...
                        '"mapSubset" must be a non-empty logical array.');
                return
            end

            obj.mapSubset = logical(val);

        end %set.mapSubset

        function set.guess(obj,val)

            % Enforce column vector guesses for vector inputs
            if (numel(val)==length(val))
                val = val(:);
            end

            obj.guess = val;

        end %set.guess

        function set.x(obj,val)
            obj.x = val(:); %enforce column vector
        end %set.x

        function set.y(obj,val)

            % Enforce column vector for vector input. This ensures that the data
            % are indexed by the last dimension (a necessity for maps)
            if numel(val)==length(val)
                val = val(:);
            end
            nd = ndims(val);

            % Validate the input
            if isempty(val) || (nd>2) || sum( ~isnan(val) )>2 %empty
                obj.y = val;
            end

        end %set.y

        function set.xLabel(obj,val)
            if ischar(val) && ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    xabel(hAx,obj.xLabel);
                end
            end
        end %set.xLabel

        function set.yLabel(obj,val)
            if ischar(val) && ~isempty(obj.hFig) && ishandle(obj.hFig)
                hAx = findobj(obj.hFig,'Tag','axes_main');
                if ~isempty(hAx)
                    ylabel(hAx,obj.yLabel);
                end
            end
        end %set.yLabel

    end %Set methods

end