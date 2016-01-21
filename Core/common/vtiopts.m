classdef vtiopts < handle
%vti class option definitions
%
%   vtiopts defines the user adjustable options that are common to all variable
%   inversion time modeling classes and QUATTRO options. This function serves
%   the latter by setting QT_OPTIONS as a sub-class of modelopts, wrapping all
%   option classes.

    properties (AbortSet,SetObservable)

        % Flag for restoring signed magnitude signal intensities
        %
        %   "usePolarityCorrection" is a logical flag that, when TRUE, attempts
        %   to restore the polarity of magnitude signal inensity data.
        %
        %   Default: TRUE
        usePolarityCorrection = true;
    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = vtiopts
        end %vtiopts.vtiopts

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.usePolarityCorrection(obj,val)
            validateattributes(val,{'logical'},{'scalar','nonempty'});
            obj.usePolarityCorrection = val;
            notify(obj,'updateModel');
        end %vtiopts.set.usePolarityCorrection

    end

end %vtiopts