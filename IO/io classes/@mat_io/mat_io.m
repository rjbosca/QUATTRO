classdef mat_io < qt_io


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = mat_io(varargin)
        %mat_io  Constructs a MAT-file I/O object
        %
        %   OBJ = mat_io creates a MAT-file I/O object, using a temporary file
        %   name and returning the object OBJ.
        %
        %   OBJ = mat_io(FILE) creates a MAT-file I/O object using the full file
        %   name, FILE. FILE can also be a directory, resulting in a temporary
        %   file being created in the specified directory

            if ~nargin
                return
            end

            %TODO: define an input parser
            [props,vals] = parse_inputs(varargin{:});

            for propIdx = 1:numel(props)
                obj.(props{propIdx}) = vals{propIdx};
            end

        end %mat_io.mat_io

    end


    % Sub-class implementation
    methods

        function read(obj)
        end %mat_io.read

    end

end %mat_io


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Setup the input parser
    parser = inputParser;
    parser.addOptional('file',tempname,@ischar);
    parser.addOptional('isTemp',false,@islogical);

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    %=====================
    % Parse the file name
    %=====================

    [fDir,fName,fExt] = deal(results.file,'','');

    % Determine if a file or directory was specified
    if (exist(varargin{1},'dir')~=2) %file name specified, parse the string
        [fDir,fName] = fileparts(varargin{1});
    end

    % No directory likely means the user is looking for a file in the current
    % working directory
    if isempty(fDir)
        fDir = pwd;
    end

    % Create a temporary file name if none was specified
    if isempty(fName)
        [~,fName] = fileparts( tempname );
    end

    % Deal the outputs
    varargout = { {'filePath','fileName','isTempFile'},...
                  {fDir,[fName fExt],results.isTemp} };

end %parse_inputs