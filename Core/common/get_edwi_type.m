function s = get_edwi_type(tag)
%get_edwi_type  Determines the diffusion encoding schema for GE MRs.
%   S = get_edwi_type(T) determines the eDWI diffusion encoding scheme as
%   specified by the IntegerSlop_DiffusionDirection (T) from the DICOM
%   header.

%% AUTHOR    : Ryan Bosca
%% $DATE     : 11-Jan-2012 11:23:48 $ 
%% $Revision : 1.01 $ 
%% DEVELOPED : 7.11.0.584 (R2010b) 
%% FILENAME  : get_edwi_type.m

switch tag
    case 7
        s = 'All';
    case 64
        s = '3-in-1';
    case 128
        s = 'Tetra';
    otherwise
        s = '?';
end