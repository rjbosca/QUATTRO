function pt_num = detect_bolus_peak(images,opt)
%DETECT_UPTAKE_ARRIVAL Detect the time point of bolus arrival.
%   t = DETECT_UPTAKE_ARRIVAL(IMS) takes an image stack stored in an m x n
%   array with m slices and n time points and attempts to detect the peak
%   concentration time point.
%
%   t = DETECT_UPTAKE_ARRIVAL(IMS,TYPE) uses an image stack of the
%   specified exam type, TYPE (either 'DCE' or 'DSC') to determine the peak
%   concentration time point.

% Check for option
if ~exist('opt','var')
    opt = 'DCE';
else
    if ~any( strcmpi(opt,{'dce','dsc'}) )
        error(['QUATTRO:' mfilename 'optionChk'],'Invalid exam type');
    end
end

% Create image mask for blank initial pixels
[blank_ims{1:size(images,1)}] = deal(zeros(size(images{1})));
for i = 1:size(images,1)
    for j = 1:size(images,2)
        blank_ims{i} = blank_ims{i} | (images{i,j} == 0);
    end
end

% Calculate mean values for each slice using the image masks from above
for i = 1:size(images,1)
    for j = 1:size(images,2)
        mean_vals(i,j) = mean( images{i,j}( ~blank_ims{i} ) );
    end
    switch opt
        case 'DCE'
            [val peak_ind(i)] = max( mean_vals(i,:) );
        case 'DSC'
            [val peak_ind(i)] = min( mean_vals(i,:) );
    end
end

pt_num = round( median(peak_ind) );