function fileName_postset(obj,src,~)
%fileName_postset  Post-set event for IMAGE2D property "fileName"
%
%   fileName_postset(OBJ,SRC,EVENT)

    % Get the affected object and the newly set file name
    val = obj.fileName;

    % Validate the initiating event
    if ~strcmpi(src.Name,'fileName')
        warning([class(obj) ':' mfilename ':invalidCaller'],...
                   'Only calls from "fileName" post-set events are permitted.');
    end

    % Only fire the "read" method to extract meta-data (and image data) if there
    % is no image
    if isempty(obj.metaData)
        tf = obj.read;
        if ~tf
            warning(['qt_image:' mfilename ':unableToRead'],...
                    ['Unable to read image data from "%s". Ensure the "format" ',...
                     'property is set appropriately.'],val{:});
        end
    end

end %image2d.fileName_postset