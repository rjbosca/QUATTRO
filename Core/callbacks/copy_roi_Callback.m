function copy_roi_Callback(hObj,eventdata)
%copy_roi_Callback  Callback for handling copy ROI requests

    % Copy selected ROI/update GUI
    obj = getappdata(gcbf,'qtExamObject');

    % Copy the current ROI
    obj.copyroi;

end %copy_roi_Callback