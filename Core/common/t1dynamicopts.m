classdef t1dynamicopts < handle
%t1dynamic class option definitions
%
%   t1dynamicopts defines the user adjustable options that are common to the
%   T1DYNAMIC class and QUATTRO options. This function serves the latter by
%   setting QT_OPTIONS as a sub-class of MODELOPTS, wrapping all option classes.

    properties (AbortSet,SetObservable)

        % Blood T10
        %
        %   "bloodT10" is the assumed blood pre-contrast relaxation time in ms.
        %   This value is only used when T1 correction is enabled.
        %
        %   Default: 1440
        bloodT10 = 1440;

        % Tissue T10
        %
        %   "tissueT10" is the assumed tissue pre-contrast relaxation time in
        %   ms. Tissue T10 can be either a scalar or an N-D array of values,
        %   where the size 
        %   This property is only used when T1 correction is enabled.
        %
        %   Default: 1000
        %TODO: finish describing the N-D array syntax
        tissueT10 = 1000;

        % Contrast agent relaxivity in /mM/s
        %
        %   "r1" is the assumed relaxivity of the contrast agent in /mM/s.  This
        %   property is only used when T1 correction is enabled. 
        %
        %   Default: 4.9
        r1 = 4.9;

        % Signal to contrast concentration flag
        %
        %   "useT1Correction" when TRUE, converts changes in signal intensity
        %   (measured from pre-contrast) to contrast agent concetration assuming
        %   a linear relaxation rate relationship
        %
        %   Default: FALSE
        useT1Correction = false;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = t1dynamicopts
        end %t1dynamicopts.t1dynamicopts

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.bloodT10(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.bloodT10 = val;
        end %t1dynamicopts.set.bloodT10

        function set.r1(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.r1 = val;
        end %t1dynamicopts.set.r1

        function set.useT1Correction(obj,val)
            val = logical(val);
            validateattributes(val,{'logical'},{'scalar','nonempty'});
            obj.useT1Correction = val;
            notify(obj,'checkCalcReady');
            notify(obj,'updateModel');
        end %t1dynamicopts.set.useT1Correction

        function set.tissueT10(obj,val)
            validateattributes(val,{'numeric'},...
                              {'finite','nonnan','positive','real','nonempty'});
            obj.tissueT10 = val;
        end %t1dynamicopts.set.tissueT10

    end %set methods

end %t1dynamicopts