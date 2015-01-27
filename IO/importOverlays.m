function [overlays overlay_lists slices] = importOverlays(im_size,raw_path,raw_files)

% Initialize variables
[overlays overlay_lists slices] = deal({});
im_pixels = prod(im_size);

% Retrieves files if none are specified
if ~exist('raw_files','var')
    temp = dir(raw_path); temp(1:2) = [];
    [raw_files{1:length(temp)}] = deal(temp.name);
    clear temp
end

% raw_files needs to be a cell
if ~iscell( raw_files )
    raw_files = {raw_files};
end

% Determines slice numbers as defined by CineTool
for i = 1:length( raw_files )
    % Find the index for the slice number
    ind = strfind( raw_files{i}, 'sl' );
    if isempty( ind )
        errordlg( {'An error occured while importing overlays.',...
                   'No overlays were imported.'} );
        return
    end
    slices{end+1} = [raw_files{i}(ind:ind+3) ' '];
    if isnan( str2double( slices{end}(4:5) ) )
        errordlg( {'Slice numbers were not found. Ensure file names',...
                   'are unchanged from CineTool output.'},...
                   'Import aborted.')
        return
    end
end
slices = unique( slices );

% Initializes the list of maps that are not loaded
maps_not_loaded{1} =  '';

% File types produced by CineTool and supported by QUATTRO
file_types = {'AUC90', 'AUC180', 'CER', 'fp', 'Ke', 'Kt', 'MxSlp',...
              'r2mask', 'r2', 'Slp', 'TTP', 've', 'WshOut'};

% Loads each map
for i = 1:length( slices )

    % Continues if the ith slice is empty
    no_overlay = strcmpi( slices{i}, 'empty' ) ||...
                 all( isspace(slices{i}) );
    if no_overlay
        continue
    end

    % Finds all file names for the ith slice
    ind = [];
    for j = 1:length( raw_files )
        if ~isempty( strfind( raw_files{j}, strtrim( slices{i} ) ) )
            ind(end+1) = j;
        end
    end

    % Initialize temporary variables
    temp_overlays = {};
    temp_overlay_list = {};

    % Stores all maps names
    for j = 1:length( ind )
        % Sets the type of map and determines if this is a type of map
        % produced by CineTool
        map_type = textscan(raw_files{ind(j)},'%s','Delimiter','-');
        map_type = strrep(map_type{1}{end}, '.raw', '');
        if isempty( strmatch( map_type, file_types ) )
            maps_not_loaded{end+1} = raw_files{ind(j)};
            continue
        end
    
        % Opens file for reading
        fid = fopen(fullfile(raw_path, raw_files{ind(j)}), 'r');

        % ERROR CHECK: Ensures that the file opened properly
        if isequal( fid, -1 )
            errordlg([raw_files{ind(j)} ' could not be loaded'],...
                     'Read Error.');
            continue
        end

        % Temporarily stores file data and closes the open file
        tempMap = fread(fid, 'single', 0, 'l');
        fclose(fid);

        % ERROR CHECK: Ensures that the loaded data is the same size as the
        % image
        if ~isequal( numel(tempMap), im_pixels )
            error_list{i} = raw_files{ind(j)};
            continue
        end

        % Resize parametric map to fit size of DICOM image
        tempMap = reshape(tempMap,im_size)';

        switch map_type
            case {'fp'}
                temp_overlays{end+1} = tempMap;
                temp_overlay_list{end+1} = 'vp';
                continue
            case {'Ke'}
                temp_overlays{end+1} = tempMap;
                temp_overlay_list{end+1} = 'kep';
                continue
            case {'Kt'}
                temp_overlays{end+1} = tempMap;
                temp_overlay_list{end+1} = 'Ktrans';
                continue
            case {'MxSlp'}
                temp_overlays{end+1} = tempMap;
                temp_overlay_list{end+1} = 'Max Slope';
                continue
            case {'Slp'}
                temp_overlays{end+1} = tempMap;
                temp_overlay_list{end+1} = 'Slope';
                continue
            case {'WshOut'}
                temp_overlays{end+1} = tempMap;
                temp_overlay_list{end+1} = 'Wash Out';
                continue
            otherwise
                temp_overlays{end+1} = tempMap;
                temp_overlay_list{end+1} = map_type;
                continue
        end
    end

    overlays{i} = temp_overlays;
    overlay_lists{i} = temp_overlay_list;
end

% Sorts all fields alphabetically on each slice
for i = 1:length(overlay_lists)
    s = overlay_lists{i};
    s_low = cellfun(@(x) lower(x), s,'UniformOutput',false);
    [s_low ind] = sort(s_low);

    overlay_lists{i} = s(ind); overlays{i} = overlays{i}(ind);
end

% Appends a 'none' field for all list structures
for i = 1:length(overlay_lists)
    if isempty(overlay_lists{i})
        overlay_lists{i} = {'None'};
    else
        overlay_lists{i}{end+1} = 'None';
    end
end

% Displays read errors 
% if exist( 'error_list', 'var' ) && ~isempty( error_list )
%     ind = ~cellfun(@isempty,error_list);
%     errordlg( error_list(ind), 'Improper overlay size.' );
% end