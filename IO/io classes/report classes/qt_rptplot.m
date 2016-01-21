classdef qt_rptplot < qt_rptobjs & qt_rptvis


    properties

        % X-axis label
        %
        %   "xLabel" is a string specifying the label to be displayed on the
        %   x-axis
        xLabel = '';

        % Y-axis label
        %
        %   "yLabel" is a string specifying the label to be displayed on the
        %   y-axis
        yLabel = '';

        % Plot title
        %
        %   "name" is a string specifing the title of the plot
        name = '';

    end

    properties (Hidden,Dependent,Access='protected')

        % Input triples
        %
        %   'triples' is a cell array of strings and corresponding values
        %   specifying the required inputs of the PLOT function
        triples

        % Names of the input triples
        %
        %   'tripleNamess' is a cell array of strings corresponding the "data"
        %   property fields, specifying the required inputs of the PLOT function
        tripleNames

        % Input options
        %
        %   'options' is a cell array of string and corresponding values
        %   specifying the optional inputs of the PLOT function
        options

        % Names of the options input
        %
        %   'optionNames' is a cell array of strings corresponding the "data"
        %   property fields, specifying the optional inputs of the PLOT function
        optionNames

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_rptplot(varargin)
        %qt_rptplot  Construct a qt_rptplot object
        %
        %   OBJ = qt_rptplot(X,Y,S) creates a qt_rptplot object - OBJ - with
        %   data X/Y and format string S all of which are added to the "data"
        %   property. S is an optional input.
        %
        %   OBJ = qt_rptplot(X1,Y1,S1,X2,Y2,S2,...) creates a qt_rptplot object,
        %   OBJ, as described above for data sets X1/Y1, X2/Y2, etc and
        %   corresponding format strings S1, S2, etc.
        %
        %   OBJ = qt_rptplot(...,'PROP1',VAL1,...) performs the creation
        %   operation described previously in addition to modifying the plot
        %   properties 'PROP1', 'PROP2', etc using the corresponding values
        %   VAL1, VAL2, etc. Only certain line series properties are supported
        %   in addition to axes properties 'XLabel', 'YLabel', and 'Title'. The
        %   latter are not handles to the respective graphics ojects, but simply
        %   a string. 
        %
        %   For more information regarding PLOT inputs, see the PLOT
        %   documentation.

            % Parse the inputs
            [obj.data,props,vals] = parse_inputs(varargin{:});

            % Update the object properties
            for idx = 1:numel(props)
                obj.(props{idx}) = vals{idx};
            end

        end %qt_rptplot.qt_rptplot

    end %class constructor


    %------------------------- Abstract Implementations ------------------------
    methods

        function hFig = preview(obj)
        %preview  Previews the qt_rptplot object
        %
        %   preview(OBJ) provides a visualization of the qt_rptplot object, OBJ,
        %   as the plot should appear in the published report

            % Data must be present in order to show the plot
            if isempty(obj.data)
                return
            end

            % Create a new figure
            %TODO: qt_rptobjs will eventually contain a way of specifying
            %figures
            hFig = figure;

            % Grab the names of the input triples and options
            triples = obj.triples;
            opts    = obj.options;

            % Show the plot
            plot(triples{:},opts{:});

            % Append the x-/y-label and title if needed
            if ~isempty(obj.xLabel)
                xlabel(obj.xLabel);
            end
            if ~isempty(obj.yLabel)
                ylabel(obj.yLabel);
            end
            if ~isempty(obj.name)
                title(obj.name);
            end

        end %qt_rptplot.preview

        function code = part2code(obj)
        %part2code  Convert qt_rptplot object properties to publishable code
        %
        %   CODE = part2code(OBJ) converts the current qt_rptplot object, OBJ,
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

        end %qt_rptplot.part2code

    end


    %------------------------------- Get Methods -------------------------------
    methods

        function val = get.optionNames(obj)

            % Grab the field names
            val   = fieldnames(obj.data)';
            tFlds = obj.tripleNames;

            % Loop through each of the input triples, removing those strings
            % along the way
            for fld = tFlds
                val( strcmpi(fld{1},val) ) = [];
            end

        end %qt_rptplot.get.options

        function val = get.options(obj)

            % Get the names of all options
            oNames = obj.optionNames;
            nNames = numel(oNames);

            % Create the output
            val = cell(2*nNames,1);
            for idx = 1:nNames
                val{2*idx} = obj.data.(oNames{idx});
            end
            val(1:2:end) = oNames;

        end %qt_rptplot.get.options

        function val = get.tripleNames(obj)

            % Grab the field names
            flds = fieldnames(obj.data);

            % Loop through the total number of possible input triples
            %TODO: this code assumes that triples must be specified. See the
            %note in "parse_inputs" about making more robust code
            val = cell(1,3);
            for idx = 1:floor( numel(flds)/3 )
                xIdx = strcmpi(['x' num2str(idx)], flds);
                yIdx = strcmpi(['y' num2str(idx)], flds);
                sIdx = strcmpi(['s' num2str(idx)], flds);
                if any(xIdx)
                    val{3*(idx-1)+1} = flds{xIdx};
                    val{3*(idx-1)+2} = flds{yIdx};
                    val{3*(idx-1)+3} = flds{sIdx};
                end
            end

        end %qt_rptplot.get.tripleNames

        function val = get.triples(obj)

            % Get the names of all triples
            tNames = obj.tripleNames;
            nNames = numel(tNames);

            % Create the output
            val = cell(nNames,1);
            for idx = 1:nNames
                val{idx} = obj.data.(tNames{idx});
            end

        end %qt_rptplot.get.triples

    end %Get methods


    %---------------------------- Internal Methods -----------------------------
    methods (Hidden,Access='protected')

        function c = pdf_code(obj)

            
            %==========================
            % Prepare the PLOT options
            %==========================

            % Grab the plot options from "data" and print the options input
            % string
            props    = obj.optionNames;
            optsStr  = '';
            if ~isempty(props) %create the options string
                props   = repmat(props(:)',[2 1]);
                optsStr = sprintf('''%s'',%s,',props{:});
                optsStr = optsStr(1:end-1); %remove the extra comma
                optsStr = [',' optsStr]; %comma separator between opts/inputs
            end


            %=========================
            % Prepare the PLOT inputs
            %=========================

            % Grab the triples from "data" and print the input string
            tNames   = obj.tripleNames;
            inputStr = sprintf('%s,%s,%s,',tNames{:});
            inputStr = inputStr(1:end-1); %remove the extra comma

            % Before creating the actual code, ensure that the data has been
            % written. The data and options structures of the "data" property
            % must be concatenated
            s = obj.data;
            obj.dataFile.write('-struct','s');

            % Print the code
            c = {'figure;';...
                 ['load(''' obj.dataFile.file ''');'];...
                 ['plot(' inputStr optsStr ');']};
            if ~isempty(obj.xLabel)
                c{end+1} = ['xlabel(''' obj.xLabel ''');'];
            end
            if ~isempty(obj.yLabel)
                c{end+1} = ['ylabel(''' obj.yLabel ''');'];
            end
            if ~isempty(obj.name)
                c{end+1} = ['title(''' obj.name ''');'];
            end

        end %qt_rpttable.pdf_code

        function c = html_code(obj)

            c = {'%';'% <html><body>';...
                 sprintf('%% <img src="Figure_%d-%d.%s" style="width:%dpx;height:%dpx">',...
                         obj.sectIdx,obj.partIdx,obj.imageFormat,520,420);...
                 '% </body></html>';'%'};

        end %qt_rpttable.html_code

    end %internal methods

end %qt_rptplot


%----------------------------------------------------
function [vals,opts,optVals] = parse_inputs(varargin)

    % For the time being, data triples must be specified
    %TODO: add more robust input parsing to avoid this issue
    narginchk(3,inf);

    % Initialize the optional outputs
    [opts,optVals] = deal({});

    % Parse the triplets. Note that the following code assumes that at least one
    % triplet has been provided as input (see TODO above).
    for idx = 1:floor(nargin/3)

        % Deal the triplets
        vals.(['x' num2str(idx)]) = varargin{1};
        vals.(['y' num2str(idx)]) = varargin{2};
        vals.(['s' num2str(idx)]) = varargin{3};

        % Remove the triplets from the remaining input stack to be parsed
        varargin(1:3) = [];

        % Determine if there are any additional triplets
        if (numel(varargin)<3) || (~isnumeric(varargin{1}) ||...
                                   ~isnumeric(varargin{2}) ||...
                                   ~ischar(varargin{3}))
            break
        end

    end

    % At this point, the inputs can be returned to the constructor if no
    % additional properties were specified
    if isempty(varargin)
        return
    end

    % Split the remaining inputs
    [props,propVals] = deal(varargin(1:2:end),varargin(2:2:end));

    % Validate that an equal number of properties and values was specified
    nVals  = numel(propVals);
    nProps = numel(props);
    if (nVals~=nProps)
        error(['qt_report:' mfilename ':incommensuratePropVals'],....
               'The number of PROPS and VALS must be the same.');
    end

    %==========================
    % Parse the property names
    %==========================
    validProps = {'Clipping','Color','DisplayName','EraseMode','LineStyle',...
                  'LineWidth','Marker','MarkerEdgeColor','MarkerFaceColor',...
                  'MarkerSize','Parent','Tag','Title','XData','XDataMode',...
                  'xLabel','YData','yLabel','ZData'};
    try
        props  = cellfun(@(x) validatestring(x,validProps),props,...
                                                         'UniformOutput',false);
    catch ME
        rethrow(ME)
    end

    % Special case for 'xLabel', 'yLabel', and 'Title'
    propStrs = {'xlabel','ylabel','title'};
    for prop = propStrs
        propIdx = strcmpi(prop{1},props);
        if any( propIdx )
            opts(end+1)    = props(propIdx); %#ok
            optVals(end+1) = propVals(propIdx); %#ok
            props          = props(~propIdx);
            propVals       = propVals(~propIdx);
        end
        if strcmpi(prop{1},'title') %special case for 'Title'
            opts{end} = 'name';
        end
    end

    % Finally, append the values to the data structure
    for idx = 1:numel(props)
        vals.(props{idx}) = propVals{idx};
    end

end %parse_inputs