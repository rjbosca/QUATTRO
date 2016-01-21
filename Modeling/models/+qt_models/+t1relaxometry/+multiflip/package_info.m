function s = package_info
%package_info  Reports the MULTIFLIP model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the MULTIFLIP modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Variable flip angle T1 exam setup',...
               'Name','Multiple Flip Angle');

end %package_info