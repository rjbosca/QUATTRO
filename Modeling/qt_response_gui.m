function varargout = qt_response_gui(varargin)
% QT_RESPONSE_GUI MATLAB code for qt_response_gui.fig
%      QT_RESPONSE_GUI, by itself, creates a new QT_RESPONSE_GUI or raises the existing
%      singleton*.
%
%      H = QT_RESPONSE_GUI returns the handle to a new QT_RESPONSE_GUI or the handle to
%      the existing singleton*.
%
%      QT_RESPONSE_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QT_RESPONSE_GUI.M with the given input arguments.
%
%      QT_RESPONSE_GUI('Property','Value',...) creates a new QT_RESPONSE_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qt_response_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qt_response_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qt_response_gui

% Last Modified by GUIDE v2.5 06-Nov-2013 13:28:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @qt_response_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @qt_response_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before qt_response_gui is made visible.
function qt_response_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to qt_response_gui (see VARARGIN)

% Choose default command line output for qt_response_gui
handles.output = hObject;

% Store current value for slider
setappdata(handles.slider_select_file,'currentvalue',0);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes qt_response_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = qt_response_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

add_logo(guifigure(hObject));

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_calculate_response.
function pushbutton_calculate_response_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_calculate_response (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_train_data.
function pushbutton_train_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_train_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_load_trained_data.
function pushbutton_load_trained_data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load_trained_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in uipanel_mode.
function uipanel_mode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_mode 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if eventdata.NewValue==handles.radiobutton_calculate_response
    set([handles.pushbutton_train_data,...
         handles.uipanel_file_details,...
         handles.popupmenu_model],'Visible','off');
    set([handles.pushbutton_calculate_response,...
         handles.pushbutton_load_trained_data],'Visible','on');
else
    set([handles.pushbutton_train_data,...
         handles.uipanel_file_details,...
         handles.popupmenu_model],'Visible','on');
    set([handles.pushbutton_calculate_response,...
         handles.pushbutton_load_trained_data],'Visible','off');
end


% --- Executes on selection change in listbox_categories.
function listbox_categories_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_categories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_categories contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_categories


% --- Executes on selection change in listbox_predictors.
function listbox_predictors_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_predictors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_predictors contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_predictors


% --- Executes on button press in pushbutton_select_q_save.
function pushbutton_select_q_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_select_q_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the slider value
fn = get(handles.slider_select_file,'Value');

% Load the file
[f_name,f_path] = uigetfile('*.mat','MAT-files (*.mat)');
if isnumeric(f_name) || isnumeric(f_path) || ~exist( fullfile(f_path,f_name),'file' )
    return
end

% Read the file
load( fullfile(f_path,f_name) );
if ~exist('save_data','var');
    return
end

% Let the user select the exam (if multiple exist)
sel = 1;
if numel( save_data.names ) > 1
    [sel,ok] = listdlg('ListString',save_data.names,'SelectionMode','Single');
    if ~ok
        return
    end
end

% Determine the ROIs and parameter maps
if ~isempty(save_data.rois{sel})
    handles.user.cat{fn} = save_data.rois{sel}.names;
else
end
if ~iscell(handles.user.cat{fn})
    handles.user.cat{fn} = {handles.user.cat{fn}};
end
handles.user.pre{fn} = fieldnames(save_data.maps{sel});
handles.user.pre{fn}( strcmpi(handles.user.pre{fn},'Scale') ) = [];
handles.user.pre{fn}( strcmpi(handles.user.pre{fn},'Names') ) = [];
handles.user.file{fn} = fullfile(f_path,f_name);

% Update the tools
set(handles.listbox_categories,'String',handles.user.cat{fn},'Value',1,'Enable','on');
set(handles.listbox_predictors,'String',handles.user.pre{fn},'Value',1,'Enable','on');
set(handles.edit_file,'String',handles.user.file{fn});

% Update handles structure
guidata(hObject,handles);


function edit_file_Callback(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_file as text
%        str2double(get(hObject,'String')) returns contents of edit_file as a double


% --- Executes on button press in pushbutton_remove_file.
function pushbutton_remove_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_remove_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get some values
val = get(handles.slider_select_file,'Value');
n   = get(handles.slider_select_file,'Max');

% Remove the data
handles.user.cat(val)     = [];
handles.user.pre(val)     = [];
handles.user.file(val)    = [];
handles.user.cat_sel(val) = [];
handles.user.pre_sel(val) = [];

% Update the slider
if n==val
    set(handles.slider_select_file,'Value',n-1);
end
set(handles.slider_select_file,'Max',n-1);
    

% --- Executes on slider movement.
function slider_select_file_Callback(hObject, eventdata, handles)
% hObject    handle to slider_select_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get slider information
val     = round( get(hObject,'Value') ); set(hObject,'Value',val);
pre_val = getappdata(hObject,'currentvalue');

% Store the user selections before updating the GUI
if pre_val~=0
    handles.user.cat_sel{pre_val} = get(handles.listbox_categories,'Value');
    handles.user.pre_sel{pre_val} = get(handles.listbox_predictors,'Value');
    guidata(hObject,handles);
end

if val==0
    set(handles.edit_file,'String','Current Trainer Summary');
    set([handles.pushbutton_select_q_save,...
         handles.pushbutton_remove_file],'Enable','off');

    % Determine what to put in the listboxes
    cat_nms = {};
    pre_nms = {};
    for i = 1:length(handles.user.cat)
        if iscell(handles.user.cat{i})
            cat_nms = {cat_nms{:} handles.user.cat{i}{handles.user.cat_sel{i}}};
        end
        if iscell(handles.user.pre{i})
            pre_nms = {pre_nms{:} handles.user.pre{i}{handles.user.pre_sel{i}}};
        end
    end
    cat_nms = unique(cat_nms);
    pre_nms = unique(pre_nms);
    set(handles.listbox_categories,'String',cat_nms,'Value',[],'Enable','off');
    set(handles.listbox_predictors,'String',pre_nms,'Value',[],'Enable','off');

else

    % Ensure the listboxes are enabled
    set([handles.listbox_categories,...
         handles.listbox_predictors],'Enable','on');

    % Update file name
    if isempty(handles.user.file{val})
        set(handles.edit_file,'String','No file selected...');
    else
        set(handles.edit_file,'String',handles.user.file{val});
    end

    % Update other buttons
    set([handles.pushbutton_select_q_save
         handles.pushbutton_remove_file],'Enable','on');

    % Update predictor names
    if isempty(handles.user.pre{val})
        set(handles.listbox_predictors,'String',{},'Value',[]);
    else
        set(handles.listbox_predictors,'String',handles.user.pre{val},...
                                       'Value',handles.user.pre_sel{val});
    end

    % Updated category names
    if isempty(handles.user.cat{val})
        set(handles.listbox_categories,'String',{},'Value',[]);
    else
        set(handles.listbox_categories,'String',handles.user.cat{val},...
                                       'Value',handles.user.cat_sel{val});
    end

end

% Update the current selection
setappdata(hObject,'currentvalue',val);


% --- Executes on button press in pushbutton_add_file.
function pushbutton_add_file_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update the slider
n = get(handles.slider_select_file,'Max');
set(handles.slider_select_file,'Max',n+1,'Value',n+1,'SliderStep',[1/(n+1) 2/(n+1)]);
if n==0
    set(handles.slider_select_file,'Visible','on');
end

% Update the file textbox
set(handles.edit_file,'String','No file selected...');
set([handles.pushbutton_select_q_save,...
     handles.pushbutton_remove_file],'Enable','on');

% Expand the storage
handles.user.cat{n+1}      = [];
handles.user.pre{n+1}      = [];
handles.user.file{n+1}     = [];
handles.user.cat_sel{n+1}  = [];
handles.user.pre_sel{n+1}  = [];

% Store the current data
val = getappdata(handles.slider_select_file,'currentvalue');
if val~=0
    handles.user.cat_sel{val} = get(handles.listbox_categories,'Value');
    handles.user.pre_sel{val} = get(handles.listbox_predictors,'Value');
end
setappdata(handles.slider_select_file,'currentvalue',n+1);

% Clear old values
set([handles.listbox_categories,...
     handles.listbox_predictors],'String',{},'Value',0);

% Update handles structure
guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Create Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes during object creation, after setting all properties.
function slider_select_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_select_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function edit_file_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function listbox_predictors_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_predictors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function listbox_categories_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_categories (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_model.
function popupmenu_model_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_model contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_model


% --- Executes during object creation, after setting all properties.
function popupmenu_model_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_model (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
