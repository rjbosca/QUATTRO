function varargout = import(varargin)
%import  Import image supported by QT_EXAM
%
%   [S,PATHNAME] = import provides UI tools allowing the user to select and
%   import a directory of DICOM images as a QT_EXAM structure. A structure
%   containing an array of qt_image objects is returned in addition to the
%   detected exam type string and the validated path from which the data were
%   loaded.
%
%   [...] = import(NAME) imports all detectable images as described previously,
%   appending the exam name, NAME, to the output structure S.
%
%   [...] = import(NAME,DIR) imports all image data from the directory specified
%   by the input DIR.
%
%   OBJ = import(OBJ,...) performs the same operations as defined previously,
%   but updates the QT_EXAM object (OBJ) properties with the imported image data
%   in lieu of returning a structure. No output is generated when this method is
%   called with a valid QT_EXAM object.
%
% 
%   SEARCHING DIRECTORIES FOR IMAGES:
%   =================================
%   "import" searches for images in one of two ways when attempting to load
%   image data. Either (1) images stored in the user-specified directory are
%   loaded or (2) the specified directory contains only other directories in
%   which case each sub-directory will be searched for images (but not further
%   nested directories).
%
%   The latter search method allows for easy import of serial data acquisitions,
%   but the directories must each contain the same number of images otherwise an
%   error will occur.
%
%   See also addexam

    %---------------
    % Input parsing
    %---------------

    % Initialize the output since there are multiple exit points
    if nargout
        [varargout{1:nargout}] = deal([]);
    end

    % Parse the inputs
    [obj,name,pathName,guiDlgs] = parse_inputs(varargin{:}); %parse inputs
    if isempty(name) || isempty(pathName)
        %TODO: there has to be a way to determine if the inputs to this function
        %(i.e., NAME and DIR) were accidentally reveresed. If so, let the user
        %know. This has been a constant struggle for me...
        return
    end
    if ~isempty(obj)
        varargout{1} = obj;
    end

    %------------------------------------
    % Data import and initial validation
    %------------------------------------

    % Import exam data
    img = qt_image(pathName,'guiDialogs',guiDlgs);
    if isempty(img)
        return
    elseif (numel(img)==1) && isempty(img.fileName)
        warning(['qt_exam:' mfilename ':noImgsImported'],...
                ['No images were imported. Likely cause: nested ',...
                 'sub-directories. Try dumping all image files into a ',...
                 'single directory.']);
        return
    end

    % Sort by image type and determine if all qt_image objects share the same
    % "format" value 
    [nType,imgType] = unique_vals(img,'format');
    if (nType>1)
        %TODO: write code to handle multiple image types
        warning(['qt_exam:' mfilename ':multiImgChk'],...
                ['Multiple image types were detected. Terminating ',...
                 'import operation...']);
        return
    end

    % At this point, attempt to merge the headers so that conformity is ensured
    % between the images' meta-data. The image type is irrelevant
    try
        hdrs = reshape( cell2mat({img.metaData}), size(img) );
    catch ME
        % Validate that the error is known
        if ~strcmpi(ME.identifier,'MATLAB:cell2mat:InconsistentFieldNames')
            rethrow(ME)
        end

        % Knowing that the error is from inconsistent field names, go through
        % image by image and create consistent fields
        hdrs = img(1).metaData;
        for imIdx = 2:numel(img)
            hdrs = combine_structs(hdrs,img(imIdx).metaData,'fill');
        end

        % Now that the meta-data structures are consistent between the images,
        % update the actual data to reflect the changes
        for imIdx = 1:numel(img)
            img(imIdx).metaData = hdrs(imIdx);
        end
    end
    
    % Some DICOM processing
    mfgTag = dicomlookup('0008','0070');
    if strcmpi(imgType{1},'dicom') && isfield(hdrs,mfgTag)

        % Verify the manufacturer since tags used by find_exam_type are
        % manufacturer dependent
        nMfg = unique_vals(hdrs,mfgTag);
        if (nMfg>1)
            %TODO: write code to handle multiple manufacturers
            warning(['qt_exam:' mfilename ':multiImgChk'],...
                    ['Multiple manufacturers were detected. Terminating ',...
                     'import operation...']);
            return
        end

        % Determine the exam type(s)
        eType = get_exam_type(img);

    end

    %TODO: it would be nice to verify if multiple exams and or series exists.
    %The current code assumes that the user has specified a folder with a single
    %series in it.

    % Split exams
    % if m(3)>1
    %     img_cell = cell(1,m(3));
    %     for i = 1:m(3)
    %         img_cell{i} = squeeze(s.imgs(:,:,i));
    %     end
    %     s.name = get_multi_exam_list(s.hdrs(1,1,:),s.type);  % Store exam names
    %     s.imgs = img_cell;                                   % Store images/headers
    %     [t{1:m(3)}] = deal(s.types); s.types = t;            % Store exam types
    % end

    % Determine output format
    if exist('obj','var') %method called with a QT_EXAM object; store the data
        obj.imgs           = img;
        obj.type           = eType; %implicitly notifies "initializeExam" event
        obj.name           = name;
        if iscell(pathName)
            obj.opts.importDir = pathName{1};
        else
            obj.opts.importDir = pathName;
        end

        % Deal the output
        varargout{1} = obj;

    else
        s = struct('imgs',img,'type',{eType});

        % Store exam name
        if ~isempty(name)
            s.name = name;
        elseif ~isfield(s,'name')
            s.name = s.type;
        end

        % Deal the outputs
        if nargout
            varargout{1} = s;
        end
        if nargout>1
            varargout{2} = pathName;
        end
    end

