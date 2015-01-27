function varargout = importDICOM(varargin)
%IMPORTDICOM  Reads a directory of DICOM images with headers.
%
%   [imgs,hdrs,type] = IMPORTDICOM reads a directory containing DICOM
%   images or sub-directories of DICOM images from the same series,
%   specified by the user and returns the images and headers in addition to
%   the detected exam type. Images and headers are sorted as described
%   below and returned.
%
%   [...] = IMPORTDICOM(DIR) reads the DICOM images stored in DIR or the 
%   associated sub-directories. Alternatively, DIR can be a cell array
%   specifying full file names of all DICOM images to import. The images and
%   headers are sorted as described below and returned.
%
%   [...] = IMPORTDICOM(Param,ParamVal,...) allows the user to pass DICOM
%   header tags and values that are checked against the images being
%   loaded. Alternatively, the group and element can be passed in a single
%   string separated by a comma. This is helpful when reading 'dump'
%   directories that contain images from multiple series, for example.
%   Image headers with a value different than that specified are not
%   loaded; image headers missing the specified DICOM tag are not loaded
%   and a warning is generated. Multiple paramerters can be specified.
%
%   [...] = IMPORTDICOM(...,'Sort',tf) specifies the defualt sort again
%   (default: true). Images are sorted by instance number and are then
%   sorted by slice location. If a particular exam type (see below) is
%   detected, the images are sorted by the following parameter/header tag
%   (private tags are denoted with parentheses): 
%
%       MRI Exam Type        Header Tag
%       -----------------------------------
%       DCE                  InstanceNumber
%       DSC                  InstanceNumber
%       DWI                 (b-values)/(b-value direction)
%       eDWI                 see DWI
%       DTI                  see DWI
%       MFGRE                EchoTime/(TemporalPositionIdentifier)
%       MultiTI              InversionTime
%       MultiTE              EchoTime
%       MultiFlip            FlipAngle
%
%       CT Exam Type         Header Tag
%       -----------------------------------
%       GSI                 (energy)
%
%       PET Exam Type        Header Tag
%       -----------------------------------
%       
%   The image and header outputs will be an m-by-n matrix, where m is the
%   unique/sorted slice location index and n is the unique/sorted header
%   tag as specified above (e.g. EchoTime). In cases where multiple header
%   tags are used to sort the data (e.g. eDWI or MFGRE exams), then 3rd
%   dimension of the array is sorted according to the 2nd header tag as
%   specified above.
%
%   NOTE: When loading headers with inconsistent structures, care is taken
%   to preserve the authenticity of combined header data. However, due to
%   the header structure output, one consistent structure must be produced;
%   missing fields are null-filled to avoid 'creating' erroneous data.
%
%   Examples
%   ========
%
%       Example 1: load a directory of images without any sorting
%
%       [images headers] = importDICOM('sort',false);
%
%
%       Example 2: load directory containing DICOM images from a patient
%       with an MRN of "test". 
%
%       [images headers] = importDICOM('PatientID','test')
%
%
%       Example 3: load DICOM images, only importing images acquired with MRI
%
%       [images headers] = importDICOM( dicomlookup('0008','0060'), 'MR' );

%# AUTHOR    : Ryan Bosca
%# $DATE     : 21-Jan-2013 19:01:33 $
%# $Revision : 2.11 $
%# DEVELOPED : 7.14.0.739 (R2012a)
%# FILENAME  : importDICOM.m


% Initialize output
[varargout{1:3}] = deal([]);

% Parse inputs
[sDir,dicomTest,isSort] = parse_opts(varargin{:});

% Get load directory
if ~nargin
    sDir = uigetdir(sDir,...
                         'Select the folder containing all DICOM images.');
    if isnumeric( sDir ) || ~isdir( sDir )
        return
    end
end

% Imports header info for all images in the specified directory
headers = read_dicom_headers(sDir,dicomTest{:});
if isempty(headers)
    errordlg( 'No DICOM images were loaded.' );
    return
end

% Attempts to patch old header data formats
headers = patch_headers(headers);

% Trys to determine exam type
eType = findExamType(headers);

% Sorts header data/stores exam type
try
    headers = sort_headers(headers,eType);
catch ME
    nSlices = numel( unique( cell2mat( {headers.SliceLocation} ) ) );
    if mod(length(headers), nSlices)
        warning([mfilename ':incommensurateData'],'%s',...
                         'Data could not be sorted into slice locations.');
    end
end

% Loads all images
images = load_images( headers );

