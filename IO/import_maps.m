function mapData = import_maps(varargin)
%import_maps  Imports images as maps for QUATTRO
%
%   M = import_maps(FILES,FORMAT,MTYPE) imports all of the image FILES specified
%   as cell array of full file names (i.e. including full path) and the
%   corresponding FORMAT. Maps are imported according to the map type specified
%   by MTYPE (see description below). A structure array of maps, M is returned.
%
%
%   Map types       Description
%   ---------------------------
%   'adc'           Apparent diffusion coefficient (units: x10^-9 mm^2/s)
%
%   'fa'            Fractional anistropy (units: a.u.)
%
%   'mineig'        Minimum DTI eigenvalue (units: x10^-9 mm^2/s)
%
%   'medeig'        Medium DTI eigenvalue (units: x10^-9 mm^2/s)
%
%   'maxeig'        Maximum DTI eigenvalue(units: x10^-9 mm^2/s)
%
%   'mtt'           Mean transit time
%
%   'rcbv'          Relative cerebral blood volume
%
%   'rcbf'          Relative cerebral blood flow
%
%   'ttp'           Time to peak
%
%
%   Image Types
%   ===========
%
%   DCM - DICOM image format
%   ------------------------
%
%   DICOM image meta data is used to inform the import. Specifically, the slice
%   location tag is used to order the slices appropriately
%
%
%   RAW - Raw image format
%   ----------------------
%
%   RAW image formats are not standardized and require additional input from the
%   user to properly import the images.
%
%   [...] = import_maps(...,M,CLASS) imports raw image data as previously
%   described using the image size specified by M and the data class specified
%   by CLASS. The latter is a string specifing the data precision to read (see
%   fread for more information). 
%
%   See also fread

% Parse inputs
[files,fmt,mType,imM,prec] = parse_inputs(varargin{:});

% Fire appropriate importer
mapData = eval([fmt '_import']);


    function s = dcm_import %#ok<*DEFNU>

        % Grab the headers/images
        [imgs,hdrs] = importDICOM(files);

        % Some logicals to be used below
        is_ge = strcmpi(hdrs(1).Manufacturer,'GE medical systems');

        % DICOM tags used below
        scale_fld = dicomlookup('0051','1004');

        % Determine scalings and generate output structure
        s = struct(mType,[]);
        switch mType
            case {'adc','fa','mtt','rcbf','rcbv','ttp'}
                if ~is_ge
                    return
                end
                for idx = 1:length(imgs)
                    if isfield(hdrs(idx),scale_fld)
                        s(idx).(mType) = double(imgs{idx})*hdrs(idx).(scale_fld);
                    end
                end
            case 'mineig'
            case 'medeig'
            case 'maxeig'

        end

    end

    function [m,ml,sls] = raw_import

        % Initialize variables
        [mapData,mapLists,slices] = deal({});
        im_pixels = prod(m);

        % Retrieves files if none are specified
        if ~exist('raw_files','var')
            temp = dir(fPaths); temp(1:2) = [];
            [files{1:length(temp)}] = deal(temp.name);
            clear temp
        end

        % raw_files needs to be a cell
        if ~iscell( files )
            files = {files};
        end

        % Determines slice numbers as defined by CineTool
        for i = 1:length( files )
            % Find the index for the slice number
            ind = strfind( files{i}, 'sl' );
            if isempty( ind )
                errordlg( {'An error occured while importing overlays.',...
                           'No overlays were imported.'} );
                return
            end
            slices{end+1} = [files{i}(ind:ind+3) ' '];
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
            for j = 1:length( files )
                if ~isempty( strfind( files{j}, strtrim( slices{i} ) ) )
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
                map_type = textscan(files{ind(j)},'%s','Delimiter','-');
                map_type = strrep(map_type{1}{end}, '.raw', '');
                if isempty( strmatch( map_type, file_types ) )
                    maps_not_loaded{end+1} = files{ind(j)};
                    continue
                end

                % Opens file for reading
                fid = fopen(fullfile(fPaths, files{ind(j)}), 'r');

                % ERROR CHECK: Ensures that the file opened properly
                if isequal( fid, -1 )
                    errordlg([files{ind(j)} ' could not be loaded'],...
                             'Read Error.');
                    continue
                end

                % Temporarily stores file data and closes the open file
                tempMap = fread(fid, 'single', 0, 'l');
                fclose(fid);

                % ERROR CHECK: Ensures that the loaded data is the same size as the
                % image
                if ~isequal( numel(tempMap), im_pixels )
                    error_list{i} = files{ind(j)};
                    continue
                end

                % Resize parametric map to fit size of DICOM image
                tempMap = reshape(tempMap,m)';

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

            mapData{i} = temp_overlays;
            mapLists{i} = temp_overlay_list;
        end

        % Sorts all fields alphabetically on each slice
        for i = 1:length(mapLists)
            s = mapLists{i};
            s_low = cellfun(@(x) lower(x), s,'UniformOutput',false);
            [s_low ind] = sort(s_low);

            mapLists{i} = s(ind); mapData{i} = mapData{i}(ind);
        end

        % Appends a 'none' field for all list structures
        for i = 1:length(mapLists)
            if isempty(mapLists{i})
                mapLists{i} = {'None'};
            else
                mapLists{i}{end+1} = 'None';
            end
        end

        % Displays read errors 
        % if exist( 'error_list', 'var' ) && ~isempty( error_list )
        %     ind = ~cellfun(@isempty,error_list);
        %     errordlg( error_list(ind), 'Improper overlay size.' );
        % end
    end %raw_import

end %import_maps


% Input parser
function varargout = parse_inputs(varargin)

% Deal outputs
[varargout{1:nargout}] = deal([]);

% Validate files
is_file = cellfun(@(x) exist(x,'file'),varargin{1});
if any(~is_file)
    error(['QUATTRO:' mfilename ':fileChk'],'Invalid file name specified');
end
varargout{1} = varargin{1};

% Validate read format
varargout{2} = validatestring(varargin{2},{'dcm','raw'});

% Validate map type
valid_maps = {'adc','fa','mineig','medeig','maxeig','mtt','rcbf','rcbv','ttp'};
varargout{3} = validatestring(varargin{3},valid_maps);

% Parse image specific inptus
parser = inputParser;
switch varargout{2}
    case 'raw'
        parser.addRequired('Size',@(x) numel(x)==2);
        parser.addRequired('Precision',@ischar);
    case 'dcm'
        return
end
parser.Parse(varargin{3:end});

% Deal the remaining outputs
[varargout{3:nargout}] = deal_cell( struct2cell(parser.Results) );

end %prase_inputs