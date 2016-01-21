function simulate(obj,varargin)
%simulate  Simulates the specified modeling object
%
%   simulate(OBJ,POS,PARAMS) generates a simulated model output for the modeling
%   object OBJ where POS specifies the [HEIGHT WIDTH] of the grid squares and
%   PARAMS is a cell 

    % Parse the inputs
    [gPos,params] = parse_inputs(varargin{:});

    % Create the parameter arrays
    [paramGrid{1:numel(params)}] = ndgrid(params{:});

    % For each of the paramter values, calculate the resulting model value
    imOut = repmat(0*paramGrid{1},gPos);
    for paramIdx = 1:numel(paramGrid{1})
    end

end %modelbase.simulate


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Parser setup
    parser = inputParser;
    parser.addRequired('gridSize',@check_grid)
    parser.addRequired('params',@check_params);

    % Parse the inputs and deal the outputs
    parser.parse(varargin{:});
    varargout = struct2cell(parser.Results);

end %parse_inputs

%-------------------------
function tf = check_grid(x)
    tf = true;
    validateattributes(x,{'numeric'},{'vector','positive','nonnan','finite',...
                                                  'real','nonempty','numel',2});
end %check_grid

%----------------------------
function tf = check_params(p)
    tf = true;
    validateattributes(p,{'cell'},{'nonempty','vector'});

    for pVal = p(:)'
        validateattributes(pVal{1},{'numeric'},{'positive','nonnan','finite',...
                                                            'real','nonempty'});
    end

end %check_params