end %import


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Initialize the outputs. This allows the parse_inputs function to return
    % before parsing in the event that the user cancels the directory selection
    [varargout{1:nargout}] = deal([]);

    % Perform the initial setup on the QT_EXAM object. Since IMPORT is a static
    % QT_EXAM method, an object is not guaranteed to be an input. Simply append
    % an empty to the first input slot to facilitate the parsing operation
    if ~strcmpi( class(varargin{1}), 'qt_exam' )
        varargin = [{qt_exam.empty(1,0)} varargin];
    end

    % Parser setup with only the 
    parser = inputParser;
    parser.addOptional('examObj',qt_exam.empty(1,0));
    parser.addOptional('name','New Exam',@ischar);
    parser.addOptional('path',pwd,@(x) exist(x,'dir'));

    parser.parse(varargin{:}); %parse the inputs
    results = parser.Results;

    % When using the "import" method with a valid QT_EXAM object, the qt_options
    % "importDir" property is used to remember the last location of import and
    % will be used if the user does not otherwise specify, as an optional input
    % argument, the directory from which to import images.
    if ~isempty(results.examObj) && (nargin<3)
        [newDir,ok] = qt_uigetdir(results.examObj.opts.importDir,...
                                               'Select directory of images...');
        if ~ok
            return
        end
        results.path = newDir;
    end

    %TODO: this is only temporary...
    fInfo  = dir(results.path);
    fNames = arrayfun(@(x) fullfile(results.path,x.name),fInfo,...
                                                         'UniformOutput',false);
    isDir  = [fInfo.isdir]';
    isImg  = cellfun(@(x,y) ~x && isimage(y),num2cell(isDir),fNames);
    isNest = isDir | ~isImg;
    if all(isNest)
        fInfo        = {fInfo(isDir).name};
        fInfo        = fInfo( ~strcmpi('.',fInfo) & ~strcmpi('..',fInfo) );
        results.path = cellfun(@(x) fullfile(results.path,x),fInfo,...
                                                         'UniformOutput',false);
    end

    % Store outputs
    varargout = struct2cell(results);

    % Because there is a possiblity of returning an empty exam object, for which
    % there is no "guiDialogs" property, the value of that field is instead
    % determined here and returned as an additional output
    varargout{end+1} = isempty(results.examObj) || results.examObj.guiDialogs;

end %parse_inputs

%----------------------------------
function eType = get_exam_type(img)
%get_exam_type  Attempts to determine exam type

    % Initialize the exam type and concatenate the meta-data into a single array
    % of structures for ease of access
    eType = 'generic';
    hdrs  = [img(:).metaData];
    nImgs = numel(hdrs);

    % Generic DICOM tag lookup
    tagModality = dicomlookup('0008','0060'); %Modality
    tagInstance = dicomlookup('0020','0013'); %InstanceNumber
    tagSliceLoc = dicomlookup('0020','1041'); %SliceLocation

    % The number of slices and slice location are necessary in a number of
    % nested functions and in the code that follows
    [nSlices,sliceLocs] = unique_vals(hdrs,tagSliceLoc);

    % Helper function for validating
    isValidFld = @(fld) isfield(hdrs,fld);

    % Perform the work
    if strcmpi(hdrs(1).(tagModality),'CT')

        % CT specific tags
