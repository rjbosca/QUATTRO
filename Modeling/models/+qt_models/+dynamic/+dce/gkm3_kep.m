classdef gkm3_kep < gkm

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
        %   implemented in GKM3_KEP
        modelName = '3 Param. General Kinetic Model (kep)';

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell array of strings containing the name of each
        %   model parameter. 'Ktrans' and either 've' or 'kep' are required for
        %   the general kinetic model. 'vp' is an optional model parameter.
        %   Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'Ktrans'        Initial [Gd] transfer rate (units: 1/s)
        %                       between the capillary space and extracellular
        %                       extravasculal space (EES)
        %
        %       'kep'           Efflux [Gd] transfer rate (units: 1/s)
        %                       between the EES and capillary space
        %
        %       'vp'            Fractional plasma volume (units: arb)
        nlinParams = {'Ktrans','kep','vp'};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = gkm3_kep(varargin)
        %gkm3_kep  Class for modeling DCE-MRI data with the 3 parameter GKM
        %
        %   OBJ = gkm3_kep(T,Y,VIF) creates a GKM3_KEP modeling object for the
        %   vector of  signal intensities, Y, at time points T using the
        %   vascular input function VIF. **Important** the time vector should be
        %   specified in units of seconds
        %
        %   OBJ = gkm3_kep(QTEXAM) creates a QUATTRO-linked GKM3_KEP modeling
        %   object. This provides automatic updates to the object properties
        %   when changes to the qt_exam object QTEXAM occur.
        %
        %   OBJ = gkm3_kep(...,'PROP1',VAL1,...) creates the modeling object as
        %   above, initializing the class properties specified by 'PROP1' to
        %   the value VAL1

            % Initialize the GKM3 specific parameter units (all others are
            % created in a super-class)
            obj.paramUnits.vp = '';

            % Parse the inputs
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

        end %gkm3_kep.gkm3_kep

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)

            % Cache the VIF and hematocrit to avoid extra property calls
            v   = obj.vifProc;
            hct = obj.hctArt;

            % Create a function handle that is based on the user-specified
            % non-linear model parameters
            val = @(x,xData) gkm_kep(x(:),xData,v,hct);

        end %gkm3_kep.get.modelFcn

        function val = get.plotFcn(obj)

            % Determine if all necessary parameters exist, creating the plotting
            % function using the estimated model parameters
            val = [];
            if all( isfield(obj.results,obj.nlinParams) )

                % Cache the VIF and hematocrit to avoid future property calls
                v   = obj.vifProc;
                hct = obj.hctArt;
                x0  = [obj.results.Ktrans.convert('1/second').value
                       obj.results.kep.convert('1/second').value
                       obj.results.ve.value];

                % Return the function handle
                val = @(x,xData) gkm_plot([x0(1);x0(1)/x0(2);x0(3)],xData,v,hct);

            end

        end %gkm3_kep.get.plotFcn

    end %get methods

end %gkm3_kep