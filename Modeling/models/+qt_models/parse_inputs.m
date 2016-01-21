function parse_inputs(obj,varargin)
%parse_inputs  Input parser API for the QT_MODELS package
%
%   qt_models.parse_inputs(OBJ,...)

    % Initialize common variables
    nReq     = 0; %number of "required" inputs for the input parser
    optsOnly = ischar(varargin{1});
    parser   = inputParser;

    % Validate that the modeling object input, OBJ, is a sub-class of MODELBASE
    if ~any( strcmpi(superclasses(obj),'modelbase') )
        error(['qt_models:' mfilename ':invalidModelObj'],...
               'The first input to %s must be a sub-class of MODELBASE.',mfilename);
    end

    % Add the required inputs when the "optsOnly" syntax is not being used,
    % removing them from the input cell array
    if ~optsOnly

        parser.addRequired('x',@(x) isnumeric(x) || strcmpi(class(x),'unit'));
        parser.addRequired('y',@isnumeric);
        nReq = nReq+2; %increment the # of require inputs

        % For classes derive from the PK class, there is an additional required
        % input (VIF) that must be added to parser
        if any( strcmpi(superclasses(obj),'pk') )
            parser.addRequired('vif',@isnumeric);
            nReq = nReq+1;
        end
 
    end

    % Separate the options from the required inputs
    opts = varargin(1+nReq:2:end);

    % Add additional options to the parser
    if ~isempty(opts)

        % Validate the options
        props = properties(obj);
        opts  = cellfun(@(x) validatestring(x,props),opts,...
                                                         'UniformOutput',false);

        % Assign the options to the parser
        for prop = opts(:)'
            parser.addParamValue(prop{1},obj.(prop{1}));
        end

    end

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % Apply user-specified options
    for prop = fieldnames(results)'
        obj.(prop{1}) = results.(prop{1});
    end

end %qt_models.parse_inputs