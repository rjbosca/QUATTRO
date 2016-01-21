function s = package_info
%package_info  Reports the GENERIC model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the GENERIC modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Generic exam setup for basic serial imaging investigations.',...
               'Name','Generic');

end %package_info