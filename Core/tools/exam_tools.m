function exam_tools(hQt)
%exam_tools  Builds exam related QUATTRO tools
%
%   exam_tools(H)

    % Verify input
    if isempty(hQt) || ~ishandle(hQt) || ~strcmpi(get(hQt,'Name'),qt_name)
        error(['QUATTRO:' mfilename 'qtHandleChk'],...
                                            'Invalid handle to QUATTRO figure');
    end

    % Prepare tools
    hUip =   uipanel('Parent',hQt,...
                     'Position',[20 20 115 50],...
                     'Tag','uipanel_exams',...
                     'Title','Exams:',...
                     'Visible','off');
           uicontrol('Parent',hUip,...
                     'Callback',@change_exam_Callback,...
                     'Position',[10 10 95 20],...
                     'BackgroundColor',[1 1 1],...
                     'ForegroundColor',[0 0 0],...
                     'String',{''},...
                     'Style','PopupMenu',...
                     'Tag','popupmenu_exams');

    % Prepare text
    uicontrol('Parent',hQt,...
              'HorizontalAlignment','Left',...
              'Position',[20 609 671 20],...
              'Style','Text',...
              'Tag','text_exam_info',...
              'Visible','off');

end %exam_tools


%-----------------------Callback/Ancillary Functions----------------------------

function change_exam_Callback(hObj,eventdata)

    % Validate that a change occured
    val = get(hObj,'Value');
    if (val==getappdata(hObj,'currentvalue'))
        return
    end

    % Get the QUATTRO figure handle and the current qt_exam object
    hFig = gcbf;
    obj  = getappdata(hFig,'qtExamObject');

    % Disable user controls and update the "examIdx" of the current QUATTRO
    % qt_exam object. This action will trigger the PostSet qt_exam object events
    % that will update all application data and the QUATTRO GUI
    update_controls(hFig,'disable');
    obj.examIdx = val;

    % Re-enable all user controls and update the application data
    update_controls(hFig,'enable');
    setappdata(hObj,'currentvalue',val);

end %change_exam_Callback