function initialize(obj)
%initialize  Reads the QUATTRO cached path log
%
%   initialize(OBJ) performs path initialization for the QT_OPTIONS object OBJ.

    % Before proceeding with the remaining initialization operations, ensure
    % that the application data and script directories exist. Otherwise, these
    % must be created before attempting to add anything to MATLAB's path
    if ~exist(obj.scptDir,'dir')
        mkdir(obj.scptDir);
    end

    % Initialize all necessary paths and configuration file
    obj.cfgFile = fullfile(obj.appDir,'QUATTRO.cfg');

    % Attempt to load the configuration file
    obj.load;

    % Force save file to be empty on initialization
    obj.saveFile = '';
    
end %qt_options.initialize