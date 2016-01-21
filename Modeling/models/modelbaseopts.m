classdef modelbaseopts < handle


    properties (SetObservable,AbortSet)

        % Algorithm used in fitting
        %
        %   "algorithm" is a string specifying fitting algorithm to be used and
        %   must be one of 'levenberg-marquardt', 'trust-region-reflective'
        %   (default), 'nelder-mead', or 'robust'. Note that the robust
        %   least-squares algorithm requires the Statistics Toolbox
        %
        %   See also lsqcurvefit, fminsearch, nlinfit, optimset, optimget
        algorithm = 'trust-region-reflective';

        % Flag for performing fits automatically
        %
        %   "autoFit" is a logical scalar that, when TRUE, enables automatic
        %   fitting of a given data set when all necessary object properties are
        %   populated. By default, this option is disabled (i.e., FALSE), but
        %   this is useful when linked to QUATTRO. This option is not advised
        %   when working with multidimensional y data (e.g., maps).
        autoFit = false;

        % Flag for using an automatic initial vaule
        %
        %   "autoGuess" is a logical scalar that when TRUE (default), the
        %   initial value used in the non-linear fitting routine is either
        %   estimated from the current modeling object's properties.
        %
        %   Note that not all models support an auto-guess feature
        autoGuess = true;

        % Fit criteria threshold
        %
        %   "fitThresh" is a numeric scalar specifying the minimum allowable fit
        %   coefficient of determination. An attempt to recover values below
        %   this threshold is made in the "cleanmaps" method. The lower the
        %   value, the more likely bad fits will be replaced by more appropriate
        %   fits, but the longer the cleaning operation will take.
        %
        %   Default: 0.5
        fitThresh = 0.5;

    end


    properties (SetObservable,Hidden,SetAccess='protected',Transient)

        % Fitting completion flag
        %
        %   "isFitted" is a logical scalar specifying whether the data stored in
        %   the current modeling object has been successfully fitted (TRUE).
        isFitted = false;

        % Computation readiness flag
        %
        %   "isReady" is a structure containing sub-class names implementing a
        %   computation readiness event for "checkCalcReady", where TRUE
        %   indicates that all data necessary for model computations are present
        isReady = struct([]);

        % Model single datum or map flag
        %
        %   "isSingle" is a logical scalar specifying whether the data stored in
        %   the property "y" consist of a single datum (TRUE) or map data
        %   (FALSE) to be modeled. This property is updated by the y_postset
        %   method
        isSingle = true;

        % Model displayed currently flag
        %
        %   "isShown" is a logical flag specifying whether the data stored
        %   currently in the modelbase object (or sub-class) has been displayed
        %   (TURE). This property is updated by the "show" method and is reset
        %   by PostSet event associated with properties that might change the
        %   value of the modeling results or data.
        isShown = false;

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = modelbaseopts

            % Add the property post-set listeners
            addlistener(obj,'autoGuess','PostSet',@obj.autoGuess_postset);

        end %modelbaseopts.modelbaseopts

    end %constructor


    %------------------------------- Set Methods -------------------------------
    methods

        function set.algorithm(obj,val)
            val = validatestring(val,{'levenberg-marquardt',...
                                      'robust',...
                                      'trust-region-reflective',...
                                      'nelder-mead'});
            if strcmpi(val,'robust') && isempty(ver('stats'))
                warning(['QUATTRO:' mfilename ':missingToolbox'],...
                         'Robust fitting requires the Statistics toolbox.');
            else
                obj.algorithm = val;
                notify(obj,'updateModel');
            end
        end %modelbaseopts.set.algorithm

        function set.autoFit(obj,val)
            validateattributes(val,{'logical'},{'nonempty','scalar'});
            obj.autoFit = val;
            notify(obj,'updateModel');
        end %modelbaseopts.set.autoFit

        function set.autoGuess(obj,val)
            validateattributes(val,{'logical'},{'nonempty','scalar'});
            obj.autoGuess = val;
            notify(obj,'updateModel');
        end %modelbaseoptsopts.set.autoGuess

        function set.fitThresh(obj,val)
            validateattributes(val,{'numeric'},{'scalar','nonempty','nonnan',...
                                                '>=',0,'<=1',1});
            obj.fitThresh = val;
            % There is no need to notify the modeling object that a new value
            % for "fitThresh" has been set as this value is only used in map
            % computations.
        end %modelbaseopts.set.fitThresh

    end %set methods


    %----------------------------- Other Methods -------------------------------
    methods (Hidden,Access='private')

        function autoGuess_postset(obj,~,~)

            % Delete any previous guesses
            if ~obj.autoGuess
%                 metaObj = eval(['?' class(obj)]);
            end

        end %modelbaseopts.autoGuess_postset

    end %other

end %modelbaseopts