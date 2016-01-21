function addroiundo(obj,roi,undoType)
%addroiundo  Creates an ROI undo instance
%
%   addroiundo(OBJ,ROI,TYPE) creates an ROI undo instance for the QT_EXAM object
%   specified by OBJ, using the QT_ROI object ROI (a member of the QT_EXAM ROI
%   storage) and the modification event specified by TYPE. TYPE is a string,
%   either 'moved' or 'deleted'. The newly created instance of the ROI undo is
%   placed on the undo stack
%
%   See also qt_exam.undoroi

    narginchk(3,3);

    % Determine the number of ROIs. For arrays, call this method via ARRAYFUN
    nRoi = numel(roi);
    if (nRoi>1)
        arrayfun(@(x) obj.addroiundo(x,undoType),roi);
        return
    end

    % Validate the undo type
    undoType = validatestring(undoType,{'moved','deleted'});

    % Determine if the ROI is part of the stack (an assumption of this code)
    if ~isfield(obj.rois,roi.tag)
        error(['qt_exam:' mfilename ':invalidRoiTag'],...
              ['"%s" is not an ROI tag on the QT_EXAM object''s ROI stack. ',...
               'The input ROI must be on the QT_EXAM objects''s stack.'],roi.tag);
    end
    roiMask = (roi==obj.rois.(roi.tag));
    if ~any(roiMask(:))
        error(['qt_exam:' mfilename ':invalidRoi'],...
              ['The supplied ROI input could not be located on the QT_EXAM ',...
               'object''s ROI stack. The input ROI must on the stack.']);
    end

    % Locate the ROI location
    [index{1:3}]              = deal(1);
    [index{1:ndims(roiMask)}] = find(roiMask);

    % Clone the ROI
    roiClone = roi.createroiundo(undoType);

    % Create the undo structure to store. The index variable should be a
    % 3-element cell array contained in a cell (for other functions). This might
    % change in a future release
    %TODO: is there a way to make "index" a single 3-element cell array instead
    %of a nested cell???
    undo = struct('roi',roiClone,'type',undoType,'index',{{index}});

    % Grab the current undo structure
    currentUndo = obj.roiUndo;
    if isempty(currentUndo)
        obj.roiUndo = undo;
    else
        obj.roiUndo = [currentUndo;undo];
    end

end %qt_exam.addroiundo