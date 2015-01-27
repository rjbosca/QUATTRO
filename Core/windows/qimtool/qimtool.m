function hFig = qimtool(obj)
%qimtool  Creates a quantitative image modeling (QIM) GUI
%
%   H = qimtool(OBJ) creates an interactive GUI that allows the user to
%   interactively navigate data and fitted models stored in one of the qt_models
%   sub-class objects specified by OBJ. The figure handle, H, is returned.
%
%   If a qt_exam object is registered with an instance of the QUATTRO GUI, the
%   UI tools of qimtool will reflect additional options for selecting data
%
%   See also qt_models.qt_models and qt_exam.qt_exam

    % Verify caller
    modelType = class(obj);
    if ~nargin || (~strcmpi(modelType,'qt_models') &&...
                                 ~any( strcmpi('qt_models',superclasses(obj)) ))
        error(['QUATTRO:' mfilename ':guiConstructorChk'],...
                             'Invalid call to GUI constructor. See qt_models.');
    elseif numel(size(obj.y))>2
        error(['QUATTRO:' mfilename ':guiAvailabiltiyChk'],...
                   'qt_models GUI is not available for multidimensional data.');
    end

    % Determine if a qt_exam object is attached
    hQt  = [];
    isQt = false;
    if ~isempty(obj.hExam) && isvalid(obj.hExam)
        hQt  = obj.hExam.hFig;
        isQt = ~isempty(hQt) && ishandle(hQt) &&...
                                                strcmp(get(hQt,'Name'),qt_name);
    end

    % Prepare figure properties and determine new figure position based on
    % QUATTRO's position if possible
    figPos = [644 454 600 470];

    % Color setup
    bkg = [93 93 93]/255;

    % Prepare main figure
    hFig = figure('CloseRequestFcn',                @delete_models_fig,...
                  'Color',                           bkg,...
                  'Filename',                        mfilename,...
                  'IntegerHandle',                  'off',...
                  'MenuBar',                        'None',...
                  'Name',                           'QUATTRO:: Modeling ::',...
                  'NumberTitle',                    'off',...
                  'Position',                        figPos,...
                  'Resize',                         'off',...
                  'Tag',                            'figure_main',...
                  'Toolbar',                        'figure',...
                  'Units',                          'Pixels',...
                  'WindowButtonDownFcn',            @button_down_Callback,...
                  'WindowKeyPressFcn',              @key_press_Callback);
    set(hFig,     'defaultuicontrolunits',          'Pixels',...
                  'defaultuicontrolbackgroundcolor',[1 1 1],...
                  'defaultuicontrolfontsize',        9,...
                  'defaultuipanelbordertype',       'etchedin',...
                  'defaultuipanelbackgroundcolor',   bkg,...
                  'defaultuipanelforegroundcolor',  [1 1 1],...
                  'defaultuipanelunits',            'Pixels',...
                  'defaultaxescolor',               [1 1 1],...
                  'defaultaxesxcolor',              [1 1 1],...
                  'defaultaxesycolor',              [1 1 1],...
                  'defaultaxesunits',               'Pixels');
    add_logo(hFig);

    % Prepare toolbar
    hTools = findall( findall(hFig,'Type','uitoolbar') );
    delete(hTools([2:7 9 13:16])); hTools([1:7 9 13:16 end]) = [];
    for idx = 1:length(hTools)
        switch get(hTools(idx),'Tag')
            case 'Exploration.DataCursor'
                set(hTools(idx),'Tag','uitoggletool_data_cursor');
            case 'Exploration.Pan'
                set(hTools(idx),'Tag','uitoggletool_drag');
            case 'Exploration.ZoomIn'
                set(hTools(idx),'Tag','uitoggletool_zoom_in');
            case 'Exploration.ZoomOut'
                set(hTools(idx),'Tag','uitoggletool_zoom_out');
            case 'Standard.NewFigure'
                set(hTools(idx),'ClickedCallback',@modeling_Callback,...
                                'Tag','uipushtool_new_quattro');
        end
    end

    % Prepare general display tools
    hPan = uipanel('Parent',hFig,...
                   'FontSize',10,...
                   'Position',[60 10 512 100],...
                   'Tag','uipanel_options',...
                   'Title','Fitting Options',...
                   'Visible','on');
    hAx  =    axes('Parent',hFig,...
                   'Color',[1 1 1],...
                   'Position',[60 150 512 288],...
                   'Tag','axes_main',...
                   'XTickLabel','',...
                   'YTickLabel','');

    % Prepare QUATTRO specific tools
    modelList = obj.modelNames;

    % Prepare universal tools
    uicontrol('Parent',hPan,...
              'Callback',@change_fit_Callback,...
              'Position',[412 10 90 20],...
              'String',modelList,...
              'Style','PopupMenu',...
              'Tag','popupmenu_model',...
              'Value',obj.modelVal);
    uicontrol('Parent',hPan,...
              'Callback',@change_fit_Callback,...
              'Position',[412 50 90 20],...
              'String',{'Lev-Marq','Robust','Trust Reg.','GP'},...
              'Style','PopupMenu',...
              'Tag','popupmenu_fit_type');
    uicontrol('Parent',hPan,...
              'Callback',@change_data_Callback,...
              'Position',[50 50 90 20],...
              'String','External',...
              'Style','PopupMenu',...
              'Tag','popupmenu_data');
    uicontrol('Parent',hPan,...
              'Callback',@change_loc_Callback,...
              'Position',[188 50 90 20],...
              'String',{''},...
              'Style','PopupMenu',...
              'Tag','popupmenu_roi',...
              'Visible','off');
    uicontrol('Parent',hPan,...
              'Callback',@change_loc_Callback,...
              'Position',[60 10 70 20],...
              'String','1',...
              'Style','Edit',...
              'Tag','edit_slice',...
              'Visible','off');
    uicontrol('Parent',hPan,...
              'Callback',@change_loc_Callback,...
              'Position',[198 10 70 20],...
              'String','1',...
              'Style','Edit',...
              'Tag','edit_series',...
              'Visible','off');

    % Prepare UI context menu tools for the axis
    hCmenu = uicontextmenu;
    uimenu(hCmenu,'Callback',@select_data_Callback,...
                  'Label','Restore Data',...
                  'Tag','context_restore_data');
    uimenu(hCmenu,'Callback',@select_data_Callback,...
                  'Label','Select Data',...
                  'Tag','context_select_data');
    uimenu(hCmenu,'Callback',@set_axes_limits_Callback,...
                  'Label','Set Axes Limits',...
                  'Tag','context_set_axes_limits');
    set(hAx,'uicontextmenu',hCmenu);
    hCmenu = uicontextmenu;
    uimenu(hCmenu,'Callback',@select_data_Callback,...
                  'Label','Remove Point',...
                  'Tag','context_remove_point');
    uimenu(hCmenu,'Callback',@select_data_Callback,...
                  'Label','Restore Data',...
                  'Tag','context_restore_data');
    uimenu(hCmenu,'Callback',@invert_data_Callback,...
                  'Label','Invert Signal',...
                  'Tag','context_invert_signal',...
                  'Visible','off');
    setappdata(hAx,'dataContextMenu',hCmenu);

    % Prepare text
    uicontrol('Parent',hPan,...
              'BackgroundColor',bkg,...
              'ForegroundColor',[1 1 1],...
              'HorizontalAlignment','Right',...
              'Position',[12 52 35 15],...
              'String','Data:',...
              'Style','Text',...
              'Tag','text_data');
    uicontrol('Parent',hPan,...
              'BackgroundColor',bkg,...
              'ForegroundColor',[1 1 1],...
              'HorizontalAlignment','Right',...
              'Position',[360 52 50 15],...
              'String','Fit Type:',...
              'Style','Text',...
              'Tag','text_fit_type');
    uicontrol('Parent',hPan,...
              'BackgroundColor',bkg,...
              'ForegroundColor',[1 1 1],...
              'HorizontalAlignment','Right',...
              'Position',[370 12 40 15],...
              'String','Model:',...
              'Style','Text',...
              'Tag','text_model');
    uicontrol('Parent',hPan,...
              'BackgroundColor',bkg,...
              'ForegroundColor',[1 1 1],...
              'HorizontalAlignment','Right',...
              'Position',[12 12 35 15],...
              'String','Slice:',...
              'Style','Text',...
              'Tag','text_slice',...
              'Visible','off');
    uicontrol('Parent',hPan,...
              'BackgroundColor',bkg,...
              'ForegroundColor',[1 1 1],...
              'HorizontalAlignment','Right',...
              'Position',[145 12 40 15],...
              'String','Series:',...
              'Style','Text',...
              'Tag','text_series',...
              'Visible','off');
    uicontrol('Parent',hPan,...
              'BackgroundColor',bkg,...
              'ForegroundColor',[1 1 1],...
              'HorizontalAlignment','Right',...
              'Position',[150 52 35 15],...
              'String','ROI:',...
              'Style','Text',...
              'Tag','text_roi',...
              'Visible','off');

    % Initialize/prepare the model UI panels
    if ~strcmpi(modelType,'generic')

        % Widen the figure to prepare for the additional tools
        figPos = figPos+[0 0 290 0]; %used later in the "isQt" section
        set(hFig,'Position',figPos);

        % Generate the panel
        paramOptsPos = [592 240 260 178];
        resultsPos   = [592  10 260 200];

        % Create the headers
        uicontrol('Parent',hFig,...
                  'BackgroundColor',bkg,...
                  'FontSize',10,...
                  'ForegroundColor',[1 1 1],...
                  'HorizontalAlignment','Left',...
                  'Position',[592 418 150 20],...
                  'String','Parameter Options',...
                  'Style','Text',...
                  'Tag','text_parameter_options');
        uicontrol('Parent',hFig,...
                  'BackgroundColor',bkg,...
                  'FontSize',10,...
                  'ForegroundColor',[1 1 1],...
                  'HorizontalAlignment','Left',...
                  'Position',[592 210 150 20],...
                  'String','Fitting Results',...
                  'Style','Text',...
                  'Tag','text_fitting_results');

        % Prepare UI context menus for the parameter options table
        hCmenu = uicontextmenu;
        uimenu('Parent',hCmenu,...
               'Callback',@copy_params_Callback,...
               'Label','Copy to Clipboard',...
               'Tag','context_copy_to_clipboard');

        % Create a table
        n = numel(obj.guess);
        uitable('Parent',hFig,...
                'CellEditCallback',@table_parameter_options_Callback,...
                'ColumnEditable',true(1,4),...
                'ColumnFormat',{'short g','short','short','logical'},...
                'ColumnName',{'Guess','Lower','Upper','Enabled'},...
                'ColumnWidth',{50 50 50 'auto'},...
                'Data',[num2cell([obj.guess(:) obj.bounds]) num2cell(true(n,1))],...
                'FontSize',10,...
                'RowName',obj.nlinParams{obj.modelVal},...
                'Position',paramOptsPos,...
                'Tag','table_parameter_options');
        uitable('Parent',hFig,...
                'ColumnEditable',false,...
                'ColumnFormat',{'char','short g','char'},...
                'ColumnName',{'Parameter','Value','Units'},...
                'ColumnWidth',{'auto',75,75},...
                'FontSize',10,...
                'RowName',[],...
                'Position',resultsPos,....
                'Tag','table_results',...
                'uicontextmenu',hCmenu);

    end

    % Perform exam specific GUI modifications
    if strcmpi(modelType,'multiti') && obj.restoreInv
        set( findobj('Tag','context_invert_signal'), 'Visible','on');
    end

    % Create some PostSet listeners for the modeling object. To avoid these
    % event listeners piling up in the modeling object, the handle to the
    % listener should be cached in the application data and deleted when the
    % figure is terminated. Currently, the modeling object is deleted upon
    % deletion of the GUI, during which time these listeners are deleted. Future
    % developments may require a more robust alternative.
    addlistener(obj,'bounds',   'PostSet',@qim_update_options);
    addlistener(obj,'guess',    'PostSet',@qim_update_options);
    addlistener(obj,'autoGuess','PostSet',@qim_update_options);
    addlistener(obj,'results',  'PostSet',@qim_update_results);

    % Cache the models object and the data mode (used to determine how to grab
    % data from qt_exam)
    setappdata(hFig,'modelsObject',obj);
    setappdata(hFig,'dataMode','none');

    % Register the "external" modeling figure with the modeling object so that
    % the figure can be updated when changes to the modeling object are made
    obj.register(hFig);

    % Create some figure menus. This most be done after registering the figure
    % handle to the modeling object because that task sets the necessary
    % application data that drives activation of the menus children
    qimtool_menus(hFig);

    % Grab the handles structure
    hs = guihandles(hFig);

    % Create some PostSet listeners for the QIM tool's UI tools
    addlistener(hs.edit_slice,   'String','PostSet',@qim_selection_postset);
    addlistener(hs.edit_series,  'String','PostSet',@qim_selection_postset);
    addlistener(hs.popupmenu_roi,'Value', 'PostSet',@qim_selection_postset);

    % All tools have been initialized at this point. Update the application data
    set_ui_current_value(hFig);

    % Perform QUATTRO specific preparations
    if isQt

        % Set the figure position so it coincides with the main QUATTRO GUI
        qtPos = get(hQt,'Position');
        set(hFig,'Position',[qtPos(1:2) figPos(3:4)])

        % Create some PostSet listeners that update the ROI information of the
        % modeling GUI following changes to the ROI listbox strings
        hList = findobj(obj.hExam.hFig,'Tag','listbox_rois');
        lhs   = addlistener(hList,'String','PostSet',...
                                              @qim_listbox_rois_string_postset);

        % Update the data mode pop-up menu and model pop-up menu to reflect the
        % data available from the main QUATTRO GUI. Also, prepare the the ROI
        % selection pop-up menu if data are available
        hQtRoi = findobj(hQt,'Tag','listbox_rois');
        if obj.hExam.exists.rois.roi
            set(hs.popupmenu_data,'String',...
                           {'','Cur. Pixel','Cur. ROI Proj.','Cur. ROI','VOI'});
            roiIdx = get(hQtRoi,   'Value');
            set(hs.popupmenu_roi,'Value',roiIdx(1));
        else
            set(hs.popupmenu_data,'String',{'','Cur. Pixel'});
        end

        % By default, the modeling GUI is linked to QUATTRO. Update the slice
        % and series locations now
        hQtSlice   = findobj(hQt,'Tag','slider_slice');
        hQtSeries  = findobj(hQt,'Tag','slider_series');
        lhs(end+1) = addlistener(hQtSlice, 'Value','PostSet',...
                                               @qim_slider_slice_value_postset);
        lhs(end+1) = addlistener(hQtSeries,'Value','PostSet',...
                                              @qim_slider_series_value_postset);
        lhs(end+1) = addlistener(hQtRoi,   'Value','PostSet',...
                                               @qim_listbox_rois_value_postset);
        sliceIdx   = get(hQtSlice, 'Value');
        seriesIdx  = get(hQtSeries,'Value');
        set(hs.edit_slice,   'String',num2str(sliceIdx));
        set(hs.edit_series,  'String',num2str(seriesIdx));

        % Store the listeners in the application to data to ensure that they are
        % deleted when the GUI is terminated
        setappdata(hFig,'listeners',lhs);

    end

    % Fire the qim_update_results event to ensure that the current results are
    % displayed properly in the GUI
    if ~isempty(obj.results)
        qim_update_results([],struct('AffectedObject',obj));
    end

