function roi_import_OpeningFcn(hObj, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roi_import (see VARARGIN)

% Choose default command line output for roi_import
handles.output = hObj;

% Fire ROI selection
handles = select_rois(handles);

% Initialize some handles
[handles.preview handles.h_img handles.h_roi] = deal([]);

% Update handles structure
guidata(hObj, handles);


% --- Outputs from this function are returned to the command line.
function varargout = roi_import_OutputFcn(hObj, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Initialize output
[varargout{1:nargout}] = deal([]);

% Store output (user canceled)
if ~isfield(handles,'user') || ~isfield(handles.user,'rois');
    delete(hObj);
    return
end

% Wait for user to finish
uiwait(handles.figure_roi_import);
if ~ishandle(handles.figure_roi_import)
    return
end

% ROI data alias
roi = handles.user.rois;

% Get colors and slice and normalize coordinates
for i = length(roi):-1:1
    if ~get(handles.(['checkbox_' num2str(i)]),'Value')
        roi(i) = [];
        continue
    end
    pop_tag = sprintf('popupmenu_color_%d',i);
    sl_tag = strrep(pop_tag,'color','slice');
    n_tag = sprintf('edit_name_%d',i);
    pix_x = sprintf('edit_pix_x_dim_%d',i);
    pix_y = sprintf('edit_pix_y_dim_%d',i);
    pix = get([handles.(pix_x) handles.(pix_y)],'String');
    pix = cellfun(@str2double,pix);
    roi(i).colors = getPopupMenu(handles.(pop_tag));
    roi(i).slice = str2double( getPopupMenu(handles.(sl_tag)) );
    roi(i).coordinates = scale_roi_verts(roi(i).coordinates,...
                                                       roi(i).types,1./pix);
    roi(i).names = get(handles.(n_tag),'String');
end

% Get default command line output from handles structure
varargout{1} = roi;
if isfield(handles,'f_info')
    varargout{2} = handles.f_info;
end

% Delete the figure
delete(handles.figure_roi_import);
delete(findall(0,'Name','ROI Import::Preview'));


function edit_Callback(hObj, eventdata, handles)
% hObj    handle to edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

val = str2double( get(hObj,'String') );
if isnan(val) || val > 4096
    set(hObj,'String','256');
end

if isempty(handles.preview) || ~ishandle(handles.preview)
    return
end

% Dimensions
obj_tag = get(hObj,'Tag'); obj_str = obj_tag(16:end);
obj_num = str2double(obj_str);
is_y = any( strfind(obj_tag ,'_y_' ) );
props = get(handles.h_img,{'XData','YData'});
if is_y
    props{2}(2) = val;
else
    props{1}(2) = val;
end

% Change image size
delete(handles.preview)
pushbutton_preview_Callback(handles.pushbutton_preview_1,[],handles);


% --- Executes on selection change in popupmenu_slice
function popupmenu_Callback(hObj, eventdata, handles)
% hObj    handle to popupmenu_slice_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.preview) || ~ishandle(handles.preview)
    return
end

% Must be from the currently displayed ROI
disp_num = get(handles.preview,'UserData');
ui_parts = textscan(get(hObj,'Tag'),'%s%s%d','delimiter','_');
if ui_parts{3} ~= disp_num
    return
end

% Determine pop-up type
is_color = any( strfind(ui_parts{2}{1},'color') );

% Get value
val = getPopupMenu(hObj);
if is_color
    rgb = colorlookup(val);
    handles.h_roi.setColor(rgb);
else
    % Determine the new slice and image size
    val = str2double(val);
    props = get(handles.h_img,{'XData','YData'});

    % Get image and resize to user specs
    obj = getappdata(findall(0,'Name',qt_name),'qtExamObject');
    im = imresize(obj.images(val,1),[props{2}(2) props{1}(2)]);
    set(handles.h_img,'CData',im);
end


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObj, eventdata, handles)
% hObj    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Resume
uiresume(handles.figure_roi_import);


% --- Executes on button press in pushbutton_preview_1.
function pushbutton_preview_Callback(hObj, eventdata, handles)
% hObj    handle to pushbutton_preview_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get object and slice number and image size
roi_tag = get(hObj,'Tag'); roi_tag = roi_tag(20:end);
roi_num = str2double(roi_tag);
flds = {['popupmenu_slice_' roi_tag],['edit_pix_x_dim_' roi_tag],...
                                     ['edit_pix_y_dim_' roi_tag]};
sl = str2double( getPopupMenu(handles.(flds{1}) ) );
x_pix = str2double( get(handles.(flds{2}),'String') );
y_pix = str2double( get(handles.(flds{3}),'String') );

% Get image and resize to user specs
obj = getappdata(findall(0,'Name',qt_name),'qtExamObject');
im = imresize(obj.images(sl,1),[y_pix x_pix]);

