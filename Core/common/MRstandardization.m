function MRstandardization(ImagesIn, pc1, pc2, s1, s2)

% MRstandardization is a display standardization tool as described by
% Bedekar (2010, MRM), Nyul (1999, MRM & 2000, IEEE Trans. on Med. Imag.),
% Udupa (2006, SPIE).
%
% ImagesIn are the 3D volumes containing similar corresponding protocols
% and body regions. pc1 and pc2 are the user-defined percentiles that
% remove iamge background and outliers. The fist mode is removed by this
% script. s1 and s2 are the limits set for training purposes only. If a
% LUT has already been prodcued there is no need to include these.

% ERROR CHECK: (1) ensure ImagesIn is a cell, if not, convert to cell
if ~iscell(ImagesIn)
    temp = ImagesIn; clear ImagesIn; ImagesIn{1} = temp; clear temp;
end

% Coverts all values to double, removes all NaNs, and removes the the first
% mode.
for i = 1:length(ImagesIn)
    ImVal{i} = double(ImagesIn{i}(:));
    ImVal{i}(isnan(ImVal{i})) = [];
    TempMode = mode(ImVal{i});
    ImVal{i}(ImVal{i}==TempMode) = [];
end
clear ImagesIn

% Calculates the histogram landmarks
for i = 1:length(ImVal)
    L{i}(1) = prctile(ImVal{i},pc1);
    L{i}(10) = prctile(ImVal{i},pc2);
    for j = 1:9
        L{i}(j) = mean(ImVal{i}(ImVal{i}<prctile(ImVal{i},j*10)));
    end
end