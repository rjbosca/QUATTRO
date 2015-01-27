function metaData_postset(src,eventdata) %#ok<*INUSL>
%metaData_postset  PostSet event for qt_image property "metaData"
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
    % im2map_filter) should be added after this PostSet event.


    % Get the image object
    obj = eventdata.AffectedObject;

    % Attempt to derive the file format from the meta data. This works well for
    % DICOM images, but remains untested on other formats
    %TODO: test on image formats other than DICOM
    if strcmpi(obj.format,'unknown') && isfield(obj.metaData,'Format')
        obj.format = obj.metaData.Format;
    end

    % Before going on, check to see if this DICOM has any image data. Delete the
    % object if no real image data exists
    if isfield(obj.metaData,'Width') && isempty(obj.metaData.Width) &&...
                                                              isempty(obj.image)
        warning(['qt_image:' mfilename ':invalidImageFile'],...
                ['Unable to load image data from "%s".\n',...
                 'Skipping file...\n'],obj.fileName);
        obj.delete;
        return
    end
        
    % Check on the window width
    if isempty(obj.ww) && isfield(obj.metaData,'WindowWidth')
        obj.ww = obj.metaData.WindowWidth;
    end

    % Check on the window level
    if isempty(obj.wl) && isfield(obj.metaData,'WindowCenter')
        obj.wl = obj.metaData.WindowCenter;
    end

    % Check on the window bounds
    if isempty(obj.windowBounds) && isfield(obj.metaData,'Modality')
        switch lower(obj.metaData.Modality)
            case 'mr'
                if isfield(obj.metaData,'LargestImagePixelValue')
                    obj.windowBounds = [0 obj.metaData.LargestImagePixelValue];
                else
                    obj.windowBounds = [0 inf];
                end
        end
    end

    % Apply the rescaling filters for Phillips data
    if all( isfield(obj.metaData,{'Modality','Manufacturer'}) ) &&...
                    strcmpi(obj.metaData.Modality,'mr') &&...
                    strcmpi(obj.metaData.Manufacturer,'philips medical systems')

        % Get the necessary DICOM tags to rescale the images
        tagSclInt  = dicomlookup('2005','100D'); %scale intercept (Philips only)
        tagSclSlp  = dicomlookup('2005','100E'); %scale slope (Philips only)
        tagRsclInt = dicomlookup('0028','1052'); %RescaleIntercept
        tagRsclSlp = dicomlookup('0028','1053'); %RescaleSlope

        % Attempt to find the scaling factors from the header
        if all( isfield(obj.metaData,{tagSclInt,tagSclSlp}) )
            sclInt = double( obj.metaData.(tagSclInt) );
            sclSlp = double( obj.metaData.(tagSclSlp) );
        elseif all( isfield(obj.metaData,{tagRsclInt,tagRsclSlp}) )
            sclInt = double( obj.metaData.(tagRsclInt) );
            sclSlp = double( obj.metaData.(tagRsclSlp) );
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
                    ['Unable to uniquely determine the rescaling slope and/or\n',...
                     'intercept for Philips MR data set. Use caution if\n',...
                     'performing image quantitation!']);
        end

    end

    % Validate/convert a DICOM tag used frequently for DCE temporal positions.
    % In my experience, this specific tag can take numeric or character data,
    % but should be represented by a number - that is checked here
    acqTimeTag = dicomlookup('0008','0032');
    if isfield(obj.metaData,acqTimeTag) && ischar(obj.metaData.(acqTimeTag))

        % Attempt to convert to a number
        numVal = str2double( obj.metaData.(acqTimeTag) );
        if ~isnan(numVal) %successful conversion - store the data
            obj.metaData.(acqTimeTag) = numVal;
        end

    end
        
    %TODO: eventually, this event will house the mechanisms for firing
    %currently displayed image changes such as updating the on-image text

end %qt_image.metaData_postset