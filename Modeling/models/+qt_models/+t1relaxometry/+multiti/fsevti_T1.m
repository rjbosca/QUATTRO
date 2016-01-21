classdef fsevti_T1 < sevti & mrimagingprops

    properties (Dependent)

        % Function used for model fitting
        %
        %   "modelFcn" is a function handle used to fit a variable inversion
        %   time spin echo relaxometry data
        modelFcn

    end

    properties (Constant)

        % Class defintion model name
        %
        %   "modelName" is a string containing a short description of the model
        %   implemented in MULTITI
        modelName = 'Multiple TI SE';

        % Non-linear model parameter names
        %
        %   "nlinParams" is a cell array of strings containing the specifier for
        %   each model parameter. Valid parameters are:
        %
        %       Parameter       Description
        %       ===========================
        %       'S0'            Equilibrium magnetization (units: a.u.)
        %
        %       'T1'            Longitudinal relaxation rate (units: 1/s)
        nlinParams = {'S0','T1'};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = fsevti_T1(varargin)
        %multiti  Class for performing quantitative VTI T1 modeling
        %
        %   OBJ = multiti(TI,Y) creates a multiti modeling object for the vector
        %   of signal intensities Y and corresponding inversion times TI,
        %   returning the multiti object, OBJ.
        %
        %   OBJ = multiti(H) creates a multiti modeling object linked to an
        %   instance of QUATTRO specified by the handle H.
        %
        %   OBJ = multiti(...,'PROP1',VAL1,...) creates a multiti modeling 
        %   object as above, initializing the class properties specified by the
        %   properties 'PROP1' to the value VAL1

            % Create listeners before modifying the object's properties
            addlistener(obj,'newResults',@obj.newResults_event);

            % Parse the inputs
            if nargin
                qt_models.parse_inputs(obj,varargin{:});
            end

        end %fsevti_T1.fsevti_T1

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.modelFcn(obj)
            val = @(x,xdata) fse_vti([x(:);180],xdata);
            if ~obj.usePolarityCorrection
                val = @(x,xdata) abs(val(x,xdata));
            end
        end %fsevti_T1.get.modelFcn

    end %get methods


    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

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

        function val = processGuess(obj,val)
        %processGuess  Estimates model parameters from simple computations
        %
        %   processGuess attempts to estimate model parameters by performing
        %   simple mathematical operations on the "y" data. This method is only
        %   employed when "autoGuess" is enabled (i.e. true).

            % Only continue if autoGuess is enabled and y data exist
            if ~obj.autoGuess || isempty(obj.y)
                return
            end

            % Find the TI corresponding to the lowest signal. This (and the two
            % TIs - one lower, one higher) will be used to define the range of
            % T1 values to search
            [~,minIdx] = min( abs(obj.y) );
            minTi      = obj.xProc(minIdx);
            maxDelTi   = max( diff(obj.x) )/2;

            % Create the vector of T1 values to search using the reduced
            % dimensionality non-linear algorithm
            vecT1 = (max([obj.paramBounds.T1(1)   minTi-maxDelTi]):...
                     min([obj.paramBounds.T1(end) minTi+maxDelTi]))/log(2);

            % Perform the non-linear estimation
            %FIXME: currently, the following code uses all values stored in the
            %"y" property. This will cause issues if the user has specified to,
            %for example, ignore a noisy data point...
            nlsInit                          = struct('tVec',obj.xProc,...
                                                      'T1Vec',vecT1);
            nls                              = getNLSStruct(nlsInit,false,1);
            [obj.tiInvThreshCache.intern,x0] = restore_ir( abs(obj.y), nls );

            % Update the parameter guess if "autoGuess" is enabled
            val.S0 = x0(1);
            val.T1 = x0(2);

        end %fsevti_T1.processGuess

    end %methods (Hidden)

    methods (Access='private',Hidden)

        function newResults_event(obj,~,~)
        %newResults_event  Performs post-processing on fitted data
        %
        %   newResults_event(OBJ,SRC,EVENT) updates the "results" structure by
        %   calculating the additional model parameter R1 that is not otherwise
        %   computed by the "fit" method

            % Calculate the non-linear parameter that was not estimated
            if strcmpi( class(obj.results.S0), 'unit' )
                u = strrep(obj.paramUnits.R1,'1/','');
                obj.addresults('T1',1./obj.results.R1.convert(u).value);
            else
                %FIXME: this is temporary code until a "convert" method is
                %implemented in the qt_image class
                obj.addresults('T1',1./obj.results.R1.value);
            end

        end %fspgrvfa_T1.newResults_event

    end %methods (Access='private',Hidden)

end %fsevti_T1