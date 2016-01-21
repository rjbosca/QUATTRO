classdef sevti < t1relaxometry & vtiopts

    properties (Dependent)

        % Function used for plotting the model
        %
        %   "plotFcn" same as "modelFcn" for the MULTTI class
        plotFcn

        % Null inversion time threshold
        %
        %   "tiInvThresh" is a numeric scalar that represents the null inversion
        %   time threshold in milliseconds. This value is only used to restore
        %   the polarity of magnitude VTI data.
        tiInvThresh

        % Processed y values
        %
        %   "yProc" is a dependent property that performs any pre-processing and
        %   applies the property "subset"
        yProc

    end

    properties (Hidden,Access='protected',Transient,SetObservable)

        % Null inversion time auto-guess cache
        %
        %   "tiInvThreshCache" is a two field structure (fields: "internal" and
        %   "user") that is used to store a numeric scalar repreenting null TI
        %   estimated by the auto-guess feature ("internal") and provided by the
        %   user ("user").
        %
        %   See also sevti.tiInvThresh
        tiInvThreshCache = struct('internal',[],'user',[]);

        % Inversion mask
        %
        %   "inversionMask" is a logical row vector that determines which values
        %   of "y" are inverted (TRUE)
        inversionMask = logical([]);

    end

    properties (Constant)

        % Class definition independent variable units
        %
        %   "xUnits" is a string specifying the units of the indpendent variable
        %   property "x"
        xUnits = 'milliseconds';

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = sevti

            % Add the event listeners
            addlistener(obj,'showModel',@obj.showModel_event);

            % Add the property post-set listeners
            addlistener(obj,'tiInvThreshCache','PostSet',@obj.tiInvThreshCache_postset);

            % Update the VTI specific model parameters
            obj.paramUnits(1).FA  = 'degree';
            obj.paramBounds(1).FA = [-inf inf];

            % Initialize the VTI specific parameter guess. The "paramGuessCache"
            % property is called instead of the dependent "paramGuess" property
            % becuase validation does not need to be performed here...
            obj.userParamGuessCache.FA = 180;

        end %sevti.sevti

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.plotFcn(obj)

            % Determine if all necessary parameters exist, creating the plotting
            % function using the estimated model parameters
            val = [];
            if all( isfield(obj.results,obj.nlinParams) )
                x0  = [obj.results.S0.value,...
                       obj.results.T1.convert('milliseconds').value,...
                       180];
                if isfield(obj.results,'FA')
                    x0(3) = obj.results.FA.convert(obj.paramUnits.FA).value;
                end
                val = @(xData) fse_vti(x0,xData);
            end
            
        end %sevti.get.plotFcn

        function val = get.tiInvThresh(obj)
            val = obj.tiInvThreshCache.user;
            if obj.autoGuess
                val = obj.tiInvThreshCache.internal;
            end
            if isempty(val)
                val = log(2)*obj.paramGuess.T1;
            end
        end %sevti.get.nullTi

        function val = get.yProc(obj)

            % Get the current "x" and "y" data
            val = obj.y;
            x   = obj.xProc;
            if ~isempty(val)
                val = val(obj.subset,:);
            end

            % Determine how to perform the signal polarity restoration. There
            % are four cases: (1) "autoGuess" is enabled - rely on the estimated
            % parameter value in the "paramGuess" property, (2) "autoGuess" is
            % enabled, but the user has provided an estimate for "nullTi", (3)
            % the user has defined a value for the starting guess, but no
            % "nullTi" value, or (4) user-defined starting guess values are
            % being used and "nullTi" has been defined.
            if obj.usePolarityCorrection
                tiThresh        = obj.tiInvThresh;
                val(x<tiThresh) = -1*val(x<tiThresh);
            end

        end %sevti.get.yProc

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.tiInvThresh(obj,val)
            validateattributes(val,{'numeric'},...
                                   {'finite','nonnan','nonsparse','nonempty',...
                                    'nonnegative','scalar','real'});
            obj.autoGuess             = false; %disable "autoGuess"
            obj.tiInvThreshCache.user = val;
        end %sevti.set.tiInvThresh

    end

end %sevti