if strcmpi(headers(1).Manufacturer,'Philips Medical Systems')
    images = convert_philips(images, headers);
end

% Deal output
[varargout{:}] = deal(images,headers,eType);

end %importDICOM


% Reads the directory of DICOM headers
function hds = read_dicom_headers(sDir,varargin)

    % Initialize output
    hds = struct([]);

    % Deal test parameters
    isTest = ~isempty(varargin);
    if isTest
        [tags,vals] = deal(varargin(1:2:end),varargin(2:2:end));
    end

    % Generate file list
    if (iscell(sDir) && numel(sDir)==1) || ~iscell(sDir)
        fList = dir(sDir);

        % Determine if a multi-directory exam is being loaded. If so, load the
        % exam and forget about the remaining code
        if all( cell2mat({fList.isdir}) )
            hds = load_multi_dir(sDir,varargin{:});
            return
        end

        % Concatenate full file names into cell array
        fList( cell2mat({fList.isdir}) ) = []; %remove directories
        fList = {fList.name};
        fList = cellfun(@(x) fullfile(sDir,x),fList,'UniformOutput',false);
    else %case: user-specified full file names
        fList = sDir;
    end

    % Removes directories and initializes wait bar/loop variables
    m       = length(fList);
    isFixed = false; %flag specifying a corrected eDWI header
    hWait   = waitbar(0, '0% Complete', 'Name', 'Loading DICOM headers.');
    tagEdwi = dicomlookup('0043','107F');

    
    for idx = 1:m

        if ishandle(hWait)
            waitbar(idx/m ,hWait,[num2str( round(idx/m*100) ) '% complete']);
        else %user deleted wait bar
            hds = [];
            return
        end

        % Check DICOM compatability
        if ~isdicom(fList{idx})
            continue
        end

        % Read header
        hdr = dicominfo( fList{idx} );
        if isempty(hdr.Width) || isempty(hdr.Height) || isempty(hdr.BitDepth)
            continue
        end

        % This is a pain in the ass! EDWI requires the following code.
        if ~isFixed && isfield(hdr,tagEdwi) && idx~=1
            [hds.(tagEdwi)] = deal(0);
            isFixed = true;
            % Reoder fields
            hds = orderfields(hds,hdr);
        elseif isFixed && ~isfield(hdr,tagEdwi)
            hdr.(tagEdwi) = 0;
            hdr = orderfields(hdr,hds);
        end

        %Checks each image against the test condition if specified.
        skip = false;
        if isTest

            for j = 1:length(tags)

                % Ensure the tag is a valid field
                validTag = isfield(hdr,tags{j});
                if ~validTag
                    warning([mfilename ':invalidTestTag'],...
                            'Invalid tag: ''%s''\n No image discrimination %s',...
                                                 tags{j},'was performed.');
                    warning('off',[mfilename ':invalidTestTag']);
                    continue
                end

                % Ensure the object classes match
                c1 = class( hdr.(tags{j}) ); c2 = class( vals{j} );
                testVal = vals{j};
                if ~strcmpi(c1,c2)
                    switch c1
                        case {'single','double','logical','int8','int16',...
                              'uint8','uint16'}
                            if ischar(c2)
                                testVal = str2double(testVal); %#ok<*NASGU>
                                testVal = eval([c1 '(test_val);']);
                            else
                                testVal = eval([c1 '(test_val);']);
                            end
                        case 'char'
                            if isnumeric(testVal)
                                testVal = num2str( testVal );
                            end
                    end
                    if isnan(testVal) || isinf(testVal)
                        error([mfilename ':evalDICOMtest'],...
                                       'Unable to test DICOM tag/values.');
                    end
                end

                % Compares the header values against the test condition
                if ischar(c1)
                    skip = ~strcmpi( hdr.(tags{j}), testVal ) || skip;
                elseif isnumeric(c1)
                    skip = (hdr.(tags{j}) ~= testVal) || skip;
                else
                    skip = true;
                end
            end

        end
        if skip
            continue
        end

        % Stores the temporary header
        try
            if isempty(hds)
                hds = hdr;
            else
                hds(idx) = hdr;
            end
        catch ME
            valid_errs = {'MATLAB:heterogeneousStrucAssignment',...
                          'MATLAB:heterogenousStrucAssignment'};
            if any( strcmpi(ME.identifier,valid_errs) )
                hds = force_consistent_fields(hds,hdr);
            else
                throw(ME)
            end
        end
    end

    % Accounts for skipped files
    hds( cellfun(@isempty,{hds.Filename}) ) = [];

    % Deletes the waitbar
    delete(hWait)

    % Activates warning for next use
    warning('on',[mfilename ':invalidTestTag']);

