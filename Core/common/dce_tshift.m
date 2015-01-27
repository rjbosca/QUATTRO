function ims = dce_tshift(ims,t,t_new)
%dce_tshift  Shifts a DCE exam in the temporal direction
%
%   ims = dce_tshift(ims,t,tnew) shifts the image stack, a 4D array where the
%   4th dimension is the time index, of images according to the current time
%   row vector (t) to the new time row vector (tnew) using linear interpolation.
%   Alternatively, the image volume can be specified in a cell array, where the
%   first dimension specifies the slice location and the second dimension
%   specifies the temporal position.
%
%   NOTES:
%       (1) it is the user's responsibility to ensure that the temporal vector,
%           t, contains the correct spacing.
%
%       (2) the current implementation of this can use an enoromous amount of
%           RAM, more specifically, EIGTH times the amount of RAM required for
%           the image stack, ims

% Some error checking
if ~((ndims(ims)~=4 && isnumeric(ims)) || (iscell(ims) && isnumeric(ims{1})))
    error(['QUATTRO:' mfilename ':inputChk'],'Invalid image array');
end
if iscell(ims)
    m = size(ims{1}); mc = size(ims);
    new_ims = zeros([m mc]);
    for i = 1:mc(1)
        for j = 1:mc(2)
            new_ims(:,:,i,j) = ims{i,j};
        end
    end
    ims = new_ims; clear new_ims;
end

% Get current size of image stack and enforce class
m = size(ims); ims = double(ims);

% Generate the current and new grid spacings
[x  y  z  t]  = ndgrid(1:m(1),1:m(2),1:m(3),t);
[xi yi zi ti] = ndgrid(1:m(1),1:m(2),1:m(3),t_new);

% Gernerate the new image stack
ims = interpn(x,y,z,t,ims,  xi,yi,zi,ti,  'linear');