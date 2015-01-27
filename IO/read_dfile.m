function tform = read_dfile(f)
%read_dfile  Reads AFNI dfile
%
%   wc = read_dfile(f) reads the AFNI dfile specified by the full file name f,
%   returning a vector of transformations that can be used with the transfom
%   method of a qt_reg object.

% Open/read file
tform = dlmread(f);

% Remove base image # and obj. fcn. values
tform = tform(2:7);

% Convert to QUATTRO transform
tform(4:end) = -tform([6 5 4]);   %reverse translation direction
tform(1:3)   = pi/180*tform([3 2 1]); %convert deg. to rads.
                                      %move from 