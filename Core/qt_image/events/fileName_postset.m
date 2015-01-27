function fileName_postset(src,eventdata)
%fileName_postset  PostSet event for qt_image property "fileName"
%
%   fileName_postset(SRC,EVENT)

    % Validate the initiating event
    if ~strcmpi(src.Name,'fileName')
        warning(['qt_image:' mfilename ':invalidCaller'],...
                    'Only calls from "fileName" PostSet events are permitted.');
    end

    % Get the affected object and the newly set file name
    obj = eventdata.AffectedObject;
    val = obj.fileName;

    % Validate/store input
    if isempty(val) || ~ischar(val) %ensure the input is a string
        error(['qt_image:' mfilename ':invalidFileName'],...
              ['The "fileName" property of a qt_image object must be a\n',...
               'non-empty string.']);
    elseif ~exist(val,'file')
        warning(['qt_image:' mfilename ':invalidFileName'],...
                                                  'Could not locate "%s".',val);
        obj.fileName = ''; %reset the fileName property
        return
    end

    % Befor setting the file name try to determine image type
    if isdicom(val) %DICOM files rarely have a standardized file extension
        obj.format = 'dicom';
    else
        % Get the extension and see if it makes sense
        [~,~,fExt] = fileparts(val);
        fExt       = strrep(fExt,'.',''); %remove the "."
        validExt   = {'bmp','cur','gif','hdf4','ico','jpg','jpeg','jpeg2000',...
                      'pbm','pcx','pgm','png','ppm','ras','tif','tiff','xwd'};
        if ~any(strcmpi(fExt,validExt))
            warning('qt_image:invldImgType',...
                    'Extensions of type "%s" are not supported',fExt);
            return
        else
            obj.format = fExt;
        end
    end

    % Fire the "read" method to extract metaData
    tf = obj.read;
    if ~tf
        warning(['qt_image:' mfilename ':unableToRead'],'%s "%s"\n%s',...
                 'Unable to read image data from',val,...
                 'Ensure the "format" property is set appropriately.');
        obj.fileName = ''; %reset the fileName property
    end

end %qt_image.fileName_postset