function [sPath,ok] = qt_uigetdir(varargin)
%qt_uigetdir  QUATTRO wrapper for uigetdir
%
%   [DIR,OK] = qt_uigetdir(STARTPATH,TITLE) presents the user with an directory
%   dialog box initializing the location in the directory STARTPATH and titling
%   the dialog box with TITLE. DIR is the directory selected by the user in
%   addition to a logical value, OK, which is true if the user provided a usable
%   directory name.
%
%   See also uigetdir, qt_uigetfile, qt_uiputfile

    % Let the user select the directory
    sPath = uigetdir(varargin{:});

    % Validate the selected directory
    ok = ~isnumeric(sPath);
    if ~ok || ~exist(sPath,'dir')
        sPath = '';
    end
    
end %qt_uigetdir