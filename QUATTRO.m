function varargout = QUATTRO(varargin)
%QUATTRO  Constructs the QUATTRO GUI
%
%   H = QUATTRO initializes the QUATTRO graphical user interface (GUI),
%   returning the handle (H) to the figure.
%
%   See also qt_startup

    narginchk(0,0);

    % Initialize QUATTRO's path. QT_STARTUP also initializes the system's
    % environment variables for accessing the image registration tools
    qt_startup;
    if nargin
        validatestring(varargin{1},{'startup'});
        return
    end

    % Set up basic display properties
    bkg = [93 93 93]/255;
    pos = get(0,'ScreenSize');
    if pos(4)<740 %determine if QUATTRO extends past top of monitor
        pos = pos(4)-640;
    else %if not, use this default vertical position
        pos = 100;
    end

    % Create the main figure and initialize the operating qt_exam object
    hQt = figure('CloseRequestFcn',     @close_request_Callback,...
                 'Color',               bkg,...
                 'Filename',            mfilename,...
                 'IntegerHandle',       'off',...
                 'MenuBar',             'None',...
                 'Name',                qt_name,...
                 'NumberTitle',         'off',...
                 'Position',            [100 pos 960 640],...
                 'Resize',              'off',...
                 'Tag',                 'figure_main',...
                 'Toolbar',             'figure',...
                 'Units',               'Pixels',...
                 'WindowButtonDownFcn', @quattro_button_down_Callback,...
                 'WindowButtonUpFcn',   @quattro_button_up_Callback,...
                 'WindowKeyPressFcn',   @key_press_Callback,...
                 'WindowKeyReleaseFcn', @(h,ed) setappdata(h,'currentKeyModifier',''),...
                 'WindowScrollWheelFcn',@scroll_wheel_Callback);
    obj = qt_exam(hQt);

    % Determine the working MATLAB version and cache in the application data for
    % faster performance
    isNumericHandle = verLessThan('matlab','8.4.0');
    setappdata(hQt,'isNumericHandle',isNumericHandle);

    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~DO NOT EDIT~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    % These defaults have been set up with consideration for the entire QUATTRO
    % GUI code. Changing these values could have far reaching and unanticipated
    % effects
         set(hQt,'defaultaxescolor',                    bkg,...
                 'defaultaxesunits',                   'Pixels',...
                 'defaultuicontrolbackgroundcolor',     bkg,...
                 'defaultuicontrolfontsize',            9,...
                 'defaultuicontrolfontweight',         'Bold',...
                 'defaultuicontrolforegroundcolor',    [1 1 1],...
                 'defaultuicontrolhorizontalalignment','center',...
                 'defaultuicontrolstyle',              'Pushbutton',...
                 'defaultuicontrolunits',              'Pixels',...
                 'defaultuicontrolvalue',               1,...
                 'defaultuicontrolvisible',            'on',...
                 'defaultuipanelbackgroundcolor',       bkg,...
                 'defaultuipanelfontsize',              9,...
                 'defaultuipanelforegroundcolor',      [1 1 1],...
                 'defaultuipanelunits',                'Pixels');
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    add_logo(hQt); %add the QT logo

    % Prepare toolbar
    for hTool = findall( findall(hQt,'Type','uitoolbar') )'

        % Starting with MATLAB 2014B, the values stored in hTools are no longer
        % the numeric handles to the associated HGOs, but rather are the actual
        % graphics objects. Since there is no function "isvalid" for the HGO
        % numeric handles, this if statement must be dichotomized.
        if (isNumericHandle  && ~ishandle(hTool)) ||...
           (~isNumericHandle && ~isvalid(hTool)) ||...
             strcmpi(get(hTool,'Tag'),'figuretoolbar') %don't delete the toolbar
            continue
        end
        switch get(hTool,'Tag')
            case 'Exploration.DataCursor'
                set(hTool,'Enable','off',...
                          'Tag','uitoggletool_data_cursor');
                addlistener(hTool,'State','PostSet',...
                                       @uitoggletool_data_cursor_state_postset);
            case 'Exploration.Pan'
                set(hTool,'ClickedCallback',@pan_Callback,...
                          'Enable','off',...
                          'Tag','uitoggletool_drag');
            case 'Exploration.ZoomIn'
                set(hTool,'ClickedCallback',@zoom_Callback,...
                          'Enable','off',...
                          'Tag','uitoggletool_zoom_in');
            case 'Exploration.ZoomOut'
                set(hTool,'ClickedCallback',@zoom_Callback,...
                          'Enable','off',...
                          'Tag','uitoggletool_zoom_out');
            case 'Standard.SaveFigure'
                set(hTool,'ClickedCallback',@save_Callback,...
                          'Enable','off',...
                          'Tag','uipushtool_save_data',...
                          'Tooltip','Save QUATTRO workspace.');
            case 'Standard.FileOpen'
                set(hTool,'ClickedCallback',@open_file_Callback,...
                          'Tag','uipushtool_open_file',...
                          'Tooltip','Open saved QUATTRO workspace.');
            case 'Standard.NewFigure'
                set(hTool,'ClickedCallback',@(h,ed) QUATTRO,...
                          'Tag','uipushtool_new_quattro',...
                          'Tooltip','New instance of QUATTRO.');
            otherwise
                delete(hTool)
        end
    end

    % Prepare UI tools
    image_tools(hQt);
    exam_tools(hQt);
    map_tools(hQt);
    roi_tools(hQt);

    % Prepare the zoom mode
    set(zoom(hQt),'ActionPostCallback',@update_zoom)

    % Attach various event listeners to the qt_exam object that was instantiated
    % with the QUATTRO figure as UI preparation relies on the existence of this
    % object. Note that in creating a QT_EXAM object, a QT_OPTIONS is also
    % created and stored appropriately 
    create_exam_events(obj);

    % Prepare menus
    gui_menus(hQt);
    roi_listbox_menus( findobj(hQt,'Tag','listbox_rois') );

    % Initialize QUATTRO key modifier cache and the modeling object placeholder
    setappdata(hQt,'currentKeyModifier','');

    % Set other application data
    set_ui_current_value(hQt);
    setappdata(hQt,'examtype','generic');

    % Store handles structure
    guidata(hQt, guihandles(hQt) );

    % Output
    if nargout
        varargout{1} = hQt;
    end