end %read_dicom_headers


% Loads all images stored in the DICOM cell array headers
function images = load_images( headers )

    % Initialize the waitbar
    hProg    = waitbar( 0, '0% Complete', 'Name', 'Loading DICOM images.' );
    mHeaders = size(headers); headers = reshape(headers,1,[]);
    imcount  = numel(headers);

    % Initialize image variable
    images{size( headers,1 ),size( headers,2 )} = 0;

    for i = 1:length(headers)
        % Updates wait bar
        waitbar( i/imcount, hProg,...
                           [num2str( round(i/imcount*100)) '% Complete'] );

        % Loads DICOM images
        images{i} = dicomread( headers(i).Filename );
    end

    % Deletes the wait bar
    delete( hProg )

    % Reshape images
    images = reshape(images,mHeaders);

end % load_images


% Attempts to determine exam type
function eType = findExamType( headers )

    % Initialize output
    eType = 'Generic';

    % DICOM tag lookup
    tagModality = dicomlookup('0008','0060'); %Modality

    if strcmpi(headers(1).(tagModality),'CT')

        % CT specific tags
        tagGsi = dicomlookup('0053','1079'); %(GSI flag)

        if is_gsi
            eType = 'GSI';
        end

    elseif strcmpi(headers(1).(tagModality),'PT')

    elseif strcmpi(headers(1).(tagModality),'MR')

        % MR specific tags
        tagNumSlices  = dicomlookup('0021','104F'); %LocationsInAcquisition
        tagNumTimePts = dicomlookup('0025','1011'); %NumberofAcquisitions
        tagImgsInAcq  = dicomlookup('0020','1002'); %ImagesInAcquisition
        tagPulseSeq   = dicomlookup('0019','109C'); %PulseSeqName
        tagAcqType    = dicomlookup('0018','0023'); %MRAcquisitionType
        tagBVals      = dicomlookup('0043','1039'); %VasCollapseFlag (b-value,GE)
        tagEdwi       = dicomlookup('0043','107F'); %ReservedForFutureUse1 (b-value offset,GE)
        tagTiVals     = dicomlookup('0018','0082'); %InversionTime
        tagTrVals     = dicomlookup('0018','0080'); %RepetitionTime
        tagTeVals     = dicomlookup('0018','0081'); %EchoTime
        tagFlipVals   = dicomlookup('0018','1314'); %FlipAngle

        % Determines if multiple time points were acquired (i.e. DCE or DW)
        if is_dce
            eType = 'DCE';
        elseif is_dsc
            eType = 'DSC';
        elseif is_multiti
            eType = 'MultiTI';
        elseif is_multiflip
            eType = 'MultiFlip';
        elseif is_multitr
            eType = 'MultiTR';
        elseif is_multite
            eType = 'MultiTE';
        elseif is_dw
            if is_dti
                eType = 'DTI';
            elseif is_edwi
                eType = 'eDWI';
            else
                eType = 'DW';
            end
        end

    end

        function tf = is_dce

            % Initialize output
            tf = false;

            % Get field name from current DICOM dictionary
            if any( ~isfield(headers,{tagNumSlices,tagNumTimePts,...
                                      tagImgsInAcq}) )
                return
            end

            numSlices       = double( headers(1).(tagNumSlices)(1) );
            numTimePts      = double( headers(1).(tagNumTimePts)(1) );
            imagesInAcq     = headers(1).(tagImgsInAcq);
            
            multipleTimePts = numTimePts~=1 &&...
                              numel(headers)==imagesInAcq &&...
                              numSlices*numTimePts==imagesInAcq;
            tf              = multipleTimePts;

        end %is_dce

        function tf = is_dsc

            % Initialize output
            tf = false;

            % Get field names from current DICOM dictionary
            if any( ~isfield(headers,{tagPulseSeq,tagAcqType}) )
                return
            end

            isSeq = strcmpi(headers(1).(tagPulseSeq),'epi') ||...
                    strcmpi(headers(1).(tagPulseSeq),'efgre');
            is2d  = strcmpi(headers(1).(tagAcqType),'2d');
            tf    = isSeq && is2d;

        end %is_dsc

        function tf = is_dti

            % Calculates b-values and gradient directions
            [bVals,dirs] = calc_diffusion(headers);

            tf = ~isempty(bVals) && any(bVals > 0) &&...
                                    length( unique(ceil(dirs),'rows') ) > 5;

        end %is_dti

        function tf = is_dw
            % Initialize output
            tf = false;

            % Setup is_dw
            headers = reshape(headers,[],1);

            % Get field name from current DICOM dictionary
            if ~isfield(headers,tagBVals)
                return
            end

            % Calculates b-values and gradient directions
            [bVals,dirs] = calc_diffusion(headers);

            tf = ~isempty(bVals) && any(bVals > 0) &&...
                                    length( unique(ceil(dirs),'rows') ) > 1;

        end %is_dw

        function tf = is_edwi
            tf = (isfield(headers,tagEdwi) &&...
                               strcmpi(headers(1).(tagPulseSeq),'epi2'));
        end %is_edwi

        function tf = is_multiti
            % Initialize output
            tf = false;

            % Get field name from current DICOM dictionary
            if ~isfield(headers,tagTiVals)
                return
            end

            % Setup is_multiti
            headers = reshape(headers,[],1);

            % Determine number of TIs
            tf = unique_field_vals(headers,tagTiVals) > 1;

        end %is_multiti

        function tf = is_multitr
            % Initialize output
            tf = false;

            % Get field name from current DICOM dictionary
            if ~isfield(headers,tagTrVals)
                return
            end

            % Setup is_multitr
            headers = reshape(headers,[],1);

            % Determine number of TRs
            tf = unique_field_vals(headers,tagTrVals) > 1;

        end %is_multitr

        function tf = is_multite
            % Initialize output
            tf = false;

            % Get field name from current DICOM dictionary
            if ~isfield(headers,tagTeVals)
                return
            end

            % Setup is_multite
            headers = reshape(headers,[],1);

            % Determine number of TEs
            tf = unique_field_vals(headers,tagTeVals) > 1;

        end %is_multite

        function tf = is_multiflip
            % Initialize output
            tf = false;

            % Get field name from current DICOM dictionary
           if ~isfield(headers,tagFlipVals)
                return
            end

            % Setup is_multiflip
            headers = reshape(headers,[],1);

            % Determine if there are multiple flip angles
            tf = unique_field_vals(headers,tagFlipVals) > 1;

        end %is_multiflip

        function tf = is_gsi
            % Initialize output
            tf = false;

            % Get field name from current DICOM dictionary
            if ~isfield(headers,tagGsi)
                return
            end

            % Determine if is GSI data
            tf = strcmpi(headers(1).(tagGsi),'GSI');

        end %is_gsi
            
