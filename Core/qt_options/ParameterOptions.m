function varargout = ParameterOptions(varargin)
% PARAMETEROPTIONS M-file for ParameterOptions.fig
%      PARAMETEROPTIONS, by itself, creates a new PARAMETEROPTIONS or raises the existing
%      singleton*.
%
%      H = PARAMETEROPTIONS returns the handle to a new PARAMETEROPTIONS or the handle to
%      the existing singleton*.
%
%      PARAMETEROPTIONS('CALLBACK',hObj,eventData,handles,...) calls the local
%      function named CALLBACK in PARAMETEROPTIONS.M with the given input arguments.
%
%      PARAMETEROPTIONS('Property','Value',...) creates a new PARAMETEROPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ParameterOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ParameterOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ParameterOptions

% Last Modified by GUIDE v2.5 12-Jun-2013 14:26:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ParameterOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @ParameterOptions_OutputFcn, ...
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


% --- Executes just before ParameterOptions is made visible.
function ParameterOptions_OpeningFcn(hObj, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ParameterOptions (see VARARGIN)

% Stores default values
options = opts_get('maps');
flds = fieldnames(options);
for i = 1:length(flds)
    if isfield(handles,flds{i})
        assign_values(handles.(flds{i}),options.(flds{i}));
    end
end

% Store default output
handles.output = hObj;

% Update handles structure
guidata(hObj, handles);


% --- Outputs from this function are returned to the command line.
function varargout = ParameterOptions_OutputFcn(hObj, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Store options for output
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                            Callback Functions                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in pushbutton_accept.
function pushbutton_close_Callback(hObj, eventdata, handles)
% hObj    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update options
if ~isempty(strfind(get(hObj,'Tag'),'accept'))
    accept_opts(handles,'maps')
end

% Delete GUI
delete(handles.figure_quattro_map_options);


% --- Exectues on user input in an edit textbox.
function edit_Callback(hObj, eventdata, handles)
% hObj    handle to edit textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get user input and field
val = str2double( get(hObj,'String') ); fld = get(hObj,'Tag');

% Update textbox and options
is_valid = check_values(hObj,val);
if ~is_valid
    val = opts_get(fld);
end

% Set string
assign_values(hObj,val);

% Update handles structure
guidata(hObj,handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                         End Callback Functions                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Key Press Functions                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on key release with focus on figure_quattro_map_options or any of its controls.
function figure_quattro_map_options_WindowKeyReleaseFcn(hObj, eventdata, handles)
% hObj    handle to figure_quattro_map_options (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)

if strcmpi(eventdata.Key,'escape')
    pushbutton_close_Callback(handles.pushbutton_cancel, eventdata, handles);
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
