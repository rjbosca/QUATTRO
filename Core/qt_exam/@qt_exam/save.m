function save(obj,varargin)
%save  Save a qt_exam object's data
%
%   save(OBJ) saves all user data from the qt_exam object specified by OBJ. A UI
%   prompt is provided to select a file in which to store the data. OBJ can also
%   be an array of qt_exam objects.
%
%   save(OBJ,TYPE) perfroms the save operation of TYPE on the data stored in the
%   object OBJ. Valid TYPE strings are:
%
%       TYPE            Description
%       -----------------------------
%       'save'          Saves all user data in a QUATTRO save file,
%                       over-writting a previous file if available
%
%       'saveas'        Saves all user data, writing a new QUATTRO save file
%
%       'images'        Saves only image data (i.e. images and headers)
%
%       'rois'          Saves only ROI data
%
%       'maps'          Saves only parametric maps
%
%   save(OBJ,TYPE,FILE) performs the save operation, as defined previously, in
%   the file specified by the full file name, FILE.
%
%   **WARNING** the functionality and output format of this method will change
%   in the future

    % Parse the inputs
    [fName,svType] = parse_inputs(varargin{:});

    % Let the user select where to save the file. There are two cases: (1) the
    % default file name (defined in parse_inputs by the qt_options properties)
    % did not exist or (2) the user selected a save type other than 'save'
    if (exist(fName,'file')~=2) || ~strcmpi(svType,'save')
        [fName,ok] = qt_uiputfile('*.mat','Save QUATTRO workspace...',fName);
        if ~ok
            errordlg('No data were saved.','Save Error','modal');
            return
        end
    end
    h = msgbox('Saving QUATTRO data','Saving...','Modal');

    % Initialize the save structure
    nExams    = numel(obj);
    save_data = struct('rois',{cell(1,nExams)},...
                       'imgs',{cell(1,nExams)},...
                       'hdrs',{cell(1,nExams)},...
                       'type',{cell(1,nExams)},...
                       'name',{cell(1,nExams)},...
                       'maps',{cell(1,nExams)},...
                       'version',qt_version('save'));

    % Remove unnecessary data fields from the save structure
    switch svType
        case 'images'
            save_data = rmfield(save_data,'rois');
        case 'maps'
            save_data = rmfield(save_data,{'rois','type','name','imgs','hdrs'});
        case 'rois'
            save_data = rmfield(save_data,{'maps','type','name','imgs','hdrs'});
    end

    % Perform the write operations on the individual fields. Each function,
    % write_*_data, prepares the data named by * and writes that data to the
    % cell corresponding to the exam index (exIdx) in the respective field of
    % the structure
    for exIdx = 1:nExams
        save_data             = write_image_data(save_data,obj(exIdx));
        save_data             = write_exam_data( save_data,obj(exIdx));
        save_data             = write_roi_data(  save_data,obj(exIdx));
        save_data             = write_map_data(  save_data,obj(exIdx));
        save_data.type{exIdx} = obj(exIdx).type;
    end

    % Write the final save structure
    save(fName,'save_data');
    delete(h);
    pause(0.25);

    % Update the qt_optoins "save" properties
    [obj.opts.saveDir,fName,fExt] = fileparts(fName);
     obj.opts.saveFile            = [fName fExt];

    function varargout = parse_inputs(varargin)

        % Create the parser, using any previous file/path as the starting point
        % for the save file
        parser = inputParser;
        parser.addOptional('type','save',@ischar);
        parser.addOptional('file',...
                          fullfile(obj.opts.saveDir,obj.opts.saveFile),@ischar);

        % Parse the inputs
        parser.parse(varargin{:});
        results = parser.Results;

        % Use validatestring (merely a convenience) to partial match and ensure
        % an appropriate save type
        results.type = validatestring(results.type,...
                                      {'save','saveas','images','rois','maps'});

        
        varargout = struct2cell(results);

        % Special case for the 'saveas' save type
        if strcmpi(results.type,'saveas')
            varargout{1} = fullfile(obj.opts.saveDir,...
                                                  createFileName(obj.metaData));
        end

    end %parse_inputs

end %qt_exam.save