% Create new figure
if isempty(handles.preview) || ~ishandle(handles.preview)
    h_preview = figure; set(h_preview,'MenuBar','none','ToolBar','none',...
                                      'NumberTitle','off',...
                                      'Name','ROI Import::Preview');
    handles.preview = h_preview; h_ax = axes;
else
    h_ax = findobj(handles.preview,'Type','axes');
end
set(handles.preview,'UserData',roi_num);

% Show image
if isempty(handles.h_img) || ~ishandle(handles.h_img)
    h_img = imshow(im,[],'Parent',h_ax); hold(h_ax,'on');
    handles.h_img = h_img;
else
    set(handles.h_img,'CData',im);
end

% Delete previous ROI/show new ROI
if ~isempty(handles.h_roi) && handles.h_roi.isvalid
    delete(handles.h_roi);
end
h_roi = eval( [handles.user.rois(roi_num).types '(h_ax,',...
                             'handles.user.rois(roi_num).coordinates);'] );

% Disables ROI functionality and change color
c = get(h_roi,'Children'); set(c,'HitTest','off');
color_name = getPopupMenu(handles.(['popupmenu_color_' roi_tag]));
rgb = colorlookup(color_name); h_roi.setColor(rgb);

% Store display handles
handles.h_roi = h_roi;

% Update handles structure
guidata(hObj,handles);


% Select ROI flies
function handles = select_rois(handles)

% Reads in an ROI and other associated Pinnacle files
[rois,fInfo] = import_rois;
if isempty( rois )
    return
end

% Get data
obj = getappdata(findall(0,'Name',qt_name),'qtExamObject');

% Deal imported data to handles structure
handles.user.rois = rois;
if ~isempty(fInfo)
    handles.user.f_info = fInfo;
end

% Initialize tools
tool_names = {'edit_name','text_roi_type','edit_pix_x_dim','text_x',...
                'pushbutton_preview','edit_pix_y_dim','popupmenu_slice',...
                'popupmenu_color','checkbox'};
for i = 2:length(rois)
    for j = 1:length(tool_names)

        % Get information about the new tool
        fld    = sprintf('%s_%d',tool_names{j},i-1);
        newFld = sprintf('%s_%d',tool_names{j},i);
        props  = get(handles.(fld),{'Style','Position','Callback',...
                                    'BackgroundColor','String'});
        pos = props{2}; pos(2) = pos(2)-28;

        % Create default tool
        handles.(newFld) = uicontrol(handles.figure_roi_import,...
                                             'Units','pixels',...
                                             'Position',pos,...
                                             'Style',props{1},...
                                             'Callback',props{3},...
                                             'BackgroundColor',props{4},...
                                             'String',props{5},...
                                             'Tag',newFld,...
                                             'Visible','off');
        if strcmpi(props{1},'edit')
            set(handles.(newFld),'String','256');
        end
    end
end

% Populate data
n_sls = obj.size('images',1); list = cell(n_sls,1);
for i = 1:n_sls
    list{i} = num2str(i);
end
[max_extent_file] = deal(0);
for i = 1:length(rois)
    for j = 1:length(tool_names)
        fld = sprintf('%s_%d',tool_names{j},i);
        set(handles.(fld),'Visible','on');
        switch tool_names{j}
            case 'checkbox'
                set(handles.(fld),'Enable','on','Value',1);
                ext = get(handles.(fld),'Extent');
                if ext(3) > max_extent_file
                    max_extent_file = ext(3);
                end
            case 'edit_name'
                [~, f_name] = fileparts(rois(i).Filename);
                set(handles.(fld),'String',f_name);
            case {'edit_pix_x_dim','edit_pix_y_dim'}
                set(handles.(fld),'Enable','on');
            case 'popupmenu_color'
                set(handles.(fld),'String',supported_colors,'Value',i);
            case 'popupmenu_slice'
                set(handles.(fld),'Enable','on','String',list);
            case 'text_roi_type'
                set(handles.(fld),'String',rois(i).types);
            case 'text_x'
                set(handles.(fld),'String','X');
        end
    end
end


% --- Executes during object creation, after setting all properties.
function CreateFcn(hObj, eventdata, handles)
% hObj    handle to edit_pix_y_dim_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Get style to determine what to do
style = get(hObj,'Style');

is_default = all(get(hObj,'BackgroundColor')==...
                                 get(0,'defaultUicontrolBackgroundColor'));
if ispc && is_default && any(strcmpi(style,{'edit','popupmenu'}))
    set(hObj,'BackgroundColor','white');
end

if is_default && strcmpi(style,'slider')
    set(hObj,'BackgroundColor',[.9 .9 .9]);
end
