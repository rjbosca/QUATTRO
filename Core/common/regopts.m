classdef regopts < hgsetget
%qt_reg class option definitions
%
%   regopts defints the user adjustable options that are common to the QT_REG
%   class and other associated QUATTRO GUIs.

    properties (AbortSet,SetObservable)

        % Image interpolation scheme
        %
        %   "interpolation" is a string specifying the image interpolation type
        %   when transforming images. Valid strings are:
        %
        %       'nearest'
        %
        %       'linear'
        %
        %       'spline'
        %
        %       'cubic'
        %
        %
        %   Default: 'linear'
        interpolation = 'linear';

        % Image similarity metric
        %
        %   "metric" is a string specifying the metric to use when computing
        %   similarity between the target and moving images. Valid strings: 
        %
        %       'MeanSquares'
        %
        %       'NormalizedCrossCorrelation'
        %
        %       'GradientDifference'
        %
        %       'MutualInformation'
        %
        %       'MattesMutualInformation'
        %
        %       'MutualInformationHistogram'
        %
        %       'NormalizedMutualInformationHistogram'
        %
        %
        %   A more complete descriptions of these metrics can be found in the
        %   ITK documentation: http://www.itk.org/Wiki/ITK
        %
        %   Default: 'NormalizedCrossCorrelation'
        metric = 'NormalizedCrossCorrelation';

        % Number of pyramid levels to use in registration
        %
        %   "multiLevel" is a numeric scalar specifying the number multio-
        %   resolution image resampling levels to use when performing the
        %   registration. multiLevel==1 corresponds to image alignment on the
        %   original images with no resampling
        %
        %   Note: the current implementation is limited and will be modified in
        %   future release. Specifically, the current algrotihm DOES NOT
        %   resample in the z direction (slice direction of axial images)
        %   because the number of samples in this direction is generally already
        %   small (on the order of 20).
        %
        %   Default: 1
        multiLevel = 1;

        % Maximum number of optimizer iterations
        %
        %   "nIterations" is a numeric scalar specifying the maximum number of
        %   iterations allowed by the optimizer. The registration process is
        %   terminated if the optimizer reaches this number of iterations.
        %
        %   Default: 500
        nIterations = 500;

        % Fraction of spatial samples to use in metric calculation
        %
        %   "nSpatialSamples" is a positive numeric scalar specifying either the
        %   the fraction (value between 0 and 1) of samples to be used when
        %   calculating the similarity metric. For histogram type metrics (e.g.
        %   MI) this setting can have a substantial impact on the computation
        %   time as each evaluation of the similarity metric requires N loop
        %   iterations where N is the number of pixels.
        %
        %   As stated in the ITK documentation, images containing little detail
        %   can, in some cases, be registered using as few as 1% (i.e., 0.01) of
        %   the voxels to compute the similarity metric. For a more refined
        %   estimate of the image alignment, higher fractions of voxels are
        %   needed to compute the similarity metric.
        %
        %   Default: 0.1
        nSpatialSamples = 0.1;

        % Registration optimizer scheme
        %
        %   "optimizer" is a string specifying the optimizer scheme to use.
        %   Valid strings are:
        %
        %       'RegularGradientStep'
        %
        %
        %   A more complete descriptions of these optimizers can be found in the
        %   ITK documentation: http://www.itk.org/Wiki/ITK
        %
        %   Note: future developments will incorporate additional optimizers
        %   within the ITK framework.
        %
        %   Default: 'RegularGradientStep'
        optimizer = 'RegularGradientStep';

        % Minimum signal intensity to consider for the metric
        %
        %   "signalThresh" is a numeric scalar specifying the minimum pixel
        %   signal intensity for a voxel to be considered in computation of the
        %   image similarity metric. In other words, values below this threshold
        %   are ignored.
        %
        %   Default: 0
        signalThresh = 0;

        % Minimum gradient step size
        %
        %   "stepSizeMin" is a numeric scalar specifying the minimium gradient
        %   step size for gradient based optimizers. When the step size falls
        %   below this value, the registration task is terminated. This value
        %   must be less than that of the property "stepSizeMax".
        %
        %   Default: 1e-5
        stepSizeMin = 1e-5;

        % Maximum gradient step size
        %
        %   "stepSizeMin" is a numeric scalar specifying the maximum gradient
        %   step size (i.e., the initial step size) for gradient based
        %   optimizers. This value must be greater than that of the property
        %   "stepSizeMin".
        %
        %   Default: 2
        stepSizeMax = 2.0;

        % Image transformation type
        %
        %   "transformation" is a string specifying the spatial transformation
        %   type to use. Valid strings are:
        %
        %       'Euler'
        %
        %       'Affine'
        %
        %
        %   More complete descriptions of these metrics can be found in the ITK
        %   documentation: http://www.itk.org/Wiki/ITK
        %
        %   Default: 'Euler'
        transformation  = 'Euler';

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = regopts

            % Add the post-set listeners
            %TODO: determine why these are here? The private methods are
            %defined...
