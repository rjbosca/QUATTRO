function val = calcmse(varargin)
%calcmse  Calculate the mean squared error
%
%   MSE = calcmse(OBJ) calculates the coefficient based on the modeling
%   object's (OBJ) current properties.
%
%   MSE = calcmse(X,Y,F) performs the calculates using the explantory data X,
%   response data Y, and fitted data F. The fitted data can be provided as an
%   array the same size as Y or as a function handle such that evaluation F(X)
%   returns an array the same size as Y.
%
%
%   Algorithm
%   ---------
%   There appears to be a variety of definitions of the mean squared error (MSE)
%   depending on the context. MSE is defined here as the sum of the squared
%   residuals divided by the number of measurements. The degrees of freedom are
%   not accounted for.


    % Parse the inputs
    [f,y] = parse_inputs(varargin{:});

    % Calculate the model residuals
    r   = (y(:)-f(:)); %model residuals

    % Calculate the mean square error
    val = sum(r'*r)/numel(y);

end %modelmetrics.calcmse


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
        varargin = {obj.xProc,obj.yProc,obj.modelFcn(params,obj.xProc)};
    elseif isX
    end

    % Parse the first two inputs
    parser.addRequired('x',@check_vars);
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