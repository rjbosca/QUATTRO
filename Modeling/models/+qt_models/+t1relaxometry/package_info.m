function s = package_info
%package_info  Reports the T1RELAXOMETRY model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the T1RELAXOMETRY modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Modeling for T1 relaxometry (MR) acquisitions.',...
               'Name','T1 Relaxometry');

end %package_info