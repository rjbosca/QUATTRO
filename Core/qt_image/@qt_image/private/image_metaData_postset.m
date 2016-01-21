function image_metaData_postset(obj,~,~)
%image_metaData_postset
%
%   image_metaData_postset(OBJ,SRC,EVENT)

    %TODO: there is currently a need to verify that the "ww" and "wl" properties
    %have been set (i.e., are not using the default values). The issue arises
    %now becuase there are non-empty default values for these properties set in
    %the qt_image class. Previously, to initialize those properties a check for
    %an empty value was performed, in which case the meta-data was used to
    %update the properties (or the image values). Those checks were removed to
    %properly initialize the values when image data were read. However, if an
    %image object is created from image data (not loaded from a file), then the
    %already initialized values will be overwritten if meta-data are created
    %with the fields that are checked for (see the code below). Maybe create a
    %"isInitialized" property for those fields...

    % Grab the meta-data
    mData = obj.metaData;

    % Check on the window width
    if isfield(mData,'WindowWidth')
        obj.ww = mData.WindowWidth;
    elseif ~isnan(obj.imgObj.elementMax) && ~isnan(obj.imgObj.elementMin)
        obj.ww = abs(obj.imgObj.elementMax - obj.imgObj.elementMin);
    end

    % Check on the window level
    if isfield(mData,'WindowCenter')
        obj.wl = mData.WindowCenter;
    else
        obj.wl = obj.ww/2;
    end

    % Apply modality specific updates for the meta-data
    if all( isfield(mData,{'Modality'}) ) && strcmpi(mData.Modality,'ct')

        switch lower(mData.Modality)
            case 'ct'
                ct_metaData_init(obj,mData)

            case 'mr'
                if isfield(mData,'Manufacturer')
                    switch lower(mData.Manufacturer)
                        case 'philips medical systems'
                            philips_metaData_init(obj,mData)
                        case 'siemens'
                            siemens_metaData_init(obj,mData)
                    end
                end

        end

    end

    %TODO: eventually, this event will house the mechanisms for firing
    %currently displayed image changes such as updating the on-image text

end %qt_image.image_metaData_postset


%-----------------------------------
function ct_metaData_init(obj,mData)

    %----------------------
    %   Rescaling Factor
    %----------------------

    % Get the necessary DICOM tags to shift the image values
    tagRsclInt = dicomlookup('0028','1052'); %RescaleIntercept

    % Attempt to find the shifting factor
    if isfield(mData,{tagRsclInt})
        sclInt = double( mData.(tagRsclInt) );
    end

    % Either update the scaling or warn the user that something might be wrong
    % with the tag
    isScl = exist('sclInt','var');
    if isScl && (numel(sclInt)==1) && sclInt
        % Add the filter to the pipeline. In general, no changes are needed for
        % the WW/WL because most vendors calculate and store an appopriate WW/WL
        % in the DICOM meta-data
        obj.addfilter( @(x) double(x)+sclInt);
    end

end %ct_metaData_init

%----------------------------------------
function philips_metaData_init(obj,mData)

    %----------------------
    %   Rescaling Factor
    %----------------------

    % Get the necessary DICOM tags to rescale the images
    tagSclInt  = dicomlookup('2005','100D'); %scale intercept (Philips only)
    tagSclSlp  = dicomlookup('2005','100E'); %scale slope (Philips only)
    tagRsclInt = dicomlookup('0028','1052'); %RescaleIntercept
    tagRsclSlp = dicomlookup('0028','1053'); %RescaleSlope

    % Attempt to find the scaling factors from the header
    if all( isfield(mData,{tagSclInt,tagSclSlp}) )
        sclInt = double( mData.(tagSclInt) );
        sclSlp = double( mData.(tagSclSlp) );
    elseif all( isfield(mData,{tagRsclInt,tagRsclSlp}) )
        sclInt = double( mData.(tagRsclInt) );
        sclSlp = double( mData.(tagRsclSlp) );
    end

    % Either update the scaling or warn the user that something might be
    % wrong
    isScl = exist('sclInt','var') && exist('sclSlp','var');
    if isScl && (numel(sclInt)==1) && (numel(sclSlp)==1)
        % Add the filter to the pipeline
        obj.addfilter( @(x) ( double(x)-sclInt)./sclSlp );

        % Rescale the WW/WL
        obj.ww = (obj.ww-sclInt)./sclSlp;
        obj.wl = (obj.wl-sclInt)./sclSlp;
    else
        warning(['qt_image:' mfilename ':invalidPhilipsScale'],...
                ['Unable to uniquely determine the rescaling slope and/or ',...
                 'intercept for Philips MR data set. Use caution if ',...
                 'performing image quantitation!']);
    end

end %philips_metaData_init

%----------------------------------------
function siemens_metaData_init(obj,mData)

    %--------------------
    %   FOV Conversion
    %--------------------

    % Get the necessary DICOM tags
    tagFov        = dicomlookup('0018','1100');
    tagSiemensFov = dicomlookup('0051','100c');

    % Determine which tag exists
    if ~isfield(mData,tagFov) && isfield(mData,tagSiemensFov)

        % Parse the Siemens style FOV
        FOV = textscan(mData.(tagSiemensFov),'FoV %d*%d');
        %TODO: is there ever a case where the FOV is different in each
        %direction??? (e.g., partial phase FOV?)

        % Update the meta-data with the new field
        obj.metaData.(tagFov) = FOV{1};

    end

    %FIXME: by setting the "metaData" property here, all meta-data post-set
    %listeners are fired twice
end %siemens_metaData_init