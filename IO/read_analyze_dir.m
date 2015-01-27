function ims_out = read_analyze_dir(p_name)

% Initialize output
ims_out = {};

% Get path
if nargin<1
    p_name = uigetdir;
    if ~isdir(p_name)
        error('invalid dir');
    end
end

% Loads all data
f_list = dir(p_name); f_list(1:2) = [];
for i = 1:length(f_list)
    if ~isempty( strfind(f_list(i).name, 'img') ) && ~f_list(i).isdir
        [im{i} dump dump hdr(i)] = ReadAnalyze([p_name filesep f_list(i).name]);
    end
end

% Reformats data
for i = length(im):-1:1
    if ~isempty(im{i})
        for j = 1:size(im{i},3)
            if j==1
                ims_out{j,end+1} = squeeze( im{i}(:,:,j) );
            else
                ims_out{j,end} = squeeze( im{i}(:,:,j) );
            end
        end
    end
end
disp('all')