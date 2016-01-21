function metadata = mhainfo(varargin)
%mhainfo  Read MHA metadata
%
%   INFO = mharead(FILENAME) attempts to read the image metadata from an MHA
%   file specified by the string FILENAME.
%
%   See also mharead mhawrite

    % Initialize output
    if (exist(varargin{1},'file')~=2)
        error([mfilename ':invalidFile'],'File does not exist.');
    end

    metadata.Filename = varargin{1};

    % Open file for reading
    fid = fopen(metadata.Filename,'r');
    if (fid==-1)
        error([mfilename ':invalidFile'],'Unable to read specified file.');
    end

    % Set up field specific read
    logical_flds     = {'BinaryData',...
                        'BinaryDataByteOrderMSB',...
                        'CompressedData'};
    int_array_flds   = {'DimSize',...
                        'NDims'};
    float_array_flds = {'CenterOfRotation',....
                        'ElementSpacing',...
                        'Offset',...
                        'TransformMatrix'};
    string_flds      = {'AnatomicalOrientation',...
                        'ElementDataFile',...
                        'ElementType',....
                        'ObjectType'};

    % Read header
    eoh = false; %end of header flag
    while ~eoh
        hdrl      = fgetl(fid); %read a line
        [fld val] = strtok(hdrl,'='); %get the variable name

        % Prepare the value and field for storage
        fld = strtrim(fld);
        val = strtrim( strrep(val,'=','') );

        % Cache the current file position. After reading the header, this position
        % will specifcy the beginning of the image
        metadata.BeginningOfImage = ftell(fid);

        % Store the data
        switch fld
            case logical_flds
                metadata.(fld) = eval( lower(val) );
            case int_array_flds
                metadata.(fld) = sscanf(val,'%d')';
            case float_array_flds
                metadata.(fld) = sscanf(val,'%f')';
            case string_flds
                metadata.(fld) = val;
            otherwise
                fclose(fid);
                error([mfilename ':invalidMetadataFld'],...
                                                      ['Unrecognized field: ' fld]);
        end

        % Determine if the end of the header has been reached. Note: according to
        % the ITK documentation (http://www.itk.org/Wiki/ITK/MetaIO/Documentation),
        % ElementDataFile is always the last field in the MHA file when the value of
        % this field is LOCAL or the image file name.
        eoh = isfield(metadata,'ElementDataFile');
    end

    % A special case for loading a list of files
    if strcmp(metadata.ElementDataFile,'LIST')
    end

    % Terminate file read
    fclose(fid);

end %mhainfo