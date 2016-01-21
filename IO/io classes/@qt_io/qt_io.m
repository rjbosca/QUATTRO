classdef qt_io < hgsetget


    %------------------------------- Properties --------------------------------

    properties (Dependent)

        % Full file name
        %
        %   "file" is a string specifying file to which IO operations are
        %   performed. This string contains the full file name
        file

    end

    properties (Hidden)

        % File name of the image
        %
        %   "fileName" is a string specifying the file name from which data are
        %   read and written.
        fileName = '';

        % Path name of the image
        %
        %   "filePath" is a string specifying the path of the IO object
        filePath = pwd;

        % Temporary file flag
        %
        %   "isTempFile" is a logical flag that directs read/write operations to
        %   a temporary file specified by "file" when TRUE. Temporary files are
        %   removed during deletion of the corresponding file_io object
        isTempFile = false;

    end

    properties (Hidden,Access='protected')

        % User-specified directory flag
        %
        %   "isUserDir" is a logical flag that denotes when the property
        %   "filePath" is a user-specified directory (TRUE) or is a temporary
        %   director (FALSE) to be removed during object deletion.
        isUserDir = false;

        % File identifier
        %
        %   "fileId" is a unique file identifier
        fileId

    end


    %--------------------------------- Events ----------------------------------

    events

        % Notification upon closing an open file
        %
        %   "fileClosed" should be notified any time the file, specified by the
        %   identifier stored in the "fileId" property, is closed
        fileClosed

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_io(varargin)
        %qt_io  Constructs a qt_io object
        %
        %   OBJ = qt_io creates an IO object using a unique file stored in a
        %   temporary direcotry in the current working directory. The file is
        %   only opened for IO operations when needed. Both the file and
        %   directory are deleted during deletion of the object OBJ.
        %
        %   OBJ = qt_io(DIR) creates an IO object using a unique file stored in
        %   the direcotry specified by the string DIR. 

            % No inputs - define the temporary file/directory names
            obj.isUserDir = nargin;
            if ~obj.isUserDir
                obj.filePath = tempdir;
            end

            % Define the file name
            [~,tempFileName] = fileparts(tempname); 
            obj.fileName     = [tempFileName '.tmp'];

            % Create the event listeners
            addlistener(obj,'fileClosed',@obj.fileclosed);

        end

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.file(obj)
            val = fullfile(obj.filePath,obj.fileName);
        end %qt_io.get.file

    end


    %------------------------------- Set Methods -------------------------------
    methods

        function obj = set.file(obj,val)
        end %qt_io.set.file

    end


    %----------------------------- Abstract Methods ----------------------------
    methods (Abstract)

        read(obj)

        write(obj)

    end


    %------------------------------ Other Methods ------------------------------
    methods (Hidden=true)

        function close(obj)

            % A file identifier must exist
            if isempty(obj.fileId)
                return
            end

            % Attempt to close the file in question if no error occured when
            % determing the file position
            if (obj.filePos~=-1)
                fclose(obj.fileId);
            end

            % Notify the object that the fileId field should be cleared
            notify(obj,'fileClosed');

        end %qt_io.close

        function delete(obj)

            % Close any opent files
            if ~isempty(obj.fileId)
                fclose(obj.fileId);
            end

            % Delete any temporary files
            if (exist(obj.file,'file')==2) && obj.isTempFile
                delete(obj.file);
            end
            
        end %qt_io.delete

    end

end