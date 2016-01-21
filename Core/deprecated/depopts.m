classdef depopts < modelopts


    %------------------------------- Properties --------------------------------
    % The "Transient" attribute is set to ensure that these properties are not
    % copied by the "clone" method of MODELBASE
    properties (Hidden,AbortSet,Transient)

        % Signal to contrast concentration flag
        %
        %   "t1Correction" - use is deprecated, use "useT1Correction" instead.
        %   For updated usage information, type "help
        t1Correction = true;

        % Number of pre-contrast image frames
        %
        %   "preEnhance" - use is deprecated, use "injectionTime" instead. For
        %   updated usage information, type "help dynamicopts.injectionTime"
        preEnhance

        % Image number of the recirculation cut-off
        %
        %   "recirc" - use is deprecated, use "recircTime" instead. For updated
        %   usage information, type "hlep dynamicopts.recircTime"
        recirc

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = depopts
        end %depopts.depopts

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.t1Correction(obj)
            warning('QUATTRO:modeling:propDeprecated',...
                   ['Use of the "t1Correction" property is deprecated. This ',...
                    'property will be removed in a future release. Use ',...
                    '"useT1Correction" instead']);
            val = obj.useT1Correction;
        end %depopts.get.t1Correction

        function val = get.preEnhance(obj)
            warning('QUATTRO:modeling:propDeprecated',...
                   ['Use of the "preEnhance" property is deprecated. This ',...
                    'property will be removed in a future release. See the ',...
                    'property "injectionTime" and its corresponding usage.']);
            val = obj.injectionTime;
        end %depopts.get.preEnhance

        function val = get.recirc(obj)
            warning('QUATTRO:modeling:propDeprecated',...
                   ['Use of the "recirc" property is deprecated. This ',...
                    'property will be removed in a future release. See the ',...
                    'property "recircTime" and its corresponding usage.']);
            val = obj.recircTime;
        end %depopts.get.recirc

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.t1Correction(obj,val)
            warning('QUATTRO:modeling:propDeprecated',...
                   ['Use of the "t1Correction" property is deprecated. This ',...
                    'property will be removed in a future release. Use ',...
                    '"useT1Correction" instead']);
            obj.useT1Correction = val;
        end %depopts.get.t1Correction

        function set.preEnhance(obj,val)
            warning('QUATTRO:modeling:propDeprecated',...
                   ['Use of the "preEnhance" property is deprecated. This ',...
                    'property will be removed in a future release. See the ',...
                    'property "injectionTime" and its corresponding usage.']);
            obj.injectionTime = val;
        end %depopts.get.preEnhance

        function set.recirc(obj,val)
            warning('QUATTRO:modeling:propDeprecated',...
                   ['Use of the "recirc" property is deprecated. This ',...
                    'property will be removed in a future release. See the ',...
                    'property "recircTime" and its corresponding usage.']);
            obj.recircTime = val;
        end %depopts.get.recirc

    end

end %depopts