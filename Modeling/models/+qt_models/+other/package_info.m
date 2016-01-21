function s = package_info
%package_info  Reports the OTHER model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the OTHER modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Non-standard models and basic exam settings.',...
               'Name','Other');

end %package_info