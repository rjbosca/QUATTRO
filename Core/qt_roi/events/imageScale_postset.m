function imageScale_postset(src,eventdata)
%imageScale_postset  PostSet event for roiview property "imageScale"
%
%   imageScale_postset(SRC,EVENT) updates the scale of the parent qt_roi object
%   after the "imageScale" property is set. Changes are only made if the scale
%   has not been initialized otherwise.

    % Grab the roiview object
    obj = eventdata.AffectedObject;

    % Set the ROI scale
    if isempty(obj.roiObj.scale)
        obj.roiObj.scale = obj.imageScale;
    end

    % Since the extent of the current ROI is dependent on the scale of the ROI,
    % take this opportunity to update the "roiExtent" property via the
    % "calcroiextent" method
    obj.calcroiextent;

end %roiview.imageScale_postset