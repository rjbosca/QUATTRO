function roisdeleted(obj,src,eventdata)
%roisdeleted  qt_exam 'roiDeleted' event handler
%
%   roisdeleted(OBJ,SRC,EVENT) updates ROI existence fields and collapses the
%   ROI index as needed for the qt_exam object specified by OBJ

    % Validate the event
    if ~strcmpi(eventdata.EventName,'roiDeleted')
        warning(['qt_exam:' mfilename ':invalidEvent'],...
              'roisdelted is only defined for the qt_exam event "roisDeleted"');
        return
    end

    % This function got complicated after changing the structure of the ROI
    % storage. Now, all fields of the "rois" property must be checked for
    % existing data
    rois = src.rois;
    for tag = fieldnames(src.rois)'

        % Squeeze out empty indices and store in the 
        rois.(tag{1}) = src.squeeze_roi_stack(rois.(tag{1}));

    end %fld

    % Store the updated ROI array in the qt_exam object
    src.rois = rois;

end %roisdeleted