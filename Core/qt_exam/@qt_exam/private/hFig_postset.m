function hFig_postset(obj,~,~)
%hFig_postset  Post-set event for QT_EXAM property "hFig"
%
%   hFig_postset(OBJ,SRC,EVENT)

    % Grab the application data. For multi-exam workspaces, 
    exObj   = getappdata(obj.hFig,'qtExamObject');
    wrkObjs = getappdata(obj.hFig,'qtWorkspace');
    if isempty(wrkObjs) %convenience for the following code
        wrkObjs = qt_exam.empty(1,0);
    end

    % Cache the exams object in the new figure and concatenate the workspace
    if isempty(exObj) || ~exObj.isvalid
        setappdata(obj.hFig,'qtExamObject',obj);
    end
    if strcmpi( class(wrkObjs), 'qt_exam' )

        % Remove invalid exams and update the application data
        wrkObjs = wrkObjs( [wrkObjs.isvalid] );
        setappdata(obj.hFig,'qtWorkspace',[wrkObjs obj]);

    else
        error(['qt_exam:' mfilename ':invalidQuattroAppData'],...
              ['Invalid data detected in the application data ',...
               '''qtWorkspace''.']);
    end

    % When setting a new figure, make sure there is a valid qt_options object
    optsObj = getappdata(obj.hFig,'qtOptsObject');
    if isempty(optsObj) || ~isvalid(optsObj)
        optsObj  = qt_options(obj.hFig);
        setappdata(obj.hFig,'qtOptsObject',optsObj);
    end
    obj.opts = optsObj;

    % When using the "hFig" property (i.e., using GUIs), enable the "guiDialogs"
    % property
    obj.guiDialogs = true;

end %qt_exam.hFig_postset