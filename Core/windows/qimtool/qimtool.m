function hFig = qimtool(obj)
%qimtool  Creates a quantitative image modeling (QIM) GUI
%
%   H = qimtool(OBJ) creates an interactive GUI that allows the user to
%   interactively navigate data and fitted models stored in one of the modeling
%   objects specified by OBJ. The figure handle, H, is returned.
%
%   If a QT_EXAM object is registered with an instance of the QUATTRO GUI, the
%   UI tools of qimtool will reflect additional options for selecting data
%
%   See also qt_models.qt_models and qt_exam.qt_exam

    % Verify caller
    mType = class(obj);
    if ~nargin || (~strcmpi(mType,'qt_models') &&...
                                 ~any( strcmpi('modelbase',superclasses(obj)) ))
        error(['QUATTRO:' mfilename ':guiConstructorChk'],...
                             'Invalid call to GUI constructor. See qt_models.');
    elseif numel(size(obj.y))>2
        error(['QUATTRO:' mfilename ':guiAvailabiltiyChk'],...
                   'qt_models GUI is not available for multidimensional data.');
    end

    % Initialize the position vector and background color
    figPos = [644 454 600 470];
    bkg    = 93/255*ones(1,3);

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
                   'NextPlot','add',...
                   'Position',[60 150 512 288],...
                   'Tag','axes_main');

    % Prepare QUATTRO specific tools
    mPkg  = meta.class.fromName(mType).ContainingPackage;
    mPkg  = strrep(mPkg.Name,[mPkg.ContainingPackage.Name '.'],'');
    mVal  = qt_models.model2val(mType);
    mList = qt_models.package2models(mPkg);

    % Prepare universal tools
    uicontrol('Parent',hPan,...
              'Callback',@change_model_Callback,...
              'Position',[412 10 90 20],...
              'String',mList,...
              'Style','PopupMenu',...
              'Tag','popupmenu_model',...
              'Value',mVal);
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

    % Register the "external" modeling figure with the modeling object so that
    % the figure can be updated when changes to the modeling object are made
    obj.register(hFig);

    % Initialize/prepare the model UI panels for those models that have a
    % defined parameterized model (i.e., not "generic")
    if ~strcmpi(mType,'generic')

        % Widen the figure to prepare for the additional tools
        figPos = figPos+[0 0 290 0]; %used later in the "isQt" section
        set(hFig,'Position',figPos);

        % Create the UI panels that will house the tables
        hUip(1) = uipanel('Parent',hFig,...
                          'FontSize',10,...
                          'Position',[587 240 270 203],...
                          'Tag','uipanel_parameter_options',...
                          'Title','Parameter Options',...
                          'Visible','on');
        hUip(2) = uipanel('Parent',hFig,...
                          'FontSize',10,...
                          'Position',[587 10 270 225],...
                          'Tag','uipanel_results',...
                          'Title','Fitting Results',...
                          'Visible','on');

        % Prepare UI context menus for the parameter options table
        hCmenu = uicontextmenu;
        uimenu('Parent',hCmenu,...
               'Callback',@copy_params_Callback,...
               'Label','Copy to Clipboard',...
               'Tag','context_copy_to_clipboard');

        % Create the tables for displaying results and editting fitting options
        uitable('Parent',hUip(1),...
                'CellEditCallback',@table_parameter_options_Callback,...
                'ColumnEditable',[obj.autoGuess true(1,2)],...
                'ColumnFormat',{'short g','short','short'},...
                'ColumnName',{'Guess','Lower','Upper'},...
                'ColumnWidth',{50 50 50},...
                'Data',qt_models.objparams2cell(obj),...
                'FontSize',10,...
                'RowName',obj.nlinParams,...
                'Position',[5 30 260 153],...
                'Tag','table_parameter_options');
        uitable('Parent',hUip(2),...
                'ColumnEditable',false,...
                'ColumnFormat',{'char','short g','char'},...
                'ColumnName',{'Parameter','Value','Units'},...
                'ColumnWidth',{'auto',75,75},...
                'FontSize',10,...
                'RowName',[],...
                'Position',[5 5 260 200],....
                'Tag','table_results',...
                'uicontextmenu',hCmenu);

        % Create the checkbox for setting the automatic estimate feature
        uicontrol('Parent',hUip(1),...
                  'BackgroundColor',bkg,...
                  'Callback',@change_auto_guess_Callback,...
                  'FontSize',10,...
                  'ForegroundColor',[1 1 1],...
                  'Position',[5 5 125 20],...
                  'String','Auto-Guess',...
                  'Style','Checkbox',...
                  'Tag','checkbox_auto_guess',...
                  'Value',obj.autoGuess);

    end

    % Add listeners to the modeling object and append to the application data
    create_model_object_listeners(obj);

    % Create some figure menus. This most be done after registering the figure
    % handle to the modeling object because that task sets the necessary
    % application data that drives activation of the menus children
    qimtool_menus(hFig);

    % Grab the handles structure
    hs = guihandles(hFig);

    % Create some post-pet listeners for the QIM tool's UI tools
    addlistener(hs.edit_slice,   'String','PostSet',@qim_selection_postset);
    addlistener(hs.edit_series,  'String','PostSet',@qim_selection_postset);
    addlistener(hs.popupmenu_roi,'Value', 'PostSet',@qim_selection_postset);

    % All tools have been initialized at this point. Update the application data
    set_ui_current_value(hFig);

    % Fire the qim_update_results event to ensure that the current results are
    % displayed properly in the GUI if they already exist
    if ~isempty(obj.results)
        notify(obj,'showModel');
    end

    % Update the handles structure
    guidata(hFig,hs);