end %qimtool


%-----------------------Callback/Ancillary Functions----------------------------

function button_down_Callback(hObj,eventdata)

    % Don't do anything unless RMB was pressed
    if ~strcmpi( get(hObj,'SelectionType'), 'alt' )
        return
    end

    % Determine what was hit
    cp       = get(hObj,'CurrentPoint');
    if verLessThan('matlab','8.4.0')
        hHit = hittest(hObj,cp);
    else
        hHit = hittest(hObj);
    end
    hParent  = get(hHit,'Parent');

    % Cache current point for "Remove Point" menu
    if strcmpi( get(hParent,'Tag'), 'axes_main')
        hHit = hParent;
    end
    if strcmpi( get(hHit,'Tag'), 'axes_main')
        cp = get(hHit,'CurrentPoint');
        setappdata(hObj,'contextPoint',cp);
    end

end %button_down_Callback

function change_data_Callback(hObj,eventdata)

    % Determine if selection has changed
    val = get(hObj,'Value');
    if val==getappdata(hObj,'currentvalue')
        return
    end

    % Get the modeling and QUATTRO figure handles, modeling object, and the
    % current data mode
    hFig     = guifigure(hObj);
    obj      = getappdata(hFig,'modelsObject');
    hQt      = getappdata(hFig,'linkedfigure');

    % Find UI control handles and update app data
    hRoi  = [findobj(hFig,'Tag','popupmenu_roi')...
             findobj(hFig,'Tag','text_roi')];
    hPos  = [findobj(hFig,'Tag','text_slice')...
             findobj(hFig,'Tag','edit_slice')...
             findobj(hFig,'Tag','text_series')...
             findobj(hFig,'Tag','edit_series')];
    setappdata(hObj,'currentvalue',val);

    % Determine what change has been made
    switch getPopupMenu(hObj)
        case 'Cur. ROI Proj.'
            % Grab the exam object so the ROI names can be determined and
            % update the appropriate controls
            set([hRoi(:);hPos(:)],'Visible','on');
            set(hRoi(1),'String',obj.hExam.roiNames.roi);

            % Define the data mode
            dataMode = 'project';
        case 'Cur. ROI'
            %TODO: write code to validate that the ROI in question is
            %available on all series points (better yet, only populate the
            %new tools with ROIs that are valid for this feature)
            set(hObj,'Value',1);
            setappdata(hObj,'currentvalue',1);
            return
        case 'VOI'
            %TODO: write code to validate that the ROI in question is
            %available on all series points (better yet, only populate the
            %new tools with ROIs that are valid for this feature)
            set(hObj,'Value',1);
            setappdata(hObj,'currentvalue',1);
            return
        case 'Cur. Pixel'
            hCur = findall(hQt,'Tag','uitoggletool_data_cursor');
            if strcmpi( get(hCur,'State'), 'off' )
                set(hCur,'State','on'); %initialize the state, which fires the
                                        %"state" PostSet event
            end

            % Hide the ROI tools on the modeling GUI
            set(hRoi,'Visible','off');

            % Store the mode
            dataMode = 'pixel';
        otherwise
            set([hRoi(:);hPos(:)],'Visible','off');
            dataMode = 'none';
    end

    % Update the application data so listeners know how to pass data along
    % to the GUI (and modeling object)
    setappdata(hFig,'dataMode',dataMode);

    % Update the modeling object y data
    if ~strcmpi(dataMode,'none')
        exObj = getappdata(hFig,'qtExamObject');
        obj.y = exObj.getroivals(dataMode,@mean,true,...
                                 'slice', str2double( get(hPos(2),'String') ),...
                                 'series',str2double( get(hPos(4),'String') ),...
                                 'roi',   get(hRoi(1),'Value'),...
                                 'tag',   'roi');
    end

