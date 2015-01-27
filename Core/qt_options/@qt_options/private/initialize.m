function initialize(obj)
%initialize  Reads the QUATTRO cached path log
%
%   initialize(OBJ) performs path initialization for the qt_options object.

    % Attempt to run qt_path
    if ~exist('qt_path','file')
        error(['qt_options:' mfilename ':missingQuattroComponent'],...
              ['Unable to locate the necessary QUATTRO file: "qt_path.m".\n',...
               'Undo any changes made to the QUATTRO directories or try\n',...
               'downloading the distribution again.\n']);
    end

    % Two calls must be made to deterine the QUATTRO parts and the application
    % direcotry
    qtPaths = [qt_path('paths') obj.scptDir];
    qtPaths = qtPaths( cellfun(@isempty,strfind(qtPaths,'@')) ); %ignore class dirs
    matPath = path;

    % Before proceeding with the path operations, ensure that the application
    % data and script directories exist. Otherwise, these must be created before
    % attempting to add anything to MATLAB's path
    if ~exist(obj.scptDir,'dir')
        mkdir(obj.scptDir);
    end

    % Now that the application directory is known, read the directory cache if
    % possible. Otherwise, this will be created after adding all of the paths
%     qtPathCache = {};
%     if exist( fullfile(appPath,'qt_path_cache.log'), 'file' )
%     end

    % Remove current components from the cache
%     if ~isempty(qtPathCache)
%         isOldPath     = cellfun(@(x) strcmpi(x,qtPaths),qtPathCache,...
%                                                          'UniformOutput',false);
%         qtPathCache   = qtPathCache( or(isOldPath{:}) );
%         for cachePath = qtPathCache
%             if ~isempty( strfind(matPath,[cachePath{1} ';']) )
%                 rmpath(cachePath{1});
%             end
%         end
%     end

    % Add all the QUATTRO sub-directories to the path if necessary
    for qtPath = qtPaths
        if isempty( strfind(matPath,[qtPath{1} ';']) )
            addpath(qtPath{1},'-end');
        end
    end

    % Attempt to save the path
    savepath;

    % Initialize all necessary paths and configuration file
    obj.cfgFile = fullfile(obj.appDir,'QUATTRO.cfg');

    % Attempt to load the configuration file
    obj.load;

    % Initialize the system's value for the MATLAB version
    verStruct     = ver('matlab');
    obj.matlabVer = str2double(verStruct.Version);

    % Force save file to be empty on initialization
    obj.saveFile = '';

    
end %qt_options.initialize