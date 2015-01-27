function qim_listbox_rois_string_postset(src,eventdata)
%qim_listbox_rois_string_postset  PostSet event for QUATTRO's ROI listbox "String" property
%
%   qim_listbox_rois_string_postset(SRC,EVENT) handles changes to the "String"
%   property of QUATTRO's ROI listbox UI using the listbox handle object (SRC)
%   and event data (EVENT) objects. Specifically, the list of ROIs available for
%   the modeling GUI are updated according to the strings stored in the QUATTRO
%   listbox

    % Get UI control handle and validate the event call
    hList = eventdata.AffectedObject;
    if ~strcmpi( get(hList,'Style'), 'listbox' )
        warning(['QUATTRO:' mfilename ':invalidHandleStyle'],...
                 'Event calls to %s must originate from a listbox UI control',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'String')
        warning(['QUATTRO:' mfilename ':invalidListboxEvent'],...
                 'Event calls to %s must originate from a "String" PostSet event.',...
                 mfilename);
        return
    end

    % Grab the qt_exam object and all associated modeling objects
    hFig = guifigure(eventdata.AffectedObject);
    mObj = getappdata(hFig,'modelsObject');
    mObj = mObj( ~isempty([mObj.hFig]) );
    if isempty(mObj)
        return
    end

    % Grab the modeling GUI handles
    hs = guihandles(mObj.hFig);

    % Determine the available options based on the new listbox string
    if isempty(hList.String)
        modes = {'','Cur. Pixel'};
    else
        modes = {'','Cur. Pixel','Cur. ROI Proj.','Cur. ROI','VOI'};
    end

    % Determine how to change the current value. The only case that must be
    % considered is in the event that ROIs existed, but have been deleted
    if get(hs.popupmenu_data,'Value')>numel(modes)
        set(hs.popupmenu_data,'Value',1);
        setappdata(mObj.hFig,'dataMode','none');
    end    
    set(hs.popupmenu_data,'String',modes)

    % Update the ROI selection pop-up menu
    set(hs.popupmenu_roi,'String',hList.String);
    if get(hs.popupmenu_data,'Value')>2
        set(hs.popupmenu_roi,'Visible','on');
    end

end %qim_listbox_rois_string_postset