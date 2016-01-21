function s = package_info
%package_info  Reports the DIFFUSION model type information
%
%   S = package_info creates a structure, from hard-coded information, that
%   describes the DIFFUSION modeling package

    s = struct('ContainingPackage',mfile2package( mfilename('fullpath') ),...
               'Name', 'Diffusion',...
               'Description', 'Modeling for diffusion weighted MR imaging.');

end %package_info