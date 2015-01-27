function update_roi_listbox(hFig)
%update_roi_listbox  Applies conditional changes to the ROI listbox
%
%   update_roi_listbox(H) applies changes to the ROI listbox child of the
%   QUATTRO instance specified by H.

    % Validate that QUATTRO called this function
    if ~strcmpi( get(hFig,'Name'), qt_name )
        return
    end

    % Get the exams object and various handles. Attempt to grab the requested
    % ROIs
    obj     = getappdata(hFig,'qtExamObject');
    hList   = findobj(hFig,'Tag','listbox_rois');
    rois    = obj.rois.(obj.roiTag);
    isValid = any( rois(:,:).validaterois, 2 );

    % Get current listbox index and ROI names
    names           = obj.roiNames.(obj.roiTag);
    nRoi            = size(rois(isValid,:,:),1);
    vals            = get(hList,'Value');
    vals(vals>nRoi) = [];

    % Update listbox values
    if isempty(vals) && isempty(names)
        set(hList,'String',{},'Value',[]);
    elseif isempty(vals)
        set(hList,'String',names,'Value',nRoi);
    elseif ~isempty(vals) && nRoi>1
        set(hList,'Max',nRoi,'String',names,'Value',vals);
    elseif ~isempty(vals) && nRoi<=1
        set(hList,'Max',2,'String',names,'Value',vals);
    end

end %update_roi_listbox