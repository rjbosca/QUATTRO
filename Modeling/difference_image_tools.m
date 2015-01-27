function difference_image_tools
%difference_image_tools  Builds the difference image QUATTRO tools

% Verify input
if isempty(h_qt) || ~ishandle(h_qt) || ~strcmpi(get(h_qt,'Name'),qt_name)
    error(['QUATTRO:' mfilename 'qtHandleChk'],...
                                            'Invalid handle to QUATTRO figure');
end

% Prepare UI panel
h_uip = uipanel('Parent',h_qt,...
                'Position',[910 30 140 140],...
                'Tag','uipanel_difference_image',...
                'Title','Difference Image',...
                'Visible','off');

% Prepare tools
uicontrol('Parent',h_uip,...
          'Callback',@show_diff_image_Callback,...
          'Position',[10 48 100 23],...
          'String','Show Difference',...
          'Style','Checkbox',...
          'Tag','checkbox_show_difference_image',...
          'Value',false);
uicontrol('Parent',h_uip,...
          'Callback',@show_mip_diff_image_Callback,...
          'Position',[10 10 120 33],...
          'String','Show MIP Difference',...
          'Style','Checkbox',...
          'Tag','checkbox_show_mip_difference_image',...
          'Value',false);
uicontrol('Parent',h_uip,...
          'BackgroundColor',[1 1 1],...
          'Callback',@edit_base_image_Callback,...
          'ForegroundColor',[0 0 0],...
          'String','1',...
          'Style','Edit',...
          'Tag','edit_base_image');

% Prepare text
uicontrol('Parent',h_uip,...
          'Position',[5 106 75 15],...
          'String','Base Image',...
          'Style','Text',...
          'Tag','text_base_image');


%-----------------------Callback/Ancillary Functions----------------------------

    function show_diff_image_Callback(hObj,eventdata) %#ok<*INUSD>

        % Deletes difference image
        hs = guihandles(hObj);
        if ~get(hObj,'Value')
            if isfield(hs, 'DiffImage')
                if ishandle(hs.DiffImage.Figure)
                    delete( hs.DiffImage.Figure );
                end
                hs = rmfield(hs, 'DiffImage');
            end
        else
            % Updates difference image
            hs = ShowDiffImage(hs);
        end

    end %show_diff_image_Callback

    function show_mip_diff_image_Callback(hObj,eventdata)

        % Deletes difference imgae
        hs = guihandles(hObj);
        if ~get(hObj,'Value')
            if isfield(hs, 'MIPImage')
                if ishandle(hs.MIPImage.Figure)
                    delete( hs.MIPImage.Figure );
                end
            end
            if isfield(hs, 'DiffMIPImage')
                if ishandle(hs.DiffMIPImage.Figure)
                    delete( hs.DiffMIPImage.Figure );
                end
            end
        else
            %Updates MIP difference image
            hs = ShowDiffImage(hs);
        end

    end %show_mip_diff_image_Callback

    function edit_base_image_Callback(hObj,eventdata)

        base_num = str2double(get(hObj,'String'));
        hs = guihandles(hObj);

        % ERROR CHECK: (1) the difference image must be dispalyed (2) the edit box
        % value must be a number greater than 1 and less than or equal to the
        % number of slices
        if ~get(handles.checkbox_view_difference, 'Value')
            return
        elseif isnan(base_num) || base_num < 1 || base_num > hdrs('size',2)
            set(hObj,'String',1);
            return
        end

        % Updates difference image
        handles = ShowDiffImage(handles);

    end %edit_base_image_Callback

end %difference_image_tools