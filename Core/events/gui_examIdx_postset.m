function gui_examIdx_postset(~,eventdata)
%gui_examIdx_postset  GUI post-set event for QT_EXAM property "examIdx"
%
%   gui_examIdx_postset(SRC,EVENT)

    % Initialize the workspace
    exObj = eventdata.AffectedObject; %alias for readibiliity
    appData = getappdata(exObj.hFig);
    examIdx = appData.qtExamObject.examIdx;

    % Determine which QT_EXAM object stored in the QUATTRO application data
    % corresponds to that same object stored in the GUI listeners. At this
    % point, also update the "isCurrent" property of all non-current objects to
    % be FALSE. For the selected exam (i.e., that object corresponding to the
    % value "examIdx"), this value will be set to TRUE later in this function
    objMask = (appData.qtExamPropListeners(1).Object{1}==appData.qtWorkspace);
    [appData.qtWorkspace(~objMask).isCurrent] = deal(false);

    % Only perform the following code when there is a mismatch between the
    % "examIdx" property of the currnet object and the object associated with
    % the listeners. This ensures that only the QT_EXAM object for which QUATTRO
    % GUI listeners are attached can update the workspace.
    if objMask(examIdx)
        return
    end

    % Update the exam selection pop-up menu
    hPop = findobj(exObj.hFig,'Tag','popupmenu_exams');
    if isempty(hPop) %no pop-up menu found - useful for devs
        warning(['QUATTRO:' mfilename ':missingUIObj'],...
                 'Unknown UI graphics object with the tag "%s".',tag);
        return
    end
    set(hPop,'Value',examIdx);
    setappdata(hPop,'currentvalue',examIdx);

    % Deconstruct the pervious exam by deleting all previous QUATTRO GUI related
    % listeners.
    delete(appData.qtExamPropListeners);
    delete(appData.qtExamEventListeners);

    % Create listeners for the new exam object and update the application data
    % to reflect the change and update the application data structure since
    % these listeners will be used to update the GUI
    obj           = appData.qtWorkspace(examIdx);
    obj.isCurrent = true; %update the current object
    create_exam_events(obj);
    appData       = getappdata(exObj.hFig);
    setappdata(exObj.hFig,'qtExamObject',obj);

    % Now that the exam object has been changed, update the image
    obj.image.show( getappdata(exObj.hFig,'qtImgObject') );

    %TODO: don't forget to notify all registered figures that the QT_EXAM object
    %has changed...

    % Use the listeners defined above to fire all updaters
    arrayfun(@fire_listener,appData.qtExamPropListeners);
    arrayfun(@fire_listener,appData.qtExamEventListeners);
              
end %gui_examIdx_postset


%-------------------------------
function fire_listener(listener)

    % Avoid recurrsion by skipping the "gui_examIdx_postset" callback (i.e.,
    % the m-file that is currently running)
    if ~isprop(listener.Source{1},'Name') ||...
                                      strcmpi(listener.Source{1}.Name,'examIdx')
        return
    end

    % Create the event data strucutre to mimic the event object and fire the
    % callback
    eventData = struct('AffectedObject',listener.Object,...
                       'Source',        listener.Source,...
                       'EventName',     listener.EventName);
    feval(listener.Callback,eventData.Source,eventData);

end %fire_listener