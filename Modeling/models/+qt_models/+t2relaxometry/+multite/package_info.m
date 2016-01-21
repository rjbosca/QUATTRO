function s = package_info
%package_info  Reports the MULTITE model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the MULTITE modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Multiple echo time T2 relaxometry modeling',...
               'Name','Multiple TE');

end %package_info