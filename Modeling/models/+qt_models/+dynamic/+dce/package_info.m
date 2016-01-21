function s = package_info
%package_info  Reports the DCE model information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the DCE modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Dynamic contrast-enhanced MR image modeling.',...
               'Name','DCE-MRI');

end %package_info