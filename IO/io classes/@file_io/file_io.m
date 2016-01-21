classdef file_io < qt_io


    %------------------------------- Properties --------------------------------

    properties (Dependent)

        % File position indicator
        %
        %   "filePos" is the location of the file position indicator in the file
        %   specified by the file_io object. -1 indicates that the file is not
        %   open. Setting this property will move the file position indicator to
        %   the specified location
        filePos

    end

    properties

        % File permission
        %
        %   "filePermission" is a string specifying the permissions with which
        %   to open files associated with this file_io object. See FOPEN for more
        %   information.
        filePermission = 'w';

        % File opeartion data format
        %
        %   "machineFormat" is the data format to be used when reading and
        %   writting data. See FOPEN for more information.
        machineFormat = 'native';

        % Character encoding scheme
        %
        %   "fileEncoding" a string specifying the character encoding values
        %   used when opening a file. See FOPEN for more information
        fileEncoding = '';

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = file_io(varargin)
        %file_io  Constructs a file I/O object
        %
        %   OBJ = file_io creates a file I/O object using a unique temporary
        %   name and sets the generated file to be deleted with the object, OBJ.
        %
        %   OBJ = file_io(FILE) creates a file I/O object using the full file
        %   name, FILE.
        %
        %   OBJ = file_io(FILE,TRUE) creates a file I/O object as above that
        %   will automatically delete the generated file when the object is
        %   destroyed.

            if ~nargin
                return
            end

            %TODO: define an input parser
            [props,vals] = parse_inputs(varargin{:});

            for propIdx = 1:numel(props)
                obj.(props{propIdx}) = vals{propIdx};
            end

        end %file_io.file_io

    end


    % Sub-Class Implementation
    methods

        function data = read(obj)
        end %file_io.read

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.filePos(obj)
            val = -1; %initialize
            if ~isempty(obj.fileId)
                val = ftell(obj.fileId);
            end
        end %file_io.get.filePos

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function obj = set.filePos(obj,val)
        end %file_io.set.filePos

    end

end %file_io


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
        [fDir,fName,fExt] = fileparts(varargin{1});
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