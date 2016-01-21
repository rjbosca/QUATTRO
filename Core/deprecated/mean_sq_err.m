function varargout = mean_sq_err(varargin)
%mean_sq_err  Calculates the mean squared error
%
%   The use of MEAN_SQ_ERR is deprecated. Use modelmetrics.calcmse instead.

    [varargout{1:nargout}] = modelmetrics.calcmse(varargin{:});

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'Use modelmetrics.calcmse instead.'],mfilename);

end