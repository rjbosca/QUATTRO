classdef t2wopts < handle
%t2w class option definitions
%
%   t2wopts defines the user-adjustable options that are common to the all T2
%   weighted options and QUATTRO options. This function serves the latter by
%   setting qt_options as a sub-class of modelopts, wrapping all properties of
%   the option classes

    properties(AbortSet,SetObservable)

        % Gd proportionality constant
        %
        %   "k" is the contrast agent proportionality constant that is used to
        %   convert signal intensity to contrast agent concentration (in
        %   arbitrary units).
        %
        %   Default: 1
        %
        %
        %   References
        %   ----------
        %
        %   [1] Weisskoff RM, et. al., Magn. Reson. Med., Vol 31 (6),
        %       pp. 601-610, 1994
        %
        %   [2] Boxerman J, et. al., Magn. Reson. Med., Vol 34 (4),
        %       pp. 555-566, 1995
        k = 1;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = t2wopts
        end %t2wopts.t2wopts

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.k(obj,val)
            validateattributes(val,{'numeric'},...
                     {'scalar','finite','nonnan','positive','real','nonempty'});
            obj.k = val;
            notify(obj,'updateModel');
        end %t2wopts.set.k

    end

end %t2wopts