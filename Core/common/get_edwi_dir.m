function s = get_edwi_dir(tag)
%get_edwi_dir  Determines the diffusion encoding direction.
%   S = get_edwi_dir(T) determines the eDWI diffusion direction as
%   specified by the VasCollapseFlag (T) from the DICOM header.

%% AUTHOR    : Ryan Bosca
%% $DATE     : 11-Jan-2012 11:24:48 $ 
%% $Revision : 1.01 $ 
%% DEVELOPED : 7.11.0.584 (R2010b) 
%% FILENAME  : get_edwi_dir.m

switch tag
    case 3
        s = 'R/L';
    case 4
        s = 'A/P';
    case 5
        s = 'S/I';
    case {15,43}
        s = 'CMB';
    otherwise
        s = '?';
end