%-------------------------------Data Writing Fcns-------------------------------

%-------------------------------------
function sv = write_image_data(sv,obj)

    % Ensure the proper fields of the save data exist
    if any( ~isfield(sv,{'imgs','hdrs'}) )
        return
    end

    % Find the first empty index in the image data fields
    idx = find( cellfun(@isempty,sv.imgs), 1, 'first' );

    % Store the data
    mIm          = size(obj.imgs);
    nIms         = numel(obj.imgs);
    sv.imgs{idx} = cell(mIm);
    for imIdx = 1:nIms
        [sv.imgs{idx}{imIdx},sv.hdrs{idx}(imIdx)] = obj.imgs(imIdx).export;
    end

    % Reshape the header structure array
    sv.hdrs{idx} = reshape(sv.hdrs{idx},size(sv.imgs{idx}));

end %write_image_data

%------------------------------------
function sv = write_exam_data(sv,obj)

    % Ensure the proper fields of the save data exist
    if any( ~isfield(sv,{'types','names'}) )
        return
    end

    % Find the first empty index in the image data fields
    idx = find( cellfun(@isempty,sv.names), 1, 'first' );

    % Write the exam data
    sv.type{idx} = obj.type;
    sv.name{idx} = obj.name;

end %write_exam_data

%-----------------------------------
function sv = write_roi_data(sv,obj)

    % Ensure the proper fields of the save data exist
    if ~isfield(sv,'rois')
        return
    end

    % Find the first empty index in the image data fields
    idx = find( cellfun(@isempty,sv.rois), 1, 'first' );

    % Loop through the ROIs and convert the objects to a save structure
    flds = fieldnames(obj.rois)';
    for fld = flds
        rois = obj.rois.(fld{:});
        if ~any(rois.validaterois)
            continue
        end
        mRoi = [size(rois,1),size(rois,2),size(rois,3)];
    for rIdx = 1:mRoi(1)

        % Initialize the temporary ROI structure
        roiData = struct('coordinates',{{}},...
                         'types',{{}},...
                         'colors',[],...
                         'names',obj.roiNames.(fld{1}){rIdx},...
                         'tags',fld{:});

    for slIdx = 1:mRoi(2)
    for seIdx = 1:mRoi(3)

        % Ignore invalid/empty ROI objects
        if ~rois(rIdx,slIdx,seIdx).validaterois
            continue
        end

        roiData.coordinates{slIdx,seIdx} = rois(rIdx,slIdx,seIdx).position;
        roiData.types{slIdx,seIdx}       = rois(rIdx,slIdx,seIdx).type;
        roiData.colors                   = rois(rIdx,slIdx,seIdx).color;

    end %series loop
    end %slice loop

        % Store the ROI structure in the save structure
        sv.rois{idx} = [sv.rois{idx} roiData];

    end %ROI loop
    end %tag loop
    
end %write_roi_data

%-----------------------------------
function sv = write_map_data(sv,obj)

    % Ensure the proper fields of the save data exist
    if ~isfield(sv,'maps') || isempty(obj.maps)
        return
    end

    % Find the first empty index in the image data fields
    idx = find( cellfun(@isempty,sv.maps), 1, 'first' );

    % Grab the map field names for the first slice. Since maps is an array of
    % structures, these field names will be good for all slices
    mapTags = fieldnames(obj.maps);
    nMapSls = length(obj.maps.(mapTags{1}));
    nMaps   = numel(mapTags);

    % Initialize the ouptut arrays
    maps    = cell(nMaps,nMapSls);
    mapHdrs = cell(nMaps,nMapSls);

    % Loop through each slice
    for mapIdx = 1:nMaps
    for slIdx  = 1:nMapSls

        %FIXME: this will likely change when the image class is updated
        if isempty(obj.maps.(mapTags{mapIdx})(slIdx))
            continue
        end

        [maps{mapIdx,slIdx},mapHdrs{mapIdx,slIdx}] =...
                                       obj.maps.(mapTags{mapIdx})(slIdx).export;

    end %slice loop
    end %map loop

    % Append the image and meta-data to the save structure
    sv.maps{idx} = struct('imgs',maps,'hdrs',mapHdrs);

end %write_map_data