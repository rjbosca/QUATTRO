function jump2ras(h_qt)
%jump2ras  Creates an interactive GUI for navigating 3D image volumes in QUATTRO
%
%   jump2ras(h_qt) creates an interactive GUI associated with QUATTRO that
%   allows the user to interactively navigate a 3D image volume by specifying
%   coordinates. This GUI only supports a single instance. Calling this function
%   with the GUI already created simply brings it to the front.
%
%       ~Note: functionality of this GUI is not supported outside of QUATTRO

if nargin<1 || ~ishandle(h_qt)
    error(['QUATTRO:' mfilename ':inputChk'],'Invalid QUATTRO figure handle.');
end

% Enforce singleton functionality
obj = getappdata(h_qt,'qtExamObject');
if ~isempty(obj.h_jump_fig) && ishandle(obj.h_jump_fig)
    figure(obj.h_jump_fig);
    return
end

% Color setup
bkg = [93 93 93]/255;

% Prepare main figure
hFig = figure('CloseRequestFcn',@delete_fig_main,...
              'Color',bkg,...
              'Filename',mfilename,...
              'IntegerHandle','off',...
              'MenuBar','None',...
              'Name','Jump to RAS',...
              'NumberTitle','off',...
              'Position',[520 596 305 150],...
              'Resize','off',...
              'Tag','figure_main',...
              'Units','Pixels',...
              'WindowKeyPressFcn',@key_press_Callback);
     set(hFig,'defaultuicontrolunits','pixels',...
              'defaultuicontrolbackgroundcolor',[1 1 1],...
              'defaultuicontrolfontsize',9,...
              'defaultuipanelbordertype','etchedin',...
              'defaultuipanelunits','Pixels',...
              'defaultuipanelbackgroundcolor',bkg,...
              'defaultuipanelforegroundcolor',[1 1 1]);
add_logo(hFig);
setappdata(hFig,'qtExamObject',obj);   %cache exams object
setappdata(hFig,'linkedfigure',h_qt); %link to QUATTRO

% Prepare general display
h_pan_ras = uipanel('Parent',hFig,...
                    'Position',[10 32 175 110],...
                    'Tag','uipanel_ras',...
                    'Title','RAS-Coordinates');
h_pan_ijk = uipanel('Parent',hFig,...
                    'Position',[195 32 100 110],...
                    'Tag','uipanel_ijk',...
                    'Title','ijk-Coordinates');

% Prepare tools
f_drop = get(findobj(h_qt,'Tag','context_drop_target'),'Callback');
uicontrol('Parent',hFig,...
          'BackgroundColor',1.2*bkg,...
          'Callback',f_drop,...
          'ForegroundColor',[1 1 1],...
          'Position',[146 5 75 22],...
          'String','Drop Target',...
          'Style','Pushbutton',...
          'Tag','pushbutton_drop_target');
uicontrol('Parent',h_pan_ras,...
          'Callback',@edit_pos_Callback,...
          'Position',[65 64 75 22],...
          'String','',...
          'Style','Edit',...
          'Tag','edit1');
uicontrol('Parent',h_pan_ras,...
          'Callback',@edit_pos_Callback,...
          'Position',[65 37 75 22],...
          'String','',...
          'Style','Edit',...
          'Tag','edit2');
uicontrol('Parent',h_pan_ras,...
          'Callback',@edit_pos_Callback,...
          'Position',[65 10 75 22],...
          'String','',...
          'Style','Edit',...
          'Tag','edit3');
uicontrol('Parent',h_pan_ijk,...
          'Callback',@edit_pos_Callback,...
          'Position',[32 64 55 22],...
          'String','',...
          'Style','Edit',...
          'Tag','edit4');
uicontrol('Parent',h_pan_ijk,...
          'Callback',@edit_pos_Callback,...
          'Position',[32 37 55 22],...
          'String','',...
          'Style','Edit',...
          'Tag','edit5');
uicontrol('Parent',h_pan_ijk,...
          'Callback',@edit_pos_Callback,...
          'Position',[32 10 55 22],...
          'String','',...
          'Style','Edit',...
          'Tag','edit6');

% Prepare text objects
set(hFig,'defaultuicontrolbackgroundcolor',bkg,...
          'defaultuicontrolforegroundcolor',[1 1 1],...
          'defaultuicontrolhorizontalalignment','right',...
          'defaultuicontrolfontweight','bold',...
          'defaultuicontrolstyle','Text');
uicontrol('Parent',h_pan_ras,...
          'Position',[13 69 50 15],...
          'String','R (mm):',...
          'Tag','text_r');
uicontrol('Parent',h_pan_ras,...
          'Position',[13 42 50 15],...
          'String','A (mm):',...
          'Tag','text_a');
uicontrol('Parent',h_pan_ras,...
          'Position',[13 15 50 15],...
          'String','S (mm):',...
          'Tag','text_s');
uicontrol('Parent',h_pan_ras,...
          'HorizontalAlignment','center',...
          'Position',[140 69 30 15],...
          'String','(R)',...
          'Tag','text1');
uicontrol('Parent',h_pan_ras,...
          'HorizontalAlignment','center',...
          'Position',[140 42 30 15],...
          'String','(A)',...
          'Tag','text2');
