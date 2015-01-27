function register(obj,varargin)
%register  Registers HGOs with a qt_exam object
%
%   register(OBJ,H) registers the figure handle specified by H to the qt_exam
%   object, OBJ. The qt_exam object and the QUATTRO figure handle (OBJ.hFig)
%   will be added to the application data for the specified figure handle.
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

    % Add the exams object and the figure handle to application data so that
    % other applications can interact.
    setappdata(varargin{1},'qtExamObject',obj);
    setappdata(varargin{1},'linkedfigure',obj.hFig);

    % Get/update the handles
    obj.hExtFig = [obj.hExtFig; varargin{1}];

end %qt_exam.register