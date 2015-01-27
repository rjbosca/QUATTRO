function roiTag_postset(obj,src,eventdata)
%roiTag_postset  PostSet event for qt_exam property "roiTag"
%
%   roiTag_postset(OBJ,SRC,EVENT) performs validation on the "rois" and "roiIdx"
%   properties of the qt_exam object OBJ to ensure that fields for exist for the
%   value of the "roiTag" property. SRC and EVENT are unused. ROI displays are
%   also updated

    % Determine if the new value for "roiTag" has been created previously. If
    % need be, simply create a field with an empty qt_roi object and a field for
    % the ROI index
    tag = obj.roiTag;
    if ~isfield(obj.rois,tag)
        obj.roiIdx.(tag) = 0; %define the index first, since updating the ROI
                              %storage will result in the notification of a
                              %number of listeners
        obj.rois.(tag)   = qt_roi.empty(1,0);
    end

    % Now that the state of the qt_exam object has been updated, grab the
    % current ROI and update the display
    rois = obj.rois.(tag);
    if any( rois(:).validaterois )
        [rois(obj.roiIdx.(tag),:).state] = deal('on'); %#ok - faster than accessing obj.rois...
    end

end %qt_exam.roiTag_postset