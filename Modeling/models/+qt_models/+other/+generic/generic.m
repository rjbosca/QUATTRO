classdef generic < modelbase

    properties (Dependent)

        % Function used for model fitting
        %
        %   "modelFcn" is a hard-coded identity function handle used to display
        %   data and is implemented to create the concrete class
        modelFcn

        % Function used for plotting the model
        %
        %   "plotFcn" same as "modelFcn" for the GENERIC class
        plotFcn

        % Processed y values
        %
        %   Performs any pre-processing (using the model specific "process"
        %   method) and applies the property "subset"
        yProc

    end

    properties (Constant)

        % Class defintion model name
        %
        %   "modelName" is a string containing a short description of the model
        %   implemented in GENERIC
        modelName = 'Generic Data Container';

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell array of strings containing the specifier for
        %   each model parameter. There are no non-linear parameters for the
        %   GENERIC class
        nlinParams = {};

        % Class definition independent variable units
        %
        %   "xUnits" is a string specifying the units of the indpendent variable
        %   property "x"
        xUnits = '';

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
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

        end %generic.generic

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(~)
            val = identityFcn;
        end %generic.get.modelFcn

        function val = get.nlinParams(~)
            val = {};
        end %generic.get.nlinParams

        function val = get.plotFcn(~)
            val = [];
        end %generic.get.plotFcn

        function val = get.yProc(obj)
            val = obj.y;
        end %generic.get.yProc

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

        function val = processGuess(~,val)
        end %processGuess

    end %methods (Hidden)

end %generic