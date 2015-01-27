function varargout = QUATTRO
%QUATTRO  Constructs the QUATTRO GUI
%
%   H = QUATTRO initializes the QUATTRO graphical user interface, returning the
%   handle (H) to the figure.
%
%   See also qt_exam, qt_image, qt_roi, qt_models, qt_options

    % Set up basic display properties
    bkg = [93 93 93]/255;
    pos = get(0,'ScreenSize');
    if pos(4)<740 %determine if QUATTRO extends past top of monitor
        pos = pos(4)-640;
    else %if not, use this default vertical position
        pos = 100;
    end

    % Perform path initialization/update
    startup = fullfile( fileparts(mfilename('fullpath')),...
                                                'Core','common','qt_startup.m');
    if ~exist(startup,'file')
        error('QUATTRO:invalidStartUpFile',...
             ['QUATTRO was unable to locate a necessary file: qt_startup.m\n',...
              'Undo any changes made to the QUATTRO directories or try\n',...
              'downloading the distribution again\n\n']);
    end
    run(startup);

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
                 'WindowButtonDownFcn', @button_down_Callback,...
                 'WindowButtonUpFcn',   @button_up_Callback,...
                 'WindowKeyPressFcn',   @key_press_Callback,...
                 'WindowKeyReleaseFcn', @(h,ed) setappdata(h,'currentKeyModifier',''),...
                 'WindowScrollWheelFcn',@scroll_wheel_Callback);
    obj = qt_exam(hQt);

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
        if (verLessThan('matlab','8.4.0') && ~ishandle(hTool)) ||...
          (~verLessThan('matlab','8.4.0') && ~isvalid(hTool)) ||...
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
    hZoom = zoom(hQt);
    set(hZoom,'ActionPostCallback',@update_zoom)

    % Attach various event listeners to the qt_exam object that was instantiated
    % with the QUATTRO figure as UI preparation relies on the existence of this
    % object. Note that in creating a qt_exam object, a qt_options is also
    % created and stored appropriately 
    create_exam_events(obj);

    % Prepare menus
    gui_menus(hQt);
    roi_listbox_menus( findobj(hQt,'Tag','listbox_rois') );

    % Initialize QUATTRO key modifier cache and the qt_models placeholder
    setappdata(hQt,'currentKeyModifier','');
    setappdata(hQt,'modelsObject',generic.empty(1,0));

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


%-----------------------Callback/Ancillary Functions----------------------------

function button_down_Callback(hObj,eventdata) %#ok<*INUSD>

        % Determine which object was hit by the button up event
        currentPoint  = get(hObj,'CurrentPoint');
        if verLessThan('matlab','8.4.0')
            obj       = hittest(hObj,currentPoint);
        else
            obj       = hittest(hObj);
        end
        objParent     = get(obj,'Parent'); %ROI handle (hopefully)
        objTag        = get(objParent,'Tag');
        if isempty(objTag) || ~isempty(strfind(objTag,'axes'))
            objTag    = get(obj,'Type');
        end
        if strcmpi(objTag,'hggroup')
            objTag    = get(obj,'Tag');
        end

        % Mouse selection type
        clickType = get(hObj,'SelectionType');

        % Determines if ROI was hit with a normal click
        hitRoi = any( strcmpi(objTag,{'imspline','imrect',...
                                        'imellipse','impoly','impoint'}) );
        if ~hitRoi || ~strcmpi(clickType,'normal')
            return
        end

        % Get handles structure and exams object
        obj = getappdata(gcbf,'qtExamObject');

        % Clone the ROI into the undo 
        setappdata(gcbf,'clickedRoiCache',obj.roi.clone);

end %button_down_Callback

function button_up_Callback(hObj,eventdata)

    % Only consider LMB interactions
    if ~strcmpi( get(hObj,'SelectionType'), 'normal' )
        return
    end

    % Get the QUATTRO figure handle and 
    hFig = gcbf;

    % Determine which object was hit
    currentPoint = get(hObj,'CurrentPoint');
    if verLessThan('matlab','8.4.0')
        obj      = hittest(hFig,currentPoint);
    else
        obj      = hittest(hFig);
    end
    objParent    = get(obj,'Parent');
    objTag       = get(objParent,'Tag');
    if strcmpi(get(obj,'Tag'),'impoint')
        objTag   = get(obj,'Tag');
    end

    % Determine if an ROI object was hit
    hitRoi = any(strcmpi(objTag,{'imspline','imrect','imellipse',...
                                 'impoly','impoint'})) && ~isempty(objTag);
    if ~hitRoi || ~isappdata(hFig,'clickedRoiCache')
        return
    end

    % Grab the qt_exam object and the cached ROII that was clicked to compare
    % with the current ROI's position vector with that of the cached ROI's, and
    % appropriately update the "roiUndo" property.
    obj      = getappdata(hFig,'qtExamObject');
    roiCache = getappdata(hFig,'clickedRoiCache');
    if any( roiCache.position(:)~=obj.roi.position(:) )
        obj.addroiundo(roiCache,'moved');
    end

    % Remove the cache
    rmappdata(hFig,'clickedRoiCache');

end %button_up_Callback

function close_request_Callback(hObj,eventdata)

    % Before deleting the QUATTRO figure all listeners attached to the qt_exam
    % object by the GUI functionality must be removed to expedite the figure
    % delete operation and avoid warning/error messages that might be triggered
    % by referencing deleted objects while deleting the QUATTRO workspace below.
    delete( getappdata(hObj,'qtexam_listeners') );

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
                if se < seM
                    set(hs.slider_series, 'Value', (se + 1) );
                    slider_Callback(hs.slider_series,[]);
                end
            case 'b' % previous series
                if se > 1 
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
                if sl < slM
                    set(hs.slider_slice, 'Value', (sl + 1) );
                    slider_Callback(hs.slider_slice, []);
                end
            case 'b' % previous slice
                if sl > 1
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