classdef dwi < modelbase

    properties (Dependent)

        % Function used for model fitting
        %
        %   Function handle to the current DWI model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   b-values).
        modelFcn

        % Function used for plotting the model
        %
        %   Calls the modelFcn property and is only here for code conformity.
        plotFcn

        yProc

    end

    properties (Constant)

        % Class defintion model name
        %
        %   "modelName" is a string containing a short description of the model
        %   implemented in 
        modelName = 'Intra-voxel incoherent motion';

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell array of strings containing the specifier for
        %   each model parameter. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'S0'            Equilibrium magnetization (units: a.u.)
        %
        %       'D'             Diffusion coefficient (units: ???)
        nlinParams = {'S0','D'};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = dwi(varargin)
        %dwi  Class for performing quantitative DWI-MRI modeling
        %
        %   OBJ = dwi(B,Y) creates a dwi modeling object for the vector of
        %   acquisition b-values B and signal intensities Y.
        %
        %   OBJ = dwi(QTEXAM) creates a dwi modeling object from the data stored
        %   in the qt_exam object QTEXAM. Associated QUATTRO links are generated
        %   if available.
        %
        %   OBJ = dce(...,'PROP1',VAL1,...) creates a dwi modeling object as
        %   above, initializing the class properties specified by 'PROP1' to
        %   the value VAL1

            % Construct DWI specific defaults
            obj.xLabel = 'b-value (sec/mm^2)';
            obj.yLabel = 'S.I. (a.u.)';

            % Parse the inputs
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

        end %dwi

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)

            switch obj.modelVal
                case 1
                    val = @(x,xdata) ivim([x(:);0;0;0],xdata);
                case 2
                    val = @(x,xdata) ivim(x(:),xdata);
                case 3
                    val = @(x,xdata) ivim([x(1);x(2);0;x(3);x(4)],xdata);
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

            % Determine if the input needs to be expanded. Store the values for
            % D*, f, and K since there is currently no way to estimate them
            my  = size(obj.y);
            ndY = numel(my);
            if ndY==2
                my(:) = 1;
            end
            if numel(obj.y(:,1,1))~=numel(val(:,:,1))
                dStar      = val(1,1,3);
                f          = val(1,1,4);
                K          = val(1,1,5);
                val        = zeros([my(1:2) 5]);
                val(:,:,3) = dStar;
                val(:,:,4) = f;
                val(:,:,5) = K;
            end

            % Estimate S0 and ADC from simple linear regression. The linear
            % regression coefficients are given by R/(Q'*y). However, to handle
            % the case of 3D y arrays, the code must be broken up again.
            [Q,R]      = qr([obj.x(:),ones(numel(obj.x),1)],0);
            Rinv       = R^-1;

            % Calculate (Q'*y)
            d          = permute(repmat(Q,[1 1 my(1:2)]),[3 4 1 2]);
            d(:,:,:,1) = squeeze(d(:,:,:,1)).*log(obj.y);
            d(:,:,:,2) = squeeze(d(:,:,:,2)).*log(obj.y);
            d          = squeeze(sum(d,3));

            % Calculate R/(Q'*y)
            b          = permute(repmat(Rinv,[1 1 my(1:2)]),[3 4 1 2]);
            b(:,:,:,1) = squeeze(b(:,:,:,1)).*d;
            b(:,:,:,2) = squeeze(b(:,:,:,2)).*d;
            b          = squeeze(sum(b,3));

            % Store S0 and ADC estimates
            if ndY==2
                b(2) = exp(b(2));
                b    = b(2:-1:1);
            else
                b(:,:,2) = exp(b(:,:,2));
                b        = b(:,:,2:-1:1);
            end
            val(:,:,1:2) = b;

            % None of the parameters should be less than zero
            val(val<0) = NaN;

        end %processGuess

    end

end %dwi