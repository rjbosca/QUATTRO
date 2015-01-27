function path = mfilepath
%MFILEPATH  Path of currently executing M-file.
%
%   path = MFILEPATH returns a string containing the path of the currently
%   executing M-file.
%
%   path = MFILEPATH(fname) returs a string containing the path of the

% Determines caller function
st = dbstack('-completenames');

% Removes the M-file name and stores the path
path = fileparts(st(2).file);