%         tagSliceLoc = dicomlookup('0020','0032'); %ImagePositionPatient
        tagGsi      = dicomlookup('0053','1079'); %(GSI flag)
        tagKvp      = dicomlookup('0053','1075'); %Private_0053_1075 (seems to correspond
                                                  %to KVp on GE scanners)

        % Determine exam type and sort by exam specific field
        if is_gsi
            eType = 'GSI';
            img = img.sort(tagKvp);
        end

    elseif strcmpi(hdrs(1).(tagModality),'PT')

        % PET specific tags
        tagSliceLoc = dicomlookup('0020','0032'); %ImagePositionPatient

    elseif strcmpi(hdrs(1).(tagModality),'MR')

        % MR specific tags
        tagAcqTime    = dicomlookup('0008','0032'); %AcquisitionTime
        tagTeValues   = dicomlookup('0018','0081'); %EchoTime
        tagFlipValues = dicomlookup('0018','1314'); %FlipAngle
        tagTiValues   = dicomlookup('0018','0082'); %InversionTime
        tagAcqType    = dicomlookup('0018','0023'); %MRAcquisitionType
        tagEdwiDir    = dicomlookup('0043','1030'); %Private_0043_1030 (eDWI direction tag)
        tagPulseSeq   = dicomlookup('0019','109C'); %PulseSeqName
        tagTrValues   = dicomlookup('0018','0080'); %RepetitionTime
        tagEdwi       = dicomlookup('0043','107F'); %ReservedForFutureUse1 (b-value offset,GE)
        tagTrigger    = dicomlookup('0018','1060'); %TriggerTime (GE)
        tagBValues    = dicomlookup('0043','1039'); %VasCollapseFlag (b-value,GE)

        % Determines if multiple time points were acquired (i.e. DCE or DW)
        if is_multiti
            eType = 'multiti';
        elseif is_multiflip
            eType = 'multiflip';
        elseif is_multitr
            eType = 'multitr';
        elseif is_multite
            eType = 'multite';
        elseif is_dw
            % Special sorting for diffusion exams. use vectors and b-values
            [b,g] = calc_diffusion(hdrs);

            % Sort according to the direction (abs forces b=0 to be the first
            % image of the series)
            if size( unique(g,'rows'),1 )>1
                [~,idx] = sortrows( abs(g) );
            else
                [~,idx] = sort(b);
            end
            img = img(idx);

            if is_dti
                eType = 'dti';
            elseif is_edwi
                eType = 'edwi';

                % Special sorting from eDWI
                img = img.sort(tagEdwiDir);
                n = unique_vals(hdrs,tagEdwiDir); %number of eDWI directions
                if any( cellfun(@(x) x.(tagEdwiDir)==14,hdrs) ) %14 means T2 image
                    n = n-1; %T2 image was dected as diffusion direction. Remove
                    img = prepare_edwi_w_t2(img,tagEdwiDir,n);
                end
            else
                eType = 'dw';
            end
        elseif is_dce
            eType = 'dce';
        elseif is_dsc
            eType = 'dsc';
            img   = img.sort(tagInstance);
        else
            img = img.sort(tagInstance);
        end

    end


    %------------------------
    % Reformat qt_image array
    %------------------------

    % Determine if the array of qt_image can be arranged (based on the number of
    % images and slice locations) by reshaping the array of qt_image objects or
    % if missing data must be "zero-filled"
    if mod(nImgs,nSlices) %missing images if non-zero
    else
        img     = reshape(img,nSlices,[]);
        img     = img.sort(tagSliceLoc);
    end


    %------------------------- Exam type test functions ------------------------

        function tf = is_dce

            % Initialize output
            tf = false;

            % These are the two tags used commonly on GE scanners to specify the
            % time in the DCE series
            [numTrigger,numAcqTimes] = deal(0);
            if isValidFld(tagTrigger)
                numTrigger  = unique_vals(hdrs,tagTrigger);
            end
            if isValidFld(tagAcqTime)
                numAcqTimes = unique_vals(hdrs,tagAcqTime);
            end

            % Determine if either of the time position DICOM tags contain the
            % right number of elements
            isMultipleTimePts = max([numTrigger numAcqTimes])>1 &&...
                                    (nImgs==(nSlices*numTrigger) ||...
                                     nImgs==(nSlices*numAcqTimes));
            if isMultipleTimePts
                tf = true;
            end

        end %is_dce

        function tf = is_dsc

            % Initialize output
            tf = false;

            % Get field names from current DICOM dictionary
            if any(isValidFld(tagPulseSeq) | isValidFld(tagAcqType))
                return
            end

            isSeq = strcmpi(hdrs(1).(tagPulseSeq),'epi') ||...
                    strcmpi(hdrs(1).(tagPulseSeq),'efgre');
            is2d  = strcmpi(hdrs(1).(tagAcqType),'2d');
            if isSeq && is2d
                tf = true;
            end

        end %is_dsc

        function tf = is_dw

            % Initialize output
            tf = false;

            % Get field name from current DICOM dictionary
            if any( isValidFld(tagBValues) )
                return
            end

            % Calculates b-values and gradient directions
            [bVals, dirs] = calc_diffusion(hdrs(:));

            if any(bVals > 0) && length( unique(ceil(dirs),'rows') ) < 6
                tf = true;
            end

        end %is_dw

        function tf = is_edwi

            tf = (any(isValidFld(tagEdwi)) &&...
                               strcmpi(hdrs(1).(tagPulseSeq),'epi2'));
        end %is_edwi

        function tf = is_multiti

            tf = any(isValidFld(tagTiValues)) &&...
                                         (unique_vals(hdrs(:),tagTiValues) > 1);

        end %is_multiti

        function tf = is_multitr

            tf = isfield(hdrs,tagTrValues) &&...
                                         (unique_vals(hdrs(:),tagTrValues) > 1);

        end %is_multitr

        function tf = is_multite

            tf = any(isValidFld(tagTeValues)) &&...
                                           (unique_vals(hdrs(:),tagTeValues)>1);

        end %is_multite

        function tf = is_multiflip

            tf = any(isValidFld(tagFlipValues)) &&...
                    (unique_vals(hdrs(:),tagFlipValues) > 1);

        end %is_multiflip

        function tf = is_gsi

            tf = any(isValidFld(tagGsi)) && strcmpi(hdrs(1).(tagGsi),'GSI');

        end %is_gsi

        function tf = is_dti

            % Calculates b-values and gradient directions
            [bVals,dirs] = calc_diffusion(hdrs);

            tf = any(bVals > 0) && (length( unique(ceil(dirs),'rows') ) > 5);

        end %is_dti
            
