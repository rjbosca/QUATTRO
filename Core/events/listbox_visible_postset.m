function listbox_visible_postset(src,eventdata)
%listbox_visible_postset  PostSet event handler for QUATTRO listbox UI controls
%
%   listbox_visible_postset(SRC,EVENT)

    % Get the UI control and figure handle and validate the action
    hList  = eventdata.AffectedObject;
    hPanel = get(hList,'Parent');
    if ~strcmpi( get(hList,'Style'), 'listbox' )
        warning(['QUATTRO:' mfilename ':invalidListHandle'],...
                 'Event calls to %s must originate from a listbox UI control.',...
                 mfilename);
        return
    elseif ~strcmpi(src.Name,'visible')
        warning(['QUATTRO:' mfilename ':invalidListHandle'],...
                 'Event calls to %s must originate from a "%s" PostSet event.',...
                 mfilename,src.Name);
        return
    end

    % Get the new value and the qt_exam object
    str = hList.Visible;
    obj = getappdata( guifigure(hPanel), 'qtExamObject' );

    % Update the associated parent
    isAny = any( cellfun(@(x) any(x(:).validaterois),struct2cell(obj.rois)) );
    if ~isAny
        set(hPanel,'Visible',str);
    end

end %listbox_visible_postset