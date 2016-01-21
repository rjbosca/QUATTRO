function val = calcrsquared(varargin)
%calcrsquared  Calculates the coefficient of determination
%
%   R2 = calcrsquared(OBJ) calculates the classical regression coefficient of
%   determination (i.e., R^2) based on the modeling object's (OBJ) current
%   properties.
%
%   R2 = calcrsquared(X,Y,F) performs the calculations using the explantory data
%   X, response data Y, and fitted data F. The fitted data can be provided as an
%   array the same size as Y or as a function handle such that evaluation F(X)
%   returns an array the same size as Y.

%   Undocumented syntax:
%   --------------------
%   R2 = calcrsquared(Y,R) performs the calculations using the response data and
%   the fit residuals R. This is used by the MODELBASE method "cleanmaps"

    % Parse the inputs
    if (nargin~=2)
        [f,y] = parse_inputs(varargin{:});
        r     = (y(:)-f(:));    %model residuals
    else %shortcut for map computations (see FITMAPS)
        [y,r] = deal(varargin{:});
    end

    % Calculate the model residuals
    ry = (y(:)-mean(y)); %average residuals

    % Calculate 1 minus the unexplained variance (SSres over SStot)
    val = 1-(r'*r)./(ry'*ry);

end %modelmetrics.calcrsquared


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Validate the inputs and initialize the parser
    narginchk(1,3);
    parser = inputParser;
    isX    = (nargin==3);

    % Special case: parse a modeling object
    %FIXME: this will error if the modeling object is being used to compute maps
    if (nargin==1) && any(strcmpi( superclasses(varargin{1}), 'modelbase' ))
        obj      = varargin{1};
        params   = cellfun(@(x) obj.results.(x).value, obj.nlinParams);
        varargin = {obj.yProc,obj.modelFcn(params,obj.xProc)};
    elseif isX
        parser.addRequired('x',@check_vars);
    end

    % Parse the first two inputs
    parser.addRequired('y',@check_vars);
    parser.parse(varargin{1:2});

    % Parse the function
    if ~isX
        parser.addRequired('f',...
                           @(f) check_fcn(f,parser.Results.y,parser.Results.y));
    else
        parser.addRequired('f',...
                           @(f) check_fcn(f,parser.Results.x,parser.Results.y));
    end
    parser.parse(varargin{:});

    % Handle the special cases
    results = parser.Results;
    if isa(results.f,'function_handle')
        results.f = results.f(results.x);
    end
 
    % Deal the outputs
    varargout = {results.f,results.y};

end %parse_input

%-----------------------------
function tf = check_fcn(f,x,y)

    tf = true; %#ok - initalize the ouptut

    if isa(f,'function_handle')
        try
            tf = all( sort( size(y) ) == sort( size(f(x)) ) );
        catch ME
            %FIXME: make this error message more meaningful
            rethrow(ME);
        end
    else
        tf = all( size(y(:)) == size(f(:)) );
    end

end

%--------------------------
function tf = check_vars(v)

    tf = true; %initialize the output

    validateattributes(v,{'numeric'},{'vector','nonempty','nonnan','finite'});

end