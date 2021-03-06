function undo_Callback(hObj,~)
%undo_Callback  Callback for handling undo requests
%
%   undo_Callback(H,EVENT) performs an "undo" operation following activation of
%   the "Undo" pushbutton specified by the handle H. Event data, EVENT, is
%   currently unused

    % Validate the input
    if ~strcmpi( get(hObj,'Style'), 'pushbutton' ) ||...
                                  ~strcmpi( get(hObj,'Tag'), 'pushbutton_undo' )
        warning(['QUATTRO:' mfilename ':invalidCaller'],...
                 '%s must be called by the undo pushbutton.',mfilename);
        return
    end

    % Undo previous action and update GUI
    hs   = guidata(hObj);
    obj  = getappdata(hs.figure_main,'qtExamObject');

    % Fire the "roiundo" method to update the QT_EXAM object
    undo = obj.undoroi;
    if isempty(undo)
        return
    end

    % Attach the appropriate listeners to the QT_ROI object and notify the
    % QT_EXAM object that changes have occured to the ROIs
    if strcmpi(undo.type,'deleted')
        fcn = @(src,event) update_roi_stats(src,event,hs.figure_main);
        addlistener(undo.roi,'roiStats','PostSet',fcn);
    end
    notify(obj,'roiChanged');

    % Move the slice/series indices and associated QUATTRO sliders
    [obj.sliceIdx,obj.seriesIdx] = deal(undo.index{1}{2:3});
    if (get(hs.slider_slice,'Value')~=obj.sliceIdx)
        set(hs.slider_slice,'Value',obj.sliceIdx);
    end
    if (get(hs.slider_series,'Value')~=obj.seriesIdx)
        set(hs.slider_series,'Value',obj.seriesIdx);
    end

    % Update the "roiTag" property and associated pop-up menu selection
    roiTag    = undo.roi(1).tag;
    roiTags   = get(hs.popupmenu_roi_tag,'String');
    newTagVal = find( strcmpi(roiTag,roiTags) );
    if (getappdata(hs.popupmenu_roi_tag,'currentvalue')~=newTagVal)
        set(hs.popupmenu_roi_tag,'Value',newTagVal);
    end
    
    % Update "roiIdx" and the associated listbox values
    obj.roiIdx.(roiTag) = cellfun(@(x) x{1},undo.index);
    listVals            = get(hs.listbox_rois,'Value');
    if (numel(listVals)~=numel(obj.roiIdx.(roiTag))) ||...
                               any(listVals(:)~=obj.roiIdx.(undo.roi(1).tag)(:))
        set(hs.listbox_rois,'Value',obj.roiIdx.(undo.roi(1).tag));
    end

end %undo_Callback