end %findExamType


% Forces two structures into a structure array
function st = force_consistent_fields(st1,st2,repTag)

    if ~exist('rep_tag','var') || isempty(repTag) || strcmpi(repTag,'replace')
        repTag = 'fill';
    end

    newFlds = fieldnames(st2); old_flds = fieldnames(st1);
    if any(~isfield(st1,newFlds)) %st2 has fields not in st1
        fInd    = ~isfield(st1,newFlds);
        newFlds = newFlds(fInd);
        if strcmpi(repTag,'fill')
            for i = 1:length(newFlds)
                for j = 1:length(st1)
                    if ischar(st2.(newFlds{i}))
                        st1(j).(newFlds{i}) = '';
                    else
                        st1(j).(newFlds{i}) = [];
                    end
                end
            end
        else
            for i = 1:length(newFlds)
                for j = 1:length(st1)
                    st1(j).(newFlds{i}) = st2.(newFlds{i});
                end
            end
        end
    elseif any(~isfield(st2,old_flds)) %st1 has fields not in st2
        newFlds = old_flds;
        fInd    = ~isfield(st2,newFlds);
        newFlds = newFlds(fInd);
        for i = 1:length(newFlds)
            st2.(newFlds{i}) = st1(1).(newFlds{i});
        end
    end

    % Combines the headers
    st2 = orderfields(st2,st1); st = [st1 st2];

end %force_consistent_fields


