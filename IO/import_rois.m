function [rData fInfo] = import_rois
%import_rois  Deteremines the ROI data type and loads all data
%
%   [rois f_info] = import_rois allows the user to select and import ROI
%   files from various proprietary software. Currently supported ROI types
%   include the following: NordiceICE, Pinnacle. f_info is additional data
%   that varies by software package (e.g. Pinnacle header is stored in
%   f_info). An attempt is made to automatically determine the header
%   software package; if this fails, no data is returned. 

% Initialize output
rData = struct('colors','','coordinates',[],'names','','slice',[],'types','');
roiType = struct('Filename','','Filepath','','Software','');

% Get file names
[fNames,ok] = qt_uigetfile({'*.roi','ROI file (*.roi)'},...
                            'Select ROIs to import.','','on');
if ~ok
    [rData,fInfo] = deal([]);
    return
end

% Load ROIs
n = length(fNames); roiType = repmat(roiType,1,n);
for i = 1:n

    % Load ROI data
    fid = fopen( fullfile(fPath,fNames{i}), 'r' );
    if fid==-1
        errordlg(['Unable to load ' fNames{i}],'Load Error');
        continue
    end
    s = textscan(fid,'%s','Delimiter','\n' ); s = s{1};
    fclose(fid);

    if isempty(s)
        errordlg(['No data found in ' fNames{i}],'Read Error');
        continue
    end

    [roiType(i),rData(i)] = find_roi_type(s);
    switch roiType(i).Software
        case 'Pinnacle'
            [rData,fInfo(i)] = read_pinnacle(fullfile(fPath,fNames{i}),s);
            if i==1
                rData = rData;
            else
                rData = [rData rData]; %#ok<*AGROW>
            end
        case 'NordicICE'
            continue
        otherwise
            errordlg(['Unknown ROI type in ' fNames{i}],'Unknown ROI');
    end
end

% Concatenate structures
f1 = fieldnames(rData); f2 = fieldnames(roiType); f = [f1; f2];
c1 = struct2cell(rData); c2 = struct2cell(roiType); c = [c1; c2];
rData = cell2struct(c,f,1);
if ~exist('f_info','var')
    fInfo = [];
end


    % --- Determines the ROI type
    function [s roi] = find_roi_type(sdata)

        % Initialize output
        s = struct('Filename',fNames{i},'Filepath',fPath,...
                                                     'Software','Unknown');
        roi = struct('colors',[],'coordinates',[],'names','','slice',[],'types','');

        % Pinnacle definition
        if strcmpi( sdata{1}, '// Region of Interest file' )
            s.Software = 'Pinnacle';
            return
        end

        % NordicICE/ImageJ definition
        if any(strcmpi(sdata{1},{'small','medium','large'}))
            roi = nordiciceread(sdata);
            if ~isempty(roi)
                s.Software = 'NordicICE';
            end
            return
        end
    end %find_roi_type

end %import_rois