function [imgs hdrs] = importAnalyze(varargin)
%importAnalyze  Reads a directory of Analyze images
%
%   [I H] = importAnalyze reads a directory containing Analyze image. The
%   user is prompted to specify the directory, returning the image and
%   header data, I and H, respectively
%
%   [I H] = importAnalyze(D) reads all files from the directory specified
%   by D.

if ~nargin || ~exist(varargin{1},'dir')
    s_dir = uigetdir('Select the folder containing all Analyze images.');
    if isnumeric( s_dir ) || ~isdir( s_dir )
        return
    end
else
    s_dir = varargin{1};
end

% Generate file list
f_list = dir( s_dir ); f_list(1:2) = []; m = size(f_list,1);

% Import all data
h_wait = waitbar(0, '0% Complete', 'Name', 'Loading Analyze images.');
for i = 1:m
    % Update waitbar
    waitbar(i/m,h_wait,[num2str(round(i/m*100)) '% complete']);

    [fp fn ext] = fileparts(f_list(i).name);
    if ~strcmpi(ext,'.hdr')
        continue
    end

    % Read image
    hdrs(i) = analyze75info(fullfile(s_dir,f_list(i).name));
    img_in{i} = analyze75read(hdrs(i));

end
delete(h_wait);

% Reorganize image data
img_in(cellfun(@isempty,img_in)) = [];
n_se = length(img_in); n_sl = size(img_in{1},3); imgs = cell(n_sl,n_se);
for i = 1:n_sl
    for j = 1:n_se
        imgs{i,j} = flipud(squeeze(img_in{j}(:,:,i)));
    end
end