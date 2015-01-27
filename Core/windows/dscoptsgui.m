function hFig = dscoptsgui(obj)
%dscoptsgui  Creates an interactive GUI for selecting DSC exam options
%
%   dscoptsgui(OBJ) creates an interactive GUI associated with QUATTRO that
%   allows the user to interactively change DSC exam options. Pressing the
%   'escape' key will cancel any actions and pressing the 'enter' key will
%   accept all options. OBJ is a valid qt_exam object
%
%       ~Note: functionality of this GUI is not supported outside of QUATTRO

    if nargin<1 || ~strcmpi( class(obj), 'qt_exam' ) || ~obj.isvalid
        error(['QUATTRO:' mfilename ':invalidObjInput'],...
                          'The input must be a valid object of class qt_exam.');
    end

    % Enforce singleton functionality
    if check_singleton(0,'Name','DSC Options')
        return
    end

    % Color setup
    bkg = [93 93 93]/255;

    % Prepare main figure
    hFig = figure('CloseRequestFcn',@(h,ed) delete(h),...
                  'Color',bkg,...
                  'Filename',mfilename,...
                  'IntegerHandle','off',...
                  'MenuBar','None',...
                  'Name','DSC Options',...
                  'NumberTitle','off',...
                  'Position',[520 380 320 460],...
                  'Resize','off',....
                  'Tag','figure_main',...
                  'Units','pixels',...
                  'WindowKeyPressFcn',@options_key_press_Callback,...
                  'WindowStyle','modal');
         set(hFig,'defaultuicontrolhorizontalalignment','right',...
                  'defaultuicontrolbackgroundcolor',bkg,...
                  'defaultuicontrolforegroundcolor',[1 1 1],...
                  'defaultuicontrolfontsize',9,...
                  'defaultuicontrolstyle','Checkbox',...
                  'defaultuicontrolunits','Pixels',...
                  'defaultuipanelbordertype','EtchedIn',...
                  'defaultuipanelunits','Pixels',...
                  'defaultuipanelbackgroundcolor',bkg,...
                  'defaultuipanelforegroundcolor',[1 1 1]);
    setappdata(hFig,'examtype',obj.type);
    add_logo(hFig);

    % Prepare UI panels
    hUip(1) = uipanel('Parent',hFig,...
                      'Position',[10 260 300 170],...
                      'Tag','uipanel_tracer_kinetics_model_options',...
                      'Title','Tracer Kinetics Model Options');
    hUip(2) = uipanel('Parent',hFig,...
                      'Position',[10 107 246 150],...
                      'Tag','uipanel_pharmacokinetic_maps',...
                      'Title','Tracer Kinetics Map Options');

    % Prepare tools
    mObj = eval(obj.type);
    uicontrol('Parent',hFig,...
              'BackgroundColor',1.2*bkg,...
              'Callback',@accept_options_Callback,...
              'Position',[60 20 60 22],...
              'String','Accept',...
              'Style','Pushbutton',...
              'Tag','pushbutton_accept');
    uicontrol('Parent',hFig,...
              'BackgroundColor',1.2*bkg,...
              'Callback',@(h,ed) delete(hFig),...
              'Position',[140 20 60 22],...
              'String','Cancel',...
              'Style','pushbutton',...
              'Tag','pushbutton_cancel');
    uicontrol('Parent',hUip(1),...
              'BackgroundColor','w',...
              'ForegroundColor','k',...
              'Position',[53 126 90 20],...
              'String',mObj.modelNames,...
              'Style','popupmenu',...
              'Tag',[obj.type 'Model']);
    uicontrol('Parent',hUip(1),...
              'BackgroundColor','w',...
              'Callback',@edit_options_Callback,...
              'ForegroundColor','k',...
              'HorizontalAlignment','center',...
              'Position',[95 100 40 20],...
              'Style','edit',...
              'Tag','preEnhance');
    uicontrol('Parent',hUip(1),...
              'BackgroundColor','w',...
              'Callback',@edit_options_Callback,...
              'ForegroundColor','k',...
              'HorizontalAlignment','center',...
              'Position',[235 100 40 20],...
              'Style','edit',...
              'Tag','recirc');
    uicontrol('Parent',hUip(1),...
              'BackgroundColor','w',...
              'Callback',@edit_options_Callback,...
              'ForegroundColor','k',...
              'HorizontalAlignment','center',...
              'Position',[95 70 40 20],...
              'Style','edit',...
              'Tag','preSteadyState');
    uicontrol('Parent',hUip(1),...
              'BackgroundColor','w',...
              'Callback',@edit_options_Callback,...
              'ForegroundColor','k',...
              'HorizontalAlignment','center',...
              'Position',[90 40 50 20],...
              'Style','edit',...
              'Tag','hctArt');
    uicontrol('Parent',hUip(1),...
              'BackgroundColor','w',...
              'Callback',@edit_options_Callback,...
              'ForegroundColor','k',...
              'HorizontalAlignment','center',...
              'Position',[235 40 50 20],...
              'Style','edit',...
              'Tag','hctCap');
    uicontrol('Parent',hUip(1),...
              'BackgroundColor','w',...
              'Callback',@edit_options_Callback,...
              'ForegroundColor','k',...
              'HorizontalAlignment','center',...
              'Position',[160 10 50 20],...
              'Style','edit',...
              'Tag','r2Gd');
    uicontrol('Parent',hUip(2),...
              'Callback',@edit_options_Callback,...
              'Position',[10 110 80 20],...
              'String','MTT',...
              'Tag','mttMap');
    uicontrol('Parent',hUip(2),...
              'Callback',@edit_options_Callback,...
              'Position',[10 85 80 20],...
              'String','rCBV',...
              'Tag','rcbvMap');
    uicontrol('Parent',hUip(2),...
              'Callback',@edit_options_Callback,...
              'Position',[150 15 80 20],...
              'String','Multi-Slice',...
              'Tag','multiSlice');

    % Prepare text
    uicontrol('Parent',hUip(1),...
              'Position',[10 124 40 20],...
              'Style','text',...
              'String','Model:',...
              'Tag','text_model');
    uicontrol('Parent',hUip(1),...
              'Position',[10 98 80 20],...
              'Style','text',...
              'String','Base Images:',...
              'Tag','text_preEnhance');
    uicontrol('Parent',hUip(1),...
              'Position',[150 98 80 20],...
              'Style','text',...
              'String','Recirc Image:',...
              'Tag','text_recirc');
    uicontrol('Parent',hUip(1),...
              'Position',[10 68 85 20],...
              'Style','text',...
              'String','Ignore Images:',...
              'Tag','text_preSteadyState');
    uicontrol('Parent',hUip(1),...
              'Position',[12 38 70 20],...
              'Style','text',...
              'String','Hct (arterial):',...
              'Tag','text_hctArt');
    uicontrol('Parent',hUip(1),...
              'Position',[150 38 80 20],...
              'Style','text',...
              'String','Hct (capillary):',...
              'Tag','text_hctCap');
    uicontrol('Parent',hUip(1),...
              'Position',[7 8 150 20],...
              'Style','text',...
              'String','Gd Relaxivity (/sec/mM):',...
              'Tag','text_r2Gd');

    % Grab the handles structure for updating the initial GUI values
    hs = guihandles(hFig);

    % Set options
    dscOpts = {'dscModel',...
               'multiSlice',...
               'hctArt',...
               'hctCap',...
               'preEnhance',...
               'recirc',...
               'preSteadyState',...
               'r2Gd',...
               'mttMap',...
               'rcbvMap'};
    cellfun(@(x) assign_values(hs.(x),obj.opts.(x)),dscOpts);

    % Set the standard application data
    setappdata(hFig,'qtExamObject',obj);
    setappdata(hFig,'qtOptsObject',obj.opts);
    setappdata(hFig,'optionNames',dscOpts);

    % All tools have been initialized at this point. Update the application data
    set_ui_current_value(hFig);

end %dscoptsgui