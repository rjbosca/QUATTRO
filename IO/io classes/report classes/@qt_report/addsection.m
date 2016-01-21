function addsection(obj,varargin)
%addsection  Adds a section to be written by the qt_report object
%
%   addsection(OBJ,TITLE) appends the section with TITLE to the report specified
%   by the qt_report object, OBJ. The "sectIdx" property is updated to reflect
%   the addition of the new section
%
%   addsection(...,SECTIDX) adds the section as above, placing the section at
%   the index specified by SECTIDX, which must be a valid index. Any sections at
%   or after the index are shifted by one index towards the end of the section
%   stack

    % Validate the number of inputs
    narginchk(2,3);

    % Parse the inputs
    nSects                         = numel(obj.sectNames);
    [sectIdx,sectTitle,permission] = parse_inputs(varargin{:});

    % There are two cases: (1) append the data to the end or (2) splice the data
    % into the existing sections
    if strcmpi(permission,'a')
        obj.sectNames{end+1} = sectTitle;
    else
        sects                  = obj.sectNames;
        sects(sectIdx+1:end+1) = sects(sectIdx:end);
        sects{sectIdx}         = sectTitle;
        obj.sectNames          = sects;
    end

    % Update the section index and code cells
    obj.sectIdx = sectIdx;
    if (sectIdx>nSects) || isempty( obj.code{sectIdx} )
        obj.code{sectIdx}   = qt_rptcode.empty(0,1);
        obj.plots{sectIdx}  = qt_rptplot.empty(0,1);
        obj.tables{sectIdx} = qt_rpttable.empty(0,1);
    end


    %------------------------------------------
    function varargout = parse_inputs(varargin)

        % Initialize the workspace

        % Parser setup
        parser = inputParser;
        parser.addRequired('title',@ischar)
        parser.addOptional('idx',nSects+1,@(x) chkIndex(x,nSects+1));

        % Parse the inputs
        parser.parse(varargin{:});

        % Deal the parsed results
        varargout = struct2cell(parser.Results);

        % Define the section write mode
        varargout{end+1} = 'a';
        if (varargout{1}~=nSects+1)
            varargout{end} = 'w';
        end

    end %parse_inputs

end %qt_report.addsection


%-------------------------------
function tf = chkIndex(x,maxVal)

    tf = true; %initialize the output

    validateattributes(x,{'numeric'},...
                          {'finite','integer','nonnan','positive','<=',maxVal});

end %chkIndex