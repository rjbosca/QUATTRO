function addcode(obj,varargin)
%addcode  Adds code (and/or comments) to a report section
%
%   addcode(OBJ,CODE) appends the code specified by the formatted string (see
%   SPRINTF for more information), CODE, to the end of the current section of
%   the qt_report object, OBJ
%
%   addcode(...,IDX) adds the code as described above, inserting the string in
%   the section specified by the valid section index, IDX.

    % Validate the number of inputs
    narginchk(2,3);

    % Parse the inputs
    [codeStr,idx] = parse_inputs(varargin{:});

    % Create a QT_CODE object and append it to the specified section
    code          = qt_rptcode(codeStr);

    % Update the indices for this particular object
    code.sectIdx = idx;
    code.partIdx = obj.nextPartIdx;
    code.format  = obj.format;

    % Append the qt_rptcode object provided by the user to the code storage
    obj.code{idx}(end+1) = code;

    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Initialize the workspace
        nSects = numel(obj.sectNames);

        % Parser setup
        parser = inputParser;
        parser.addRequired('code',@chkCode)
        parser.addOptional('idx',obj.sectIdx,@(x) chkIndex(x,nSects));

        % Parse the inputs
        parser.parse(varargin{:});

        % Deal the parsed results
        varargout = struct2cell(parser.Results);

    end %parse_inputs

end %qt_report.addcode


%-----------------------
function tf = chkCode(x)

    tf = ischar(x) || strcmpi(class(x),'qt_rptcode'); %initialize the output
    if ~tf
        error(['qt_report:' mfilename ':nonCharCodeStr'],...
               'CODE must be a string.');
    end

end %chkCode

%-------------------------------
function tf = chkIndex(x,maxVal)

    tf = true; %initialize the output

    validateattributes(x,{'numeric'},...
                          {'finite','integer','nonnan','positive','<=',maxVal});

end %chkIndex