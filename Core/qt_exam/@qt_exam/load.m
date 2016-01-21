function varargout = load(varargin)
%load  Loads a QUATTRO exam
%
%   [QSAVE,FILE,PATH] = load(FILE) opens a user specified file specified by
%   QSAVE's full file name FILE and returns the QUATTRO save information in a
%   structure, QSAVE. If FILE specifies a directory, the user is prompted to
%   select a QUATTRO save file. The QSAVE data structure and validated file name
%   are returned to the user.
%
%   [...] = load(...,DATATYPE) opens a user specified QUATTRO save file,
%   loading only data of the type specified by DATATYPE. Valid strings for
%   DATATYPE are: 
%
%       String          Loaded Data
%       ---------------------------
%       'images'        Images and the associated meta-data are loaded
%                       from the specified QUATTRO save file
%
%       'maps'          Parametric map images and the associated meta-data
%                       are loaded from the specified QUATTRO save file
%
%       'rois'          ROI data are loaded from the specified QUATTRO
%                       save file
%
%       'any'           All data (any combination of images, rois, and
%                       parametric maps) are loaded from the specified
%                       QUATTRO save file
%
%
%   OBJ = load(OBJ,...) performs all operations defined previously, storing the
%   loaded data in the qt_exam object OBJ. Under certain circumstances, the OBJ
%   will need to be expanded to an array of qt_exam objects to accommodate
%   multiple exams. Therefore, the best practice is to always return the object
%   as a method output.
%
%   See also addexam and import

    % Initialize output, parse the inputs and validate that an appropriate
    % number of outputs was provided
    [dataType,loadDir,obj] = parse_inputs(varargin{:});
    if isempty(obj)
        varargout = {[],'',''};
        nargoutchk(1,3)
    else %when the qt_exam object is passed as an input,
         %outputs aren't required but are good practice.
        nargoutchk(0,1)
    end

    % UI file selection options: (1) the specified file name exists and is not a
    % directory - load the file or (2) the file name is a directory - prompt the
    % user
    if (exist(loadDir,'file')==2)
        [fPath,fName,fExt] = fileparts(loadDir);
        if isempty(fPath) %file is not on the path and partial name was given
            fPath          = pwd;
        end
    else
        [fName,fPath] = uigetfile('*.mat','MAT-files (*.mat)',loadDir);
        fExt          = '';
    end
    fName = [fName fExt];
    if isa(fName,'numeric') || isa(fPath,'numeric') ||...
                                            ~exist(fullfile(fPath,fName),'file')
        return
    end

    % Determines variables in MAT file and loads data
    [tf,evalStr] = validate_vars( who('-file',fullfile(fPath,fName)) );
    if any(tf)
        load(fullfile(fPath,fName));
        eval(evalStr);
        qtVer = 0;
        if isfield(s,'version') %#ok-s is defined by eval(evalStr)
            qtVer = s.version;
        end
    else
        return
    end

    % Validate data
    if qtVer < 5.03 %version cutoff. Before 5.1, inconsistent saves were used and
                  %are no longer supported
        warning(['qt_exam:' mfilename ':saveChk'],...
                ['%s is either an invalid or outdated save file. If the latter\n',...
                 'Please use the save converter provided in \\QUATTRO\\Core\n'],fName);
        errordlg([fName ' is not a QUATTRO save file.'],'Error', 'Modal');
        return
    elseif qtVer < qt_version('save')
        s = convert_old_save_format(s);
    end

    % Now that the save file has been validated, remove data fields for which no
    % further processing is required. Namely, these dta are not required
    % according to the DATATYPE input
    if ~strcmpi(dataType,'any')
        switch dataType
            case 'images'
                rmFields = {'rois','maps'};
            case 'maps'
                rmFields = {'imgs','hdrs','type','name','rois'};
            case 'rois'
                rmFields = {'imgs','hdrs','type','name','maps'};
        end
        for rmFld = rmFields
            if isfield(s,rmFld{1})
                s = rmfield(s,rmFld{1});
            end
        end
    end

    % Convert private fields
    %TODO: QUATTRO no longer supports the use of custom DICOM dictionaries...
    %Remove at a furutre time
    if isfield(s,'hdrs')
