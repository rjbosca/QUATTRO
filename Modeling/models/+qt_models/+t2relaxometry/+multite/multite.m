classdef multite < modelbase

    properties (Dependent)

        % Function used for model fitting
        %
        %   "modelFcn" is a function handle used to fit
        modelFcn

        % Function used for plotting the model
        %
        %   Calls the modelFcn property and is only here for code conformity.
        plotFcn;

        yProc

    end

    properties (Constant)

        % Class defintion model name
        %
        %   "modelName" is a string containing a short description of the model
        %   implemented in MULTITE
        modelName = 'Variable Echo Time';

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell array of strings containing the specifier for
        %   each model parameter. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'S0'            Equilibrium magnetization (units: a.u.)
        %
        %       'R2'            Transverse relaxation rate (units: 1/s)
        nlinParams = {'S0','R2'};

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
            obj.xLabel = 'Echo Time (ms)';
            obj.yLabel = 'S.I. (a.u.)';

            % Parse the inputs
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

        end %multite.multite

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

        function val = process(obj,val)
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

end %multite