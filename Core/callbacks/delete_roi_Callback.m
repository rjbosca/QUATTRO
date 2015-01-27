function delete_roi_Callback(hObj,eventdata)
%delete_roi_Callback  Callback for ROI or ROI label deleteion requests
%
%   delete_roi_Callback(H,EVENT)

    % Context menu "Delete" calls have special functionality. Namely, these
    % calls remove the entire ROI label instead of a single ROI instance.
    % However, the call should appear to originate from the ROI listbox
    isRmLabel = strcmpi(get(hObj,'Tag'),'context_delete');
    if isRmLabel
        hObj  = getappdata(get(hObj,'Parent'),'listboxhandle');
    end

    % Get GUI info
    hFig = gcbf;
    obj  = getappdata(hFig,'qtExamObject');
    if ~isRmLabel && ~any(obj.roi.validaterois)
        return
    end

    % Perform deletion
    if isRmLabel %remove an entire ROI label

        % Confirm label delete
        names = get(hObj,'String');
        vals  = get(hObj,'Value');
        if ~cine_dlgs('delete_roi_label',names(vals))
            return
        end

        % Remove labels and update GUI
        obj.rois.(obj.roiTag)(vals,:,:).delete;

    else %delete the current instance of an ROI

        % Create undo data for the ROI to be deleted and delete the ROI. Include
        % the ROI name and scale so that the ROI can be restored properly if the
        % undo button is pressed.
        roi = obj.roi;

        % Clone the ROI to be stored in the "roiUndo" stack
        roiNew = roi.clone('name','scale','tag');

        % The QUATTRO PostSet listener must be added here
        fcn = @(src,event) update_roi_stats(src,event,hFig);
        for roiObj = roiNew(:)'
            addlistener(roiObj,'roiStats','PostSet',fcn);
        end

        % Create the undo and delete the original ROI object
        obj.addroiundo(roiNew,'deleted');
        roi.delete;

    end

    % Notify the exam object of the deletion
    notify(obj,'roiDeleted');
    update_roi_listbox(hFig); %update after removing the deleted ROIs

    % Updates GUI according to remaining ROI information
    if ~obj.exists.rois.any
    %     update_controls(hFig,'hide');
    end
    if ~obj.roi.validaterois
        set([findobj(hFig,'Tag','pushbutton_delete_roi')...
             findobj(hFig,'Tag','pushbutton_copy')], 'Enable','off');
    end
    update_controls(hFig,'enable');

end %delete_roi_Callback