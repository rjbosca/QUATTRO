function roi = nordiciceread(sdata)
%nordiciceread  Reads a NordicICE *.roi file
%
%   roi = nordiciceread(FILE) reads the Nordic ICE ROI data contained in FILE.
%
%   see also read_pinnacle and imagejread

% This fileis essentially a wrapper for imagejread. The two ROI files seem
% identical, at least to me.

roi = imagejread(sdata);