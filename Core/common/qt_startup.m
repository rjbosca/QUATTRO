function qt_startup(varargin)
%qt_startup  Initializes the QUATTRO environment 
%
%   qt_startup validates and initializes system and MATLAB environment variables
%   and paths.
%
%   qt_startup(PACKAGE) validates and initializes the system and MATLAB
%   environment for the requested PACKAGE. PACKAGE a QUATTRO object or class
%   name.

    % Parse the inputs
    narginchk(0,1);
    if nargin && ~ischar(varargin{1})
        varargin = class( varargin{1} );
    elseif ~nargin
        varargin = {'quattro'};
    end
    package = validatestring(varargin{1},{'quattro','qt_reg'});

    % Perform the specified actions
    switch package
        case 'qt_reg'
            reg_init;
        case 'quattro'
            path_init;
            reg_init;
    end

end %qt_startup


%-----------------
function path_init
%path_init  Initialize QUATTRO path
%
%   path_init initializes the MATLAB path to ensure that all necessary QUATTRO
%   files are available for execution

    % Determine if qt_options is a valid m-file. Ultimately, qt_options is
    % responsible for handling the QUATTRO paths. In the event that the m-file
    % is not on the path, the associated sub-directory dependencies must be
    % added manually after which a qt_options object is constructed to handle
    % the rest...
    if ~exist('qt_options','file')

        % Grab the current directory of qt_startup since qt_paths, which exists
        % in the same directory, must be run as a function. This will occur in
        % the qt_options initialization, so both paths must be added.
        startupDir = fileparts( mfilename('fullpath') );
        qtOptsDir  = strrep(startupDir,'common','qt_options');
        addpath([startupDir ';' qtOptsDir],'-end');
        
    else

        % Validate that this is the expected qt_options m-file (i.e. qt_options
        % should be near qt_startup)
        qtOptsFile = fileparts( which('qt_options.m') );
        qtOptsIdx  = regexpi(qtOptsFile,...
                              '[/\\](core)[/\\](qt_options)[/\\](@qt_options)');
        qtPathFile = fileparts( mfilename('fullpath') );
        qtPathIdx  = regexpi(qtPathFile,'[/\\](core)[/\\](common)');

        if ~strcmpi(qtOptsFile(1:qtOptsIdx),qtPathFile(1:qtPathIdx))
            error(['QUATTRO:' mfilename ':tooManyQuattroVersions'],...
                  ['Attempted to run:\n\n',...
                   '\t"%s"\n\n',...
                   'but another version of QUATTRO exists in MATLAB''s path.\n\n',...
                   '\t"%s"\n\n',...
                   'Remove all other QUATTRO directories from MATLAB''s path\n',...
                   'and try starting this version of QUATTRO again.\n'],...
                   fullfile(qtPathFile(1:qtPathIdx),'QUATTRO.m'),...
                   fullfile(qtOptsFile(1:qtOptsIdx),'QUATTRO.m'));
        end
    end

    % Now that the qt_options directory is ensured to be on MATLAB's path, fire
    % an instance of qt_options to initialize the path cache
    qt_options;

end %path_init


%----------------
function reg_init
%reg_init  Initialize image registration paths
%
%   reg_init initializes the system environment variable PATH to ensure that the
%   ITK executables can be found

    % Grab the current system path
    envPath    = textscan(getenv('PATH'),'%s','Delimiter',';');
    envPath    = envPath{1};
    regPath    = strrep(qt_path,'Core','Registration');
    regBinPath = fullfile(regPath,'@qt_reg','private','bin');

    % Add the registration binaries to the path
    if ~any( strcmpi(envPath,regBinPath) )

        % Determine which itkReg.exe to use. This is a workaround while QUATTRO
        % is in the Dropbox folder. When I get a GITHUB account then I'll change
        % this to download the appropriate build.
        %TODO: determine a more efficient way to handle the registration exes
        if ispc
            cpuArch = getenv('PROCESSOR_ARCHITECTURE');
            if strcmpi(cpuArch,'x86')
                regBinPath = fullfile(regBinPath,'ITK (x86)');
            elseif strcmpi(cpuArch,'AMD64')
                regBinPath = fullfile(regBinPath,'ITK');
            end
        else
        end

        % Add the itkReg.exe path and concatenate with the current system PATH
        % varialbe
        envPath{end+1} = regBinPath;
        envPath        = sprintf('%s;',envPath{:});
        setenv('PATH',envPath);

    end

end