uicontrol('Parent',h_pan_ras,...
          'HorizontalAlignment','center',...
          'Position',[140 15 30 15],...
          'String','(S)',...
          'Tag','text3');
uicontrol('Parent',h_pan_ijk,...
          'Position',[10 69 20 15],...
          'String','I :',...
          'Tag','text_j');
uicontrol('Parent',h_pan_ijk,...
          'Position',[10 42 20 15],...
          'String','J :',...
          'Tag','text_j');
uicontrol('Parent',h_pan_ijk,...
          'Position',[10 15 20 15],...
          'String','K :',...
          'Tag','text_k');

% Populate edit text boxes
xyz = obj.ras;
ras_str = {'(L)','(P)','(I)'};
for i = 1:length(xyz)
    tags = {['edit' num2str(i)],['edit' num2str(i+3)],['text' num2str(i)]};
    h =[findobj(hFig,'Tag',tags{1}),...
        findobj(hFig,'Tag',tags{2}),...
        findobj(hFig,'Tag',tags{3})];
    set(h(1),'String',sprintf('%3.3f',xyz(i)));
    set(h(2),'String',num2str(obj.sl_index(i)-1));
    if xyz(i) < 0
        set(h(3),'String',ras_str{i});
    end

    % Store string as application data
    for j = 1:length(h)
        setappdata(h(j),'currentstring',get(h(j),'String'));
    end
end

% Update exams object
obj.update(hFig);


%-----------------------Callback/Ancillary Functions----------------------------

    function edit_pos_Callback(hObj,eventdata) %#ok

        % Verify user input
        str = get(hObj,'String');
        str_old = getappdata(hObj,'currentstring');
        if strcmpi(str,str_old) || isnan(str2double(str))
            set(hObj,'String',str_old);
            return
        end

        % Get some necessary values
        obj = getappdata(hFig,'qtExamObject');
        ras = ones(4,1); ijk = obj.sl_index;
        m = obj.scale;
        tag = get(hObj,'Tag'); tag = str2double(tag(end));
        drct = {'L','-';'P','-';'I','-';'R','';'A','';'S',''};

        % Perform case specific operation
        if tag<4 %case for RAS specified by user
            % Get string for the coordinate axis
            for ii = 1:size(drct,1)
                str = strrep(str,drct{ii,1},drct{ii,2});
            end
            num = str2double(str);
            if numel(num)==1 && ~isnan(num)
                if any(tag==[1 2])
                    ras(tag) = -num;
                else
                    ras(tag) = num;
                end
            else
                error(['QUATTRO:' mfilename ':textChk'],'Invalid position string');
            end

            % Enforce volume bounds
            ijk = obj.dicom_trafo\ras+1;
            ijk = round(ijk)-1; % -1 for 0-indexed array
            if ijk(tag)<0
                ijk(tag) = 0;
            elseif ijk(tag)>m(tag)
                ijk(tag) = m(tag)-1;
            end

        else %case for IJK specified by user
            tag = tag-3; %forces tag number to be 1, 2, or 3 for the update lines below
            num = round(str2double(str)); ijk(tag) = num;
            if isnan(num)
                error(['QUATTRO:' mfilename ':textChk'],...
                                                 'Invalid position string');
            end

            % Enforce volume bounds and update the textbox
            if ijk(tag)<0
                ijk(tag) = 0;
            elseif ijk(tag)>m(tag)-1
                ijk(tag) = m(tag)-1;
            else
                ijk(tag) = num;
            end
            ijk = [ijk(:);1];

            if tag==3
                ijk(3) = m(3)-ijk(3)-1;
            end

        end

        % Update text box strings and app data
        ras = obj.dicom_trafo*ijk;
        if any(tag==[1 2])
            ras(tag) = -ras(tag);
        else
            ijk(3) = m(3)-ijk(3)-1;
        end
        h_ras = findobj(hFig,'Tag',['edit' num2str(tag)]);
        h_ijk = findobj(hFig,'Tag',['edit' num2str(tag+3)]);
        set(h_ras,'String',sprintf('%3.3f',ras(tag)));
        set(h_ijk,'String',num2str(ijk(tag)));
        setappdata(h_ras,'currentstring',get(h_ras,'String'));
        setappdata(h_ijk,'currentstring',get(h_ijk,'String'));
        h_text = findobj(hFig,'Tag',['text' num2str(tag)]);
        if ras(tag) >= 0
            set(h_text,'String',['(' drct{tag+3,1} ')']);
        else
            set(h_text,'String',['(' drct{tag,1} ')']);
        end

        % Update the exams object to reflect new location
        obj.update(h_ijk);

        % Clear all displays
        obj.delete_go('regions');

        % Check current QUATTRO view
        if get(obj.h_view,'Value')==tag
            set(obj.h_sl(1),'Value',obj.sl_index(tag));
            deleteChildren(obj.h_axes.main,'text'); obj.show('image','rois','text');
        end

        % Show 3-plane viewer
        if ~isempty(obj.h_view_fig) && ishandle(obj.h_view_fig);
            obj.show('3plane','crosshairs');
        end
        obj.show('rois','text');

    end %edit_pos_Callback

    function key_press_Callback(hObj,eventdata)

        if strcmpi(eventdata.Key,'escape')
            close(hObj);
        end

    end %key_press_Callback

end %jump2ras