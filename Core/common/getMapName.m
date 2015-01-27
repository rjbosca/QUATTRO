function map = getMapName(map)
%GETMAPNAME  Returns the full parametric map name.
%
%   S = getMapName(S) takes an input string S and returns the full
%   parametric map name if any exist. Otherwise, S is returned.

% Initialize
if ~ischar(map)
    map = 'Unknown';
end

switch map
    case {'fp', 'fpv'}
        map = 'vp';
    case {'Ke','Kep'}
        map = 'kep';
    case 'Kt'
        map = 'Ktrans';
    case 'MxSlp'
        map = 'Max Slope';
    case {'Rsq','r2'}
        map = 'R2';
    case 'Slp'
        map = 'Slope';
    case 'WshOut'
        map = 'Wash Out';
end