%         s.hdrs = cellfun(@convert_private_dicom_fields,s.hdrs,...
%                                                          'UniformOutput',false);
    end

    % Convert the cell/structure format of the Q-save to associated objects
    s = save2objs(s);

    % Removes the ROI field
    if ~any(strcmpi(dataType,{'rois','any'})) || ~isfield(s,'rois') ||...
                             all(cellfun(@(x) all(~x(:).validaterois),{s.rois}))
        s      = rmfield(s,'rois');
    end

    % Determine what to do with the loaded data: (1) store in the qt_exam object
    % or (2) return to the user
    if ~isempty(obj)

        % Expand the qt_exam object storage as necessary
        nNewExams = numel(s)-1;
        if nNewExams
            newObj = qt_exam.empty(nNewExams,0);

            % Copy the QUATTRO link for the new exam
            for exIdx = 1:nNewExams
                newObj(exIdx) = qt_exam(obj.hFig);
            end

            % Combine the array of objects
            obj = [obj newObj];
        end

        % Deal the data. Order is important in this circumstance because the
        % property listeners for the qt_exam object will only update the object
        % and any associated QUATTRO tools if fired in the appropriate manner
        flds = {'imgs','name','type','rois','maps'};
        for fld = flds
            if ~isfield(s,fld{1})
                continue
            end
            
            switch fld{1}
                case 'rois'
                    % Loop through each exam and add the ROIs to the appropriate
                    % object
                    for exIdx = 1:numel(obj)

                        mRoi = size(s(exIdx).rois);
                        if (numel(mRoi)<3)
                            mRoi(3) = 1;
                        end

                    for rIdx = 1:mRoi(1)
                    for slIdx = 1:mRoi(2)
                    for seIdx = 1:mRoi(3)

                        if ~s(exIdx).rois(rIdx,slIdx,seIdx).validaterois
                            continue
                        end
                        obj(exIdx).addroi(s(exIdx).rois(rIdx,slIdx,seIdx),...
                                          'slice', slIdx,...
                                          'series',seIdx);

                    end %series index loop
                    end %slice index loop
                    end %ROI index loop
                    end %exam index loop

                case 'maps'
                    % Loop through each exam and add the maps to the appropriate
                    % qt_exam object
                    for exIdx = 1:numel(obj)

                        mMaps = size(s(exIdx).maps);

                    for mapIdx = 1:mMaps(1)
                    for slIdx  = 1:mMaps(2)
                        obj(exIdx).addmap(s(exIdx).maps(mapIdx,slIdx),...
                                          s(exIdx).maps(mapIdx,slIdx).tag,...
                                          'slice',slIdx);
                    end %map indexed loop
                    end %slice indexed loop
                    end %exam index loop
                otherwise
                    [obj(:).(fld{1})] = deal(s(:).(fld{1}));
            end
        end

        % Update the load directory/file. Since only one instance of the options
        % exist (TODO: this will likely change in a future release), update the
        % first qt_exam object in the stack
        obj(1).opts.loadDir  = fPath;
        obj(1).opts.loadFile = fName;

        % Notify the new objects of the data
        notify(obj,'initializeExam');

        % For best programming practice, the qt_exam object should always be
        % returned. This is absolutely necessary if the number of exams in a
        % given file is greater than one because the array of objects will be
        % expanded and deleted on return if outputs are not requested
        if nargout
            varargout = {obj};
        end

    else %return data to the user
        varargout = {s,fName,fPath};
    end

end %qt_exam.load

%------------------------------------------------------------
function varargout = parse_inputs(varargin)

    % Initialize the default directory to dichotomize the static syntax and
    % qt_exam method syntax
    defaultDir = pwd;

    % When a qt_exam object has been passed as the first input, parse that
    % argument manually and remove from "varargin" so that a simpler version of
    % the input parser can be prepared. Also update the default directory using
    % the current options
    obj = qt_exam.empty(1,0);
    if strcmpi( class(varargin{1}),'qt_exam')
        obj         = varargin{1};
        varargin(1) = [];
        defaultDir  = obj.opts.loadDir;
    end

    % A special case that allows the user to specify "dataType" and use the
    % default load directory
    if ~isempty(varargin) && isempty(varargin{1})
        varargin{1} = defaultDir;
    end

    % Parser setup
    parser = inputParser;
    parser.addOptional('loadDir',defaultDir,@ischar);
    parser.addOptional('dataType','any',...
                         @(x) any( strcmpi(x,{'images','maps','rois','any'}) ));

    % Parser inputs
    parser.parse(varargin{:});
    results     = parser.Results;

    % Perform some additional input validation on the data type string and the
    % input directory
    results.dataType = validatestring(results.dataType,...
                                                {'images','maps','rois','any'});

    % Assign outputs
    varargout = [struct2cell(results);{obj}];

