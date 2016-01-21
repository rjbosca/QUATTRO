function obj = create_exam_events(obj)
%create_exam_events  Creates QUATTRO specific events
%
%   create_exam_events(OBJ) creates QUATTRO specific events for the qt_exams
%   object specified by OBJ, storing the newly created listener objects in the
%   application data 'qtExamPropListeners'. Listeners are appended to any previous,
%   valid listeners existing in the application data.

    % Validate object class
    if ~strcmpi(class(obj),'qt_exam') || ~obj.isvalid
        error(['QUATTRO:' mfilename ':invalidExamsObj'],...
                                    'A valid QT_EXAM object must be specified');
    end

    % Grab any previous property event listenrs, removing invalid objects from
    % the array and appending the new objects
    lProp = getappdata(obj.hFig,'qtExamPropListeners');
    if ~isempty(lProp) && strcmpi( class(lProp), 'event.proplistener' )
        lProp = lProp(lProp.isvalid);
    elseif ~isempty(lProp)
        error(['QUATTRO:' mfilename ':invalidQuattroAppData'],...
               'Invalid application data detected in ''qtExamPropListeners''.');
    end

    % Grab any previous event listenrs, removing invalid objects from the array
    % and appending the new objects
    lEvents = getappdata(obj.hFig,'qtExamEventListeners');
    if ~isempty(lEvents) && strcmpi( class(lEvents), 'event.listener' )
        lEvents = lEvents(lEvents.isvalid);
    elseif ~isempty(lEvents)
        error(['QUATTRO:' mfilename ':invalidQuattroAppData'],...
               'Invalid application data detected in ''qtExamEventListeners''.');
    end

    % Create the pre- and post-set events for updating the QUATTRO GUI following
    % changes to the QT_EXAM object
    lEvents = [lEvents addlistener(obj,'roiChanged',    @update_roi_tools)];
    lProp   = [lProp addlistener(obj,'maps',     'PostSet',@update_map_tools),...
                     addlistener(obj,'imgs',     'PostSet',@update_img_tools),...
                     addlistener(obj,'type',     'PostSet',@update_exam_tools),...
                     addlistener(obj,'name',     'PostSet',@update_name_tools),...
                     addlistener(obj,'roiIdx',   'PreSet', @gui_roiIdx_preset),...
                     addlistener(obj,'roiIdx',   'PostSet',@gui_roiIdx_postset),...
                     addlistener(obj,'examIdx',  'PostSet',@gui_examIdx_postset),...
                     addlistener(obj,'sliceIdx', 'PostSet',@gui_sliceIdx_postset),...
                     addlistener(obj,'seriesIdx','PostSet',@gui_seriesIdx_postset)];

    % Add listener for updating the "Paste" pushbutton
    lProp(end+1) = addlistener(obj,'roiCopy','PostSet',@gui_roiCopy_postset);

    % Add listener for updating the "Undo" pushbutton
    lProp(end+1) = addlistener(obj,'roiUndo','PostSet',@gui_roiUndo_postset);

    % Cache the listeners in main figure's application data. When the figure is
    % deleted, these listeners should be removed before destroying the QT_EXAM
    % object(s) to ensure that no unintended events occur during calls to the
    % object's destructors
    setappdata(obj.hFig,'qtExamPropListeners',lProp);
    setappdata(obj.hFig,'qtExamEventListeners',lEvents);

end %create_exam_events