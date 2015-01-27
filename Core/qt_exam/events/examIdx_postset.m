function examIdx_postset(src,eventdata)
%examIdx_postset  PostSet event for qt_exam "examIdx" property
%
%   examIdx_postset(SRC,EVENT) updates application data associated with the
%   qt_exam object when a GUI is associated with the object

    % A figure must be present
    exObj = eventdata.AffectedObject;
    if isempty(exObj.hFig) || ~ishandle(exObj.hFig)
        return
    end

    % Update the "examIdx" property of all other objects
    wrkObjs = getappdata(exObj.hFig,'qtWorkspace');
    [wrkObjs(wrkObjs~=exObj.hFig).examIdx] = deal(exObj.examIdx); %#ok
    
end %qt_exam.examIdx_postset