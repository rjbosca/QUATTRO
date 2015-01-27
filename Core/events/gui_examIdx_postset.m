function gui_examIdx_postset(src,eventdata)
%gui_examIdx_postset  GUI PostSet event for qt_exam property "examIdx"
%
%   gui_examIdx_postset(SRC,EVENT)

    exObj = eventdata.AffectedObject; %alias for readibiliity

    % Grab all of QUATTRO's application data since a large portion of it will be
    % needed. Only perform the following code when the  "examIdx" property was
    % matches between the currnet object and the listeners.
    appData = getappdata(exObj.hFig);
    examIdx = appData.qtExamObject.examIdx;
    objMask = (appData.qtexam_listeners(1).Object{1}==appData.qtWorkspace);
    if objMask(examIdx)
        return
    end

    % Update the exam selection pop-up menu
    hPop = findobj(exObj.hFig,'Tag','popupmenu_exams');
    if isempty(hPop) %no pop-up menu found - useful for devs
        warning(['QUATTRO:' mfilename ':missingUIObj'],...
                 'Unknown UI graphics object with the tag "%s".\n',tag);
        return
    end

    % Update the pop-up menu value according to the "examIdx" value and update
    % the application data
    set(hPop,'Value',examIdx);
    setappdata(hPop,'currentvalue',examIdx);

    % Deconstruct the pervious exam by deleting all previous QUATTRO GUI related
    % listeners.
    delete(appData.qtexam_listeners);

    % Create listeners for the new exam object and update the application data
    % to reflect the change and update the application data structure since
    % these listeners will be used to update the GUI
    obj = appData.qtWorkspace(examIdx);
    create_exam_events(obj);
    appData.qtexam_listeners = getappdata(exObj.hFig,'qtexam_listeners');
    setappdata(exObj.hFig,'qtExamObject',obj);

    % Now that the exam object has been changed, update the image
    %TODO: the current syntax will not know how to handle an image axis of a
    %different size. This is something that will need to be addressed in
    %qt_image...
    obj.image.show( getappdata(exObj.hFig,'qtImgObject') );

    %TODO: don't forget to notify all registered figures that the qt_exam object
    %has changed...

    % Use the listeners defined above to fire all updaters
    for listener = appData.qtexam_listeners

        % Avoid recurrsion by skipping the "gui_examIdx_postset" callback (i.e.,
        % the m-file that is currently running)
        if strcmpi(listener.Source{1}.Name,'examIdx')
            continue
        end
        
        % Create the event data strucutre to mimic the event object and fire the
        % callback
        eventData = struct('AffectedObject',listener.Object,...
                           'Source',        listener.Source,...
                           'EventName',     listener.EventName);
        feval(listener.Callback,eventData.Source,eventData);

    end
              
end %gui_examIdx_postset