end %get_exam_type

%----------------------------------------
function [n,vals] = unique_vals(hdrs,fld)
%unique_vals  Determines unique field values of header cell

    % Store all the values in the field
    vals = {hdrs.(fld)};
    if ~ischar(vals{1})
        vals = cell2mat(vals);
    end

    % Get the number of unique values
    vals = unique(vals);
    n    = numel(vals);

end %unique_vals

%--------------------------------------------
function imgs = prepare_edwi_w_t2(imgs,fld,n)
%prepare_edwi_w_t2  Prepares eDWI headers with a T2 image

    % Grab the headers from the image object
    hds = [imgs.metaData];

    % Store the T2 stack
    t2 = hds([hds.(fld)]==14);
    hds([hds.(fld)]==14) = [];

    % Determines the number of T2 images
    m = length(t2);

    % Determines the unique directions
    dirVal             = unique([hds.(fld)]);
    dirVal(dirVal==14) = [];

    % Replicates the T2 stack for each acquired direction
    t2 = repmat(t2,n,1);

    % Replaces the T2 tag with a directional tag
    for i = 1:n
        [t2((i-1)*m+1:i*m).(fld)] = deal(dirVal(i));
    end

    % Combines all headers
    hds = [hds; t2];

    % Resorts the header information
    hds = sortFields(hds,'SliceLocation',1);
    if unique_field_vals(hds,'AcquisitionTime') > 1
        hds = sortFields(hds,'AcquisitionTime',1);
    end
    hds = sortFields(hds,'MultiB',1);
    hds = sortFields(hds,fld,1); %#ok
    error('qt_exam:import:badProgramming',...
                                   'Did you really think you''d get this far?');
    
end %prepare_edwi_w_t2