%             addlistener(obj,'stepSizeMin','PostSet',@obj.stepSizeMin_postset);
%             addlistener(obj,'stepSizeMax','PostSet',@obj.stepSizeMax_postset);

        end %regopts.regopts

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.interpolation(obj,val)
            obj.interpolation = validatestring(val,{'linear','nearest',...
                                                             'spline','cubic'});
        end %regopts.set.interpolation

        function set.metric(obj,val)

            % For compatability purposes, check for old strings
            %TODO: remove 1/1/2016
            try
                val = validatestring(val,{'mmi','ncc','mi'});
                str = sprintf(['''%s'' is deprecated and will be removed in ',...
                                'a future release. '],val);
                switch val
                    case 'mmi'
                        val = 'MattesMutualInformation';
                    case 'ncc'
                        val = 'NormalizedCrossCorrelation';
                    case 'mi'
                        val = 'MutualInformation';
                end
                warning('QUATTRO:qt_reg:deprecatedSimilarityStr',...
                                              '%s Use ''%s'' instead.',str,val);
            catch ME %#ok - do nothing as the validator below will throw a
                     %      more appropriate error
            end

            obj.metric = validatestring(val,...
                                       {'MeanSquares',...
                                        'NormalizedCrossCorrelation',...
                                        'GradientDifference',...
                                        'MutualInformation',...
                                        'MattesMutualInformation',...
                                        'MutualInformationHistogram',...
                                        'NormalizedMutualInformationHistogram'});
        end %regopts.set.metric

        function set.multiLevel(obj,val)
            validateattributes(val,{'numeric'},{'finite','nonempty','integer',...
                                                'nonnan','positive','scalar',...
                                                'nonsparse'});
            obj.multiLevel = val;
        end %regopts.set.multiLevel

        function set.nIterations(obj,val)
            validateattributes(val,{'numeric'},{'finite','nonempty','integer',...
                                                'nonnan','positive','scalar',...
                                                'nonsparse'});
            obj.nIterations = val;
        end %regopts.set.nIterations

        function set.nSpatialSamples(obj,val)
            validateattributes(val,{'numeric'},{'<=',1,'nonempty','positive',...
                                                'nonnan','scalar','nonsparse'});
            obj.nSpatialSamples = val;
        end %regopts.set.nSpatialSamples

        function set.optimizer(obj,val)

            % For compatability purposes, check for old strings
            %TODO: remove 1/1/2016
            try
                val = validatestring(val,{'mmi','ncc','mi'});
                str = sprintf(['''%s'' is deprecated and will be removed in ',...
                                'a future release. '],val);
                switch val
                    case 'reg-grad-step'
                        val = 'RegularGradientStep';
                    case 'nelder-mead'
                        val = 'Simplex';
                end
                warning('QUATTRO:qt_reg:deprecatedOptimizerStr',...
                                              '%s Use ''%s'' instead.',str,val);
            catch ME %#ok - do nothing as the validator below will throw a
                     %      more appropriate error
            end
            obj.optimizer = validatestring(val,{'RegularGradientStep',...
                                                'Simplex'});
        end %regopts.set.optimizer

        function set.signalThresh(obj,val)
            validateattributes(val,{'numeric'},{'finite','nonempty','scalar',...
                                                'nonnan','nonsparse'});
            obj.signalThresh = val;
        end %regopts.set.signalThresh

        function set.stepSizeMin(obj,val)
            validateattributes(val,{'numeric'},{'finite','nonempty','scalar',...
                                                'nonnan','positive','nonsparse'});
            obj.stepSizeMin = val;
        end %regopts.set.stepSizeMin

        function set.stepSizeMax(obj,val)
            validateattributes(val,{'numeric'},{'finite','nonempty','scalar',...
                                                'nonnan','positive','nonsparse'});
            obj.stepSizeMax = val;
        end %regopts.set.stepSizeMax

        function set.transformation(obj,val)

            % For compatability purposes, check for old strings
            %TODO: remove 1/1/2016
            try
                val = validatestring(val,{'mmi','ncc','mi'});
                str = sprintf(['''%s'' is deprecated and will be removed in ',...
                                'a future release. '],val);
                switch val
                    case 'rigid'
                        val = 'Euler';
                end
                warning('QUATTRO:qt_reg:deprecatedTransformationStr',...
                                              '%s Use ''%s'' instead.',str,val);
            catch ME %#ok - do nothing as the validator below will throw a
                     %      more appropriate error
            end
            obj.transformation = validatestring(val,{'Euler',...
                                                     'Affine'});
        end %regopts.set.transformation

    end
    
end %regprops