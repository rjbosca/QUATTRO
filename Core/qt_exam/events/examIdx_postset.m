function examIdx_postset(~,eventdata)
%examIdx_postset  Post-set event for QT_EXAM "examIdx" property
%
%   examIdx_postset(SRC,EVENT) updates application data associated with the
%   QT_EXAM object when a GUI is associated with the object

    % Operations for changing the "examIdx" property only make sense when the
    % QUATTRO figure is being used.
    exObj = eventdata.AffectedObject;
    if isempty(exObj.hFig) || ~ishandle(exObj.hFig)
        return
    end

    % Update the "examIdx" property of all other objects associated with the
    % same QUATTRO figure. This ensures that the "examIdx" will be synchronized
    % across all objects and that any GUI specific listeners attached to other
    % QT_EXAM objects will be notified of the changes.
    wrkObjs                                = getappdata(exObj.hFig,'qtWorkspace');
    [wrkObjs(wrkObjs~=exObj.hFig).examIdx] = deal(exObj.examIdx); %#ok
    
end %qt_exam.examIdx_postset