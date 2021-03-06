function load(obj)
%load  Load a stored QUATTRO configuration
%
%   load(OBJ) loads a stored QUATTRO configuration into the qt_options object
%   OBJ using the file stored in the "cfgFile" property. Failed file validation
%   will result in the writting of a new configuration file.

    % Validate the configuration file
    if ~exist(obj.appDir,'dir') || (exist(obj.cfgFile,'file')~=2)
        warning('QUATTRO:options:noConfig','%s\n%s\n%s\n',...
                'Missing QUATTRO configuration file or application directory.',...
                'Creating a new configuration file in:',obj.appDir);
        obj.save;
        return %no need to reload the default config options
    end

    % Read QUATTRO configuration file
    fid = fopen(obj.cfgFile,'r');
    if fid==-1
        warning('QUATTRO:options:invalidConfigFile',...
                      ['The file %s could not be opened for reading.\n',...
                       'Using default configuration.'],obj.cfgFile);
        return
    end
    opts = textscan(fid,'%s','CommentStyle','%','Delimiter','\n');
    opts = opts{1};
    fclose(fid);

    % Remove empty strings
    opts( cellfun(@isempty,opts) ) = [];

    % Create a structure of options
    for idx = 1:length(opts)
        eval(['newOpts.' opts{idx} ';']);
    end

    % Verify options structure
    flds      = fieldnames(newOpts)';
    for fld = flds
        try
            obj.(fld{1}) = newOpts.(fld{1});
        catch ME
            switch ME.identifier
                case {'MATLAB:noPublicFieldForClass'
                      'MATLAB:class:InvalidProperty'}
                    warning(['qt_options:' mfilename ':invalidConfigOption'],...
                            ['"%s" is an invalid option or is inaccessible ',...
                             'to the user.'],fld{1});
                otherwise
                    rethrow(ME)
            end
        end
    end

end %qt_options.load