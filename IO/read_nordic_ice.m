function roi = read_nordic_ice(sdata)
%read_nordic_ice  Reads a NordicICE *.roi file
%
%   roi = read_nordic_ice(f_name) reads the file, f_name, containing a
%   Nordic ICE ROI
%
%   roi = read_nordic_ice(s) reads the data stored in the cell array of
%   strings from a NordicICE ROI file.
%
%   Example 1: Read a NordicICE ROI file
%       fid = fopen('newROI.roi');
%       s = textscan(fid,'%s','Delimiter','\n'); s = s{1};
%       fclose(fid);
%       roi = read_nordic_ice(s);
%
%   see also read_pinnacle

% Initialize output
roi = struct('colors',[],'coordinates',[],'names','','slice',[],'types',''); %#ok<*NASGU>

% Determine input type
if ischar(sdata) && exist(sdata,'file')
    fid = fopen(sdata,'r'); sdata = textscan(fid,'%s','Delimiter','\n' );
    sdata = sdata{1}; fclose(fid);
end

% Scan data points
roi_coors = cellfun(@(x) sscanf(x,'%d;%d'),sdata(3:end)',...
                                                    'UniformOutput',false);

% Restructure data
switch lower(sdata{2})
    case {'freehand','polygon'}
        sdata{2} = strrep(sdata{2},'freehand','imspline');
        sdata{2} = strrep(sdata{2},'polygon','impoly');
        try
            roi_coors = cell2mat(roi_coors);
            roi_coors = permute(roi_coors,[2 1]);
        catch ME
            rethrow(ME);
        end

    case {'ellipse','rectangle'}
        sdata{2} = strrep(sdata{2},'ellipse','imellipse');
        sdata{2} = strrep(sdata{2},'rectangle','imrect');
        try
            roi_coors = cell2mat(roi_coors);
            roi_coors = roi_coors(:)'; roi_coors = roi_coors([3 4 1 2]);
        catch ME
            rethrow(ME);
        end

        
end

% Store ROI output data
roi = struct('colors',[],'coordinates',roi_coors,'names','','slice',1,...
                                                          'types',sdata{2});