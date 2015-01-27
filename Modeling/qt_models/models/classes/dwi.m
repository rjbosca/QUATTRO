classdef dwi < qt_models

    properties (Dependent = true)

        % Function used for model fitting
        %
        %   Function handle to the current DWI model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   b-values).
        modelFcn;

        % Function used for plotting the model
        %
        %   Calls the modelFcn property and is only here for code conformity.
        plotFcn;

    end

    properties (Dependent = true, Hidden = true)

        % Model parameter indices
        %
        %   A set of indices used to ensure only parameters to be modeled are
        %   used by the modeling objects.
        modelInds;

    end

    properties (Constant,Hidden = true)

        % Structure of DWI model information
        modelInfo = struct('Scale',{[1 1000 1000 100 1]},...
                           'Names',{{'S0','ADC','D_Star','f','K'}},...
                           'Units',{{'','x10^-3 mm^2/s','x10^-3 mm^2/s','',''}});

        % Model names
        %
        %   A string cell array containing the names of the models. The location
        %   of each string specifies the index that should be used to access the
        %   actual model using the model property.
        %
        %   The qt_models GUI uses this property to populate the "Models" pop-up
        %   menu.
        modelNames = {'Mono-Exp.','IVIM (Full)','IVIM (No D*)','Linear'};

        % Flag for computation readiness
        %
        %   This flag is defined in all sub-classes of qt_models. However,
        %   because the "calcsReady" property of qt_models checks the x/y data
        %   of the object, no checks need be performed here.
        isReady = true;

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
            obj.bounds = [0  inf
                          0  inf
                          0  0.01
                          0   1
                          0  inf];
            obj.xLabel = 'b-value (sec/mm^2)';
            obj.yLabel = 'S.I. (a.u.)';
            obj.guess  = [1 1 1 1 1];

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

        function val = get.modelInds(obj)

            switch obj.modelVal
                case 1
                    val = 1:2;
                case 3
                    val = [1 2 4 5];
                otherwise
                    val = 1:5;
            end

        end %get.modelInds

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
            %   This method performs no processing for dwi modeling objects and
            %   is here for code conformity as the "yProc" property of qt_models
            %   calls this method.
        end %process

        function val = processFit(obj,val) %#ok
            %processFit  Performs post-processing on fitted data
            %
            %   processFit calculates additional model parameters that are not
            %   otherwise computed by the "fit" method. For DWI objects, no
            %   additional computations are currently supported. This code is
            %   here simply for conformity
        end %processFit

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

    end %methods (Access = 'private', Hidden = true)

end %classdef


function varargout = parse_inputs(varargin)

    % Determine input syntax (either figure handle or b-value/signal)
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