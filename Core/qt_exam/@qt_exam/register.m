function register(obj,varargin)
%register  Registers HGOs with a qt_exam object
%
%   register(OBJ,H) registers the figure handle specified by H to the QT_EXAM
%   object, OBJ. The QT_EXAM object and the QUATTRO figure handle ("hFig"
%   property) will be added to the application data of the specified figure
%   handle and any script data (set using SCRIPTDATA) will be added to the
%   QUATTRO GUI
%
%   register(OBJ,H1,H2,...) registers all figure handles (H's) as described
%   previously.

    % Catch multiple inputs and fire individually
    if nargin>2
        cellfun(@(x) obj.register(x),varargin);
    end

    % Determine what HGO the user has supplied
    if ~ishandle(varargin{1})
        warning(['qt_exam:' mfilename ':invalidHandle'],...
                          'Attempted to register an invalid HGO with QUATTRO.');
        return
    end

    % Add the QT_EXAM object(s) and the QUATTRO figure handle to application
    % data so that other applications can interact.
    setappdata(varargin{1},'qtExamObject',obj);
    setappdata(varargin{1},'linkedfigure',obj.hFig);

    % Add any script data to QUATTRO
    if isappdata(varargin{1},'qtScriptData')
        scriptdata(obj.hFig, getappdata(varargin{1},'qtScriptData'));
    end

    % Get/update the handles
    obj.hExtFig = [obj.hExtFig; varargin{1}];

end %qt_exam.register