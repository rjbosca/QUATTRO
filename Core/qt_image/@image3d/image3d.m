classdef image3d < imagebase

    properties (AbortSet)

        % Dimension size
        %
        %   "dimSize" is a a numeric vector representing the number of elements
        %   in each dimension
        dimSize = ones(1,3);

        % Physical element size
        %
        %   "elementSpacing" is a numeric vector representing the physical size
        %   of elements in each dimension. By default, this value is set to
        %   ONES(1,2)
        elementSpacing = ones(1,3);

        % Position within an image
        %
        %   "imagePos" is a numeric vector representing the indexed position
        %   within an image for each dimension. By default, this value is set to
        %   ONES(1,2).
        %
        %   This property is currently unused in the IMAGE2D class
        imagePos = ones(1,3);

    end

    properties (Hidden,Access='private',SetObservable)

        % 2-D image stack
        %
        %   "imgStack" is an array of IMAGE2D objects that provide the basis for
        %   the 3-D volume
        imgStack = image2d.empty(0,1);

        % Mask of loaded images
        %
        %   "isImgLoaded" is an array of logicals that specify, when TRUE, that
        %   a speecific slice has been loaded from the original file
        isImgLoaded = false;

    end

    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = image3d(varargin)
        %image3d  Constructs a 3-D image object
        %
        %   OBJ = image3d

            addlistener(obj,'imgStack','PostSet',@obj.imgStack_postset);

            if ~nargin
                return
            end

            % Parse the inputs
            [props,vals] = parse_inputs(varargin{:});

            % Update the properties
            for pIdx = 1:numel(props)
                obj.(props{pIdx}) = vals{pIdx};
            end

        end %image3d.image3d

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.dimSize(obj,val)
            validateattributes(val,{'numeric'},...
                                   {'finite','positive','nonnan','real',...
                                    'vector','numel',3});
            obj.dimSize = val(:)'; %enforce row vector
        end %image3d.set.dimSize

        function set.elementSpacing(obj,val)
            validateattributes(val,{'numeric'},...
                                   {'finite','positive','nonnan','real',...
                                    'vector','numel',3});
            obj.elementSpacing = val(:)'; %enforce row vector
        end %image3d.set.elementSpacing

        function set.imgStack(obj,val)
            % There are numerous properties that should be validated when
            % setting the "imgStack" property

            % Basic validation
            validateattributes(val,{'image2d'},{'nonempty','vector'});

            % Ensure all images have the same format
            %TODO: only the code to support DICOMs has been written...
            if any( ~strcmpi('dicom',{val.format}) )
                error(['QUATTRO:' mfilename ':unsupportedImgFrmt'],...
                      ['Only DICOM images are supported currently by the ',...
                                                             'IMAGE3D class.']);
            end

            % Attempt to sort the 2D images by slice location
            pPos = arrayfun(@(x) x.metaData.ImagePositionPatient,val,...
                                                         'UniformOutput',false);
            pPos = cell2mat(pPos);
            nSl  = numel( unique(pPos(3,:)) );
            if (nSl==1)
                error([mfilename ':set_imgStack:tooFewSlices'],...
                      ['Only one volume slice was detected. At least 2 ',...
                       'slices are required to construct an IMAGE3D object.']);
            end
            [~,idx] = sort( pPos(3,:) );

            % Store the newly sorted stack
            obj.imgStack = val(idx);

        end %image3d.set.imgStack

    end

end %image3d


%---------------------------------------------
function [props,vals] = parse_inputs(varargin)

    % Initialize the parser
    parser = inputParser;


    parser.addRequired('imgStack',@(x) validateattributes(x,{'image2d'},...
                                                        {'nonempty','vector'}));


    % Prase the inputs
    parser.parse(varargin{:});

    % Store the outputs
    [props,vals] = deal(fieldnames(parser.Results),struct2cell(parser.Results));

end %parse_inputs