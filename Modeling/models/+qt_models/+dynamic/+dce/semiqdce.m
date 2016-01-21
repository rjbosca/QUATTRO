classdef semiqdce < t1dynamic

    properties (Dependent)

        % Function used for model fitting
        %
        %   Function handle to the current DCE model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   time).
        %
        %   Note that uniformly spaced values of t are assumed for this function
        %   handle. For non-uniformly spaced values, use plotFcn instead
        modelFcn

        % Function used for plotting the model
        %
        %   "plotFcn" an interpolating version of "modelFcn" for the GKM class
        plotFcn

    end


    properties (Constant)

        % Class defintion model name
        %
        %   "modelName" is a string containing a short description of the model
        %   implemented in semiqdce
        modelName = 'Semi-Quantitative Kinetics';

        % Non-linear model parameter names
        %
        %   "nlinParams" is an empty cell array because semiqdce does not
        %   implement any non-linear model parameters
        nlinParams = {};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = semiqdce(varargin)
        %semiqdce  Class for semi-quantitative DCE-MRI modeling DCE-MRI
        %
        %   OBJ = semiqdce(T,Y) creates a semiqdce modeling object for the
        %   vector of signal intensities, Y, at time points T. **Important** the
        %   time vector should be specified in units of seconds
        %
        %   OBJ = semiqdce(QTEXAM) creates a QUATTRO-linked semiqdce modeling
        %   object. This provides automatic updates to the gkm properties when
        %   changes to the qt_exam object QTEXAM occur.
        %
        %   OBJ = semiqdce(...,'PROP1',VAL1,...) creates a semiqdce modeling
        %   object as above, initializing the class properties specified by
        %   'PROP1' to the value VAL1, etc.

            % Parse the inputs
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

            % Set some default values for SEMIQDCE that are different from those
            % defined in the super-class definitions
            obj.useRSI          = true;

            % Create the event listeners
            addlistener(obj,'newResults',@obj.newResults_event);

        end %semiqdce.semiqdce

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)

            val = [];

        end %semiqdce.get.modelFcn

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

        function val = processGuess(~,val)
        %processGuess  Performs sub-class specific estimates for "guess"
        end %semiqdce.processGuess

    end

    methods (Access='private')

        function newResults_event(obj,~,~)
        %newResults_event  Performs post-processing on fitted data
        %
        %   newResults_event(OBJ,SRC,EVENT) updates the "results" structure by
        %   calculating all semi-quantitative parameters as these parameters are
        %   not otherwise computed by the "fit"

            obj.calciauc; %this will also call "calciauc"
            obj.calcpeak;   %this will compute SER and TTP
            obj.calcslopes;

        end %semiqdce.newResults_event

    end


end %semiqdce