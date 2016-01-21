function sliceIdx_postset(obj,src,~)
%sliceIdx_postset  Post-set event for QT_EXAM "sliceIdx" property
%
%   sliceIdx_postset(OBJ,SRC,EVENT)

    % Only update the display when the specified exam object is selected
    % currently
    if ~obj.isCurrent
        return
    end

    % Validate the new value of "sliceIdx"
    img = obj.image;
    if isempty(img) && ~isempty(obj.imgs)
        % Grab the size of the image stack to enforce the upper bound on the
        % slice index
        m = size(obj.imgs);

        % Reset "sliceIdx" to the largest possible value. Since the lower bound
        % (i.e. an index less than 1) is handled in the "seriesIdx" set method
        % there is no need to verify that here...
        obj.(src.Name) = m(1);

        % Notify the user that the upper bound was hit
        warning(['qt_exam:' mfilename ':invalidSliceIndex'],...
                ['An error occured while setting: "%s"',...
                 '"%s" exceeds the number of image slices, and was reset',...
                 'to the maximum extent of the imaging volume: %d'],...
                  src.Name,src.Name,m(1));
        return
    end

    % Determine if maps exist on the current slice
    if obj.exists.maps.any
        obj.exists.maps.current = ~isempty(obj.mapNames);
    end

    % Determine if ROIs exist on the current slice and update the QT_ROI object
    % "state" property to ensure that the ROIs are visulaized
    roi                     = obj.roi;
    obj.exists.rois.current = any(roi(:).validaterois);
    if obj.exists.rois.current
        [roi(:).state] = deal('on'); %#ok
    end

    % Update the image display. Since this post-set event requires that image
    % data exist (the display for which is initialized following the load
    % operation), simply find the old QT_IMAGE object to be replaced from the
    % QUATTRO figure and update the view on all axes on which that old image is
    % being displayed
    if ~isempty(obj.hFig) && ~isempty(obj.image)
        oldObj = getappdata(obj.hFig,'qtImgObject');
        obj.image.show(oldObj);
    end

end %qt_exam.sliceIdx_postset