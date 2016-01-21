function obj = multiflip(varargin)
%multiflip  FSPGR modeling constructor
%
%   The use of MULTIFLIP is deprecated. Use one of the FSGPR modeling classes
%   instead: 
%
%       qt_models.t1Relaxometry.multiflip.fspgrvfa_T1
%
%       qt_models.t1Relaxometry.multiflip.fspgrvfa_R1

    if strcmpi( class(varargin{1}), 'qt_exam' )
        exObj       = varargin{1};
        varargin(1) = [];
        obj         = exObj.createmodel(varargin{:});
    else
        obj         = qt_models.t1relaxometry.multiflip.fspgrvfa_T1(varargin{:});
    end

    warning(['QUATTRO:' mfilename ':functionDeprecated'],...
            ['"%s" is deprecated and will be removed in a future release. ',...
             'An object of class "%s" has been constructed instead. ',...
             'In the future, use "%s" instead.'],...
                                               mfilename,class(obj),class(obj));

end %multiflip