end %QUATTRO


%---------------------------------- Callbacks ----------------------------------


function close_request_Callback(hObj,~)

    % Before deleting the QUATTRO figure all listeners attached to the qt_exam
    % object by the GUI functionality must be removed to expedite the figure
    % delete operation and avoid warning/error messages that might be triggered
    % by referencing deleted objects while deleting the QUATTRO workspace below.
    delete( getappdata(hObj,'qtExamPropListeners') );

    % Delete the QUATTRO workspace
    delete( getappdata(hObj,'qtWorkspace') );

    % Delete the main figure
    delete(hObj)

end %close_request_Callback

function key_press_Callback(hObj,eventdata)

    % Get handles structure and find axes children
    hs = guidata(hObj);
    if isempty(get(hs.axes_main,'Children'))
        return
    end

    % Stores some useful values
    [slM,seM] = deal_cell( get([hs.slider_slice...
                                hs.slider_series],'Max') );
    [sl,se]   = deal_cell( get([hs.slider_slice...
                                hs.slider_series],'Value') );

    % Cache modifier for external use
    keyMod = getappdata(hObj,'currentKeyModifier');
    if ~any(strcmpi(keyMod,eventdata.Modifier)) && ~isempty(eventdata.Modifier)
        setappdata(hObj,'currentKeyModifier',eventdata.Modifier{1});
    end

    % Determine action
    if isempty(eventdata.Modifier)
        switch eventdata.Key
            case 'n' % next series
                if (se<seM) && strcmpi(get(hs.slider_series,'Enable'),'on')
                    set(hs.slider_series, 'Value', (se + 1) );
                    slider_Callback(hs.slider_series,[]);
                end
            case 'b' % previous series
                if (se>1 ) && strcmpi(get(hs.slider_series,'Enable'),'on')
                    set(hs.slider_series, 'Value', (se - 1) );
                    slider_Callback(hs.slider_series,[]);
                end
            case 'delete' % delete selected contour
                delete_roi_Callback(hs.pushbutton_delete_roi,[]);
            case {'uparrow','downarrow','rightarrow','leftarrow'}
                if get(hs.figure_main,'CurrentObject')~=hs.listbox_rois
                    obj  = getappdata(hs.figure_main,'qtExamObject');
                    obj.roi.nudgeroi(eventdata.Key);
                end
        end
    elseif strcmpi(eventdata.Modifier{1},'control')
        switch eventdata.Key
            case 'c' % 'Copy' button
                copy_roi_Callback(hs.pushbutton_copy,[])
            case 'v' % 'Paste' button
                paste_roi_Callback(hs.pushbutton_paste,[]);
            case 'z' % undo
                undo_Callback(hs.pushbutton_undo,[]);
            case {'uparrow','downarrow','rightarrow','leftarrow'}
                if get(hs.figure_main,'CurrentObject')~=hs.listbox_rois
                    obj = getappdata(hs.figure_main,'qtExamObject');
                    obj.roi.nudgeroi(eventdata.Key,eventdata.Modifier{1});
                end
        end
    elseif strcmpi(eventdata.Modifier{1},'shift')
        switch eventdata.Key
            case 'n' % next slice
                if (sl<slM) && strcmpi(get(hs.slider_slice,'Enable'),'on')
                    set(hs.slider_slice, 'Value', (sl + 1) );
                    slider_Callback(hs.slider_slice, []);
                end
            case 'b' % previous slice
                if (sl>1) && strcmpi(get(hs.slider_slice,'Enable'),'on')
                    set(hs.slider_slice, 'Value', (sl - 1) );
                    slider_Callback(hs.slider_slice,[]);
                end
            case 'e' % ENABLE CONTROLS
                update_controls(hObj,'enable');
        end
    end

end %key_press_Callback

function scroll_wheel_Callback(hObj,eventdata)

    % Get handles structure and find axes children
    hFig = gcbf;
    hAx  = findobj(hFig,'Tag','axes_main');
    if isempty(get(hAx,'Children'))
        return
    end

    % Gets the slider info
    if strcmpi(getappdata(hObj,'currentKeyModifier'),'control')
        h = findobj(hFig,'Tag','slider_series');
    else
        h = findobj(hFig,'Tag','slider_slice');
    end
    if strcmpi(get(h,'Enable'),'off') %perform no action when disabled
        return
    end
    sliderCallback = get(h,'Callback');
    sliderNum      = get(h,'Value');
    sliderMax      = get(h,'Max');

    % Sets the new slider value
    if isequal(eventdata.VerticalScrollCount, -1)
        if (sliderNum+1) <= sliderMax
            set(h, 'Value', (sliderNum+1));
            sliderCallback(h,[]);
        end
    elseif isequal(eventdata.VerticalScrollCount, 1)
        if (sliderNum-1) >= 1
            set(h, 'Value', (sliderNum-1));
            sliderCallback(h,[]);
        end
    end

end %scroll_wheel_Callback