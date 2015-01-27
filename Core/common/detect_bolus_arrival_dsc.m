function pt_num = detect_bolus_arrival_dsc(im,enhance)
%detect_bolus_arrival_dsc Detect the time point of bolus arrival
%
%   t = detect_bolus_arrival_dsc(IMS) takes an image stack stored in an m x n
%   array with m slices and n time points and attempts to detect the bolus
%   arrival
%
%   t = detect_bolus_arrival_dsc(...,flag) attempts to detect the
%   bolus arrival for positive enhancement (flag=ture; default) or negative
%   enhance (flag = flase).

    % Determine enhancement type
    if nargin == 1
        enhance = 1;
    end

    % Create image mask that ignores pixels with a value of zero
    mask = cellfun(@(x) x==0,im,'UniformOutput',false);
    mask = cell_or(mask);
    if ~iscell(mask)
        mask = {mask};
    end

    % Calculate mean values for each slice using the image masks from above
    for i = 1:size(im,1)
        for j = 1:size(im,2)
            if ~enhance
                im_c = imcomplement(im{i,j});
                im_c = im_c - min(im_c(:));
            else
                im_c = im{i,j};
            end
            mean_vals(i,j) = mean( im_c( ~mask{i} ) );
        end
    end

    % Remove the first time point
    mean_vals = mean_vals(:,2:end);

    exit_flag = false; pt_num = 2;
    while ~exit_flag
        % Calculates moving average up to time point pt_num
        mean_baseline = mean(mean_vals(:,1:pt_num-1),2);
        if ~exist('std_vals','var')
            std_vals = std(mean_vals(:,1:pt_num),0,2);
        end
    %     std_vals = std(mean_vals(:,1:pt_num),0,2);
        temp_vals = std(mean_vals(:,1:pt_num),0,2);
        std_vals(temp_vals > std_vals) = temp_vals(temp_vals > std_vals);

        % Determines if there are any possible bolus arrivals
        num_enhanced = sum( abs(mean_vals(:,pt_num) - mean(mean_baseline,2)) > 2*std_vals );
        if num_enhanced > size(im,1)/2
            exit_flag = true;
        end

        % Stores new std. dev. values
    %     std_vals(temp_vals > std_vals) = temp_vals(temp_vals > std_vals);

        pt_num = pt_num + 1;
        if pt_num > size(mean_vals)
            h = figure; plot(permute(mean_vals,[2 1]));
            pt_num = inputdlg('What frame?'); pt_num = str2double(pt_num{1});
            delete(h)
            return
        end
    end

    pt_num = pt_num - 1;

end %detect_bolus_arrival_dsc