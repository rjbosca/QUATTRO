function qtVer = qt_version(verType)
%qt_version  Returns the current version of QUATTRO
%
%   VER = qt_version returns the current working version of the QUATTRO GUI
%
%   VER = qt_version(TYPE) returns the current working version of the QUATTRO
%   component specified by type. Components:
%
%       Type            Description
%       -----------------------------
%       'gui'           QUATTRO GUI version
%
%       'save'          QUATTRO save format version

    persistent qtVersion

    % Create the data if none exist
    if isempty(qtVersion)
        qtVersion = struct('gui', 6.01,...
                           'save',5.1);
    end

    % Get the requested output
    qtVer = qtVersion;
    if nargin
        qtVer = qtVersion.( validatestring(verType,fieldnames(qtVersion)) );
    end


end %qt_version