% Load multiple-directory exam
function hds = load_multi_dir(sDir,varargin)

    % Store only sub-directories
    dInfo = dir(sDir);
    dInfo( strcmpi('.',{dInfo.name}) || strcmpi('..',{dInfo.name}) ) = [];
    dInfo( ~cell2mat({dInfo.isdir}) )                                = [];

    % Loads all data from all directories
    hdCell = cell(length(dInfo),1);
    for i = 1:length(dInfo)
        newPath = [sDir filesep dInfo(i).name filesep];
        hdCell{i} = read_dicom_headers(newPath,varargin{:});
    end

    % Convert to a single structure
    try
        hds = cell2mat(hdCell); hds = hds(:);
    catch ME
        switch ME.identifier
            case 'MATLAB:cell2mat:InconsistentFieldNames'
                hds = hdCell{1};
                for i = 2:length(hdCell)
                    for j = 1:length(hdCell{i})
                        hds = force_consistent_fields(hds,hdCell{i}(j));
                    end
                end
            case {'MATLAB:catenate:dimensionsMismatch','MATLAB:catenate:dimensionMismatch'}
                hdCell = cellfun(@(x) x(:),hdCell,'UniformOutput',false);
                hds    = cell2mat(hdCell); hds = hds(:);
            otherwise
                hds = [];
        end
    end

end %load_mutli_dir


% Patches old DIOCM header formats
function hds = patch_headers(hds)

    if ~isfield(hds,'Manufacturer') || strcmpi(hds(1).Manufacturer,'GE')
        return
    end

    % Patch for old GE DICOM header formats
    tag = {dicomlookup('0019','109C'), @isnumeric,      @(x) reshape(char(x),1,[]);...
           dicomlookup('0043','1030'), @(x) numel(x)>1, @rm_zeros;...
           dicomlookup('0021','104F'), @(x) numel(x)>1, @rm_zeros;...
           dicomlookup('0025','1011'), @(x) numel(x)>1, @rm_zeros;...
           dicomlookup('0008','0033'), @ischar,         @str2double};

    % Check all header info formats defined above
    for i = 1:size(tag,1)
        if ~isfield(hds,tag{i,1})
            continue
        end

        hdrX = {hds(:).(tag{i,1})};
        if any( cellfun(tag{i,2},hdrX) )
            hdrX = cellfun(tag{i,3},hdrX,'UniformOutput',false);
            [hds.(tag{i,1})] = deal(hdrX{:});
        end
    end

    function x = rm_zeros(x)
        x(x==0) = [];
    end %rm_zeros

end %patch_headers


% Signal intensity data conversion for Philips' images
function im = convert_philips(im,h)

    % Get necessary DICOM tags
    tagSclInt  = dicomlookup('2005','100D');
    tagSclSlp  = dicomlookup('2005','100E');
    tagRsclInt = dicomlookup('0028','1052');
    tagRsclSlp = dicomlookup('0028','1053');
    if any( ~isfield(h,{tagSclInt,tagSclSlp,tagRsclInt,tagRsclSlp}) )
        return
    end
    im           = cellfun(@double,im, 'UniformOutput',false);
    for slIdx = 1:size(im,1)
        for seIdx = 1:size(im,2)
            im{slIdx,seIdx} = (im{slIdx,seIdx}-h(slIdx,seIdx).(tagSclInt))/...
                                                     h(slIdx,seIdx).(tagSclSlp);
        end
    end

end


% Parse inputs
function varargout = parse_opts(varargin)

    % Initialize deafualts/output
    [varargout{1:nargout}] = deal(pwd,{},true);

    % Determine if a directory was specified
    if nargin && mod(nargin,2) &&...
                       ((~iscell(varargin{1}) && exist(varargin{1},'dir')) ||...
                               all( cellfun(@(x) exist(x,'file'),varargin{1}) ))
        varargout{1} = varargin{1}; varargin(1) = [];
    end
    if nargin<2 %no need to parse any other inputs
        return
    end

    % Determine if the sort option was specified
    sortInd = strcmpi('sort',varargin);
    if any(sortInd) && sum(sortInd)==1
        varargin(sortInd) = [];
        varargout{3} = logical(varargin{sortInd});
        varargin(sortInd) = [];
    elseif any(sortInd)
        error([mfilename ':sortOptChk'],'Invalid syntax');
    end

    % Parse DICOM test objects
    [tags,vals] = deal(varargin(1:2:end),varargin(2:2:end));
    for i = length(tags):-1:1 % replace group/element with tag name and check tags
        isValid = true;
        if any( strfind(tags{i},',') )
            [g,el] = sscanf(tags{i},'%s,%s');
            tags{i} = dicomlookup(g,el);
            isValid = ~isempty(tags{i});
        else
            [g,el] = dicomlookup(tags{i});
            isValid = (~isempty(g) && isempty(el));
        end
        if ~isValid
            warning([mfilename ':invalidTestTag'],...
                    'Invalid DICOM tag: ''%s''\nNo header data will %s',...
                                                    tags{i},'be checked.');
            tags(i) = []; vals(i) = [];
        end
    end
    varargout{2} = [tags,vals{:}];
end