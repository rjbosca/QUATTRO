function metaData_postset(obj,~,~)
%metaData_postset  Post-set event for the IMAGEBASE property "metaData"
%
%   metaData_postset(SRC,EVENT) performs various validations and computations to
%   prepare the associated qt_image object for display and the imaging pipeline
%   following changes to the "metaData" qt_image property specified by the
%   source object, SRC, and event data object, EVENT.
%
%   All computations performed herein should be minimal in nature, i.e., setting
%   properties or calculating, for example, the window width and window level.
%   More importantly, calling methods or changing properties that require image
%   data (such as the "addfilter" method) should be avoided as this will waste
%   load when the memory saver mode is activated

    % **WARNING** There seems to be a strange quark that causes MATLAB to crash
    % if an external function (i.e. an m-file) is passed to the "addfilter"
    % method as a function handle. Instead those type of filters (such as
    % dicom2map) should be added after this Pos-Set event.


    % Perform heuristic processing of the format specific meta-data. Since these
    % classes were designed primarily for processing DICOM images, meta-data
    % should, where possible, conform to the tags used in DICOM images
    switch obj.format
        case 'dicom'
            mData = process_dicom_meta_data(obj,obj.metaData);
        otherwise
    end

    % Update the "metaData" property
    if obj.isvalid
        obj.metaData = mData;
    end

end %qt_image.metaData_postset


%--------------------------------------------------
function mData = process_dicom_meta_data(obj,mData)

    % Before going on, check to see if this DICOM meta-data has any associated
    % image data, deleting the object if no real image data exists
    if isfield(mData,'Width') && isempty(mData.Width)
        warning(['qt_image:' mfilename ':invalidImageFile'],...
                'Unable to load image data from "%s". Skipping file...',...
                                                                  obj.fileName);
        obj.delete;
        return
    end

    % Validate/convert a DICOM tag used frequently for DCE temporal positions.
    % In my experience, this specific tag can take numeric or character data,
    % but should be represented by a number - that is checked here
    acqTimeTag = dicomlookup('0008','0032');
    if isfield(mData,acqTimeTag) && ischar(mData.(acqTimeTag))

        % Attempt to convert to a number
        numVal = str2double( mData.(acqTimeTag) );
        if ~isnan(numVal) %successful conversion - store the data
            mData.(acqTimeTag) = numVal;
        end

    end

    % Validate/convert a DICOM tag used frequently for reporting the RAS
    % coordinate position. Similar to the DCE temporal position, this tag can
    % hold numeric or character data. The former is usually associated with some
    % third party DICOM write utilite (e.g., MATLAB)
    rasTag = dicomlookup('2001','108b');
    if isfield(mData,rasTag) && ~ischar(mData.(rasTag))

        % Remove NULL characters (i.e., 0's)
        numVal = mData.(rasTag)(:)';
        numVal = char( numVal( logical(numVal) ) );

        % Update the value to a string
        if (numel(numVal)==1)
            mData.(rasTag) = numVal;
        end

    end

    % Validate/convert a DICOM tag used frequently for reporting the number of
    % locations in a 3D MR slab. Similar to the RAS tag above, this tag can be a
    % vector with numerous NULL elements, which is usually the result of some
    % third party DICOM write utilite (e.g., MATLAB)
    nLocTag = dicomlookup('2001','1018');
    if isfield(mData,nLocTag) && (numel(mData.(nLocTag))>1)

        % Remove NULL values (i.e., 0's)
        val = mData.(nLocTag);
        val = val( logical(val) );

        % Update the value to a scalar
        if (numel(val)==1)
            mData.(nLocTag) = val;
        end

    end

    % Validate/convert a DICOM tag used frequently for reporting the matrix size
    % in MR imaging exams.
    nFreqTag  = dicomlookup('0027','1060');
    nPhaseTag = dicomlookup('0027','1061');
    if isfield(mData,nFreqTag) && (numel(mData.(nFreqTag))>1)

        % Convert from the default write type of an 8-bit unsigned integer to a
        % single floating point number
        mData.(nFreqTag) = typecast( uint8(mData.(nFreqTag)), 'single' );

    end
    if isfield(mData,nPhaseTag) && (numel(mData.(nPhaseTag))>1)

        % Convert from the default write type of an 8-bit unsigned integer to a
        % single floating point number
        mData.(nPhaseTag) = typecast( uint8(mData.(nPhaseTag)), 'single' );

    end

    % Validate/convert a DICOM tag used by Siemens to store the FOV size
    fovTag = dicomlookup('0051','100c');
    if isfield(mData,fovTag) && ~ischar(mData.(fovTag))

        % Convert for the numeric input to a string
        fovStr = char( mData.(fovTag)(:)' );
        if ~isempty( strfind(fovStr,'FoV') )
            mData.(fovTag) = fovStr;
        end

    end

    % Determine the image size from the meta-data fields "Rows" and "Columns".
    % If this operation fails (or the fields do not exist), then the image data
    % are read and those values are updated in the meta-data
    %FIXME: this only works for 2-D images. Maybe make "metaData" an abstract
    %property...
    %Update - N-D images do not currently access/write the "metaData"
    %property...
    if isfield(mData,'Rows')
        obj.dimSize(1) = mData.Rows;
    end
    if isfield(mData,'Columns')
        obj.dimSize(2) = mData.Columns;
    end

    % Apply the pixel spacing
    if isfield(mData,'PixelSpacing')
        obj.elementSpacing = mData.PixelSpacing;
    elseif ~isempty(obj.fileName)
        warning(['imagebase:' mfilename ':unknownElementSpacing'],...
                ['Unable to determine the element spacing from the DICOM ',...
                 'meta-data.']);
    end

    % Determine the smallest/largest image values
    if isfield(mData,'SmallestImagePixelValue')
        obj.elementMin = mData.SmallestImagePixelValue;
    end
    if isfield(mData,'LargestImagePixelValue')
        obj.elementMax = mData.LargestImagePixelValue;
    end

    % Create the physical coordinate transformation matrix (for details of the
    % DICOM transformation, see nipy.org/nibabel/dicom/dicom_orientation.html)
    if isfield(mData,'ImagePositionPatient')
        obj.coorTrafo(1:3,end) = mData.ImagePositionPatient;
    end
    if all( isfield(mData,{'ImageOrientationPatient','PixelSpacing'}) )
        obj.coorTrafo(1:3,1) =...
                       mData.ImageOrientationPatient(1:3)*mData.PixelSpacing(1);
        obj.coorTrafo(1:3,2) =...
                       mData.ImageOrientationPatient(4:6)*mData.PixelSpacing(2);
    end     

end %process_dicom_meta_data