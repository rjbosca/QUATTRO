classdef fspgrvfa_R1 < fspgrvfa & mrimagingprops

    properties (Dependent)

        % Function used for model fitting
        %
        %   "modelFcn" is a function handle used to fit a variable flip angle
        %   fast spoiled gradient echo data
        modelFcn

    end

    properties (Constant)

        % Class defintion model name
        %
        %   "modelName" is a string containing a short description of the model
        %   implemented in FSPGRVFA_R1
        modelName = 'Variable Flip Angle FSPGR (R1)';

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

        function obj = fspgrvfa_R1(varargin)
        %fspgrvfa_R1  Class for performing quantitative VFA T1 modeling
        %
        %   OBJ = fspgrvfa_R1(FA,Y) creates an FSPGRVFA_R1 model object from the
        %   vector of data acquisition flip angles FA and flip angle dependent
        %   signal intensities (Y), returning the object OBJ.
        %
        %   OBJ = fspgrvfa_R1(...,'PROP1',VAL1,...) creates the modeling object
        %   as above, initializing the class properties specified by the
        %   properties 'PROP1' to the value VAL1

            % Create listeners before modifying the object's properties
            addlistener(obj,'newResults',@obj.newResults_event);

            % Parse the inputs
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

        end

    end %fspgrvfa_R1.fspgrvfa_R1


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)
            trVal = obj.tr;
            val   = @(x,xdata) fspgr_vfa([x(1);1000/x(2)],xdata,trVal);
        end %fspgrvfa_R1.get.modelFcn

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

        function val = processGuess(obj,val)

            % Only continue if autoGuess is enabled and y data exist
            if ~obj.autoGuess || isempty(obj.y)
                return
            end

            % Estimate S0 and T1 using least squares and convert T1 to R1
            % (accounting for the difference in units)
            g      = fspgr_vfa_ols(obj.xProc,obj.yProc,obj.tr);
            val.S0 = g(1,:);
            val.R1 = 1000./g(2,:);

        end %fspgrvfa_R1.processGuess

    end %methods (Hidden)

    methods (Access='private')

        function newResults_event(obj,~,~)
        %newResults_event  Performs post-processing on fitted data
        %
        %   newResults_event(OBJ,SRC,EVENT) updates the "results" structure by
        %   calculating the additional model parameter T1 that is not otherwise
        %   computed by the "fit" method

            % Calculate the non-linear parameter that was not estimated
            if strcmpi( class(obj.results.S0), 'unit' )
                u = ['1/' obj.paramUnits.T1];
                obj.addresults('T1',1./obj.results.R1.convert(u).value);
            else
                %FIXME: this is temporary code until a "convert" method is
                %implemented in the qt_image class
                obj.addresults('T1',1000./obj.results.R1.value);
            end

        end %fspgrvfa_R1.newResults_event

    end

end %fspgrvfa_R1