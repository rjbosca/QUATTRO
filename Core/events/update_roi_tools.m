function update_roi_tools(obj,eventdata)
%update_roi_tools  Updates the QUATTRO GUI following changes to ROI data
%
%   update_roi_tools(OBJ,EVENT) updates the various ROI UI tools using the
%   QT_EXAM object OBJ and the event data object EVENT. EVENT must be generated
%   from an 'roiChanged' event.

    % Validate the event source
    if ~any( strcmpi(eventdata.EventName,{'roiChanged'}) )
        error(['QUATTRO:' mfilename ':invalidEventSrc'],...
               'Only calls from QT_EXAM events ''roiChanged'' are allowed.');
    end

    % Grab the exam object, the rois, and some handles
    rois = obj.rois;
    hs   = guidata(obj.hFig);

    % Determine if any ROIs exist on the current tag or in general
    isAnyRois = any( cellfun(@(x) any(x(:).validaterois),struct2cell(rois)) );

    % Update the ROI context menus
    if isAnyRois
        set([hs.uipanel_roi_stats
             hs.uipanel_roi_tools
             hs.uipanel_roi_labels
             hs.listbox_rois
             hs.popupmenu_stats
             hs.pushbutton_clone_roi
             hs.pushbutton_paste_to_all
             hs.pushbutton_delete_roi
             hs.pushbutton_paste
             hs.pushbutton_copy
             hs.pushbutton_undo],'Visible','on');

    else %ROIs do not exist; disable/hide conrols
        set(hs.listbox_rois,'String',{},'Enable','off');
        hVisOff = [hs.uipanel_roi_stats
                   hs.popupmenu_stats
                   hs.pushbutton_clone_roi
                   hs.pushbutton_delete_roi
                   hs.pushbutton_copy];

        % Only disable/hide if no undo data exist
        if isempty(obj.roiUndo)
            hVisOff(end+1) = hs.pushbutton_undo;
        end

        % Only disable/hide if no ROI copy data exist
        if ~obj.roiCopy.validaterois
            hVisOff(end+1:end+2) = [hs.pushbutton_paste_to_all
                                    hs.pushbutton_paste];
        end

        set(hVisOff,'Visible','off');

    end

    % Prepare listbox and associated context menus
    update_roi_listbox(hs.listbox_rois,obj);

    % Create the context menus
    update_roi_context_menus(hs.listbox_rois);

    % UI controls with respect to the updated ROIs
    update_controls(hs.figure_main,'enable');

end %update_roi_tools