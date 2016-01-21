classdef t1dynamic < t1dynamicopts & dynamic & mrimagingprops

    properties (Dependent)

        % Processed y values
        %
        %   "yProc" applies the "subset" property to the first dimension of "y"
        %   and calculates the contrast agent concentration (or a surrogate)
        %   from the stored signal intensity
        %
        %   See also useT1Correction, useRSI, subset, and vifProc
        yProc

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = t1dynamic

            % Add the property post-set listeners for the dependent variable
            % pre-processing flags
            addlistener(obj,'tissueT10',      'PostSet',@obj.tissueT10_postset);
            addlistener(obj,'useRSI',         'PostSet',@obj.useRSI_postset);
            addlistener(obj,'useT1Correction','PostSet',...
                                                  @obj.useT1Correction_postset);
            addlistener(obj,'y',              'PostSet',@obj.y_postset);

            % Add the event listeners
            addlistener(obj,'checkCalcReady',@obj.checkCalcReady_event);

            % Initialize the "isReady" field
            obj.isReady.(mfilename) = false;

        end %t1dynamic.t1dynamic

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.yProc(obj)

            % Determine the y-data size so that map computations can be reshaped
            % and initialize the output
            if ~obj.isSingle
                mY = size(obj.y);
            end
            val = double( obj.y(:,:) );
            if isempty(val)
                return
            end

            % Initialize the workspace
            nSeries = size(obj.y,1);
            if obj.useT1Correction
                t10 = obj.tissueT10;
                if ~obj.isSingle && (numel(t10)==1)
                    t10 = repmat(t10,mY(2:end));
                end
            end

            % Average the pre-contrast signal along the temporal dimension.
            % Always use the optional dimenions input to ensure that a singleton
            % first dimension does not collapse an array (map computations) to a
            % scalar.
            yPre = mean( val(obj.subset & obj.preInds,:), 1 );

            % Process the y-data
            if obj.useT1Correction
                val = si_ratio2gd(yPre,val,obj.fa,obj.tr,t10(:)',obj.r1);
            elseif obj.useRSI
                % RSI is defined as: (SI_c - SI)/SI. SI_c is the signal
                % intensity post-contrast and SI is the baseline signal
                % intensity
                mask         = (obj.subset & ~obj.preInds);
                val(mask,:)  = val(mask,:)./repmat(yPre,[sum(mask) 1])-1;
                val(~mask,:) = 0;
            else %delta S.I. computation
                val = val-repmat(yPre,[nSeries 1]);
            end

            % Apply the "subset" property
            if ~any(obj.subset)
                val = val(obj.subset,:);
            end

            % Restore the orignal size
            if ~obj.isSingle
                val = reshape(val,mY);
            end

        end %t1dynamic.get.yProc

    end %get methods

end %t1dynamic