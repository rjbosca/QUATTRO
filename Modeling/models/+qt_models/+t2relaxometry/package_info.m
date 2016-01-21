function s = package_info
%package_info  Reports the T2RELAXOMETRY model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the T2RELAXOMETRY modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Modeling for T2 relaxometry (MR) acquisitions.',...
               'Name','T2 Relaxometry');

end %package_info