end %change_data_Callback

function change_loc_Callback(hObj,eventdata)

    % Determine if the selection was changed
    uiStyle = get(hObj,'Style');
    val     = get(hObj,'Value');
    if strcmpi(uiStyle,'edit')
        val = str2double( get(hObj,'String') );

        % Validate the text box data
        if isnan(val) || isinf(val)
            set(hObj, 'String', num2str( getappdata(hObj,'currentvalue') ));
            return
        end
    end
    if (val==getappdata(hObj,'currentvalue'))
        return
    end

    % Update the application data
    setappdata(hObj,'currentvalue',val);

    % Normally, this callback would handle updating the modeling object,
    % resulting in a cascade of changes to the QIM tool. However, when linking
    % is enabled between QUATTRO and the QIM tool, changes to the text boxes are
    % made through the "set" method, which, in turn causes the firing of
    % property listeners (specifically qim_selection_postset). This listener
    % performs all necessary updates.

    % This callack is necessary to ensure that the "bad" values provided by the
    % user in the edit text boxes are handled appropriately.

end %change_loc_Callback

function change_fit_Callback(hObj,eventdata)

    % Get and update current value
    val = get(hObj,'Value');
    if val==getappdata(hObj,'currentvalue')
        return
    end

    % Store model value if needed
    obj = getappdata( guifigure(hObj), 'modelsObject' );
    if strcmpi(get(hObj,'Tag'),'popupmenu_model')
        obj.modelVal = val;
    elseif strcmpi(get(hObj,'Tag'),'popupmenu_fit_type')
        switch val
            case 1
                obj.algorithm = 'levenberg-marquardt';
            case 2
                obj.algorithm = 'robust';
            case 3
                obj.algorithm = 'trust-region-reflective';
            case 4
                warndlg('GP is a work in progress...');
                set(hObj,'Value',getappdata(hObj,'currentvalue'));
        end
    end

    % Update new current value
    setappdata(hObj,'currentvalue',val);

