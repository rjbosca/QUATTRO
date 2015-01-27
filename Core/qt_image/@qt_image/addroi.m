function addroi(obj,roi)
%addroi  Adds a qt_roi object to the image object
%
%   addroi(OBJ,ROI) registers the qt_roi object ROI to the qt_image object OBJ,
%   updating scale information and displaying if necessary

    % Validiate the ROI
    if ~strcmpi( class(roi), 'qt_roi' )
        error(['qt_image:' mfilename ':invalidROI'],...
                                       'Linked ROIs must be of class "qt_roi"');
    end

    % Get only validated ROI objects
    hRoi = obj.roiObj;
    if any(hRoi==roi) %don't re-register the same ROI object
        return
    end

    % Combine the ROI objects
    obj.roiObj = [hRoi roi];

    % A note on reciprocity: Images are automatically registered with ROI objects
    % when setting the "hAx" property of an ROI. This has caused some confusion
    % in the past...

    % When an ROI is presented for registration with an image object, there is
    % nothing preventing an empty "scale" property. To circumvent this, the
    % property is updated according to the image object if no prior information
    % exists
    if isempty(roi.scale)
        roi.scale = obj.imageSize;
    end

    % Notify any image view objects of the change
    if ~isempty(obj.imgViewObj)
        roi.show([obj.imgViewObj.hAxes]);
    end

end %qt_image.addroi