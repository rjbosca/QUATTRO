function hFig_postset(obj,src,eventdata)
%hFig_postset  PostSet event for qt_exam property "hFig"
%
%   hFig_postset(OBJ,SRC,EVENT)

    % Set basic existence properties
    obj.isQuattro = ~isempty(obj.hFig) && strcmpi(get(obj.hFig,'Name'),qt_name);

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
               'Invalid data detected in the application data ''qtWorkspace''.\n');
    end

    % When setting a new figure, make sure there is a valid qt_options object
    optsObj = getappdata(obj.hFig,'qtOptsObject');
    if isempty(optsObj) || ~isvalid(optsObj)
        optsObj  = qt_options(obj.hFig);
        setappdata(obj.hFig,'qtOptsObject',optsObj);
    end
    obj.opts = optsObj;

end %qt_examhFig_postset