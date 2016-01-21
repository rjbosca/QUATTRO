function seriesIdx_postset(obj,src,~)
%seriesIdx_postset  Post-set event for the QT_EXAM "seriesIdx" property
%
%   seriesIdx_postset(OBJ,SRC,EVENT)

    % Only update the display when the specified exam object is selected
    % currently
    if ~obj.isCurrent
        return
    end

    % Validate the new value by attempting to grab one of the images
    img = obj.image;
    if isempty(img) && ~isempty(obj.imgs)

        % Grab the size of the image stack to enforce the upper bound on the
        % slice index
        m = size(obj.imgs);

        % Reset "seriesIdx" to the largest possible value. Since the lower bound
        % (i.e. an index less than 1) is handled in the "seriesIdx" set method
        % there is no need to verify that here...
        obj.(src.Name) = m(2);

        % Notify the user that the upper bound was hit
        warning(['qt_image:' mfilename ':invalidSeriesIndex'],...
                ['An error occured while setting: "%s"\n',...
                 '"%s" exceeds the number of images in the series, and\n',...
                 ' was reset to the maximum extent of the imaging volume: %d\n'],...
                  src.Name,src.Name,m(2));

        return
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
    % operation), simply find the QT_IMAGE object from the QUATTRO figure and
    % replace the old views with the new view at the specified "sliceIdx"
    % position
    if ~isempty(obj.image)
        oldObj = getappdata(obj.hFig,'qtImgObject');
        obj.image.show(oldObj);
    end

end %qt_exam.seriesIdx_postset