end %change_fit_Callback

function copy_params_Callback(hObj,eventdata)

    % Find the results table
    hTable = findobj( guifigure(hObj), 'Tag', 'table_results' );
    if isempty(hTable)
        return
    end

    % Get the table values
    vals = get(hTable,'Data');
    vals = vals(:,2);
    if isempty(vals)
        return
    end

    %TODO: currenlty, this callback grabs all values in the "Fitting Results"
    %table. In the future, it would be nice to allow the user to select specific
    %values within the table.

    % Create a sting of numeric values
    str = sprintf('%f\n',vals{:});

    % Copy string to clipboard
    clipboard('copy',str);

end %copy_params_Callback

function key_press_Callback(hObj,eventdata)

    % Determine action
    if isempty(eventdata.Modifier)
        if strcmpi(eventdata.Key,'escape')
            close( guifigure(hObj) );
        end
    elseif strcmpi(eventdata.Modifier{1},'control')
        if strcmpi(eventdata.Key,'c')
            copy_params_Callback(hObj,eventdata);
        end
    end

end %key_press_Callback

function invert_data_Callback(hObj,eventdata)

    obj = getappdata( guifigure(hObj), 'modelsObject' );
    if isempty(obj.yProc)
        return
    end

    % Get the last point clicked
    curPt = get( get(gco,'Parent'), 'CurrentPoint' );

    % Calculate closest point
    if ~isempty(obj.yProc)
        d = sqrt( (obj.x-curPt(1,1)).^2 + (obj.yProc-curPt(1,2)).^2 );
    else
        d = sqrt( (obj.x-curPt(1,1)).^2 + (obj.y-curPt(1,2)).^2 );
    end

    % Invert, fit, and show new data
    obj.yProc((d==min(d))) = -obj.yProc(d==min(d));

