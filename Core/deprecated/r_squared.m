function varargout = r_squared(varargin)
%r_squared  Calculates the coefficient of determination
%
%   R_SQUARED is deprecated. Use modelmetrics.calcrsquared instead.

    [varargout{1:nargout}] = modelbase.calcrsquared(varargin{:});

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use gensubdirs instead.'],mfilename);

end %r_squared