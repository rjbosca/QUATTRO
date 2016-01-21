function varargout = parse_sub_dirs(varargin)
%parse_sub_dirs  Returns all sub-directories within in a directory
%
%   The use of PARSE_SUB_DIRS is deprecated. Use GENSUBDIRS instead.

    [varargout{1:nargout}] = gensubdirs(varargin{:});

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use gensubdirs instead.'],mfilename);

end