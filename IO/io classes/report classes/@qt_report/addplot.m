function addplot(obj,varargin)
%addplot  Adds plot code to a qt_report object
%
%   addplot(OBJ,X,Y,S) appends a plot, with data X/Y and format string S, to the
%   report generating object, OBJ. S is an optional input.
%
%   addplot(OBJ,X1,Y1,S1,X2,Y2,S2,...) appends a plot function as described
%   above for data sets Xi/Yi with format strings Si.
%
%   addplot(...,'PROP1',VAL1,...) appends the plot function in addition to plot
%   parameter/value pairs.
%
%   For more information regarding ADDPLOT inputs and values, see the PLOT
%   documentation

    % Ensure that a section exist
    if isempty(obj.sectNames)
        error(['qt_report:' mfilename ':invalidSection'],...
               'A section name must exist before a table can be added.');
    end

    % Send the property/value pair inputs to the qt_rpttable constructor
    plotObj = varargin{1};
    if ~strcmpi( class(plotObj), 'qt_rptplot' )
        plotObj = qt_rptplot(varargin{:});
    end

    % Update the indices and format for this particular object
    plotObj.sectIdx = obj.sectIdx;
    plotObj.partIdx = obj.nextPartIdx;
    plotObj.format  = obj.format;

    % Append the qt_rptplot object to the visualization storage
    obj.plots{obj.sectIdx}(end+1) = plotObj;

end %qt_report.addplot