function deconstruct(obj,src,eventdata)
%deconstruct  Tears down an ROI object

    % Delete the roiview object
    viewObj = obj.roiViewObj;
    if ~isempty(viewObj)
        obj.roiViewObj.delete;
    end

end %qt_roi.deconstruct