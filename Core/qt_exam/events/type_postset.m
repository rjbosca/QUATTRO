function type_postset(src,eventdata)
%type_postset  PostSet event for the qt_exam "type" property
%
%   type_postset(SRC,EVENT) updates the "examType" property of the associated
%   qt_options object and re-initializes the qt_exam object.

    % Get the various figure handles and the new exam type
    hFig   = eventdata.AffectedObject.hFig;
    hExt   = eventdata.AffectedObject.hExtFig;
    exType = eventdata.AffectedObject.type;
    if isempty(hFig) || ~ishandle(hFig)
        return
    end

    % Set the application data for all figures associated with QUATTRO and
    % update the qt_options object (so dependent properties will work properly).
    %TODO: what happens when there are multiple exams? what happens if the user
    %changes the exam type of an object that isn't the focus of QUATTRO?
    setappdata([hFig hExt],'examtype',exType);
    eventdata.AffectedObject.opts.examType = exType;

    % Prepare the exam
    notify(eventdata.AffectedObject,'initializeExam');

end %qt_exam.type_postset