function hFig = dwoptsgui(obj)
%dwoptsgui  Creates an interactive GUI for selecting DWI exam options
%
%   dwoptsgui creates an interactive GUI associated with QUATTRO that allows
%   the user to edit DWI exam options. Pressing the 'escape' key will cancel any
%   changes and pressing the 'enter' key will accept all option changes.
%
%       ~Note: functionality of this GUI is not supported outsied of QUATTRO

    if nargin<1 || ~strcmpi( class(obj), 'qt_exam' ) || ~obj.isvalid
        error(['QUATTRO:' mfilename ':invalidObjInput'],...
                          'The input must be a valid object of class qt_exam.');
    end

    % Enforce singleton functionality
    if check_singleton(0,'Name','DW Options')
        return
    end

    % Color setup and exams object retrevial
    bkg = [93 93 93]/255;

    % Prepare main figure
    hFig = figure('CloseRequestFcn',@(h,ed) delete(h),...
                  'Color',bkg,...
                  'Filename',mfilename,...
                  'IntegerHandle','off',...
                  'MenuBar','None',...
                  'Name','DWI Options',...
                  'NumberTitle','off',...
                  'Position',[520 380 266 250],...
                  'Resize','off',....
                  'Tag','figure_main',...
                  'Units','pixels',...
                  'WindowKeyPressFcn',@options_key_press_Callback,...
                  'WindowStyle','modal');
         set(hFig,'defaultuicontrolhorizontalalignment','right',...
                  'defaultuicontrolbackgroundcolor',bkg,...
                  'defaultuicontrolforegroundcolor',[1 1 1],...
                  'defaultuicontrolfontsize',9,...
                  'defaultuicontrolstyle','checkbox',...
                  'defaultuicontrolunits','pixels',...
                  'defaultuipanelbordertype','etchedin',...
                  'defaultuipanelunits','Pixels',...
                  'defaultuipanelbackgroundcolor',bkg,...
                  'defaultuipanelforegroundcolor',[1 1 1]);
    setappdata(hFig,'examtype',obj.type);
    add_logo(hFig);

    % Prepare UI panels
    hUip(1) = uipanel('Parent',hFig,...
                      'Position',[10 84 246 150],...
                      'Tag','uipanel_diffusion_model_options',...
                      'Title','Diffusion Model Options');
    hUip(2) = uipanel('Parent',hUip(1),...
                      'Position',[10 8 226 85],...
                      'Tag','uipanel_diffusion_maps',...
                      'Title','Maps');

    % Prepare tools
    mObj = eval(obj.type);
    uicontrol('Parent',hFig,...
              'BackgroundColor',1.2*bkg,...
              'Callback',@accept_options_Callback,...
              'Position',[60 40 60 22],...
              'String','Accept',...
              'Style','Pushbutton',...
              'Tag','pushbutton_accept');
    uicontrol('Parent',hFig,...
              'BackgroundColor',1.2*bkg,...
              'Callback',@(h,ed) delete(hFig),...
              'Position',[140 40 60 22],...
              'String','Cancel',...
              'Style','pushbutton',...
              'Tag','pushbutton_cancel');
    uicontrol('Parent',hUip(1),....
              'BackgroundColor',[1 1 1],...
              'ForegroundColor',[0 0 0],...
              'Position',[53 106 90 20],...
              'String',mObj.modelNames,...
              'Style','PopupMenu',...
              'Tag','dwModel');
    uicontrol('Parent',hUip(1),...
              'Position',[156 106 80 20],...
              'String','Multi-slice',...
              'Tag','multiSlice');
    uicontrol('Parent',hUip(2),...
              'Position',[15 45 70 20],...
              'String','S0 (a.u.)',...
              'Tag','s0Map');
    uicontrol('Parent',hUip(2),...
              'Position',[15 15 100 20],...
              'String','ADC (mm^2/s)',...
              'Tag','adcMap');
    uicontrol('Parent',hUip(2),...
              'Position',[100 45 120 20],...
              'String','Mean ADC (mm^2/s)',...
              'Tag','meanAdcMap');

    % Prepare text
    uicontrol('Parent',hUip(1),...
              'Position',[10 104 40 20],...
              'String','Model:',...
              'Style','Text',...
              'Tag','text_model');

    % Grab the handles structure for updating the initial GUI values
    hs = guihandles(hFig);

    % Set options
    dwOpts = {'dwModel',...
              'multiSlice',...
              's0Map',...
              'adcMap',...
              'meanAdcMap'};
    cellfun(@(x) assign_values(hs.(x),obj.opts.(x)),dwOpts);

    % Set the standard application data
    setappdata(hFig,'qtExamObject',obj);
    setappdata(hFig,'qtOptsObject',obj.opts);
    setappdata(hFig,'optionNames',dwOpts);

    % All tools have been initialized at this point. Update the application data
    set_ui_current_value(hFig);

end %dwoptsgui