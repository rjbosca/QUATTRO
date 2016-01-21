classdef qt_rptcode < qt_rptobjs


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_rptcode(varargin)
        %qt_rptcode  Constructs a qt_rptcode object
        %
        %   OBJ = qt_rptcode(CODE) creates a qt_rptcode object, OBJ, using the
        %   code defined by the formatted string (see SPRINTF for more
        %   information), CODE.

            % Perform no action with no inputs - required by MATLAB
            if ~nargin
                return
            end

            % Parse the inputs
            [props,vals] = parse_inputs(varargin{:});

            % Update the object properties
            for idx = 1:numel(props)
                obj.(props{idx}) = vals{idx};
            end

        end %qt_rptcode.qt_rptcode

    end %class constructor


    %------------------------- Abstract Implementations ------------------------
    methods

        function preview(obj)
        %preview  Previews the qt_rptcode object
        %
        %   preview(OBJ) provides a visualization of the qt_rptcode object, OBJ,
        %   as the table should appear in the published report

            sprintf('%s\n',obj.data{:});

        end %qt_rptcode.preview

        function code = part2code(obj)
        %part2code  Convert qt_rptcode object properties to publishable code
        %
        %   CODE = part2code(OBJ) converts the current qt_rptcode object, OBJ,
        %   properties to publishable code, CODE. CODE will be a cell column
        %   vector of strings, with each element of the column representing a
        %   new line of code.

            %TODO: this should change after I create a way to write other types
            %of code. For example, HTML...
            code = obj.data(:);

        end %qt_rptcode.part2code

    end %abstract method implementation
    
end %qt_rptcode


%------------------------------------------
function [props,vals] = parse_inputs(varargin)

    % Create a qt_rptcode object and grab the properties
    parseObj = qt_rptcode;
    objProps = properties(parseObj);
    objProps = objProps( ~strcmpi('data',objProps) );

    % Parser setup
    parser   = inputParser;
    parser.addRequired('data',@chkCode)
    cellfun(@(x) parser.addParamValue(x,parseObj.(x)),objProps);    

    % Parse the inputs
    parser.parse(varargin{:});
    results = parser.Results;

    % Convert the input to a cell if needed
    if ~iscell(results.data)
        results.data = {results.data};
    end

    % Deal the parsed results
    [props,vals] = deal(fieldnames(results),struct2cell(results));

end %parse_inputs


%-----------------------
function tf = chkCode(x)

    isCellIn = iscell(x);
    isCharIn = ischar(x);
    tf       = isCharIn || isCellIn; %initialize the output
    if ~tf
        error(['qt_rptcode:' mfilename ':nonCharCodeInput'],...
               'CODE must be a string.');
    end

    % Attempt to print the string
    try
        if isCharIn
            sprintf(x);
        elseif isCellIn
            sprintf(x{:});
        end
    catch ME
        error(['qt_rptcode:' mfilename ':invalidFormatString'],...
               'Unable to print the specified formatted string');
    end

end %chkCode