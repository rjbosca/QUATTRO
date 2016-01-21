classdef qt_rpttable < qt_rptobjs & qt_rptvis


    %------------------------------- Properties --------------------------------
    properties

        % Table contents alignment
        %
        %   "alignment" is a cell array of strings specifying the format of each
        %   cell within the table or each column. When using the former
        %   alignment input, the "alignment" property and the table data must be
        %   the same size. Otherwise, when specifying a single format for an
        %   entire column, the cell array should be a vector with a length
        %   equivalent to the number of columns in the table
        alignment = {};

        % Table column names
        %
        %   "columnName" is a cell array of strings specifying the heading to be
        %   used for each column of the table (excluding the row heading column)
        columnName = {};

        % Table data display format
        %
        %   "dispFormat" is a cell array of strings specifying the format of
        %   each cell within the table or each column. When using the former
        %   formatting style, the "dispFormat" property and the table data must
        %   be the same size. Otherwise, when specifying a single format for an
        %   entire column, the cell array should be a vector with a length
        %   equivalent to the number of columns in the table.
        dispFormat = {};

        % Font size
        %
        %   "fontSize" is a number specifying the size of the table fonts
        %   (default: 8). For HTML formats, a cell array spanning the size of
        %   the table data and/or the row headings can be used to customize the
        %   display property
        fontSize = 8;

        % Font weight
        %
        %   "fontWeight" is a cell array of strings specifying the font weight
        %   of each cell within the table or for each of the columns. When using
        %   the former input syntax, the "fontWeight" property and the table
        %   data must be the same size. Otherwise, when specifying a single
        %   format for an entire column, the cell array should be a vector with
        %   a length equal to that of the number of columns
        fontWeight = {};

        % Table row names
        %
        %   "rowName" is a cell array of strings specifying the heading to be
        %   used for each row of the table
        rowName = {};

        % UITABLE options structure
        %
        %   "uitableOpts" is a structure that specifies the options to be used
        %   when creating a PDF document. Only those options specified in this
        %   structure are passed along to the table constructor
        uitableOpts = struct([]);

    end

    properties (Hidden,Constant)

        % UI Table properties
        %
        %   'uitableProps' is a cell array of strings specifying all UITABLE
        %   specific property names
        uitableProps = {'ColumnName',...
                        'ColumnWidth',...
                        'CreateFcn',...
                        'Data',...
                        'DeleteFcn',...
                        'Extent',...
                        'FontAngle',...
                        'FontName',...
                        'FontSize',...
                        'FontUnits',...
                        'FontWeight',...
                        'ForegroundColor',...
                        'Position',...
                        'RowName',...
                        'RowStriping',...
                        'Tag',...
                        'Units',...
                        'Visible'};

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_rpttable(varargin)
        %qt_rpttable  Construct a qt_rpttable object
        %
        %   OBJ = qt_rpttable(DATA,'PROP1',VAL1,'PROP2',VAL2,...) creates a
        %   qt_rpttable object, OBJ, using the data stored in the cell array
        %   DATA and setting the table properties 'PROP1', 'PROP2', etc with
        %   corresponding values VAL1, VAL2, etc.
        %
        %   For more information regarding table properties and values, see the
        %   UITABLE documentation.

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

        end %qt_rpttable.qt_rpttable

    end %class constructor


    %------------------------- Abstract Implementations ------------------------
    methods

        function preview(obj)
        %preview  Previews the qt_rpttable object
        %
        %   preview(OBJ) provides a visualization of the qt_rpttable object,
        %   OBJ, as the table should appear in the published report

            % Data must be present in order to show the table
            if isempty(obj.data)
                return
            end

            % Create the specified figure
            hFig = obj.fig.preview;

            % Create the input cell
            inputs                        = struct2cell(obj.data);
            [inputs{2:2:2*numel(inputs)}] = deal(inputs{:});
            inputs(1:2:end)               = fieldnames(obj.data);

            % Show the table
            uitable('Parent',hFig,inputs{:});

        end %qt_rpttable.preview

        function code = part2code(obj)
        %part2code  Convert qt_rpttable object properties to publishable code
        %
        %   CODE = part2code(OBJ) converts the current qt_rpttable object, OBJ,
        %   properties to publishable code, CODE. CODE will be a cell column
        %   vector of strings, with each element of the column representing a
        %   new line of code.

            if isempty(obj.format)
                error([mfilename ':part2code:unspecifiedFormat'],...
                      ['The "format" property must be specified before code ',...
                       'can be generated.']);
            end
                      
            switch obj.format
                case 'pdf'
                    code = obj.pdf_code;
                case 'html'
                    code = obj.html_code;
            end

        end %qt_rpttable.part2code

    end


    %---------------------------- Internal Methods -----------------------------
    methods (Hidden,Access='protected')

        function c = pdf_code(obj)

            % Create the data structure that will be written to the temporary
            % data file
            s = obj.uitableOpts;

            % Grab the table properties from "uitableOpts" and the additional
            % object properties that are needed by UITABLE
            props = fieldnames(obj.uitableOpts);
            props = repmat(props',[2 1]); %simplifies SPRINTF input

            %TODO: update this code to format the data as specified by the
            %property "dispFormat"

            % Before creating the actual code, ensure that the data has been
            % written
            obj.dataFile.write('-struct','s');

            % Create a string that will specify the inputs to UITABLE in the
            % publishable script
            inputStr = '';
            if ~isempty(props)
                inputStr = sprintf('''%s'',%s,',props{:});
                inputStr = inputStr(1:end-1); %remove the extra comma
            end

            % Print the code
            c = {'figure;';...
                ['load(''' obj.dataFile.file ''');'];...
                ['uitable(' inputStr ');']};

        end %qt_rpttable.pdf_code

        function c = html_code(obj)

            %===============
            % Initialization
            %===============

            nRows       = size(obj.data,1);
            nCols       = size(obj.data,2);

            % Aliases
            cellFrmt    = obj.dispFormat;
            cellAlign   = obj.alignment;
            cellData    = [obj.rowName(:) obj.data];

            % Determine what needs to be down with the row headings
            isRowNames  = ~isempty(obj.rowName); %create a row heading?
            isRowAlign  = (size(obj.alignment,2)==(nCols+1)); %use alignment?
            isRowFrmt   = (size(obj.dispFormat,2)==(nCols+1)); %use custom format?
            isRowWeight = (size(obj.fontWeight,2)==(nCols+1)); %use font weight?

            % Determine if the alignment cell needs to be replicated
            isRepAlign  = any( (size(obj.alignment,2)==[nCols nCols+1]) ) &&...
                                            (numel(obj.alignment)~=nRows*nCols);

            % Determine if the format cell needs to be replicated
            isRepFrmt   = any( (size(obj.dispFormat,2)==[nCols nCols+1]) ) &&...
                                           (numel(obj.dispFormat)~=nRows*nCols);


            %=================
            % Data preparation
            %=================

            % Prepare the column format
            if isempty(cellFrmt)
                % Find all the character data types in the tabular data
                cellFrmt = cellfun(@class,obj.data,'UniformOutput',false);
                charIdx  = cellfun(@ischar,cellFrmt);

                % Replace the character data types with a string format
                % and all others with a numeric format
                [cellFrmt{charIdx}]  = deal('%s');
                [cellFrmt{~charIdx}] = deal('%g');
            elseif isRepFrmt
                % Make the column format specification match the size of the
                % data cell array
                cellFrmt = repmat(cellFrmt(:)',[nRows 1]);
            end
            if isRowNames && ~isRowFrmt %row format does not exist - append default
                cellFrmt = [repmat({'%s'},[nRows 1]) cellFrmt];
            end

            % Prepare the cell alignment
            if isempty(cellAlign)
                % Define the cell default - 'center' justification
                [cellAlign{1:nRows,1:nCols}] = deal('center');
            elseif isRepAlign
                cellAlign = repmat(cellAlign(:)',[nRows,1]);
            end
            if isRowNames && ~isRowAlign %row alignment does not exist - append default
                cellAlign = [repmat({'right'},[nRows 1]) cellAlign];
            end


            %===========
            % HTML write
            %===========

            % Initialize the output and define the table header
            c = {'%';'% <html>';'% <table border=1>'};

            % Add the table headings
            if ~isempty(obj.columnName)
                cHead = cellfun(@(x) sprintf('%%   <th>%s</th>',x),...
                                     obj.columnName,'UniformOutput',false);
                if ~isempty(obj.rowName)
                    c = [c(:);'% <tr>';'%   <th></th>';cHead(:);'% </tr>'];
                else
                    c = [c(:);'% <tr>';cHead(:);'% </tr>'];
                end
            end

            % Loop through row/column, writing the data code along the way
            for rIdx = 1:nRows

                % Append the row command
                c{end+1} = '% <tr>'; %#ok<*AGROW>

                % Writ the row headings
                if isRowNames
                    c{end+1} = data2str(obj.rowName{rIdx},cellFrmt{rIdx},...
                                        cellAlign{rIdx},'bold');
                end

                % Write the data for this row
                for cIdx = (1+isRowNames):(nCols+isRowNames)

                    % Write actual table data
                    val      = cellData{rIdx,cIdx};
                    pStr     = data2str(val,cellFrmt{rIdx,cIdx},...
                                            cellAlign{rIdx,cIdx},'');
                    c{end+1} = pStr;

                end

                % Append the footer
                c{end+1} = '% </tr>';

            end

            % Write the HTML table footer
            c{end}         = [c{end} '</table>'];
            c(end+1:end+2) = {'% </html>';'%'};

        end %qt_rpttable.html_code

    end %internal methods

end %qt_rpttable


%---------------------------------------------
function [props,vals] = parse_inputs(varargin)

    % Setup the input parser and initialize the class properties to add to the
    % parser
    parseObj = qt_rpttable;
    objProps = properties(parseObj);
    parser   = inputParser;
    if mod(nargin,2)
        parser.addRequired('data',@iscell)
    end

    % Add the class properties to the parser and parse the inputs. Keep the
    % unmatched input parameters as these are likely specific to the UITABLE
    % properties
    cellfun(@(x) add_input_param(parser,x,parseObj.(x)),objProps);
    parser.KeepUnmatched = true;
    parser.parse(varargin{:});

    % Grab the table options (i.e., the unmatched input parameter/value pairs)
    % and append to the parser results in the field "uitableOpts"
    results             = parser.Results;
    results.uitableOpts = parser.Unmatched;

    %=================================
    % Parse the UITABLE property names
    %=================================

    % Validate the property names. Use VALIDATESTRING for partial matching
%     props      = cellfun(@(x) validatestring(x,validProps),props,...
%                                                          'UniformOutput',false);

    % Validate that all data within a cell contains numeric, logical, or char
    % data types otherwise, UITABLE will error
%     cellfun(@validate_cell,propVals);


    %=================================
    % Parse the qt_rpttable properties
    %=================================

    % Special case for the 'data' property
    if ~iscell(results.data) && isnumeric(results.data)
        results.data = num2cell(results.data);
    elseif ~iscell(results.data)
        error([mfilename ':invalidDataType'],...
               '"data" must be a cell or numeric array.');
    end

    % Store the final results of the above parsing operation and return those
    % data to the class constructor
    props = fieldnames(results);
    vals  = struct2cell(results);

end %parse_inputs

%---------------------------------------------
function add_input_param(parser,param,default)
    if isempty(parser.Parameters) || ~any( strcmpi(param,parser.Parameters) )
        parser.addParamValue(param,default);
    end
end %add_input_param

%--------------------------------------------------
function s = data2str(data,frmt,alignStr,weightStr)

    % Parse the font options
    if ~isempty(alignStr)
        alignStr = sprintf(' style="text-align:%s"',alignStr);
    end
    if ~isempty(weightStr)
        weightStr = sprintf(' style="font-weight:%s"',weightStr);
    end

    % Write the output string
    s = sprintf(['%%   <td%s%s>' frmt '</td>'],alignStr,weightStr,data);

end %style2str

%------------------------
function validate_cell(c)
    if iscell(c)
        nInCell = cellfun(@numel,c);
        if (max( nInCell(~cellfun(@ischar,c)) )>1)
            error(['qt_report:' mfilename ':tooManyElements'],...
                   'Data within cell array must have size [1 1].');
        end
    end
end %validate_cell