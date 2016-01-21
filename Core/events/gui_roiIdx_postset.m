function gui_roiIdx_postset(~,eventdata)
%gui_roiIdx_postset  GUI post-set event for QT_EXAM property "roiIdx"
%
%   gui_roiIdx_postset(SRC,EVENT)

    % Get the handle information from QUATTRO
    obj = eventdata.AffectedObject; %QT_EXAM object alias
    hs  = guidata(obj.hFig);

    % Grab the new ROI index from the exam object, removing 0's from the array,
    % and update the list box value
    vals = obj.roiIdx.(obj.roiTag);
    vals = vals( logical(vals) );
    set(hs.listbox_rois,'Value',vals);

    % Update the ROI push button tools "enable" state when ROIs exist for the
    % specified "tag" and "roiIdx".
    if any(vals) && any(any( obj.rois.(obj.roiTag)(vals,:).validaterois ))
        set(hs.pushbutton_clone_roi,'Enable','on');
    else
        set([hs.pushbutton_copy,...
             hs.pushbutton_delete_roi,...
             hs.pushbutton_clone_roi],'Enable','off');
    end

    % Grab the current ROI and update the ROI stats (the stats boxes are cleared
    % during a "roiIdx" property pre-set event)
    %TODO: why is this here? There should be a better way to notify something
    %that the (QUATTRO GUI) ROI stats boxes need to be updated...
    if any(obj.roi(:).validaterois)
        set([hs.pushbutton_copy,...
             hs.pushbutton_delete_roi],'Enable','on');
        update_roi_stats([],struct('AffectedObject',obj.roi),obj.hFig);
    end

    % Update all ROI context menus
    update_roi_context_menus(hs.listbox_rois,obj);

end %gui_roiIdx_postset