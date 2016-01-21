classdef qt_rptfig < qt_rptobjs


    %------------------------------- Properties --------------------------------
    properties

    end


    %---------------------------- Class Constructor ----------------------------
    methods

        function obj = qt_rptfig(varargin)
        %qt_rptfig  Constructor for qt_rptfig class
        %
        %   OBJ = qt_rptfig('PROP1',VAL1,'PROP2',VAL2,...) creates an instance
        %   of the qt_rptfig class, OBJ, setting the figure properties 'PROP1',
        %   'PROP2', etc. to the values specified by VAL1, VAL2, etc.
        %
        %   For more information regarding figure properties and values, see the
        %   FIGURE documentation

            % Parse the inputs
            [obj.data] = parse_inputs(varargin{:});

        end %qt_rptfig.qt_rptfig

    end %class constructor


    %------------------------- Abstract Implementations ------------------------
    methods

        function h = preview(obj)
        %preview  Previews the qt_rptfig object
        %
        %   H = preview(OBJ) provides a visualization of the qt_rptfig object,
        %   OBJ, as the figure should appear in the published report, returning
        %   the figure handle H.

            % Data must be present in order to show the plot
            if isempty(obj.data)
                return
            end

            % Create a new figure with the specified properties
            inputs                      = fieldnames(obj.data);
            inputs(1:2:2*numel(inputs)) = inputs;
            inputs(2:2:end)             = struct2cell(obj.data);
            h                           = figure(inputs{:});

        end %qt_rptfig.preview

        function code = part2code(obj)
        %part2code  Convert qt_rptfig object properties to publishable code
        %
        %   CODE = part2code(OBJ) converts the current qt_rptfig object, OBJ,
        %   properties to publishable code, CODE. CODE will be a cell column
        %   vector of strings, with each element of the column representing a
        %   new line of code.

            code = {};

        end %qt_rptfig.part2code

    end


end %qt_rptfig


%-------------------------------------
function vals = parse_inputs(varargin)

    % Initialize the outputs
    vals = struct([]);
    if ~nargin
        return
    end

    % Split the inputs
    [props,vals] = deal(varargin(1:2:end),varargin(2:2:end));

    % Validate that an equal number of properties and values was specified
    nVals  = numel(vals);
    nProps = numel(props);
    if (nVals~=nProps)
        error(['qt_report:' mfilename ':incommensuratePropVals'],....
               'The number of PROPS and VALS must be the same.');
    end

    %==========================
    % Parse the property names
    %==========================

    % Validate the property names. Use VALIDATESTRING for partial matching
    validProps = {'AlphaMap','Color','ColorMap','DoubleBuffer','IntegerHandle',...
                  'InvertHardcopy','MenuBar','Name','NextPlot','NumberTitle',...
                  'OuterPosition','PaperOrientation','PaperPosition',...
                  'PaperPositionMode','PaperSize','PaperType','PaperUnits',...
                  'Position','Renderer','RendererMode','Tag','ToolBar','Units'};
    props      = cellfun(@(x) validatestring(x,validProps),props,...
                                                         'UniformOutput',false);

    % Finally, before returning the validated inputs, sort the PROPS cell array
    % and create a structure of data to be saved. Sorting is performed as an
    % easy solution to the need for the 'Units' property to be updated first
    [props,idx] = sort(props);
    vals        = cell2struct(vals(idx(end:-1:1)),props(end:-1:1),2);

end %parse_inputs