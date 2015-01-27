classdef dsc < qt_models

    properties %general model properties

        % MR imaging echo time in milliseconds
        te;

        % Gd proportionality constant
        %
        %   Contrast agent proportionality constant that allows conversion of
        %   signal intensity to concentration of contrast. The default of 1
        %   provides an arbitrary unit of concentration.
        %
        %   For a thorough discussion of this topic, see:
        %   [1] Weisskoff RM, et. al., Magn. Reson. Med., Vol 31 (6),
        %       pp. 601-610, 1994
        %
        %   [2] Boxerman J, et. al., Magn. Reson. Med., Vol 34 (4),
        %       pp. 555-566, 1995
        k = 1;

        % Number of initial time points to ignore
        %
        %   An integer representing the number of time points to ignore when
        %   computiong model parameters. Only values starting at the index of
        %   ignore+1 are considered the model.
        %
        %   Often in DSC acquisitions, the initial images have not reached
        %   steady-state causing signal intensity values decrease substaintially
        %   until steady-state imaging has been reached.
        %
        %   Default: 0
        ignore = 0;

        % Number of baseline time points
        %
        %   An integer representing the number of baseline time points to use
        %   in the estimation of the steady-state signal intensity, S0. Note
        %   that preEnhance>ignore
        preEnhance;

        % Image number of the recirculation cut-off
        %
        %   An integer representing the last image before contrast recirculation
        %   occurs. This value is used in "first pass" models to neglect data
        %   that contain contributions from recirculated contrast. Note that
        %   recirc>preEnhance
        recirc;

        % Artery hematocrit
        %
        %   Default: 0.45
        hctArt = 0.45;

        % Capillary hematocrit
        %
        %   Default: 0.25
        hctCap = 0.25;

        % Tissue density
        %
        %   Default: 1.04 [g/mL]
        density = 1.04;

    end

    properties (SetAccess = 'protected')

        % VIF gamma variate fit parameters
        %
        %   A row vector of gamma variate parameters (i.e., [k alpha beta t0])
        %   fitted to the vascular input function. For a complete description of
        %   these parameters:
        %
        %   See also gamma_var
        vifParams

        % VIF coefficient of determination
        %
        %   A goodness-of-fit parameter for the estimated gamma-variate function
        %   of the VIF
        vifR2

    end

    properties (Dependent = true)

        % rCBV normalizing factor
        %
        %   alpha is a normalizing factor that accounts for the differences in
        %   the hematocrit of small and large blood vessels (see "hctCap" and
        %   "hctArt") and incorporates the tissue density (in [g/mL]).
        %
        %   For a more thorough discussion, see:
        %   [1] Calamante F, et al., J. Cereb. Blood Flow Metab., Vol 19 (7),
        %       pp. 701-735, 1999
        %
        %   [2] Tofts P, "Quantitative MRI of the Brain", Ch. 11,
        %       Chichester, UK: John Wiley & Sons, Ltd, 2003
        alpha

        % Function used for model fitting
        %
        %   Function handle to the current DSC model of the form @(x0,t) f(x0,t)
        %   where x0 are model parameters and t is the dependent variable (i.e.
        %   time).
        %
        %   Note that uniformly spaced values of t are assumed for this function
        %   handle. For non-uniformly spaced values, use plotFcn instead
        modelFcn

        % Function used for plotting the model
        %
        %   Function handle to the current DSC convenient for plotting the model
        %   with the form @(x0,t) f(x0,t).
        plotFcn

    end

    properties (Dependent = true, Hidden = true)

        % Flag for computation readiness
        %
        %   Returns true if the object is prepared for computation and false
        %   otherwise.
        isReady;

        % Processed VIF curve
        %
        %   Calculated [Gd] concentration of the VIF. Gamma-variate fitting is
        %   also performed here. The "get" method of this property populates the
        %   vifParams and vifR2 properties.
        vifProc;

    end

    properties (Constant,Hidden = true)

        % Structure of DSC model information
        modelInfo = struct('Scale',{[1 1 1 1 1]},...
                           'Names',{{'gammaK','gammaA','gammaB','BAT','rCBV'}},...
                           'Units',{{'','','','','mL/g'}});

        % Model names
        %
        %   A string cell array containing the names of the models. The location
        %   of each string specifies the index that should be used to access the
        %   actual model using the model property.
        %
        %   The qt_models GUI uses this property to populate the "Models" pop-up
        %   menu.
        modelNames = {'First Pass'};

        % Model parameter indices
        %
        %   A set of indices used to ensure only parameters to be modeled are
        %   used by the modeling objects.
        modelInds = 1:4;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = dsc(varargin)
        %dsc  Class for performing quantitative DSC-MRI modeling
        %
        %   OBJ = dsc(T,Y,VIF) creates a dsc model object for the vector of
        %   signal intensities, Y, at the time points T using the vascular input
        %   function VIF.
        %
        %   OBJ = dsc(QTEXAM) creates a dsc modeling object from the data stored
        %   in the qt_exam object QTEXAM. Associated QUATTRO links are generated
        %   if available.
        %
        %   OBJ = dsc(...,'PROP1',VAL1,...) creates a dsc modeling object as
        %   above, initializing the class properties specified by 'PROP1' to
        %   the value VAL1

            % Construct DSC specific defaults
            obj.bounds = [zeros(4,1) inf(4,1)];
            obj.guess  = [1 1 1 1];
            obj.xLabel = 'Time (sec)';
            obj.yLabel = '[Gd] (mM)';

            % Parse the inputs
            if isempty(varargin)
                return
            end
            [exam,props,vals] = parse_inputs(varargin{:});

            % Associate an instance of a QUATTRO GUI
            if ~isempty(exam)
                if ~isempty(exam.hFig) && ishandle(exam.hFig)
                    obj.hQt    = exam.hFig;
                end
                obj.x          = exam.modelXVals;
                obj.preEnhance = exam.opts.preEnhance;
                obj.k          = exam.opts.dscK;
                obj.hctArt     = exam.opts.hctArt;
                obj.hctCap     = exam.opts.hctCap;
                obj.te         = exam.header.EchoTime;
                obj.guiDialogs = obj.hExam.guiDialogs;
            end

            % Apply user-specified options
            for prpIdx = 1:length(props)
                obj.(props{prpIdx}) = vals{prpIdx};
            end

        end %dsc

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods 

        function val = get.alpha(obj)
            val = obj.density/( (1-obj.hctArt)/(1-obj.hctCap) );
        end %get.alpha

        function val = get.isReady(obj)

            % Initialize the output
            val = false;

            val = val || (~isempty(obj.te) &&...
                          ~isempty(obj.k) &&...
                          ~isempty(obj.ignore) &&...
                          ~isempty(obj.preEnhance) &&...
                          ~isempty(obj.vifProc));
                          
        end %get.isReady

        function val = get.modelFcn(obj)

            switch obj.modelVal
                case 1 %first-pass kinetic model
                    val = @(x,xdata) gamma_var(x(:),xdata);
            end

        end %get.modelFcn

        function val = get.plotFcn(obj)

            switch obj.modelVal
                case 1 %first-pass kinetic model
                    val = obj.modelFcn;
            end

        end %get.plotFcn

        function val = get.vifProc(obj)

            val = obj.vif(:);
            if isempty(val)
                return
            end

            if ~isempty(obj.vifParams) %VIF has already been fit
                val = gamma_var(obj.vifParams,obj.x);
            else
                % Values necessary for model computation
                start  = obj.ignore+1;
                preIdx = obj.preEnhance;
                recIdx = obj.recirc;
                t      = obj.x;

                % Process VIF 
                if (numel(val)==length(val))
                    val = permute(val(:),[3 2 1]);
                end
                vifGd = squeeze(obj.process(val)); %[Gd] conversion
                x0    = tracer_gammafit(vifGd(start:end),t(start:end),...
                                        preIdx,recIdx); %fit first pass to gamma
                val   = gamma_var(x0,t);

                % Cache the gamma variate fit parameters for later use
                obj.vifParams = x0;

                % Determine the max value. This will become the new upper bound
                % on the bolus arrival time
                [~,tMax] = max(val);
                obj.bounds(2,end) = t(tMax);

                % Similarly, arrival of contrast should not occur before the
                % passage of the bolus through the AIF
                obj.bounds(1,end) = x0(4);

                % Calculate the fitted R^2 value
                obj.vifR2 = r_squared(t(start:recIdx),vifGd(start:recIdx),...
                                                             val(start:recIdx));
            end

        end %get.vifProc

    end %get methods


    %------------------------------- Set Methods -------------------------------
    methods

        function set.ignore(obj,val)

            % Force a rounded value
            val = round(val);

            % Validate the value
            if numel(val)>1
                error('qt_models:dsc:nonScalarIgnoreIndex',...
                      'Ignore index must be a scalar');
            elseif numel(val)<0
                error('qt_models:dsc:negativeIgnoreIndex',...
                      'Ignore index must be a positive scalar or 0');
            elseif length(obj.x)<val
                warning('qt_models:dsc:invalidIgnoreIndex','%s\n%s\n',...
                        'The ignore index exceeds the number of datums.',...
                        'No changes have been made to "ignore"');
                return
            end

            % Store the value and update the index
            obj.ignore = val;
            if ~isempty(val)
                obj.subset(1:val) = false;
            end

        end %set.ignore

        function set.recirc(obj,val)

            % Force a rounded value
            val = round(val);

            % Validate the value
            if numel(val)>1
                error('qt_models:dsc:nonScalarRecirculationIndex',...
                      'Recirculation index must be a scalar');
            elseif numel(val)<1
                error('qt_models:dsc:negativeRecirculationIndex',...
                      'Recirculation index must be a positive scalar greater than 0');
            elseif length(obj.x)<val
                warning('qt_models:dsc:invalidRecirculationIndex','%s\n%s\n',...
                        'The recirculation index exceeds the number of datums.',...
                        'No changes have been made to "recirc"');
                return
            end

            % Store the value and update the index
            obj.recirc = val;
            if ~isempty(val)
                obj.subset(val:end) = false;
            end

        end %set.recirc

    end %set methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden = true)

        function val = process(obj,val)
            %proccess  Performs pre-processing on data to be fitted
            %
            %   process calculates signal inensity conversion for various
            %   qt_models sub-classes during calls to the "yProc" property of
            %   qt_models.
            %
            %   This method converts dsc signal intensity to arbitrary units of
            %   [Gd] by calculating the ratio of post-contrast signal intensity
            %   to pre-contrast SI. The resulting [Gd] is then -k/te*log(SR),
            %   where SR is the signal intensity ratio and all other symbols are
            %   given by the associated dsc property.

            if isempty(val)
                return
            end

            % Get some fitting options
            start  = obj.ignore+1;
            preIdx = obj.preEnhance;

            % Convert SI to [Gd], removing user-selected frames, rejecting the
            % pre-steady-state frames
            s0  = mean(val(:,:,start:preIdx),3);
            val = -1000*obj.k/obj.te * log(val./repmat(s0,[1 1 size(val,3)]));

            % Remove inifinte relative [Gd] values
            val(isinf(val)) = NaN;

        end %get.process

        function val = processFit(obj,val)
            %processFit  Performs post-processing on fitted data
            %
            %   processFit calculates additional model parameters that are not
            %   otherwise computed by the "fit" method. For DSC objects, the
            %   regional cerebral blood volume is calculated

            if all(isfield(obj.results,{'gammak','gammaa','gammab','bat'})) %rCBV map

                % Generate the rCBV map
                f      = obj.modelFcn;
                vifInt = quadgk(@(t) f(obj.vifParams,t),0,obj.x(end));
                ctInt  = arrayfun(@(x1,x2,x3,x4) quadgk(@(t) f([x1,x2,x3,x4],t),0,obj.x(end)),...
                                    obj.results.gammak,...
                                    obj.results.gammaa,...
                                    obj.results.gammab,...
                                    obj.results.bat);

                % Store the map
                obj.results.rcbv = (1/obj.alpha)*ctInt/vifInt;
            end

        end %processFits

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

            % Use the VIF parameters as the initial guess
            if isempty(obj.vifParams) || isempty(obj.vif)
                obj.vifProc; %fire the VIF processor
            end
            val = obj.vifParams;

        end %processGuess

        function [yc,r2] = results2array(obj)

            % Generate the parameter array
            yc(:,:,1) = obj.results.gammak;
            yc(:,:,2) = obj.results.gammaa;
            yc(:,:,3) = obj.results.gammab;
            yc(:,:,4) = obj.results.bat;

            %TODO: there are currently no bounds for handling rCBV. This is a
            %major issue that needs to be addressed.
            
            % Output R^2
            r2 = obj.results.R_squared;

            % Apply any bounds
            r2(obj.results.rcbv<0 | obj.results.rcbv>2) = NaN;
            r2(obj.results.bat<obj.bounds(1,end) |...
                                       obj.results.bat>obj.bounds(2,end)) = NaN;

        end %results2array

    end %methods (Access = 'private', Hidden = true)

end %classdef


function varargout = parse_inputs(varargin)

    % Determine input syntax (either qt_exam object or time/signal/vif)
    parser = inputParser;
    if strcmpi(class(varargin{1}),'qt_exam')
        parser.addRequired('hExam',@(x) x.isvalid);
        opts = varargin(2:2:end);
    elseif nargin==1
        error(['qt_models:' mfilename ':invalidExamObj'],...
                        'Single input syntax requires a valid qt_exam object.');
    else
        parser.addRequired('x',  @isnumeric);
        parser.addRequired('y',  @isnumeric);
        parser.addRequired('vif',@isnumeric);
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