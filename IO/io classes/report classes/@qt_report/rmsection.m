function rmsection(obj,varargin)
%rmsection  Removes a section from the qt_report object
%
%   rmsection(OBJ) removes the current section, as specified by the property
%   "sectIdx", from the qt_report object, OBJ.
%
%   rmsection(OBJ,IDX) removes the section specified by the section index, IDX.
%   IDX must be a valid section index.

    % Validate that data to be removed actually exists
    if isempty(obj.sectNames)
        warning(['qt_report:' mfilename ':noSectionData'],...
                 'No section data exists to be removed.');
        return
    end

    % Validate the number of inputs and determine the number of current sections
    narginchk(1,2);
    nSects = numel(obj.sectNames);

    % Parse the inputs
    sectIdx = parse_inputs(varargin{:});

    % Remove all data from the specified section
    obj.sectNames(sectIdx) = [];
    obj.code(sectIdx)      = [];
    obj.plots(sectIdx)     = [];
    obj.tables(sectIdx)    = [];

    % Update the index if necessary
    if (obj.sectIdx>nSects-1)
        obj.sectIdx = nSects-1;
    end


    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Initialize the workspace

        % Parser setup
        parser = inputParser;
        parser.addOptional('idx',obj.sectIdx,@(x) chkIndex(x,nSects));

        % Parse the inputs
        parser.parse(varargin{:});

        % Deal the parsed results
        varargout = struct2cell(parser.Results);

    end %parse_inputs

end %qt_report.rmsection


%-------------------------------
function tf = chkIndex(x,maxVal)

    tf = true; %initialize the output

    validateattributes(x,{'numeric'},...
                          {'finite','integer','nonnan','positive','<=',maxVal});

end %chkIndex