function update_name_tools(src,eventdata)
%update_name_tools  QUATTRO PostSet event for qt_exam "name" property
%
%   update_name_tools(SRC,EVENT) updates the exams pop-up menu following changes
%   to a qt_exam object's "name" property.

    % Find the exam selection pop-up menu and grab ths current QUATTRO workspace
    hPop   = findobj(eventdata.AffectedObject.hFig,'Tag','popupmenu_exams');
    qtObjs = getappdata(eventdata.AffectedObject.hFig,'qtWorkspace');

    % Update the strings
    set(hPop,'String',{qtObjs.name});

end %update_name_tools