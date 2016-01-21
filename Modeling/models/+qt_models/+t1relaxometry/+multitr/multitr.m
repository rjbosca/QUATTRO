classdef multitr < modelbase & mrimagingprops

    properties (Dependent)

        % Function used for model fitting
        %
        %   "modelFcn" is a function handle used to fit a 
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
        %   implemented in MULTITR
        modelName = 'Saturation Recovery';

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell array of strings containing the specifier for
        %   each model parameter. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'S0'            Equilibrium magnetization (units: a.u.)
        %
        %       'R1'            Longitudinal relaxation rate (units: 1/s)
        nlinParams = {'S0','R1'};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = multitr(varargin)
        %multitr  Class for performing quantitative multiple-TR T1 modeling
        %
        %   OBJ = multitr(TR,Y) creates a multitr modeling object for the vector
        %   of signal intensities Y and corresponding repetition time values TR
        %   (in milliseconds), returning the multitr object, OBJ.
        %
        %   OBJ = multitr(QTEXAM) creates a multitr modeling object from the
        %   data stored in the qt_exam object QTEXAM. Associated QUATTRO links
        %   are generated if available.
        %
        %   OBJ = multitr(...,'PROP1',VAL1,...) creates a multitr modeling
        %   object as above, initializing the class properties specified by the
        %   properties 'PROP1' to the value VAL1

            % Construct VTR specific defaults
            obj.xLabel = 'TR (msec)';
            obj.yLabel = 'S.I. (a.u.)';

            % Parse the inputs
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

        end %multitr.multitr

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)

            % Cache the TR value
            teVal = obj.te;

            switch obj.modelVal
                case 1
                    val = @(x,xdata) multi_tr(x(:),xdata,teVal);
                case 2
                    val = @(x,xdata) multi_tr([x(1) 1./x(2)],xdata,teVal);
            end

        end %get.modelFcn

        function val = get.plotFcn(obj)
            val = obj.modelFcn;
        end %get.plotFcn

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

        function val = processGuess(obj,val)

            % Only continue if autoGuess is enabled and y data exist
            if ~obj.autoGuess || isempty(obj.y)
                return
            end

            % Estimate S0 from the maximum signal intensity
            val(:,:,1) = max(obj.y);

        end %processGuess

    end

end %multitr