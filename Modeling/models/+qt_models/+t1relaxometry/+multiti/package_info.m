function s = package_info
%package_info  Reports the MULTITI model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the MULTITI modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Multiple inversion time T1 modeling',...
               'Name','Multiple TI');

end %package_info