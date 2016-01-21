classdef pk < t1dynamic & pkopts

    properties (AbortSet,SetObservable)

        % Vascular input function
        %
        %   "vif" is a vector containing the signal intensity for DCE and
        %   DSC exams. To use a custom VIF, set this property. When using
        %   the qt_models object with QUATTRO, just calling this property
        %   will access the curent ROIs to calculate the VIF
        vif

    end

    properties (SetAccess='protected',SetObservable)

        % Blood-Normalized Initial area under the curve parameter names
        %
        %   "bniaucParams" is a cell array containing the names of all blood
        %   normalized intial areas under the curve (BNIAUC) parameters
        %   estimated by the pk object
        bniaucParams = {'BNIAUC60','BNIAUC120','BNIAUC180'};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = pk

            % Add the property post-set listeners to update object following
            % changes to DCE specific properties occur
            addlistener(obj,'tIntegral','PostSet',@obj.tIntegral_postset);

            % Since pk inherits from dynamic, the parameter units structure has
            % already been initialized. Add the default BNIAUC units to the
            % structure. As with the superclass, these values will be updated
            % when changes to the "tIntegral" property are made
            obj.paramUnits.BNIAUC60  = '';
            obj.paramUnits.BNIAUC120 = '';
            obj.paramUnits.BNIAUC180 = '';

            % Add the event listeners
            addlistener(obj,'checkCalcReady',@obj.checkCalcReady_event);
            addlistener(obj,'showModel',     @obj.showModel_event);

            % Initialize the "isReady" field
            obj.isReady.(mfilename) = false;

        end %pk.pk

    end %Class Constructor


    %------------------------------- Set Methods -------------------------------
    methods

        function set.vif(obj,val)
            validateattributes(val,{'numeric'},...
                  {'vector','finite','nonnan','nonnegative','real','nonempty'});
            obj.vif = val(:); %enforce column vector - as per property "x"
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %pk.set.vif

    end %set methods

end %pk