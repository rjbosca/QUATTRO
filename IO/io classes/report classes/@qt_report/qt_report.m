classdef qt_report < hgsetget


    %------------------------------- Properties --------------------------------

    properties (SetObservable,AbortSet)

        % File format of the generated report
        %
        %   "format" is a string specifying the format to use when publishing
        %   the report. Valid format strings are: {'html'} or 'pdf'
        format = 'html';

        % Section index
        %
        %   "sectIdx" is a number specifying the current section to which
        %   modifications can be made.
        sectIdx = 1;

        % Report title
        %
        %   "title" is a string specifying the title to display at the top of
        %   the report
        title = '';

    end

    properties (SetAccess='protected')

        % Full file name of the report file
        %
        %   "reportFile" is the full file name of the generated report file.
        %   When using the HTML output format, the final file is stored in a
        %   sub-directory, "html", that contains all associated files
        reportFile = '';

        % Section code to be written
        %
        %   "code" is a cell array containing strings that specify the code to
        %   be used in generating each section of the report
        %
        %   See also qt_report.addsection and qt_report.rmsection
        code = {};

        % Section names
        %
        %   "sectNames" is a cell array containing strings that specify the
        %   title of each section of the report
        %
        %   See also qt_report.addsection and qt_report.rmsection
        sectNames = {};

        % Array of plot objects
        %
        %   "plots" is a cell array of qt_rptplot objects
        plots = {};

        % Array of table objects
        %
        %   "tables" is a cell array of qt_rpttable objects
        tables = {};

    end

    properties (Access='protected',Hidden)

        % Generating m-file object
        %
        %   "genFile" is an file_io object that interfaces the qt_reports object
        %   with the report generating script
        genFile = file_io.empty(1,0);

        % Temporary data file objects
        %
        %   "dataFiles" is an array of mat_io objects that interfaces data used
        %   in the generation of a report with the generating script
        dataFiles = mat_io.empty(1,0);

    end

    properties (Dependent,Hidden)

        % Current report code part indices
        %
        %   "codeInds" is a row vector of the report code part indices in the
        %   current section
        codeInds

        % Next usable report part index
        %
        %   "nextPartIdx" is a number specifying the report part index to use
        %   when adding code or a visualization
        nextPartIdx

        % Current report part indices
        %
        %   "partInds" is a row vector of the report part indices in the current
        %   section
        partInds

        % Current report plot part indices
        %
        %   "plotInds" is a row vector of the report plot part indices in the
        %   current section
        plotInds

        % Current report table part indices
        %
        %   "tableInds" is a row vector of the report table part indices in the
        %   current section
        tableInds

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_report(varargin)
        %qt_report  Constructs a QUATTRO reporting object
        %
        %   OBJ = qt_report(FILE) creates a reporting object, where FILE is a
        %   string specifying the full path of the report to be generated

            % Do nothing with no inputs
            if ~nargin
                return
            end

            %TODO: define an input parser
            [props,vals] = parse_inputs(varargin{:});

            for propIdx = 1:numel(props)
                obj.(props{propIdx}) = vals{propIdx};
            end

            % Instantiate the file writing object
            fName       = strrep(obj.reportFile,['.' obj.format],'.m');
            obj.genFile = file_io(fName,true);

            % Create the post-set listeners
            addlistener(obj,'format','PostSet',@obj.format_postset);

        end %qt_report.qt_report

    end %class constructor


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.codeInds(obj)
            val = [obj.code{obj.sectIdx}.partIdx];
        end %qt_report.get.codeInds

        function val = get.nextPartIdx(obj)
            val = max(obj.partInds)+1;
            if isempty(val)
                val = 1;
            end
        end %qt_report.get.nextPartIdx

        function val = get.partInds(obj)
            val = [obj.codeInds obj.plotInds obj.tableInds];
        end %qt_report.get.partInds

        function val = get.plotInds(obj)
            val = [obj.plots{obj.sectIdx}.partIdx];
        end %qt_report.get.plotInds

        function val = get.tableInds(obj)
            val = [obj.tables{obj.sectIdx}.partIdx];
        end %qt_report.get.tableInds

    end %get methods

end %qt_reports


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Validate that the input is not a directory
    if (exist(varargin{1},'dir')==7)
        error(['qt_report:' mfilename ':invalidFile'],...
               'FILE must be a valid file name.');
    end

    % Parse the file string
    [fDir,fName,fExt] = fileparts(varargin{1});

    % Validate the extension
    if ~any( strcmpi(fExt,{'.pdf','.html','.doc','.ppt','.xml'}) )
        warning(['qt_report:' mfilename ':invalidFileFrmt'],...
                ['"%s" file formats are not supported by qt_report, changing ',...
                 'format to "PDF".'],fExt);
        fExt = '.pdf';
    end

    % No directory likely means the user is looking for a file in the current
    % working directory
    if isempty(fDir)
        fDir = pwd;
    end

    % Deal the outputs
    varargout = {{'reportFile','format'},...
                 {fullfile(fDir,[fName fExt]),fExt(2:end)}};

end %parse_inputs