end %qimtool


%-----------------------Callback/Ancillary Functions----------------------------

%------------------------------------------
function create_model_object_listeners(obj)

    % Create some post-set and event listeners for the modeling object. To avoid
    % these event listeners piling up in the modeling object, the handle to the
    % listener should be cached in the application data and deleted when the
    % figure is terminated. Currently, the modeling object is deleted upon
    % deletion of the GUI, during which time these listeners are deleted. Future
    % developments may require a more robust alternative.
    eLhs = [getappdata(obj.hFig,'eventListeners')
            addlistener(obj,'showModel',            @qim_update_results)
            addlistener(obj,'updateModel',          @qim_update_options)];
    pLhs = [getappdata(obj.hFig,'propListeners')
            addlistener(obj,'autoGuess','PostSet',@qim_autoGuess_postset)];

    % Update the application data
    setappdata(obj.hFig,'eventListeners',eLhs);
    setappdata(obj.hFig,'propListeners', pLhs);

end %create_model_object_listeners

%------------------------------------------
function change_auto_guess_Callback(hObj,~)

    % Update the modeling object's "autoGuess" property. The post-set listeners
    % will take care of the rest
    obj           = getappdata(gcbf,'modelsObject');
    obj.autoGuess = logical( get(hObj,'Value') );

end %change_auto_guess_Callback

%------------------------------------
function button_down_Callback(hObj,~)

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

%------------------------------------
function change_data_Callback(hObj,~)

    % Determine if selection has changed
    if qt_abort_set(hObj,'Value')
        return
    end

    % Get the modeling and QUATTRO figure handles, modeling object, and the
    % current data mode
    hFig     = gcbf;
    hs       = guidata(hFig);
    obj      = getappdata(hFig,'modelsObject');

    % Find UI control handles and update app data
    hRoi  = [hs.popupmenu_roi hs.text_roi];
    hPos  = [hs.text_slice hs.edit_slice hs.text_series hs.edit_series];
    setappdata(hObj,'currentvalue',get(hObj,'Value'));

    % Determine what change has been made
    switch getPopupMenu(hObj)
        case 'Cur. ROI Proj.'
            % Grab the exam object so the ROI names can be determined and
            % update the appropriate controls
            set([hRoi(:);hPos(:)],'Visible','on');

            % Define the data mode
            obj.dataMode = 'project';
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
            % Hide the ROI tools on the modeling GUI
            set(hRoi,'Visible','off');
            obj.dataMode = 'pixel';
        otherwise
            set([hRoi(:);hPos(:)],'Visible','off');
            obj.dataMode = 'manual';
    end

end %change_data_Callback

%-----------------------------------
function change_loc_Callback(hObj,~)

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

