function s = package_info
%package_info  Reports the MULTITR model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the MULTITR modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Multiple TR (saturation recovery) T1 modeling',...
               'Name','Multiple TR');

end %package_info