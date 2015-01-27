function show(obj,varargin)
%show  Displays the ROI
%
%   show(OBJ) displays the ROIs specified by the qt_roi object, OBJ, on all
%   images specified in the property "hAx". If none exist, the ROI is displayed
%   in a new figure.
%
%   show(OBJ,HAX) displays data in the manner defined previously on the axis
%   specified by the handle HAX. HAX can also be an array of handles.

    % Check the number of input arguments
    narginchk(2,2);

    % Catch calls for arrays of ROI objects
    if numel(obj)>1
        arrayfun(@(x) show(x,varargin{:}),obj);
        return
    end

    % Parse inputs and pass to the imgview object
    hAxNew = []; %initialize
    if nargin>1
        [hAxNew] = parse_inputs(varargin{:});
    elseif obj.roiViewObj.isvalid
        hAxNew = {obj.hAx};
    end

    % **IMPORTANT** An roiview object must always be created during valid calls
    % to the "show" method, even when the qt_roi object "state" property is
    % 'off'. This ensures that future changes to the "state" property will
    % result in appropriate display updates

    % Determine if any previous displays exist. When all requested axes have
    % already been used by an roiview object, then there is nothing left to do.
    hAxOld = [obj.roiViewObj.hAxes];
    if ~isempty(hAxOld)
        isShown = cellfun(@(x) any(hAxOld==x),hAxNew);
        hAxNew  = hAxNew(isShown);
    end
    if isempty(hAxNew)
        return
    end

    % Determine the number of new roiview objects that must be created and
    % create them
    nAxNew                           = numel(hAxNew);
    obj.roiViewObj(end+1:end+nAxNew) = roiview(obj);

    % Store te axes (firing ROI display)
    [obj.roiViewObj(:).hAxes] = deal(hAxNew{:});

end %qt_roi.show


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Deal empty outputs
    [varargout{1:nargout}] = deal([]);

    % Set up the parser
    parser = inputParser;
    parser.addOptional('axes',[],@(x) all(ishandle(x)) &&...
                                         all( strcmpi('axes',get(x,'Type')) ) );

    % Parse and deal outputs
    parser.parse(varargin{:});
    varargout{1} = struct2cell(parser.Results);

end %parse_inputs