%-----------------------------------
function change_fit_Callback(hObj,~)

    % Get and update current value
    val = get(hObj,'Value');
    if (val==getappdata(hObj,'currentvalue'))
        return
    end

    % Store model value if needed
    obj = getappdata(gcbf,'modelsObject');
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

    % Update new current value
    setappdata(hObj,'currentvalue',val);

end %change_fit_Callback

%-------------------------------------
function change_model_Callback(hObj,~)

    % Get and update current value
    val = get(hObj,'Value');
    if (val==getappdata(hObj,'currentvalue'))
        return
    end

    % Get the handles structure and some additional application data
    hs      = guidata(hObj);
    appData = getappdata(hs.figure_main);

    % Create a new modeling object from the old modeling object
    mClass  = class(appData.modelsObject);
    mPkg    = meta.class.fromName(mClass).ContainingPackage;
    newObj  = eval( mPkg.ClassList(val).Name );

    % Clone the old object's values and destroy the previous object
    newObj  = appData.modelsObject.clone(newObj,'exclude',...
                           {'autoFit','paramGuess','paramBounds','paramUnits'});
    appData.modelsObject.delete;

    % Copy the "y" property from the previous object and store in the qt_exam
    % object to ensure that updates are handled properly
    newObj.register(hs.figure_main);
    appData.qtExamObject.addmodel(newObj);

    % Add the listeners that update the modeling GUI
    create_model_object_listeners(newObj);

    % Fire the qim_update_results event to ensure that the current results are
    % displayed properly in the GUI if they already exist
    if ~isempty(newObj.results)
        notify(newObj,'showModel');
    end

    % Update the row names for the parameter table
    set(hs.table_parameter_options,'Data',qt_models.objparams2cell(newObj),...
                                   'RowName',newObj.nlinParams);

    % Update the application data
    setappdata(hs.figure_main,'modelsObject',newObj);
    setappdata(hObj,'currentvalue',val);

end %change_model_Callback

%------------------------------------
function copy_params_Callback(hObj,~)

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

%------------------------------------------
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

%------------------------------------
function select_data_Callback(hObj,~)

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

        % Convert numeric data to string data for the list dialog
        xStr = arrayfun(@num2str,obj.x,'UniformOutput',false);

        % Get user input
        [sel,ok] = listdlg('InitialValue',find(obj.subset),...
                           'ListString',xStr,...
                           'Name',[str ' selection'],...
                           'PromptString',['Select ' str ' to use:'],...
                           'SelectionMode','multiple');
        if ok
            newSub      = false(size(obj.subset));
            newSub(sel) = true;
            obj.subset  = newSub;
        end
    end

end %select_data_Callback

%----------------------------------------
function set_axes_limits_Callback(hObj,~)

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

%--------------------------------------------------------
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
    obj   = getappdata( guifigure(hObj), 'modelsObject' );
    param = obj.nlinParams{inds(1)};

    % There are a few cases to handle here: (1) one of the guess values have
    % been changed - disable autoGuess and re-fit, (2) one of the parameter
    % bounds has been changed - if the results are within the bounds do nothing,
    % otherwise re-fit. The PostSet property events of the qt_models object
    % perform validation on the values (bounds and guess), and the PostSet
    % events attached by qimtool updates the table accordingly.
    if (inds(2)==1) %new guess
        obj.paramGuess.(param)             = eventdata.NewData;
    else %new parameter bounds
        obj.paramBounds.(param)(inds(2)-1) = eventdata.NewData;
    end
    
end %table_parameter_options_Callback

%---------------------------------
function delete_models_fig(hObj,~)

    % Get the figure handle
    hFig = gcbf;

    % When working with QUATTRO, the modeling object should be deleted during
    % calls to the figure's CloseRequestFcn
    %FIXME: when using a stand-alone modeling object, the user will likely be
    %upset if the object is destroyed along with the GUI
    obj = getappdata(hFig,'modelsObject');
    if ~isempty(obj) && obj.isvalid
        obj.delete;
    end

    % Various listeners might be cached (QUATTRO links only). These must be
    % deleted to avoid wasting computation
    delete( getappdata(hFig,'propListeners') );
    delete( getappdata(hFig,'eventListeners') );

    % Delete the figure
    delete(hObj);

end %delete_models_fig