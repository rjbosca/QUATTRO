classdef multite < qt_models

    properties (Dependent = true)

        % Function used for model fitting
        %
        %   Function handle to the current VTE model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   echo time).
        modelFcn;

        % Function used for plotting the model
        %
        %   Calls the modelFcn property and is only here for code conformity.
        plotFcn;

    end

    properties (Constant,Hidden = true)

        % Model parameter indices
        %
        %   A set of indices used to ensure only parameters to be modeled are
        %   used by the modeling objects.
        modelInds = 1:2;

        % Structure of multiple TE model information
        modelInfo = struct('Scale',{[1 1]},...
                           'Names',{{'S0','T2'}},...
                           'Units',{{'','ms'}})

        % Model names
        %
        %   A string cell array containing the names of the models. The location
        %   of each string specifies the index that should be used to access the
        %   actual model using the model property.
        %
        %   The qt_models GUI uses this property to populate the "Models" pop-up
        %   menu.
        modelNames = {'T2','R2'};

        % Flag for computation readiness
        %
        %   This flag is defined in all sub-classes of qt_models. However,
        %   because the "calcsReady" property of qt_models checks the x/y data
        %   of the object, no checks need be performed here.
        isReady = true;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = multite(varargin)
        %multite  Class for performing quantitative multi-echo modeling
        %
        %   OBJ = multite(TE,Y) creates a multite model object from the vector
        %   of signal intensities Y and corresponding echo times TE (in
        %   milliseconds), returning the multite object, OBJ.
        %
        %   OBJ = multite(QTEXAM) creates a multite modeling object from the
        %   data stored in the qt_exam object QTEXAM. Associated QUATTRO links
        %   are generated if available.
        %
        %   OBJ = multite(...,'PROP1',VAL1,...) creates a multite modeling
        %   object as above, initializing the class properties specified by the
        %   properties 'PROP1' to the value VAL1

            % Construct VTE specific defaults
            obj.bounds = [0  inf
                          0 20000];
            obj.guess  = [2000 50];
            obj.xLabel = 'Echo Time (ms)';
            obj.yLabel = 'S.I. (a.u.)';

            % Parse the inputs
            if isempty(varargin)
                return
            end
            [exam,props,vals] = parse_inputs(varargin{:});

            % Associate an instance of a QUATTRO GUI
            if ~isempty(exam)
                if ~isempty(exam.hFig) && ishandle(exam.hFig)
                    obj.hQt = exam.hFig;
                end
                obj.x       = exam.modelXVals;
            end

            % Apply user-specified options
            for prpIdx = 1:length(props)
                obj.(props{prpIdx}) = vals{prpIdx};
            end

        end %multite

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)

            switch obj.modelVal
                case 1
                    val = @(x,xdata) multi_te(x(:),xdata);
                case 2
                    val = @(x,xdata) multi_te([x(1);x(2)],xdata);
            end

        end %get.modelFcn

        function val = get.plotFcn(obj)
            val = obj.modelFcn;
        end %get.plotFcn

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden = true)

        function val = process(obj,val) %#ok
            %proccess  Performs pre-processing on data to be fitted
            %
            %   process calculates signal inensity conversion for various
            %   qt_models sub-classes during calls to the "yProc" property of
            %   qt_models.
            %
            %   This method performs no processing for multite modeling objects
            %   and is here for code conformity as the "yProc" property of
            %   qt_models calls this method.
        end %process

        function val = processFit(obj,val)
            %processFit  Performs post-processing on fitted data
            %
            %   processFit calculates additional model parameters that are not
            %   otherwise computed by the "fit" method. For VTE objects, the
            %   relaxation rate (R2) is calculated using the data stored in the
            %   "results" property

            if isfield(obj.results,'t2')
                obj.results.r2 = 1000./obj.results.t2;
            end

        end %processFit

        function val = processGuess(obj,val)

            % Only continue if autoGuess is enabled and y data exist
            if ~obj.autoGuess || isempty(obj.y)
                return
            end

            % Estimate S0 from the maximum signal intensity
            val(:,:,1) = max(obj.y);

        end %processGuess

    end %methods (Access = 'private', Hidden = true)

end %classdef


function varargout = parse_inputs(varargin)

    % Determine input syntax (either qt_exam object or TE/signal)
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

    % Deal the outputs
    varargout{1} = fieldnames(parser.Results);
    varargout{2} = struct2cell(parser.Results);

end