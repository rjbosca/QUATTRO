function newObj = clone(obj,varargin)
%clone  Clones a qt_roi object
%
%   OBJCLONE = clone(OBJ) creates a new clone of the qt_roi object OBJ, and
%   returns the unique clone OBJCLONE. Only the position, ROI type, and color
%   are cloned.
%
%   OBJCLONE = clone(OBJ,PARAM1,PARAM2,...) clones the properties defined
%   previously in addition to those properties defined by the input strings
%   PARAM1, PARAM2, etc.

    % Catch an array of ROIs and refire the "clone" method on the individual
    % qt_roi objects
    nObj = numel(obj);
    if (nObj>1)

        % Because arrayfun cannot handle returning arrays of arbitrary classes,
        % a loop must be used to generate the clone of an array of qt_roi
        % objects
        mObj              = num2cell( size(obj) );
        newObj            = qt_roi.empty(mObj{:},0);
        newObj(mObj{:},1) = qt_roi;

        % Now that the empty index has been removed, loop through each qt_roi
        % object and clone/store the object for output
        for objIdx = 1:nObj
            newObj(objIdx) = obj(objIdx).clone(varargin{:});
        end

        return

    end

    % Ensure that the specified object is a valid ROI. When passing an array of
    % objects, this is especially important as some of the objects in the array
    % might have been created from null filling
    if ~any(obj.validaterois)
        newObj = qt_roi;
        return
    end

    % Parse the inputs
    props = parse_inputs(varargin{:});

    % Generate a new qt_roi object using only those details needed reconstruct the
    % qt_roi object. This method is used mainly in copying ROIs associated with a
    % qt_exam object
    newObj = qt_roi(obj.position,obj.type);

    % Using the properties defined by the user (or the default property), update
    % the cloned object
    for pIdx = 1:length(props)
        newObj.(props{pIdx}) = obj.(props{pIdx});
    end

end %qt_roi.clone


%------------------------------------------
function varargout = parse_inputs(varargin)

    % Add the default property 'color' to the list
    varargin{end+1} = 'color';
    varargin        = unique(varargin);

    % Validate the requested properties against the qt_roi properties
    roiProps     = properties(qt_roi);
    varargout{1} = cellfun(@(x) validatestring(x,roiProps),varargin,...
                                                         'UniformOutput',false);
end %parse_inputs