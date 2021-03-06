function image_tools(hQt)
%image_tools  Builds basic QUATTRO image tools
%
%   image_tools(H) creates the basic image tools used by QUATTRO specified by
%   the handle H.

    % Verify input
    if isempty(hQt) || ~ishandle(hQt) || ~strcmpi(get(hQt,'Name'),qt_name)
        error(['QUATTRO:' mfilename 'qtHandleChk'],...
                                            'Invalid handle to QUATTRO figure');
    end

    % Prepare the image display using the API imdisp
    hs = imdisp(hQt,[20 98 512 512]);

    % Update some of the API properties
    set(hs.uipanel_image,'Tag','uipanel_axes_main',...
                         'Visible','off');
    set(hs.axes_image,   'Tag','axes_main');
    set(hs.slider_bottom,'Callback',@slider_Callback,...
                         'Min',1,...
                         'Max',2,...
                         'Tag','slider_slice',...
                         'Visible','off');
    set(hs.slider_side,  'Callback',@slider_Callback,...
                         'Min',1,...
                         'Max',2,...
                         'Tag','slider_series',...
                         'Visible','off');

    uicontrol('Parent',hQt,...
              'Callback',@change_view_Callback,...
              'Position',[145 30 95 20],...
              'BackgroundColor',[1 1 1],...
              'ForegroundColor',[0 0 0],...
              'String',{''},...
              'Style','PopupMenu',...
              'Tag','popupmenu_view_plane',...
              'Visible','off');

    % Prepare text
    uicontrol('Parent',hQt,...
              'Enable','on',...
              'Position',[145 50 95 20],...
              'String','View Plane:',...
              'Style','text',...
              'Tag','text_view_plane',...
              'Visible','off');

    drawnow;

end %image_tools