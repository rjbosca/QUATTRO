function open(obj)
%open  Opens a file
%
%   open(OBJ) opens the file specified in the properties of the qt_io object,
%   OBJ, using the file permission, machine format, and encoding specified in
%   the respective object properties. This is essentially a warpper for the
%   built-in MATLAB function FOPEN
%
%   See FOPEN for more information regarding file operations

    % Attempt to open the file
    fid = fopen(obj.file,obj.filePermission,obj.machineFormat,obj.fileEncoding);

    % Notify the user when a file fails the open operation
    if (fid==-1)
        warning(['qt_io:' mfilename ':unableToOpenFile'],...
                '%s could not be opened.',obj.file);
        return
    end

    % Update the file identifier property
    obj.fileId = fid;

end %qt_io.open