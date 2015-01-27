function varargout = hist_viewer(varargin)
%hist_viewer  Provides an interactive histogram tool for QUATTRO
%
%   hist_viewer(H) creates a GUI associated with QUATTRO GUI specified by the
%   handle H that allows the user to interactively show histograms of the images
%   and parametric maps available in the current exam. Multiple instances of the
%   GUI are supported.
%
%   H = hist_viewer(I) creates a stand-alone GUI that allows interactive
%   navigation of the input image's (I) histogram. The figure handle H is
%   returned as the only ouptut

    % Parse inputs
    [hQt,img,obj] = input_parser(varargin{:});

    % Color set up
    bkg = [93 93 93]/255;

    % Determine QUATTRO info if not stand-alone
    figPos = [520 380 560 420];
    popStr = {'Image'};
    if ~isempty(hQt)
        % Determine new figure position
        qtPos = get(hQt,'Position');
        figPos(1:2) = qtPos(1:2);

        % Determine string for pop-up menu
        popStr = [popStr;obj.mapNames];
    end

    % Prepare main figure
    hFig = figure('Color',               bkg,...
                  'Filename',            mfilename,...
                  'IntegerHandle',      'off',...
                  'MenuBar',            'None',...
                  'Name',               'QUATTRO-Image Histogram',...
                  'NumberTitle',        'off',...
                  'Position',            figPos,...
                  'Tag',                'figure_main',...
                  'Toolbar',            'figure',...
                  'Units',              'Pixels');
         set(hFig,'defaultuicontrolunits',          'Pixels',...
                  'defaultuicontrolbackgroundcolor',[1 1 1],...
                  'defaultuicontrolfontsize',        9,...
                  'defaultaxescolor',               [1 1 1],...
                  'defaultaxesxcolor',              [1 1 1],...
                  'defaultaxesycolor',              [1 1 1],...
                  'defaultaxesunits',               'Pixels');
    hTools = findall( findall(hFig,'Type','uitoolbar') );
    delete(hTools([2:7 9 13:17]))
    add_logo(hFig);

    % Prepare display
    axes('Parent',hFig,...
         'Position',[50 50 480 270],...
         'Tag','axes_main');

    % Prepare tools
               set(hFig,'defaultuicontrolcallback',@edit_val,...
                        'defaultuicontrolstyle','edit')
    hStr(1) = uicontrol('Parent',hFig,...
                        'Position',[50 345 50 22],...
                        'String','256',...
                        'Tag','edit_n_bins');
    hStr(2) = uicontrol('Parent',hFig,...
                        'Position',[130 345 55 22],...
                        'String','-inf',...
                        'Tag','edit_minimum');
    hStr(3) = uicontrol('Parent',hFig,...
                        'Position',[210 345 55 22],...
                        'String','inf',...
                        'Tag','edit_maximum');
    hVal(1) = uicontrol('Parent',hFig,...
                        'Callback',@select_data,...
                        'Position',[305 347 95 20],...
                        'String',popStr,...
                        'Style','PopupMenu',...
                        'Tag','popupmenu_data_type');
    hVal(2) = uicontrol('Parent',hFig,...
                        'BackgroundColor',bkg,...
                        'Callback',@show_hist,...
                        'ForegroundColor',[1 1 1],...
                        'Position',[410 345 85 20],...
                        'String','Apply Mask',...
                        'Style','CheckBox',...
                        'Tag','checkbox_apply_mask');

    % Prepare text
    set(hFig, 'defaultuicontrolstyle',              'text',...
              'defaultuicontrolbackgroundcolor',     bkg,...
              'defaultuicontrolforegroundcolor',    [1 1 1],...
              'defaultuicontrolhorizontalalignment','left');
    uicontrol('Parent',hFig,...
              'Position',[50 370 70 20],...
              'String','# of Bins:',...
              'Tag','text_n_bins');
    uicontrol('Parent',hFig,...
              'Position',[130 370 70 20],...
              'String','Minimum:',...
              'Tag','text_minimum');
    uicontrol('Parent',hFig,...
              'Position',[210 370 70 20],...
              'String','Maximum:',...
              'Tag','text_maximum');
    uicontrol('Parent',hFig,...
              'Position',[305 370 70 20],...
              'String','Data Type:',...
              'Tag','text_data_type');

    % Set application data
    arrayfun(@(x) setappdata(x,'currentString',get(x,'String')),hStr);
    arrayfun(@(x) setappdata(x,'currentValue',get(x,'Value')),hVal);

    % Store additional application data used for displaying the histograms
    setappdata(hFig,'histogramData',double(img));
    setappdata(hFig,'roiData',[]);
    setappdata(hFig,'qtExamObject',obj);

    % Deal the output
    if nargout
        varargout{1} = hFig;
    end

    % Show histogram
    show_hist(hFig);

end %hist_viewer


%-------------------------Callback Functions------------------------------------

function edit_val(hObj,eventdata) %#ok<*INUSD>

    % Get the axes handle and UI control values
    hAx    = findobj(guifigure(hObj),'Tag','axes_main');
    tag    = get(hObj,'Tag');
    str    = get(hObj,'String');
    val    = str2double(str);
    strOld = getappdata(hObj,'currentString');
    xl     = get(hAx,'XLim');

    % Verify user input
    isInvalid = strcmpi(str,strOld) || isnan(val) ||...no change/invalid value
               (strcmpi(tag,'edit_n_bins')  && (val < 1 || isinf(val))) ||...
               (strcmpi(tag,'edit_minimum') && (val >= max(xl))) ||...
               (strcmpi(tag,'edit_maximum') && (val <= min(xl)));
    if isInvalid
        set(hObj,'String',strOld);
        return
    end

    % Store app data and update display
    setappdata(hObj,'currentString',str);
    show_hist(hObj);

end %edit_val

function select_data(hObj,eventdata)

    % Verify user input
    if get(hObj,'Value')==getappdata(hObj,'currentValue')
        return
    end

    % Set new app data and show new image histogram
    setappdata(hObj,'currentValue',get(hObj,'Value'));
%     rmappdata(guifigure(hObj),'histogramData');
    show_hist(hObj);

end %select_data


%----------------------------Other Functions------------------------------------

function varargout = input_parser(varargin)

    % Initialize output
    [varargout{1:nargout}] = deal([]);

    % Determine input type
    if numel(varargin{1}) == 1 && ishandle(varargin{1}) &&...
                                        strcmpi(get(varargin{1},'Name'),qt_name)
        varargout{1} = varargin{1};
        varargout{3} = getappdata(varargin{1},'qtExamObject');
    elseif all( size(varargin{1})>1 ) && isnumeric(varargin{1})
        varargout{2} = varargin{1};
    else
        error(['QUATTRO:' mfilename ':inputChk'],'Invalid inputs.');
    end
end