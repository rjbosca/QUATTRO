classdef t2w < t2wopts & pk & mrimagingprops

    properties (Dependent)

        % Processed y values
        %
        %   "yProc" applies the "subset" property to the first dimension of "y"
        %   and calculates the contrast agent concentration (or a surrogate)
        %   from the stored signal intensity
        %
        %   See also useT1Correction, useRSI, subset, and vifProc
        yProc

        % Processed VIF values
        %
        %   "vifProc" applies the "subset" property to "vif" and calculates the
        %   contrast agent concentration (or a surrogate) from the stored signal
        %   intensity.
        %
        %   See also useT1Correction, useRSI, subset, and yProc
        vifProc

    end

    properties (Hidden,SetAccess='protected')
        vifParams
    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = t2w

            % Add the event listeners
            addlistener(obj,'checkCalcReady',@obj.checkCalcReady_event);

            % Initialize the "isReady" field
            obj.isReady.(mfilename) = false;

        end %t2w.t2w

    end %class constructor


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

            %TODO: this is old code copied directly from the original "dsc"
            %class definition file. The code should be updated to incorporate
            %the ability to turn gamma fitting on and off. Also, caches should
            %be setup for the intense operations here...
            if ~isempty(obj.vifParams) %VIF has already been fit
                val = gamma_var(obj.vifParams,obj.x);
            else
                % Values necessary for model computation
                start  = obj.ignore+1;
                preIdx = obj; %"preEnhance" has been changed to "injectionTime"
                recIdx = obj.recirc;
                t      = obj.x;

                vifGd = squeeze(obj.process(val)); %[Gd] conversion
                x0    = tracer_gammafit(vifGd(start:end),t(start:end),...
                                        preIdx,recIdx); %fit first pass to gamma
                val   = gamma_var(x0,t);

                % Cache the gamma variate fit parameters for later use
                obj.vifParams = x0;

                % Determine the max value. This will become the new upper bound
                % on the bolus arrival time
                [~,tMax] = max(val);
                obj(2,end) = t(tMax);

                % Similarly, arrival of contrast should not occur before the
                % passage of the bolus through the AIF
                obj(1,end) = x0(4);

                % Calculate the fitted R^2 value
                obj.vifR2 = modelmetrics.calcrsquared(t(start:recIdx),vifGd(start:recIdx),...
                                                             val(start:recIdx));
            end

        end %t2w.get.vifProc

        function val = get.yProc(obj)

            % Initialize common variables
            nSeries = size(obj.y,1);

            % Determine the y-data size so that map computations can be
            % reshaped. Also, initialize the output
            if ~obj.isSingle
                mY = size(obj.y);
            end
            val = double( obj.y(:,:) );
            if isempty(val)
                return
            end

            % Average the pre-contrast signal along the temporal dimension.
            % Always use the optional dimenions input to ensure that a singleton
            % first dimension does not collapse an array (map computations) to a
            % scalar.
            yPre = mean( val(obj.subset & obj.preInds,:), 1 );

            % Process the y data
            %TODO: as with the note in get.vifProc, this code should be updated
            %to reflect the new class definition
            val = -1000*obj.k/obj.te * log(val./repmat(yPre,[nSeries 1]));

            % Apply the "subset" property
            val = val(obj.subset,:);

            % Restore the orignal size
            if ~obj.isSingle
                val = reshape(val,mY);
            end

        end %t2w.get.yProc

    end %get methods

end %t2w.t2w