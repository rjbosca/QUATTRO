classdef generic < qt_models

    properties (Constant)

        % Function used for model fitting
        %
        %   Function handle to the current model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   time).
        %
        %   Note that uniformly spaced values of t are assumed for this function
        %   handle. For non-uniformly spaced values, use plotFcn instead
        modelFcn = identityFcn;

        % Function used for plotting the model
        %
        %   Function handle to the current model convenient for plotting the
        %   model with the form @(x0,t) f(x0,t).
        plotFcn = identityFcn;

        % Flag for computation readiness
        %
        %   Returns true if the object is prepared for computation and false
        %   otherwise.
        isReady = false;

        % Model parameter indices
        %
        %   A set of indices used to ensure only parameters to be modeled are
        %   used by the modeling objects.
        modelInds = 1;

        % This is hear for conformity
        modelInfo = struct('Scale',{},...
                           'Names',{''},...
                           'Units',{});

        % Model names
        %
        %   A string cell array containing the names of the models. The location
        %   of each string specifies the index that should be used to access the
        %   actual model using the model property.
        %
        %   The qt_models GUI uses this property to populate the "Models" pop-up
        %   menu.
        modelNames = {''};

    end

    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = generic(varargin)
        %generic  Class for performing quantitative visualization
        %
        %   OBJ = generic(X,Y) creates a generic model object for the vector of
        %   signal intensities Y and corresponding acquisition points X,
        %   returning the generic model object, OBJ.
        %
        %   OBJ = generic(QTEXAM) creates a generic modeling object from the
        %   data stored in the qt_exam object QTEXAM. Associated QUATTRO links
        %   are generated if available.
        %
        %   OBJ = generic(...,'PROP1',VAL1,...) creates a generic modeling
        %   object as above, initializing the class properties specified by the
        %   properties 'PROP1' to the value VAL1

            % Construct generic specific defaults
            obj.xLabel = 'Series #';
            obj.yLabel = 'Signal Intensity';

            % Parse the inputs
            if isempty(varargin)
                return
            end
            [props,vals] = parse_inputs(varargin{:});

            % Associate an instance of a QUATTRO GUI
            if ~isempty(obj.hExam) && obj.hExam.isvalid
                obj.x = exam.modelXVals;
            end

            % Apply user-specified options
            for prpIdx = 1:length(props)
                obj.(props{prpIdx}) = vals{prpIdx};
            end

        end %generic

    end %class constructor


    %------------------------------ Other Methods ------------------------------
    methods (Hidden = true)

        function val = process(obj,val) %#ok
            %
            %   process calculates signal inensity conversion for various
            %   qt_models sub-classes during calls to the "yProc" property of
            %   qt_models.
            %
            %   This method performs no processing for generic modeling objects
            %   and is here for code conformity as the "yProc" property of
            %   qt_models calls this method.
        end %process

        function val = processFit(obj,val) %#ok
            %processFit  Performs post-processing on fitted data
            %
            %   processFit calculates additional model parameters that are not
            %   otherwise computed by the "fit" method. For GENERIC objects, no
            %   additional computations are currently supported. This code is
            %   here simply for conformity
        end %processFit

        function val = processGuess(obj,val) %#ok
        end %processGuess

    end %methods (Hidden = true)

end %classdef


function varargout = parse_inputs(varargin)

    % Determine input syntax (either qt_exam object or series #/signal)
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