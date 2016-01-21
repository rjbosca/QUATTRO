function fileclosed(obj,source,eventdata)
%fileclosed  Callbac for qt_io event "fileClosed"
%
%   fileclosed(OBJ,SRC,EVENT)

    % Empty the file identifier
    obj.fileId = [];

end %qt_io.fileclosed