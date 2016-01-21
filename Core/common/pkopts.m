classdef pkopts < handle
%pk class option definitions
%
%   pkopts defines the user adjustable options that are common to the pk class
%   and QUATTRO options. This function serves the latter by setting qt_options
%   as a sub-class of modelopts, wrapping all option classes.

    properties (AbortSet,SetObservable)

        % Semi-quantitative parameter computation flag
        %
        %   "calcSemiQ", when TRUE, computations of semi-quantitative parameters
        %   (such as the initial area under the curve) are flagged to be
        %   calculated in addition to the other model parameters
        %
        %   Default: FALSE
        calcSemiQ = false;

        % Tissue density
        %
        %   "density" is the density of tissue (units: [g/mL]) to be modeled.
        %   For brain tissue, value of 1.04 g/mL is usually used
        %
        %   Default: 1.04
        density = 1.04;

        % Large artery hematocrit
        %
        %   "hctArt" is the large artery hematocrit
        %
        %   Default: 0.45
        hctArt = 0.45;

        % Capillary hematocrit
        %
        %   "hctCap" is the capillary hematocrit
        %
        %   Default: 0.25
        hctCap = 0.25;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = pkopts
        end %pkopts.pkopts

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.calcSemiQ(obj,val)
            validateattributes(val,{'logical'},{'scalar','nonempty'});
            obj.calcSemiQ = val;
            notify(obj,'updateModel');
        end %pkopts.set.calcSemiQ

        function set.density(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.density = val;
            notify(obj,'updateModel');
        end %idtopts.set.density

        function set.hctArt(obj,val)
            validateattributes(val,{'numeric'},{'scalar','finite','nonnan',...
                                                'positive','real','nonempty',...
                                                                       '<=',1});
            obj.hctArt = val;
            notify(obj,'updateModel');
        end %pkopts.set.hctArt

        function set.hctCap(obj,val)
            validateattributes(val,{'numeric'},{'scalar','finite','nonnan',...
                                                'positive','real','nonempty',...
                                                                       '<=',1});
            obj.hctCap = val;
            notify(obj,'updateModel');
        end %idtopts.set.hctCap

    end

end %pkopts