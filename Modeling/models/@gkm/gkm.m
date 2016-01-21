classdef gkm < pk

    properties (Dependent)

        % Processed VIF values
        %
        %   "vifProc" applies the "subset" property to "vif" and calculates the
        %   contrast agent concentration (or a surrogate) from the stored signal
        %   intensity.
        %
        %   See also useT1Correction, useRSI, subset, and yProc
        vifProc

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = gkm

            % Initialize the object's parameter units.
            obj.paramUnits(1).Ktrans = '1/second';
            obj.paramUnits(1).kep    = '1/second';
            obj.paramUnits(1).ve     = '';

            % Initialize the parameter bounds that are common to all general
            % kinetic model sub-classes
            obj.paramBounds(1).Ktrans = [0 5/60];
            obj.paramBounds(1).kep    = [0 5/60];
            obj.paramBounds(1).ve     = [0 1];
            obj.paramBounds(1).vp     = [0 1];

            % Initialize the parameter guesses that are common to all general
            % kinetic model sub-classes. The "paramGuessCache" property is
            % called instead of the dependent "paramGuess" property becuase
            % validation does not need to be performed here...
            obj.userParamGuessCache = struct('Ktrans',0.5/60,...units: 1/s
                                             'kep',   0.5/60,...units: 1/s
                                             've',    0.5,...   units: N/A (vol. frac.)
                                             'vp',    1);      %units: N/A (vol. frac.)

            % Create listeners before modifying the object's properties
            addlistener(obj,'newResults',@obj.newResults_event);

        end %gkm.gkm

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.vifProc(obj)

            val = double(obj.vif);
            if isempty(val)
                return
            end

            % Initialize common variables
            yPre = mean( val(obj.preInds & obj.subset) );
            val  = val(obj.subset);

            % Process the VIF
            if obj.useT1Correction
                val = si_ratio2gd(yPre,val,obj.fa,obj.tr,obj.bloodT10,obj.r1);
            elseif obj.useRSI
                val = val./repmat(yPre,size(val))-1;
            else
                val = val-repmat(yPre,size(val));
            end

        end %gkm.get.vifProc

    end

    %------------------------------ Other Methods ------------------------------
    methods (Hidden)

        function val = processGuess(obj,val)
        %processGuess  Performs sub-class specific estimates for "paramGuess"
        %
        %   processGuess(OBJ,VAL)

            % Only continue if multi-dimensional y data exist
            if obj.isSingle
                return
            end

            % Calculate the mask of voxels that need to be processed (i.e. those
            % that enhanced)
            mask = obj.processMapSubset;

            % Since there is currently no way to estimate the parameters, the
            % "paramGuess" property should simply be a vector of N elements,
            % where N is the number of model parameters
            for p = obj.nlinParams(:)'
                if (numel(val.(p{1}))==1)
                    val.(p{1}) = repmat(val.(p{1}),[1 numel(mask)]);
                end
                val.(p{1})(:,~mask) = NaN;
            end

        end %gkm.processGuess

    end %methods (Hidden)

end %gkm