end %invert_data_Callback

function select_data_Callback(hObj,eventdata)

    % Get figure handle and modeling object
    hFig = guifigure(hObj);
    tag  = get(hObj,'Tag');
    obj  = getappdata(hFig,'modelsObject');

    % Determine action
    if strcmpi(tag,'context_restore_data')
        obj.subset(:) = true; %resets index
    elseif strcmpi(tag,'context_remove_point')
        % Get the last point clicked
        cp = getappdata(hFig,'contextPoint' );

        % Calculate closest point
        d = inf(size(obj.subset));
        d(obj.subset) = sqrt( (obj.xProc-cp(1,1)).^2 + (obj.yProc-cp(1,2)).^2 );

        % Remove index
        obj.subset(d==min(d)) = false;
    else

        % Grab the exams object to determine what exam type is being used
        exObj = getappdata(hFig,'qtExamObject');

        % Get values
        switch exObj.type
            case {'edwi','dw','dti'}
                str = 'b-values';
            case {'dce','dsc'}
                str = 'Time Pts.';
            case 'multiti'
                str = 'TI';
            case 'multiflip'
                str = 'Flip Angle';
            case 'multitr'
                str = 'TR';
            case 'multite'
                str = 'TE';
        end

        % Get user input
        [ind,ok] = cine_dlgs('multi_param_select',str,obj.x);
        if ok
            obj.subset = ind;
        end
    end

