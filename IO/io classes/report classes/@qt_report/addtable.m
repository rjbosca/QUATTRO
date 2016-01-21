function addtable(obj,varargin)
%addtable  Adds UI table code to a qt_report object
%
%   addtable(OBJ,'PROP1',VAL1,'PROP2',VAL2,...) appends a UI table to the report
%   generating object OBJ, where 'PROP' is the name of the table prpoerty, and
%   VAL, is the value to be used for that property.
%
%   addtable(OBJ,TABLE) appends the qt_rpttable object, TABLE, to the report
%   generating object.
%
%   For more information regarding table properties and values, see the UITABLE
%   documentation.

    % Ensure that a section exists
    if isempty(obj.sectNames)
        error(['qt_report:' mfilename ':invalidSection'],...
               'A section name must exist before a table can be added.');
    end

    % Send the property/value pair inputs to the qt_rpttable constructor
    tableObj = varargin{1};
    if (nargin>2)
        tableObj = qt_rpttable(varargin{:});
    end

    % Update the indices and output format for this particular object
    tableObj.sectIdx = obj.sectIdx;
    tableObj.partIdx = obj.nextPartIdx;
    tableObj.format  = obj.format;

    % Append the qt_rpttable object provided by the user to the visualization
    % storage
    obj.tables{obj.sectIdx}(end+1) = tableObj;

end %qt_report.addtable