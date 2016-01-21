function roiDeleted_event(obj,~,eventdata)
%roiDeleted_event  Callback for QT_EXAM "roisDeleted" event
%
%   roiDeleted_event(OBJ,SRC,EVENT) updates ROI existence fields and collapses
%   the ROI index as needed for the qt_exam object specified by OBJ

    % Validate the event
    if ~strcmpi(eventdata.EventName,'roiDeleted')
        warning(['qt_exam:' mfilename ':invalidEvent'],...
                 '%s is only defined for the qt_exam event "roisDeleted"',...
                 mfilename);
        return
    end


    %--------------------
    % ROI Stack Clean-up
    %--------------------

    % This function got complicated after changing the structure of the ROI
    % storage. Now, all fields of the "rois" property must be checked for
    % existing data
    rois    = obj.rois;
    nLabels = size(rois.(obj.roiTag),1);
    for tag = fieldnames(obj.rois)'

        % Squeeze out empty indices and store in the structure of qt_roi objects
        rois.(tag{1}) = obj.squeeze_roi_stack(rois.(tag{1}));

    end

    % Store the updated ROI array in the qt_exam object
    obj.rois = rois;

    % By updating the "rois" property above, a number of other post-set events
    % are fired that modify, as necessary, properties such as "roiIdx". At this
    % point, a special case must be handled. Namely, when an ROI label has been
    % removed, there is no mechanism to notify any attached displays that the
    % "roiIdx" (which hasn't changed unless the label was at the end of the
    % stack "rois") now represents a new ROI
    if (nLabels~=size(rois.(obj.roiTag),1))
        roiIdx_postset([],struct('AffectedObject',obj));
    end

end %qt_exam.roiDeleted_event