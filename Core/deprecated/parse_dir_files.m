function varargout = parse_dir_files(varargin)
%parse_dir_files  Returns all files in a directory
%
%   The use of parse_dir_files is deprecated. Use GENDIRFILES instaed.

    [varargout{1:nargout}] = gensubdirs(varargin{:}); %temporary wrapper

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use gendirfiles instead.'],mfilename);

end %parse_dir_files