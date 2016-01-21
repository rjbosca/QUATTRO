classdef image2d < imagebase

    properties (AbortSet)

        % Dimension size
        %
        %   "dimSize" is a a numeric vector representing the number of elements
        %   in each dimension
        dimSize = [1 1];

        % Physical element size
        %
        %   "elementSpacing" is a numeric vector representing the physical size
        %   of elements in each dimension. By default, this value is set to
        %   ONES(1,2)
        elementSpacing = [1 1];

        % Position within an image
        %
        %   "imagePos" is a numeric vector representing the indexed position
        %   within an image for each dimension. By default, this value is set to
        %   ONES(1,2).
        %
        %   This property is currently unused in the IMAGE2D class
        imagePos = [1 1];

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = image2d(varargin)
        %image2d  Constructs a 2-D image object
        %
        %   OBJ = image2d(FILE) creates the IMAGE3D object OBJ from the image
        %   data stored in the file specified by the full file name FILE. An
        %   attempt will be made to load the image and any associated meta-data.
        %
        %   OBJ = image2d(I) creates the IMAGE3D object OBJ using the image data
        %   stored in the 2-D array I.
        %
        %   OBJ = image2d(SIZE,VAL) creates a IMAGE3D object OBJ with a uniform
        %   image using a sparse representation that is determined by the values
        %   of "dimSize" and "image" specified by the inputs SIZE and VAL,
        %   respectively. VAL is a numeric scalar
        %
        %   OBJ = image2d(...,'PROP1',VAL1,...) creates the image2d object OBJ
        %   as described previously, setting the properties 'PROP1', 'PROP2',
        %   etc. to the respective values VAL1, VAL2, etc.

            % Attach the properties' listeners
            addlistener(obj,'fileName','PostSet',@obj.fileName_postset);

            if ~nargin
                return
            end

            % Parse the inputs
            [props,vals] = parse_inputs(varargin{:});

            % Always set the "isSparse" property before all others to ensure
            % that other inputs (e.g., "dimSize" and "image") are allocated
            % appropriately
            sIdx = strcmpi('issparse',props);
            if any(sIdx)
                obj.isSparse = vals{sIdx};
            end

            % Update the properties
            for pIdx = 1:numel(props)
                obj.(props{pIdx}) = vals{pIdx};
            end

            % Some files (e.g., OSIRIX DICOMs) contain no image or meta-data;
            % delete these objects
            if obj.isvalid && isempty(obj.metaData)
                obj.delete;
            end

        end %image2d.image2d

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function set.dimSize(obj,val)
            validateattributes(val,{'numeric'},...
                                   {'finite','positive','nonnan','real',...
                                    'vector','numel',2});
            obj.dimSize = val(:)'; %enforce row vector
        end %image2d.set.dimSize

        function set.elementSpacing(obj,val)
            validateattributes(val,{'numeric'},...
                                   {'finite','positive','nonnan','real',...
                                    'vector','numel',2});
            obj.elementSpacing = val(:)'; %enforce row vector
        end %image2d.set.elementSpacing

    end

end %image2d


%---------------------------------------------
function [props,vals] = parse_inputs(varargin)

    % Initialize the parser
    parser = inputParser;

    % There are three unique cases for the first two inputs: (1) a file name has
    % been specified, (2) an image array has been specified, (3) an image size
    % and scalar value has been specified
    if isnumeric(varargin{1})
        if (nargin>1) && isnumeric(varargin{2}) %sparse image
            parser.addRequired('dimSize'); %no validator - set method validates
            parser.addRequired('value',@(x) numel(x)==1);

            % Since "isSparse" is a hidden property, the parameter/value parser
            % will not be setup below when adding the options and must be
            % handled independently
            parser.addParamValue('isSparse',false);
            varargin(end+1:end+2) = {'isSparse',true};
        else %image
            parser.addRequired('value');
        end
    elseif exist(varargin{1},'file')
        parser.addRequired('fileName'); %no validator - already validated
    else
        error(['QUATTRO:' mfilename ':invalidInputArgs'],...
              ['Invalid input arguments. Type "help image2d.image2d" for '...
               'more information.']);
    end
 
    % Grab the class properties and update the parser for additional inputs if
    % necessary
    if (nargin>2)
        obj      = eval(mfilename);
        cellfun(@(x) parser.addParamValue(x,obj.(x)),properties(obj))
    end

    % Prase the inputs
    parser.parse(varargin{:});

    % Store the outputs
    [props,vals] = deal(fieldnames(parser.Results),struct2cell(parser.Results));

end %prase_inputs