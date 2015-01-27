classdef multiti < qt_models

    properties %general model properties

        % Flag for inverting magnitude signal intensities
        %
        %   Flag for performing magnitude signal inensity inversion. When true
        %   (default), an attempt is made to invert magnitude signal
        %   intensities. If any negative values exist in the property "y", this
        %   flag is ignored 
        restoreInv = true;

    end

    properties (Dependent = true)

        % Function used for model fitting
        %
        %   Function handle to the current VTI model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   inversion times in milliseconds).
        modelFcn;

        % Model parameter indices
        %
        %   A set of indices used to ensure only parameters to be modeled are
        %   used by the modeling objects.
        modelInds = 1:2;

        % Function used for plotting the model
        %
        %   Calls the modelFcn property and is only here for code conformity.
        plotFcn;

    end

    properties (Constant,Hidden = true)

        % Flag for computation readiness
        %
        %   This flag is defined in all sub-classes of qt_models. However,
        %   because the "calcsReady" property of qt_models checks the x/y data
        %   of the object, no checks need be performed here.
        isReady = true;

        % Structure of multi-TI model information
        modelInfo = struct('Scale',{[1 1 1]},...
                           'Names',{{'S0','T1','theta'}},...
                           'Units',{{'','ms','deg.'}});

        % Model names
        %
        %   A string cell array containing the names of the models. The location
        %   of each string specifies the index that should be used to access the
        %   actual model using the model property.
        %
        %   The qt_models GUI uses this property to populate the "Models" pop-up
        %   menu.
        modelNames = {'T1','R1','T1 (3 param.)','R1 (3 param.)'};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = multiti(varargin)
        %multiti  Class for performing quantitative VTI T1 modeling
        %
        %   OBJ = multiti(TI,Y) creates a multiti modeling object for the vector
        %   of signal intensities Y and corresponding inversion times TI,
        %   returning the multiti object, OBJ.
        %
        %   OBJ = multiflip(H) creates a multiti modeling object linked to an
        %   instance of QUATTRO specified by the handle H.
        %
        %   OBJ = multiflip(...,'PROP1',VAL1,...) creates a multiti modeling
        %   object as above, initializing the class properties specified by the
        %   properties 'PROP1' to the value VAL1

            % Construct VTI specific defaults
            obj.bounds = [0  inf
                          0 20000
                          0  360];
            obj.guess  = [2000 100  180];
            obj.xLabel = 'TI (msec)';
            obj.yLabel = 'S.I. (a.u.)';

            % Parse the inputs
            if isempty(varargin)
                return
            end
            [exam,props,vals] = parse_inputs(varargin{:});

            % Associate an instance of a qt_exam object
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

        end %multiti

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)

            switch obj.modelVal
                case 1
                    val = @(x,xdata) multi_ti([x(:);180],xdata);
                case 2
                    val = @(x,xdata) multi_ti([x(1);1/x(2);180],xdata);
                case 3
                    val = @(x,xdata) multi_ti(x(:),xdata);
                case 4
                    val = @(x,xdata) multi_ti([x(1);1/x(2);x(3)],xdata);
            end
            if ~obj.invert
                val = @(x,xdata) abs(val(x,xdata));
            end

        end %get.modelFcn

        function val = get.modelInds(obj)

            switch obj.modelVal
                case {1,2}
                    val = 1:2;
                otherwise
                    val = 1:3;
            end

        end %get.modelInds

        function val = get.plotFcn(obj)
            val = obj.modelFcn;
        end %get.plotFcn

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden = true)

        function val = process(obj,val)
            %proccess  Performs pre-processing on data to be fitted
            %
            %   process calculates signal inensity conversion for various
            %   qt_models sub-classes during calls to the "yProc" property of
            %   qt_models.
            %
            %   This method inverts magnitude signal intensities based on the
            %   value of the "invert" property

            if obj.invert && all(obj.y(:)>0)
                for xidx = 1:size(val,1)
                    for yidx = 1:size(val,2)
                        val(xidx,yidx,:) = restore_ir(obj.x,val(xidx,yidx,:));
                    end
                end
            end

        end %process

        function val = processFits(obj,val)
            %processFit  Performs post-processing on fitted data
            %
            %   processFit calculates additional model parameters that are not
            %   otherwise computed by the "fit" method. For VTI objects, the
            %   relaxation rate (R1) is calculated

            if isfield(obj.results,'t1')
                obj.results.r1 = 1000./obj.results.t1;
            end

        end %processFit

        function val = processGuess(obj,val)
            %processGuess  Estimates model parameters from simple computations
            %
            %   processGuess attempts to estimate model parameters by performing
            %   simple mathematical operations on the "y" data. This method is
            %   only employed when "autoGuess" is enabled (i.e. true).

            % Only continue if autoGuess is enabled and y data exist
            if ~obj.autoGuess || isempty(obj.y)
                return
            end

            % Estimate of the null crossing (used to estimate T1) and validate
            % the array size of guess is appropriate
            if ndims(obj.y)<3
                data = permute(obj.y,[2 3 1]);
            end
            [~,ind] = min(data,[],3);
            if numel(ind)~=prod([size(val,1) size(val,2)])
                val = zeros(size(ind));
            end

            % Store the guesses
            val(:,:,1) = max(data,[],3); %S0
            val(:,:,2) = arrayfun(@(idx) obj.x(idx),ind)/log(2); %T1
            val(:,:,3) = 180; %inversion flip angle

        end %processGuess

    end %methods (Access = 'private', Hidden = true)

end %classdef


function varargout = parse_inputs(varargin)

    % Determine input syntax (either qt_exam object or inversion time/signal)
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