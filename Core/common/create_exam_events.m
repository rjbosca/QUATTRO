function obj = create_exam_events(obj)
%create_exam_events  Creates QUATTRO specific events
%
%   create_exam_events(OBJ) creates QUATTRO specific events for the qt_exams
%   object specified by OBJ, storing the newly created listener objects in the
%   application data 'qtexam_listeners'. Listeners are appended to any previous,
%   valid listeners existing in the application data.

    % Validate object class
    if ~strcmpi(class(obj),'qt_exam') || ~obj.isvalid
        error(['QUATTRO:' mfilename ':invalidExamsObj'],...
                                   'A valid qt_exams object must be specified');
    end

    % Grab any previous property PostSet listenrs, removing invalid objects from
    % the array and appending the new objects
    l = getappdata(obj.hFig,'qtexam_listeners');
    if ~isempty(l) && strcmpi( class(l), 'event.proplistener' )
        l = l(l.isvalid);
    elseif ~isempty(l)
        error(['QUATTRO:' mfilename ':invalidQuattroAppData'],...
               'Invalid application data detected in ''qtexam_listeners''.\n');
    end

    % Create the PostSet events for updating QUATTRO with respect to GUI changes
    l = [l addlistener(obj,'rois',     'PostSet',@update_roi_tools),...
           addlistener(obj,'maps',     'PostSet',@update_map_tools),...
           addlistener(obj,'imgs',     'PostSet',@update_img_tools),...
           addlistener(obj,'type',     'PostSet',@update_exam_tools),...
           addlistener(obj,'name',     'PostSet',@update_name_tools),...
           addlistener(obj,'examIdx',  'PostSet',@gui_examIdx_postset),...
           addlistener(obj,'sliceIdx', 'PostSet',@gui_sliceIdx_postset),...
           addlistener(obj,'seriesIdx','PostSet',@gui_seriesIdx_postset)];

    % Add listener for updating the "Paste" pushbutton
    l(end+1) = addlistener(obj,'roiCopy','PostSet',@gui_roiCopy_postset);

    % Add listener for updating the "Undo" pushbutton
    l(end+1) = addlistener(obj,'roiUndo','PostSet',@gui_roiUndo_postset);

    % Cache the listeners in main figure's application data. When the figure is
    % deleted, these listeners should be removed before destroying the qt_exam
    % object(s) to ensure that no unintended events occur during object
    % destruction
    setappdata(obj.hFig,'qtexam_listeners',l);

end %create_exam_events