end %select_data_Callback
        
function set_axes_limits_Callback(hObj,eventdata) %#ok<*INUSL,*INUSD>

    % Find the axis
    hAx = findobj( guifigure(hObj), 'Tag', 'axes_main' );
    if isempty(hAx)
        return
    end

    % Get the current limits so those values can be used as defaults when the
    % user is prompted to enter new values
    xlim = get(hAx,'XLim');
    ylim = get(hAx,'YLim');
    [xlim,ylim,ok] = cine_dlgs('axes_limits',xlim(1),xlim(2),ylim(1),ylim(2));
    if ~ok
        return
    end

    % Update the axis
    set(hAx,'XLim',xlim,'YLim',ylim);

end %set_axes_limits_Callback

function table_parameter_options_Callback(hObj,eventdata)

    % Grab the data
    data = get(hObj,'Data');
    inds = eventdata.Indices;

    % Check that the input is convertable to a number
    if isnan( str2double(eventdata.EditData) )
        data{inds(1),inds(2)} = eventdata.PreviousData;
        set(hObj,'Data',data);
        return
    end

    % Get the modeling object
    obj = getappdata( guifigure(hObj), 'modelsObject' );

    % There are a few cases to handle here: (1) one of the guess values have
    % been changed - disable autoGuess and re-fit, (2) one of the bounds have
    % been changed - if the results are within the bounds do nothing, otherwise
    % re-fit. The PostSet property events of the qt_models object perform
    % validation on the values (bounds and guess), and the PostSet events
    % attached by qimtool updates the table accordingly.
    if inds(2)==1 %new guess
        obj.guess = cell2mat(data(:,1));
    elseif any(inds(2)==2:3) %new bounds
        obj.bounds(inds(1),inds(2)-1) = eventdata.NewData;
    else %enable/disable parameter
        %TODO: since most of the testing of this feature were performed using
        %VFA relaxometry techniques (i.e., there were two parameters that are
        %always estimated), the code here needs to be designed and tested with
        %more complex models that have parameters that can be enabled/disabled
    end
    
end %table_parameter_options_Callback

function delete_models_fig(hObj,eventdata)

    % Get the figure handle
    hFig = guifigure(hObj);
    hQt  = getappdata(hFig,'linkedfigure');

    % Grab the models object and delete if possible
    obj = getappdata(hFig,'modelsObject');
    if ~isempty(obj) && obj.isvalid
        obj.delete;
    end

    % Recycle the recently removed models object
    if ~isempty(hQt) && ishandle(hQt)
        qtObjs = getappdata(hQt,'modelsObject');
        qtObjs = qtObjs( qtObjs.isvalid );
        setappdata(hQt,'modelsObject',qtObjs);
    end

    % Various listeners might be cached (QUATTRO links only). These must be
    % deleted to avoid wasting computation
    lhs = getappdata(hFig, 'listeners');
    if ~isempty(lhs)
        delete(lhs);
    end

    % Delete the figure
    delete(hObj);

end %delete_models_fig