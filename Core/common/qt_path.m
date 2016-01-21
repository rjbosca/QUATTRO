function guiPath = qt_path(opt)
%qt_path  Returns QUATTRO's path
%
%   PATH = qt_path returns the path of "QUATTRO.m"
%
%   PATH = qt_path(OPT) returns the path specified by the string OPT. Valid path
%   option strings are:
%
%       String      Description
%       ------------------------
%       'appdata'   Location of QUATTRO application data
%
%       'gui'       Find QUATTRO.m (Default)
%
%       'paths'     Location of all necessary QUATTRO files
%
%       'script'    Location of local user QUATTRO scripts

    if (nargin==0)
        opt = 'gui';
    end

    % Validate the path option
    validOpts = {'appdata','gui','paths','script'};
    opt       = validatestring(opt,validOpts);


    switch opt
        case 'appdata' %Find application directory

            % Get system dependent path
            if ispc
                guiPath = getenv('LOCALAPPDATA');
                guiPath = fullfile(guiPath,'QUATTRO');
            elseif isunix
                guiPath = getenv('HOME');
                guiPath = fullfile(guiPath,'.quattro');
            end

        case 'gui' %Find QUATTRO

            % Find QUATTRO.m and get the path
            guiPath = which('QUATTRO');

            % When using WHICH, there are a couple of cases to consider if the
            % output is empty: (1) the requested m-file is in the current
            % working directory or (2) the file could not be found on the path
            if isempty(guiPath) && exist('QUATTRO.m','file')
                guiPath = fullfile(pwd,'QUATTRO.m');
            elseif isempty(guiPath)

                % Since qt_path was intented to always know where QUATTRO is,
                % parse the location of the m-file in an attempt to find QUATTRO
                mPath = fileparts( mfilename('fullpath') );

                % The current version of QUATTRO is stored in the parent
                % directory, while qt_path is in /Core/common. See if QUATTRO is
                % where expected
                guiPathIdx = regexpi(mPath,'[/\\](core)[/\\](common)');
                guiPath    = mPath(1:guiPathIdx);
                if ~exist( fullfile(guiPath,'QUATTRO.m'), 'file' )
                    error(['QUATTRO:' mfilename ':missingQuattroFile'],...
                          ['Unable to locate a necessary file: "QUATTRO.m". ',...
                           'Undo any changes made to the QUATTRO directories ',...
                           'or try downloading the distribution again.']);
                end

            end
                
            guiPath = fileparts(guiPath);

        case 'paths' %find all QUATTRO sub-directories

            % Determine where QUATTRO lives
            qtPath = qt_path;

            % Recursively read all QUATTRO sub-directories, and concatenates
            % those directories with the QUATTRO path and major QUATTRO
            % sub-directories. Although GENPATH could be used, this stores the
            % directories in a cell array
            guiPath = [{qtPath} read_dirs(qtPath)];

        case 'script' %Find the directory of QUATTRO scripts

            guiPath = fullfile(qt_path('appdata'),'scripts');

    end

end %qt_path


%-----------------------
function sd = read_dirs(d)

    % To simplify code, read_dirs only works on strings. When calls to read_dirs
    % are made with cell arrays (i.e., seeking multiple sub-diretory expansion),
    % simply run read_dirs using cellfun.
    if iscell(d)
        sd = cellfun(@read_dirs,d,'UniformOutput',false);
        sd = sd(~cellfun(@isempty,sd)); %remove failed directory searches
        if ~isempty(sd) %ensures that the output is an empty cell
            sd = [sd{:}];
        end
        return
    end

    % Parse all sub-directories of "d"
    sd = gensubdirs(d);

    % Determine if any additional sub-directories exist for those directories
    % found in fList
    if ~isempty(sd)
        ssd = read_dirs(sd);
        ssd = ssd(~cellfun(@isempty,ssd)); %remove failed directory searches
        sd  = [sd(:);ssd(:)]; %concatenate paths
    end

    % Always return a row vector for easy concatenation
    sd = sd(:)';

end %read_dirs