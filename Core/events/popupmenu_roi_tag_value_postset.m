function popupmenu_roi_tag_value_postset(src,eventdata)
%popupmenu_roi_tag_value_postset  PostSet event for QUATTRO ROI tag pop-up menu
%
%   popupmenu_roi_tag_value_postset(SRC,EVENT) updates the qt_exam property
%   "roiTag" and QUATTRO ROI displays, where SRC and EVENT are the source and
%   event data, respectively

    % Get the UI control handle and validate the action
    hPop = eventdata.AffectedObject;
    if ~strcmpi( get(hPop,'Style'), 'popupmenu' )
        warning(['QUATTRO:' mfilename ':invalidPopupHandle'],...
                 'Event calls to %s must originate from a pop-up menu UI control.',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'Value')
        warning(['QUATTRO:' mfilename ':invalidPopupEvent'],...
                 'Event calls to %s must originate from a "%s" PostSet event.',...
                 mfilename,src.Name);
        return
    elseif (hPop.Value==getappdata(hPop,'currentvalue'))
        return
    end

    % Get the handles structure, new value and all of the strings for the pop-up
    % menu
    hs   = guihandles( guifigure(hPop) );
    val  = hPop.Value;
    strs = cellfun(@lower,hPop.String, 'UniformOutput',false);

    % Grab the exams object and update the "roiTag" property
    obj        = getappdata(hs.figure_main,'qtExamObject');
    obj.roiTag = strs{val};

    % Hide the "Use As" sub-menu associated with the current value of the pop-up
    % menu
    set(hs.(['context_use_as_' strs{val}]),'Visible','off');
    strs(val) = []; %remove the current string
    
    % Set all the sub-menus (not the one associated with the current value of
    % the pop-up menu) to be enabled
    cellfun(@(x) set(hs.(['context_use_as_' x]),...
                                            'Enable','On','Visible','on'),strs);

    % Update the listbox, "Go to"->"Slice" context menus, and the current value
    % for the UI control
    update_roi_listbox(hs.listbox_rois,obj);
    update_roi_context_menus(hs.listbox_rois);
    setappdata(hPop,'currentvalue',val);

end %popupmenu_roi_tag_value_postset