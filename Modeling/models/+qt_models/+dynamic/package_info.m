function s = package_info
%package_info  Reports the DYNAMIC model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the DYNAMIC modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Modeling for time-resolved imaging.',...
               'Name','Dynamic');

end %package_info