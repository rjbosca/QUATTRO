function delete_roi_Callback(hObj,~)
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
        if (numel(vals)==1)
            cName = names{vals};
        else
            cName = ''; %initialize
            if (numel(vals)>2)
                cName = sprintf('%s, ',names{vals(1:end-2)});
            end
            cName = [cName sprintf('%s and %s',names{vals(end-1:end)})];
        end
        str = questdlg(['Delete all data from ' cName '?'],...
                        'Delete ROI Label(s)?','Yes','No','Yes');
        if isempty(str) || ~strcmpi(str,'yes')
            return
        end

        % Grab the ROIs to be deleted, which will be passed as event data to the
        % "roiChanged" event
        rois = obj.rois.(obj.roiTag)(vals,:,:);

    else %delete the current instance of an ROI

        % Grab the ROIs to be deleted, which will be passed as event data to the
        % "roiChanged" event
        rois = obj.roi;

    end

    % Delete the ROIs and notify the QT_EXAM object of the deletion, sending the
    % "roiChanged" event data object. A clone of the ROI will be added to the
    % undo stack and the ROI object will be deleted bye the "deleteroi" method.
    % This will also update a number of UI  controls, e.g., the ROI list box
    % through the "update_roi_tools" function
    obj.deleteroi(rois);
    notify(obj,'roiChanged');

    % Updates GUI according to remaining ROI information
    if ~obj.roi.validaterois
        set([findobj(hFig,'Tag','pushbutton_delete_roi')...
             findobj(hFig,'Tag','pushbutton_copy')], 'Enable','off');
    end
    update_controls(hFig,'Enable');

end %delete_roi_Callback