function texture_tools(h_qt)
%texture_tools  Builds QUATTRO tools for performing texture analysis of images
%
%   texture_tools(h_qt) creates a stand-alone interface and associated tools for
%   performing texture analysis, linking the instance of QUATTRO specified by
%   the handle h_qt

% Verify input
if nargin< 1 || isempty(h_qt) || ~ishandle(h_qt) || ~strcmpi(get(h_qt,'Name'),qt_name)
    error(['QUATTRO:' mfilename ':qtHandleChk'],...
                                            'Invalid handle to QUATTRO figure');
end

%%%%%%%%%% If you want to enforce singleton (i.e. only one figure at a time), do
%          that here. I can show you how to do that if you want. %%%%%%%%%%


% Get handles structure and some color properties
hs = guidata(h_qt); %use the handles structure (specifically, hs.listbox_regions)
bkg = get(h_qt,'Color');

% Prepare main figure
qt_pos = get(h_qt,'Position'); %use QUATTRO position to place new window on same monitor
fig_pos = [qt_pos(1:2) 808 420];
h_fig = figure('CloseRequestFcn',@delete_fig_main,...
               'Color',          bkg,...
               'Filename',       mfilename,...
               'IntegerHandle',  'off',...
               'MenuBar',        'None',... you might want to have oDid you know ne of these (e.g. to save data)
               'Name',           'What''s my name?!',...define the name of your figure
               'NumberTitle',    'off',...
               'Position',       fig_pos,...
               'Tag',            'figure_main',...
               'Toolbar',        'figure',...
               'Units',          'Pixels');
     set(h_fig,'defaultaxescolor',     [1 1 1],...
               'defaultaxesxcolor',    [1 1 1],...
               'defaultaxesycolor',    [1 1 1],...
               'defaultaxesunits',     'normalized',...
               'defaultaxesxticklabel','',...
               'defaultaxesyticklabel','');
setappdata(h_fig,'qtExamObject',obj);   %cache exams object
setappdata(h_fig,'linkedfigure',h_qt); %link to QUATTRO
add_logo(h_fig);


%%%%%%%%%% Define your tools here  (see uicontrol) %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%% Define callbacks for UI tools here      %%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%