classdef qt_reg < regopts
%qt_reg  Create an image registration object
%
%   Specifying individual registration component options such as the optimizer
%   can be accomplished using the following properties. While these specific
%   options contribute significantly to the behavior of the registration task,
%   not all are relevant depending on the combination of basic properties (see
%   above) specified. Every effort has been made to warn the user when options
%   are not being used.
%
%   Notes on the ITK implementation: ITK libraries were used to genereate the
%   executables responsible for performing the registration tasks. All efforts
%   were made to ensure that the various options associated with each optimizer,
%   interpolator, similarity measure, and transformation were made availsable to
%   the user. For a complete description of these options, please see the ITK
%   docmentation which can be found here: http://www.itk.org/Wiki/ITK
%
%   Notes on images transformations: all rotations are assumed to occur about
%   the images center. This means, before any rigid or affine transformation
%   that the centers of the moving and target images are calculated using the
%   pixel dimensions and image size. The images are then translated to this
%   center before any rotation operations are performed.

    properties (AbortSet,SetObservable,GetObservable)

        % Target image
        %
        %   "imTarget" is a 2- or 3-D numeric array specifying the target image
        %   and can be specified in one of two ways: (1) a 3D array where x, y,
        %   and z indices are represented by the 1st, 2nd, and 3rd dimensions,
        %   respecively, or (2) an array of QT_IMAGE objects. The latter is
        %   generally prefereable because image object meta-data (when present)
        %   is used to populate the QT_REG properties.
        %
        %   Currently, only syntax (1) is supported...
        imTarget

        % Moving image
        %
        %   "imMoving" is a 2- or 3-D numeric array specifying the moving image.
        %   Type "help qt_reg.imTarget" for more information.
        imMoving

        % Dimensions of target image's x, y, and z voxels
        %
        %   "pixdimTarget" is a 3 element numeric row vector specifying the x,
        %   y, and z voxel dimensions of the target image, "imTarget", in
        %   physical coordinates.
        %
        %   When disparate pixel dimensions (or image sizes) are present, QT_REG
        %   resamples each image to a grid that spans the physical space of the
        %   largest image using the smallest physical voxel size in each
        %   dimension (i.e. min([pixdimTarget;pixdimMoving],2)). Zero filling is
        %   performed on the smaller of the two images if needed. 
        %
        %   Any unit of distance can be used as long as the units are consistent
        %   with pixdimTarget. Additionally, the units used here will be the
        %   units used to represent the resulting transformation (e.g. mm or cm)
        %
        %   Default: [1 1 1]
        pixdimTarget = [1 1 1];

        % Dimensions of moving image's x, y, and z voxels
        %
        %   "pixdimMoving" is a 3 element numeric row vector specifying the x,
        %   y, and z voxel dimensions of the moving image, "imMoving", in
        %   physical coordinates.
        %
        %   Type "help qt_reg.pixdimTarget" for more information.
        %
        %   Default: [1 1 1]
        pixdimMoving = [1 1 1];

        % Moving image transformation
        %
        %   "wc" is a numeric vector specifying the transformation for the
        %   moving image ("imMoving"). This property is automatically updated
        %   after performing image registration and is used to perform
        %   post-registration transforms.
        wc

        % Application directory
        %
        %   "appDir" is a string specifying the directory to which temporary ITK
        %   files should be written
        appDir = fullfile(qt_path('appdata'),'temp');

    end

    properties (Dependent)

        % Current image similarity
        %
        %   "similarity" is a numeric scalar calculated according to the
        %   "metric" property that represents the mathematical similarity
        %   between the target and moving images.
        similarity

    end

    properties (SetAccess = 'protected')

        % Total CPU time used by registration computations
        %
        %   "time" is a numeric scalar representing the total CPU time used
        %   during the registration computation, including pre-registration and
        %   post-registration operations such as reading/writing the temporary
        %   image files and iteration history.
        time

        % ITK link file prefix
        %
        %   "itkFile" is a file name prefix that is used to generate a random
        %   string during qt_reg object initialization. This ensures that
        %   multiple instances of qt_reg can be run simultaneously without fear
        %   of overwritting interface file data.
        itkFile

    end

    properties (Dependent,Hidden)

        % Similarity function handle
        %
        %   "similarityFcn" is a function handle that accepts the moving image
        %   as input and returns the similarity metric value as the sole output.
        similarityFcn

        % Transformation function handle
        %
        %   "transformationFcn" is a function handle that accepts the moving
        %   image coordinates and the transformation array as inputs, returning
        %   the transformed image coordinates as the sole output.
        transformationFcn

        % Identity transformation
        %
        %   "identity" is a numeric row vector defining the identity
        %   transformation based on the property values for "transformation" and
        %   "imTarget"/"imMoving" (the latter is used to determine
        %   dimensionality).
        identity

        % Maximun registration displacement
        %
        %   "displacement" is the maximum Euclidian distance between the
        %   original image coordinates and the transformed image coordinates.
        displacement

        % Maximum registration linear offset
        %
        %   "offset" is the maximum displacement of the transformation specified
        %   by the property "wc" in each of the x, y, and z directions based on
        %   the scaling of "pixdimMoving". Note that this property differs from
        %   "displacement" in that it only measures the linear displacement
        %   (i.e. xi-T(xi) for i = x, y, z) not the Euclidian distance
        offset

        % Image properties
        x1; %grid of coordinates for imTarget; transformations are applied to this array
        x2; %gird of cooridnates for imMoving;
    
    end

    properties (Hidden)

        % Image dimensionality
        %
        %   "n" is the dimensionality of the input images and assumes a value of
        %   either 2 or 3. When registering image series, the 4th dimension
        %   (series dimension) of the moving image is not considered
        n

        % Target image size
        %
        %   "mTarget" is a numeric row vector specifying the size of the target
        %   image (i.e. size(ITARGET)) and is initialized during the PostSet
        %   event for "imTarget"
        mTarget

        % Moving image size
        %
        %   "mMoving" is a numeric row vector specifying the size of the moving
        %   image (i.e. size(IMTARGET)) and is initialized during the PostSet
        %   event for "imMoving"
        mMoving

        % Transform iteration history
        %
        %   "wcHistory" is a numeric array where each row sequentially
        %   represents the calculated transformation at each iteration of the
        %   image registration process
        wcHistory

        % Similarity iteration history
        %
        %   "simHistory" is a numeric column vector where each row sequentially
        %   represents the image similarity calculated by ITK at each iteration
        %   of the image registration process.
        simHistory

        hFig; %qt_reg figure handle

        % qt_exam object handle
        %
        %   "hExam" stores the qt_exam objects (a 1-by-2 array) 
        hExam = qt_exam.empty(1,0);

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_reg(varargin)
        %qt_reg  QUATTRO image registration class
        %
        %   H = qt_reg creates an empty QUATTRO image registration object.
        %   Object properties such such as imTarget, imMoving, etc. can be set
        %   after instantiating the object.
        %
        %   H = qt_reg(IFIXED,IMOVING) creates a QUATTRO image registration
        %   object using the fixed and moving images, IFIXED and IMOVING,
        %   respectively. These inputs can be 2-, 3-, or 4-D arrays such that
        %   NDIMS(IFIXED)<=NDIM(IMOVING) or can be qt_image objects; the latter
        %   is preferred.
        %
        %   H = qt_reg(...,'Property1',PropertyValue1,...) performs the object
        %   instantiation with the fixed and moving images as described
        %   previously, initiating the properties 'Property1', and so on, the
        %   respective value, PropertyValue1, etc.

        %Undocumented qt_reg syntax
        %--------------------------
        %
        %   H = qt_reg(HEXAM) creates an image registration object linked to an
        %   instance of a qt_exam object specified by HEXAM. This is an interal
        %   syntax used in conjunction with the QUATTRO application and should
        %   not be used for any other purpose

            % Attach the properties' PostSet listeners
            addlistener(obj,'appDir',        'PostSet',@newappdir);
            addlistener(obj,'imTarget',      'PostSet',@newregimage);
            addlistener(obj,'imMoving',      'PostSet',@newregimage);
            addlistener(obj,'interpolation', 'PostSet',@newinterp);
            addlistener(obj,'metric',        'PostSet',@newmetric);

            % Parse the inputs
            if (nargin==0)
                return
            end
            [obj.imTarget,obj.imMoving,props,vals] = parse_inputs(varargin{:});

            % Deal optional inputs. The property specific set method performs
            % the input validation.
            for prpIdx = 1:length(props)
                obj.(props{prpIdx}) = vals{prpIdx};
            end

            % Initialize the file name prefix
            [~,obj.itkFile] = fileparts(tempname);

            % Validate that the application directorty exists
            if ~exist(obj.appDir,'dir')
                try
                    mkdir(obj.appDir);
                catch ME
                    warning('qt_reg:missingAppDir','%s\n%s\n',...
                            'Invalid or missing application directory:',...
                            obj.appDir);
                    rethrow(ME);
                end
            end

        end

    end %constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.displacement(obj)

            val = 0; %initialize
            if isempty(obj.wc) || isempty(obj.imMoving)
                return
            end

            % Get the tranform function and grid
            f = obj.transformationFcn;
            x = obj.x2;

            % Perform transform
            xi = f(obj.wc,x);

            % Calculate the maximum displacement
            val = zeros( numel(x{1}), 1 );
            for i = 1:length(x)
                val(:) = val + (x{i}(:)-xi{i}(:)).^2;
            end
            val = max( sqrt(val) );

        end %get.displacement

        function val = get.imMoving(obj)
            % Type cast to double (this saves memory as opposed to type casting
            % when the images are first stored in the qt_reg object).
            val = double( obj.imMoving );
        end %get.imMoving

        function val = get.imTarget(obj)
            % Type cast to double (this saves memory as opposed to type casting
            % when the images are first stored in the qt_reg object).
            val = double( obj.imTarget );
        end %get.imTarget

        function val = get.identity(obj)

            % Determine the image dimensions size and default value
            val = [];
            nd  = obj.n;
            if ~nd
                return
            end

            % Get the transformation specific identity function
            switch obj.transformation
                case 'affine'
                    val = [reshape( eye(nd), 1, [] ) zeros(1,nd)];
                case 'rigid'
                    val = zeros(1,2*nd);
                case 'rotation'
                    val = zeros(1,nd);
                case 'translation'
                    val = zeros(1,nd);
            end

        end %get.identity

        function val = get.n(obj)

            val = 0; %initialize
            if ~isempty(obj.imTarget) || ~isempty(obj.imMoving)
                % Get dimension sizes
                ns(1) = numel( obj.mTarget>1 );
                ns(2) = numel( obj.mMoving>1 );

                % Use limiting case
                val = min( ns(ns~=0) );
            end

        end %get.n

        function val = get.offset(obj)

            val = zeros(1,3); %initialize
            if isempty(obj.wc) || isempty(obj.imMoving)
                return
            end

            % Get the transform function and grid
            f = obj.transformationFcn;
            x = obj.x2;

            % Perform the transform
            xi = f(obj.wc,x);

            % Calcuate the maximum displacements in X, Y, and Z
            val = cellfun(@(g1,g2) max(g1(:)-g2(:)),x,xi);

        end %get.offset

        function val = get.similarity(obj)
            % Transform the moving image and pass it to the similarity function
            val = obj.similarityFcn( obj.transform );
        end %get.similarity

        function val = get.similarityFcn(obj)

            % Target image alias and default value
            val = [];
            im  = obj.imTarget;
            if isempty(im)
                return
            end

            % Grab the function handle
            switch obj.metric
                case 'mi'
                    val = @(I) mi(I(:),im(:));
                case 'msd'
                    val = @(I) msd(I(:),im(:));
                case 'ncc'
                    val = @(I) ncc(I(:),im(:));
                case 'mmi'
                    val = @(I) mi(I(:),im(:));
                    warning(['qt_reg:' mfilename ':implementationError'],...
                            'Mattes MI is not implemented....using MI instead');
                case 'nmi'
                    val = @(I) nmi(I(:),im(:));
                case 'smi'
                    val = @(I) smi(I,im); %don't list image values for spatial MI
                case 'ssd'
                    val = @(I) ssd(I(:),im(:));
            end
            
        end %get.similarityFcn

        function val = get.transformationFcn(obj)

            % Dimensionality alias and default value
            nd  = obj.n;
            val = [];
            if ~nd
                return
            end

            % Get the appropriate transformation
            switch lower(obj.transformation)
                case 'affine'
                    if nd==2
                        val = @affine2;
                    elseif nd==3
                        val = @affine3;
                    end
                case 'euler'
                    if nd==2
                        val = @rigid2;
                    elseif nd==3
                        val = @rigid3;
                    end
                case 'rotation'
                    if nd==2
                        val = @rotation2;
                    elseif nd==3
                        val = @rotation3;
                    end
                case 'translation'
                    if nd==2
                        val = @translation2;
                    elseif nd==3
                        val = @translation3;
                    end
            end

        end %get.transformationFcn

        function val = get.x1(obj)

            val = []; %initialize
            if isempty(obj.pixdimTarget) || isempty(obj.imTarget)
                return
            end
            dim = obj.pixdimTarget;
            m   = obj.mTarget;

            % Get vectors of coordinates
            nd = obj.n;
            val = arrayfun(@(x,y,z) linspace(0,x*y,x),m,dim,...
                                                         'UniformOutput',false);
            [val{1:nd}] = ndgrid(val{:});

        end %get.x1

        function val = get.x2(obj)

            val = []; %initialize
            if isempty(obj.pixdimMoving) || isempty(obj.imMoving)
                return
            end
            dim = obj.pixdimMoving;
            m   = obj.mMoving;

            % Get vectors of coordinates
            nd  = obj.n;
            val = arrayfun(@(x,y,z) linspace(0,x*y,x),m,dim,...
                                                         'UniformOutput',false);
            [val{1:nd}] = ndgrid(val{:});

        end %get.x2

    end %get.methods