end %parse_inputs


%--------------------------------------
function s = convert_old_save_format(s)

    switch s.version
        case 5.03
            if isfield(s,'types')
                s.type = s.types;
                s      = rmfield(s,'types');
            end
            if isfield(s,'names')
                s.name = s.names;
                s      = rmfield(s,'names');
            end
            s.version = qt_version('save');
        otherwise
            warning(['qt_exam:' mfilename ':unsupportedVer'],...
                     '%3.2f is unsupported currently.\n',s.version);
    end

end %convert_old_save_format


%------------------------
function s = save2objs(s)

    % Replace the old naming convention
    if isfield(s,'names')
        s.name = deal(s(:).names);
        s      = rmfield(s,'names');
    end
    if isfield(s,'types')
        s.type = deal(s(:).types);
        s      = rmfield(s,'types');
    end

    % Clean up spurious data fields that are no longer used in the remainder of
    % the load processing
    for fld = fieldnames(s)'
        if ~any( strcmpi(fld{1},{'imgs','hdrs','rois','maps','name','type'}) )
            s = rmfield(s,fld{1});
        end
    end

    % Convert the images/headers to QT_IMAGE objects
    if all( isfield(s,{'imgs','hdrs'}) )

        % Loop through all stored exams
        for exIdx = 1:numel(s.imgs)

            % Create an empty array of qt_image objects
            mImgs  = size(s.imgs{exIdx});
            imObjs = qt_image.empty(prod(mImgs),0);

            % Loop through each image in the array, converting it from image and
            % the associated header to a qt_image object. Normally this would be
            % accomplished using cellfun, but cellfun does not currently support
            % "qt_image" output.
            for imIdx = 1:prod(mImgs)
                imObjs(imIdx) = qt_image(s.imgs{exIdx}{imIdx},...
                                         'metaData',s.hdrs{exIdx}(imIdx),...
                                         'format','dicom');
            end

            % Store the converted qt_image objects
            s.imgs{exIdx} = reshape(imObjs,mImgs);

        end

        % The "hdrs" field is no longer needed since the qt_image objects
        % contain that information
        s = rmfield(s,'hdrs');

    end %imgs

    % Convert the ROIs to qt_roi objects
    if isfield(s,'rois')

        % Loop through all stored exams
        for exIdx = 1:numel(s.rois)

            % Generate an empty array of qt_roi objects
            rois = qt_roi.empty(1,1,0);

            % Loop through each ROI in the array, converting the structure
            % information to a qt_roi object
            for rIdx = 1:numel(s.rois{exIdx})

                % Grab some ROI properties
                c        = s.rois{exIdx}(rIdx).coordinates;
                t        = s.rois{exIdx}(rIdx).types;
                roiName  = s.rois{exIdx}(rIdx).names;
                roiColor = s.rois{exIdx}(rIdx).colors;
                roiTag   = 'roi'; %default tag
                if isfield(s.rois{exIdx},'tags')
                    roiTag = s.rois{exIdx}(rIdx).tags;
                end

            for slIdx = 1:size(c,1)
            for seIdx = 1:size(c,2)

                % Load non-empty cells
                if ~isempty(t{slIdx,seIdx})

                    if (numel(s.rois{exIdx}(rIdx).types(slIdx,seIdx)) > 1)
                        warning(['qt_exam:' mfilename ':invalidRoiData'],...
                                ['Multiple ROIs were detected while loading',...
                                 'saved data for ROI number %u at slice %u ',...
                                 'and series %u. This is an old save format ',...
                                 'that is no longer supported.'],...
                                 rIdx,slIdx,seIdx);
                        continue
                    end

                    if iscell( c{slIdx,seIdx} )
                        rois(rIdx,slIdx,seIdx) = qt_roi(c{slIdx,seIdx}{1},...
                                                        t{slIdx,seIdx}{1},...
                                                        'name',roiName,...
                                                        'color',roiColor,...
                                                        'tag',roiTag);
                    else
                        rois(rIdx,slIdx,seIdx) = qt_roi(c{slIdx,seIdx},...
                                                        t{slIdx,seIdx},...
                                                        'name',roiName,...
                                                        'color',roiColor,...
                                                        'tag',roiTag);
                    end
                end

            end %series index
            end %slice index
            end %ROI index

            % Store the converted qt_roi objects
            s.rois{exIdx} = rois;

        end %Exam index

    end

    % Convert the maps to qt_image objects
    if isfield(s,'maps')

        % Loop through all stored exams
        for exIdx = 1:numel(s.maps)

            % Convert old save format
            if isstruct(s.maps{exIdx}) &&...
                                  any( ~isfield(s.maps{exIdx},{'imgs','hdrs'}) )

                % Determine which map fields are present
                flds  = fieldnames(s.maps{exIdx});
                flds  = flds( ~strcmpi('scale',flds) & ~strcmpi('names',flds) );
                nFlds = numel(flds);

                % Create the new storage array
                newMaps = struct('imgs',[],'hdrs',[]);
                newMaps = repmat(newMaps,nFlds,numel(s.maps{exIdx}));

                % Loop through each field and create the new data structure
                for fldIdx = 1:nFlds
                    [newMaps(fldIdx,:).imgs] =...
                                             deal(s.maps{exIdx}.(flds{fldIdx}));
                    [newMaps(fldIdx,:).hdrs] =...
                                       deal( struct('ImageType',flds{fldIdx},...
                                                    'Units','') );
                end

                % Store the new data structure
                s.maps{exIdx} = newMaps;

            end

            % Create an empty arrary of qt_image objects
            mMaps   = size(s.maps{exIdx});
            mapObjs = qt_image.empty(prod(mMaps),0);

            % Loop through each of the map locations
            for mIdx  = 1:prod(mMaps)

                % Temporarily store the new map (and meta-data)
                mapIm   = s.maps{exIdx}(mIdx).imgs;
                mapHdr  = s.maps{exIdx}(mIdx).hdrs;

                %TODO: this is temporary. I want a better means of parsing
                %parameter map objects when creating qt_image objects
                imType = textscan(mapHdr.ImageType,'%s','Delimiter','\\');

                % Create a qt_image object from the map information
                mapObjs(mIdx) = qt_image(mapIm,...
                                         'metaData',mapHdr,...
                                         'tag',lower(imType{1}{end}),...
                                         'units',mapHdr.Units);

            end %map index loop

            % Store the converted qt_image objects
            s.maps{exIdx} = reshape(mapObjs,mMaps);

        end

    end %maps

    % Finally, as a convenience, replace a scalar structure with fields
    % containing cells with a structure array containing scalar fields
    if (numel(s)==1) && any(isfield(s,{'rois','imgs','maps'}))

        if isfield(s,'rois')
            nEx = numel(s.rois);
        elseif isfield(s,'imgs')
            nEx = numel(s.imgs);
        elseif isfield(s,'maps')
            nEx = numel(s.maps);
        end

        % Initialize the structure that will supply the cells to be dealt at the
        % end of the array of structures "s". Then simply replace the fields,
        % starting from the beginning of the array, with the value of the cell
        s(nEx) = s;
        for sIdx = 1:nEx
            for fld = fieldnames(s)'
                s(sIdx).(fld{1}) = s(end).(fld{1}){sIdx};
            end
        end

    end

end %save2objs


%------------------------------------
function [tf,s] = validate_vars(vars)

    % Validate the file variables
    validStrs = {'image_data','save_data','roi_data'};
    tf        = cellfun(@(x) any(strcmp(x,vars)),validStrs);

    % Store the conversion string to evaluate
    s       = '';
    if any(tf)
        str = validStrs{tf};
        s   = sprintf('s=%s; clear %s',str,str);
    end

end %validate_vars