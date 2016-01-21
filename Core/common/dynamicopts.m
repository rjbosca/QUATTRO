classdef dynamicopts < handle
%dynamic class option definitions
%
%   dynamicopts defines the user adjustable options that are common to the
%   dynamicopts class and QUATTRO options. This function serves the latter by
%   setting qt_options as a sub-class of modelopts, wrapping all option classes.

    properties (AbortSet,SetObservable)

        % Time of bolus arrival
        %
        %   "injectionTime" specifies the time in seconds at which the contrast
        %   agent injection began. All data preceeding this time are considered
        %   pre-contrast, and used in computing the baseline signal intensity S0
        %
        %   Default: 0
        injectionTime = 0;

        % Dynamic analysis cut-off time
        %
        %   "recircTime" specifies the time within the dynamic data at which
        %   further data are ignored
        %
        %   For perfusion models based on indicator dilution theory, this value
        %   is used to define the "first pass" of contrast agent through the
        %   vasculature, omitting any data beyond the defined cut-off.
        %
        %   For semi-quantitative DCE-MRI analysis, this cut-off is used to
        %   define the latest time at which peak enhancement may occur
        recircTime

        % Minimum enhancement threshold
        %
        %   "enhanceThresh" specifies the minimum relative signal enhancement
        %   (defined as Smax/S0-1, where Smax is the maximum signal intensity in
        %   the dynamic series and S0 is the baseline signal). Voxels below this
        %   threshold are ignored during map computations.
        %
        %   Default: 0.5
        enhanceThresh = 0.5;

        % Number of initial time points to ignore
        %
        %   "ignore" is an integer representing the number of data points to
        %   ignore from the beginning of the data vectors when computiong model
        %   parameters. Only data values occuring after the value of "ignore"
        %   are considered when modeling.
        %
        %   Often in DSC acquisitions, the initial images have not reached
        %   steady-state causing signal intensity values decrease substaintially
        %   until steady-state imaging has been reached.
        %
        %   Default: 0
        ignore = 0;

        % Integration time for area under the curve (AUC)
        %
        %   "tIntegral" is a numeric vector (or scalar) of integration times
        %   (specified in seconds) to use when calculating the initial area
        %   under the curve (IAUC) and blood-normalized initial area under the
        %   curve (BNIAUC).
        %
        %   Default: [60 120 180]
        tIntegral = 60:60:180;

        % Integration start time
        %
        %   "tIntStart" is a numeric value specifying the starting time of the
        %   AUC integrations to be performed. If no value is specified, all
        %   integrations are started at the value of the "injectionTime"
        %   property
        %
        %   Default: 0
        %
        %   See also dynamic.injectionTime
        tIntStart = 0;

        % Integration time step
        %
        %   "tIntStep" is a numeric value specifying the spacing (in seconds) at
        %   which the dynamic signal should be interpolated to in order to
        %   estimate the integral. Smaller time steps (to an extent) will
        %   provide more accurate integration, but require more time.
        %
        %   Default: 1
        tIntStep = 1;

        % Relative signal compuation flag
        %
        %   "useRSI" when TRUE, normalizes changes in signal intensity to the
        %   pre-contrast value. In other words, S/S0-1, where S is the signal in
        %   question and S0 is the pre-contrast signal
        %
        %   Default: false
        useRSI = false;

    end


    %---------------------------- Class Constructor ----------------------------
    methods
        function obj = dynamicopts
        end
    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.enhanceThresh(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.enhanceThresh = val;
        end %dynamicopts.set.enhanceThresh

        function set.ignore(obj,val)
            validateattributes(val,{'numeric'},...
                                   {'scalar','finite','nonnan','real',...
                                    'nonnegative','nonempty','integer'});
            obj.ignore = val;
            notify(obj,'updateModel');
        end %dynamicopts.set.ignore

        function set.injectionTime(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.injectionTime = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %dynamicopts.set.injectionTime

        function set.recircTime(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.recircTime = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %dynamicopts.set.recircTime

        function set.tIntegral(obj,val)
            validateattributes(val,{'numeric'},...
                                   {'finite','nonnan','positive','real'});
            if ~isempty(val) && ((size(val,1)~=1) || (size(val,2)~=1))
                error([mfilename ':tIntegral:invalidInput'],...
                                     'Expected input to be a scalar or vector');
            end
            obj.tIntegral = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %dynamicopts.set.tIntegral

        function set.tIntStart(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.tIntStart = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %dynamicopts.set.tIntStart

        function set.tIntStep(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.tIntStep = val;
            notify(obj,'updateModel');
        end %dynamicopts.set.tIntStep

        function set.useRSI(obj,val)
            validateattributes(val,{'logical'},{'scalar','nonempty'});
            obj.useRSI = val;
            notify(obj,'updateModel');
        end %dynamicopts.set.useRSI

        
    end

end