end


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Initialize the output
    [varargout{1:nargout},props] = deal([]);

    % Create an input parser object
    parser = inputParser;

    % Determine the input syntax. There are two cases: (1) the user provided the
    % images with or without additional options and (2) the user provided a
    % qt_exam object with or without additional options
    isQtExam = strcmpi( class(varargin{1}), 'qt_exam' );
    if isQtExam
        parser.addRequired('hExam',@(x) x.isvalid);
    else %user provided images
        parser.addRequired('imTarget',@isnumeric);
        parser.addRequired('imMoving',@isnumeric);
    end

    % Grab the remaining properties
    if (isQtExam && nargin>1) || (~isQtExam && nargin>2)
        regProps = properties('qt_reg');
        props = cellfun(@(x) validatestring(x,regProps),...
                            varargin(3-isQtExam:2:end-1),'UniformOutput',false);
    end
    for pIdx = 1:numel(props)
        parser.addParamValue(props{pIdx},varargin{2*pIdx+1+(~isQtExam)});
    end

    % Parse the inputs
    parser.parse(varargin{:});

    % Deal the parsed inputs
    results = parser.Results;
    if ~isQtExam
        [varargout{1:2}] = deal(results.imTarget,results.imMoving);
        results          = rmfield(results,{'imTarget','imMoving'});
    end
    varargout{3} = fieldnames(results);
    varargout{4} = struct2cell(results);

end %parser_inputs