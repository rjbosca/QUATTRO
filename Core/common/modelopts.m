classdef modelopts < dynamicopts & pkopts & t1dynamicopts & t2wopts & vtiopts
% qt_models sub-class property wrapper
%
%   modelopts defines model selection properties in addition to wrapping the
%   properties from all qt_models option definition classes. This class is used
%   primarily as a means of defining these properties by sub-classing qt_options

    properties

        % Diffusion weighted imaging model
        %
        %   "dwiModel" is a string specifying the modeling class to be used
        %   from the "dwi" modeling package
        dwiModel

        % Dynamic constrast-enhanced imaging model
        %
        %   "dceModel" is a string specifying the modeling class to be used
        %   from the "dce" modeling package
        dceModel

        % Dynamic susceptibility contrast imaging model
        %
        %   "dscModel" is a string specifying the modeling class to be used
        %   from the "dsc" modeling package
        dscModel

        % Generic serial imaging visualization model
        %
        %   "genericModel" is a string specifying the modeling class to be used
        %   from the "generic" modeling package
        genericModel

        % Multiple flip angle imaging model
        %
        %   "multiflipModel" is a string specifying the modeling class to be
        %   used from the "multiflip" modeling package
        multiflipModel

        % Multiple echo time imaging model
        %
        %   "multiteModel" is a string specifying the modeling class to be used
        %   from the "multite" modeling package
        multiteModel

        % Multiple inversion time imaging model
        %
        %   "multitiModel" is a string specifying the modeling class to be used
        %   from the "multiti" modeling package
        multitiModel

        % Multiple repetition time imaging model
        %
        %   "multitrModel" is a string specifying the modeling class to be used
        %   from the "multitr" modeling package
        multitrModel

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = modelopts

            % During object construction, verify that a property exists for each
            % of the models defined in this class's M-file by comparing the
            % fields of the qt_models packages with the properties of modelopts.
            % The default values are also set during this process
            pkgs = qt_models.model_info;
            for fld = fieldnames(pkgs)'
                if ~isprop(obj,[fld{1} 'Model'])
                    warning(['QUATTRO:' mfilename ':classPropsOutOfDate'],...
                            ['No property is defined for "%sModel", but a ',...
                             'modeling package for "%s" exists. QUATTRO will ',...
                             'be unable to utilize this package until a model ',...
                             'selection property is defined in the class ',...
                             'definition of %s.'],fld{1},fld{1},mfilename);
                end

                % Define the default
                %FIXME: the following "if" statement is a patch for an
                %issue that arises when running compiled versions of
                %QUATTRO on Mac OS... Why???
                if ~isdeployed
                    mClasses = meta.package.fromName(qt_models.model2str(fld{1}));
                    obj.([fld{1} 'Model']) = strrep(mClasses.ClassList(1).Name,...
                                                        [mClasses.Name '.'],'');
                end
            end

        end %modelopts.modelopts

    end %class constructor


    %------------------------------- Set Methods -------------------------------
    methods

        function set.dwiModel(obj,val)
            mClasses     = meta.package.fromName( qt_models.model2str('dwi') );
            mClasses     = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                                   {mClasses.ClassList.Name},...
                                   'UniformOutput',false);
            obj.dwiModel = validatestring(val,mClasses);
        end %modelopts.dwiModel

        function set.dceModel(obj,val)
            mClasses     = meta.package.fromName( qt_models.model2str('dce') );
            mClasses     = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                                   {mClasses.ClassList.Name},...
                                   'UniformOutput',false);
            obj.dceModel = validatestring(val,mClasses);
        end %modelopts.dceModel

        function set.dscModel(obj,val)
            mClasses     = meta.package.fromName( qt_models.model2str('dsc') );
            mClasses     = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                                   {mClasses.ClassList.Name},...
                                   'UniformOutput',false);
            obj.dscModel = validatestring(val,mClasses);
        end %modelopts.dscModel

        function set.genericModel(obj,val)
            %FIXME: this "if" statement is a temporary patch for an issue
            %that arises when running compiled versions of QUATTRO on Mac
            %OS... Why???
            if ~isdeployed
            mClasses = meta.package.fromName( qt_models.model2str('generic') );
            mClasses = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                               {mClasses.ClassList.Name},...
                               'UniformOutput',false);
            obj.genericModel = validatestring(val,mClasses);
            end
        end %modelopts.genericModel

        function set.multiflipModel(obj,val)
            mClasses = meta.package.fromName( qt_models.model2str('multiflip') );
            mClasses = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                               {mClasses.ClassList.Name},...
                               'UniformOutput',false);
            obj.multiflipModel = validatestring(val,mClasses);
        end %modelopts.multiflipModel

        function set.multiteModel(obj,val)
            mClasses = meta.package.fromName( qt_models.model2str('multite') );
            mClasses = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                               {mClasses.ClassList.Name},...
                               'UniformOutput',false);
            obj.multiteModel = validatestring(val,mClasses);
        end %modelopts.multiteModel

        function set.multitiModel(obj,val)
            mClasses = meta.package.fromName( qt_models.model2str('multiti') );
            mClasses = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                               {mClasses.ClassList.Name},...
                               'UniformOutput',false);
            obj.multitiModel = validatestring(val,mClasses);
        end %modelopts.multitiModel

        function set.multitrModel(obj,val)
            mClasses = meta.package.fromName( qt_models.model2str('multitr') );
            mClasses = cellfun(@(x) strrep(x,[mClasses.Name '.'],''),...
                               {mClasses.ClassList.Name},...
                               'UniformOutput',false);
            obj.multitrModel = validatestring(val,mClasses);
        end %modelopts.multitrModel

    end %set methods

end %modelopts