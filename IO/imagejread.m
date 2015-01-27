function roi = imagejread(sData)
%imagejread  Reads an ImageJ *.roi file
%
%   ROI = imagejread(FILE) reads the ImageJ ROI data contained in FILE.
%
%   See also nordiciceread

% Initialize output
roi = struct('colors',[],'coordinates',[],'names','','slice',[],'types',''); %#ok<*NASGU>

% Determine input type
if ischar(sData) && exist(sData,'file')
    fid = fopen(sData,'r');
    sData = textscan(fid,'%s','Delimiter','\n' );
    sData = sData{1}; fclose(fid);
end

% Scan data points
roi_coors = cellfun(@(x) sscanf(x,'%d;%d'),sData(3:end)',...
                                                         'UniformOutput',false);

% Restructure data
switch lower(sData{2})
    case {'freehand','polygon'}
        sData{2} = strrep(sData{2},'freehand','imspline');
        sData{2} = strrep(sData{2},'polygon','impoly');
        try
            roi_coors = cell2mat(roi_coors);
            roi_coors = permute(roi_coors,[2 1]);
        catch ME
            rethrow(ME);
        end

    case {'ellipse','rectangle'}
        sData{2} = strrep(sData{2},'ellipse','imellipse');
        sData{2} = strrep(sData{2},'rectangle','imrect');
        try
            roi_coors = cell2mat(roi_coors);
            roi_coors = roi_coors(:)'; roi_coors = roi_coors([3 4 1 2]);
        catch ME
            rethrow(ME);
        end
end

% Store ROI output data
roi = struct('colors',[],'coordinates',roi_coors,'names','','slice',1,...
                                                          'types',sData{2});