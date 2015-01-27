function undoroi(obj)
%undoroi  Reverts a pre-modification ROI
%
%   undoroi(OBJ) undoes modifications performed on ROIs stored in the qt_exam
%   object OBJ using the data stored in the "roiUndo" property. Every call to
%   "undoroi" removes data at the end of the stack; if the undo stack is empty,
%   no actions are performed.

    undo = obj.roiUndo(end);
    if isempty(undo)
        return
    end

    % Perform undo type specific operations: (1) 'moved' only requires reverting
    % coordinates, (2) 'deleted' requires
    if strcmpi(undo.type,'moved')

        roiTag = undo.roi.tag; %alias for readability

        % Store the old position and notify the ROI that a manual update is
        % required 
        %TODO: as the code is written now, a "moved" ROI is assumed to have
        %occured for only one ROI object. Should this be changed in the future
        %to account for moving multiple ROI objects?
        obj.rois.(roiTag)(undo.index{1}{:}).position = undo.roi.position;
        notify(obj.rois.(roiTag)(undo.index{1}{:}),'newManualPosition');

    elseif strcmpi(undo.type,'deleted')

        % Add the ROI to the original position
        for undoIdx = 1:numel(undo.roi)
            obj.addroi(undo.roi(undoIdx),'roi',   undo.index{undoIdx}{1},...
                                         'slice', undo.index{undoIdx}{2},...
                                         'series',undo.index{undoIdx}{3});
        end

    else
        error(['qt_exam:' mfilename ':invalidType'],...
                            '"%s" is not a valid modification type.',undo.type);
    end

    % Fire the stats computation to initialize the ROI before removing from the
    % undo structure
    arrayfun(@(x) qt_roi.calcstats(x),undo.roi);

    % Remove the end of the stack
    obj.roiUndo(end) = [];

end %qt_exam.undoroi