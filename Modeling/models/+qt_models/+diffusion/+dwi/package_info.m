function s = package_info
%package_info  Reports the DWI model information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the DWI modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Description','Multiple b-value (single direction) diffusion weighted MR modeling.',...
               'Name','DWI');

end %package_info