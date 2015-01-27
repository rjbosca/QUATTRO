function varargout = gpr_viewer(varargin)
% GPR_VIEWER M-file for gpr_viewer.fig
%      GPR_VIEWER, by itself, creates a new GPR_VIEWER or raises the existing
%      singleton*.
%
%      H = GPR_VIEWER returns the handle to a new GPR_VIEWER or the handle to
%      the existing singleton*.
%
%      GPR_VIEWER('CALLBACK',hObj,eventData,handles,...) calls the local
%      function named CALLBACK in GPR_VIEWER.M with the given input arguments.
%
%      GPR_VIEWER('Property','Value',...) creates a new GPR_VIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gpr_viewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gpr_viewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gpr_viewer

% Last Modified by GUIDE v2.5 13-Jun-2012 23:05:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gpr_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @gpr_viewer_OutputFcn, ...
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


% --- Executes just before gpr_viewer is made visible.
function gpr_viewer_OpeningFcn(hObj, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gpr_viewer (see VARARGIN)

% Choose default command line output for gpr_viewer
handles.output = hObj;
handles.user.data = varargin{1};
handles.user.time = varargin{2};

cla(handles.axes_plot)

% Update handles structure
guidata(hObj, handles);


% --- Outputs from this function are returned to the command line.
function varargout = gpr_viewer_OutputFcn(hObj, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Plot data
plot(handles.axes_plot,handles.user.time,handles.user.data,'xr');

showGPR(handles);
set(handles.slider_length,'Max',2*length(handles.user.time));

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_optimize.
function pushbutton_optimize_Callback(hObj, eventdata, handles)
% hObj    handle to pushbutton_optimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_gpr = findobj(handles.figure1,'Tag','GPR');
is_fixed = get(handles.checkbox_fix,'Value');

if is_fixed
    l = str2double( get(handles.edit_length,'String') );
    [t y hyp] = regress_gp(handles.user.time,handles.user.data,1000,l);
else
    [t y hyp] = regress_gp(handles.user.time,handles.user.data,1000);
end
if ~isempty(h_gpr)
    set(h_gpr,'YData',y);
else
    hold(handles.axes_plot,'on'); 
    h = plot(t,y,'b'); set(h,'Tag','GPR');
    hold(handles.axes_plot,'off');
end

maxes = get([handles.slider_length handles.slider_noise_var handles.slider_function_var],'Max');
if hyp(1) > maxes{1}
    set(handles.slider_length,'Value',maxes{1});
else
    set(handles.slider_length,'Value',hyp(1));
end
if hyp(2) > maxes{2}
    set(handles.slider_noise_var,'Value',maxes{2});
else
    set(handles.slider_noise_var,'Value',maxes{2});
end
if hyp(3) > maxes{3}
    set(handles.slider_function_var,'Value',maxes{3});
else
    set(handles.slider_function_var,'Value',maxes{3});
end
set(handles.edit_length,'String',num2str(hyp(1)));
set(handles.edit_noise_var,'String',num2str(hyp(2)));
set(handles.edit_function_var,'String',num2str(hyp(3)));


% --- Executes on slider movement.
function slider_length_Callback(hObj, eventdata, handles)
% hObj    handle to slider_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

l = get(hObj,'Value');
set(handles.edit_length,'String',num2str(l));

showGPR(handles);


% --- Executes on slider movement.
function slider_noise_var_Callback(hObj, eventdata, handles)
% hObj    handle to slider_noise_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mu_n = get(hObj,'Value');
set(handles.edit_noise_var,'String',num2str(mu_n));

showGPR(handles);


% --- Executes on slider movement.
function slider_function_var_Callback(hObj, eventdata, handles)
% hObj    handle to slider_function_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mu_f = get(hObj,'Value');
set(handles.edit_function_var,'String',num2str(mu_f));

showGPR(handles);


function edit_length_Callback(hObj, eventdata, handles)
% hObj    handle to edit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

l = str2double( get(hObj,'String') );
l_max = get(handles.slider_length,'Max');
if l > l_max
    set(handles.slider_length,'Value',l_max);
else
    set(handles.slider_length,'Value',l);
end

showGPR(handles);


function edit_noise_var_Callback(hObj, eventdata, handles)
% hObj    handle to edit_noise_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mu_n = str2double( get(hObj,'String') );
mu_n_max = get(handles.slider_noise_var,'Max');
if mu_n > mu_n_max
    set(handles.slider_noise_var,'Value',mu_n_max);
else
    set(handles.slider_noise_var,'Value',mu_n);
end

showGPR(handles);


function edit_function_var_Callback(hObj, eventdata, handles)
% hObj    handle to edit_function_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mu_f = str2double( get(hObj,'String') );
mu_f_max = get(handles.slider_function_var,'Max');
if mu_f > mu_f_max
    set(handles.slider_function_var,'Value',mu_f_max);
else
    set(handles.slider_function_var,'Value',mu_f);
end

showGPR(handles);


% --- Executes during object creation, after setting all properties.
function edit_CreateFcn(hObj, eventdata, handles)
% hObj    handle to edit_function_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObj,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObj,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObj, eventdata, handles)
% hObj    handle to slider_noise_var (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObj,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObj,'BackgroundColor',[.9 .9 .9]);
end


function showGPR(handles)

h_gpr = findobj(handles.figure1,'Tag','GPR');

% Get hyperparameters
hyp = get([handles.edit_length handles.edit_noise_var handles.edit_function_var],'String');
hyp = cellfun(@str2double,hyp);

% Check for NaNs
if isnan(hyp(1))
    hyp(1) = get(handles.slider_length,'Value');
    set(handles.edit_length,'String',num2str(hyp(1)));
end
if isnan(hyp(2))
    hyp(2) = get(handles.slider_noise_var,'Value');
    set(handles.edit_noise_var,'String',num2str(hyp(2)));
end
if isnan(hyp(3))
    hyp(3) = get(handles.slider_function_var,'Value');
    set(handles.edit_function_var,'String',num2str(hyp(3)));
end

[t y] = regress_gp(handles.user.time,handles.user.data,1000,hyp);
if ~isempty(h_gpr)
    set(h_gpr,'YData',y);
else
    hold(handles.axes_plot,'on'); 
    h = plot(t,y,'b'); set(h,'Tag','GPR');
    hold(handles.axes_plot,'off');
end