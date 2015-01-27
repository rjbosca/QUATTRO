function listbox_value_postset(src,eventdata)
%listbox_value_postset  PostSet event for QUATTRO ROI listbox
%
%   listbox_value_postset(SRC,EVENT)

    % Get the UI control handle and validate the action
    hList  = eventdata.AffectedObject;
    if ~strcmpi( get(hList,'Style'), 'listbox' )
        warning(['QUATTRO:' mfilename ':invalidListHandle'],...
                 'Event calls to %s must originate from a listbox UI control.',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'value')
        warning(['QUATTRO:' mfilename ':invalidListEvent'],...
                 'Event calls to %s must originate from a "%s" PostSet event.',...
                 mfilename,src.Name);
        return
    end

    % Get the new value
    val = get(hList,'Value');
    if isempty(val)
        val = 0;
    end

    % Update other associated controls
    hFig     = guifigure(hList);
    hs       = guihandles(hFig);
    hContext = get(hList,'UIContextMenu');
    hKids    = get(hContext,'Children');
    hKids    = hKids( ~strcmpi('context_order',get(hKids,'Tag')) ); %this tag is
                                                                    %handled in the 
                                                                    %string PostSet

    % Grab the qt_exam object to update the "roiIdx" property to refelect the
    % new value and notify the "update_roi_stats" event to ensure proper stats
    % display
    obj                     = getappdata(hFig,'qtExamObject' );
    obj.roiIdx.(obj.roiTag) = val;

    % Update UI controls enable state when ROIs exist for the specified label
    % and ROI index. These values must be handled separately from an ROI
    % existing on the current view
    if all(val>0) && any(any( obj.rois.(obj.roiTag)(val,:).validaterois ))
        set([hKids' hs.pushbutton_clone_roi],'Enable','on');
    else
        set([hs.pushbutton_copy,...
             hs.pushbutton_delete_roi,...
             hs.pushbutton_clone_roi,...
             hKids'],'Enable','off');
    end

    % Grab the current ROI and update the ROI stats (the stats boxes are cleared
    % during a listbox value PreSet event)
    if any(obj.roi(:).validaterois)
        set([hs.pushbutton_copy hs.pushbutton_delete_roi],'Enable','on');
        update_roi_stats([],struct('AffectedObject',obj.roi),obj.hFig);
    end

end %listbox_value_postset