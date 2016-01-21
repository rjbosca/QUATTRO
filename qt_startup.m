function qt_startup
%qt_startup  Prepares MATLAB and system paths for QUATTRO
%
%   qt_startup performs a number of checks and path additions (to both the
%   MATLAB and system paths). This file must be run to ensure that all tools are
%   available to QUATTRO.
%
%   When the QUATTRO GUI is called, this command is called implicitly.
%
%   For systems where saving the MATLAB path is not possible, it is helpful to
%   use the "run" command (as shown in the example) with the full file name of
%   this start-up script.
%
%       Example:
%       --------
%
%       run qt_startup

    % Determine if QT_STARTUP has already been fired. This saves a significant
    % amount of time on start-up
    persistent isFired
    if ~isempty(isFired) && isFired
        return
    end

    %----------------------------------------
    % QUATTRO and script path initialization
    %----------------------------------------

    % M-file paths are not used in deployed applications
    if ~isdeployed
        add_quattro;
        addpath( qt_path('script') );
    end


    %-----------------------
    % Registration Path Init
    %-----------------------

    % Grab the current system path
    envPath    = textscan(getenv('PATH'),'%s','Delimiter',';');
    envPath    = envPath{1};
    regPath    = fullfile(qt_path,'Core','Registration');
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



    % Update the "isFired" flag and lock the m-file
    isFired = true;
    mlock;

end %qt_startup


%--------------------
function add_quattro

    % Determine how many versions of QUATTRO exist on the path to avoid
    % potential conflicts with previous versions.
    qtFcns = which('QUATTRO.m','-all');
    qtLoc  = [mfilename('fullpath') '.m'];
    if ~isempty(qtFcns)
        qtFcns = qtFcns( ~strcmp(qtLoc,qtFcns) );
    end
    nQts   = numel(qtFcns);
    if (nQts>1)
        error('QUATTRO:qt_startup:tooManyQuattroVersions',...
             ['Multiple version of QUATTRO exist on MATLAB''s path. To avoid ',...
              'conflicting function calls, QUATTRO will not run until all ',...
              'other directories containing QUATTRO.m are removed from ',...
              'MATLAB''s path.']);
    end

    % Add QUATTRO's containing directory to MATLAB's path. This will allow the
    % user to call QUATTRO directly
    qtLoc = fileparts(qtLoc);
    if isempty( strfind(path,[qtLoc ';']) )
        addpath(qtLoc)
        savepath
    end

    % Update MATLAB's path with the remaining sub-directories
    addpath( genpath(qtLoc) );

end %add_quattro