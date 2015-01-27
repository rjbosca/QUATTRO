function varargout = OverlaySliceOrder(varargin)
% OVERLAYSLICEORDER M-file for OverlaySliceOrder.fig
%      OVERLAYSLICEORDER, by itself, creates a new OVERLAYSLICEORDER or raises the existing
%      singleton*.
%
%      H = OVERLAYSLICEORDER returns the handle to a new OVERLAYSLICEORDER or the handle to
%      the existing singleton*.
%
%      OVERLAYSLICEORDER('CALLBACK',hObj,eventData,handles,...) calls the local
%      function named CALLBACK in OVERLAYSLICEORDER.M with the given input arguments.
%
%      OVERLAYSLICEORDER('Property','Value',...) creates a new OVERLAYSLICEORDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OverlaySliceOrder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OverlaySliceOrder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OverlaySliceOrder

% Last Modified by GUIDE v2.5 17-Jan-2010 18:38:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OverlaySliceOrder_OpeningFcn, ...
                   'gui_OutputFcn',  @OverlaySliceOrder_OutputFcn, ...
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


% --- Executes just before OverlaySliceOrder is made visible.
function OverlaySliceOrder_OpeningFcn(hObj, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OverlaySliceOrder (see VARARGIN)

% Sets listbox_slice_order 'Stinrg' value
set(handles.listbox_slice_order, 'String', varargin{1}, 'Min', 1,...
                                 'Max', length(varargin{1}));

% UIWAIT makes OverlaySliceOrder wait for user response (see UIRESUME)
uiwait(handles.OverlaySliceOrder);

% Gets the ordered list of slices
slice_nums = get(handles.listbox_slice_order, 'String');

% Store slice numbers
handles.output = cellfun(@(s) str2double( s( isstrprop(s,'digit') ) ),...
                           slice_nums);

% Update handles structure
guidata(hObj, handles);


% --- Outputs from this function are returned to the command line.
function varargout = OverlaySliceOrder_OutputFcn(hObj, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObj    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Close Overlay Slice Number
delete(hObj)


% --- Executes on button press in pushbutton_move_up.
function pushbutton_move_up_Callback(hObj, eventdata, handles)
% hObj    handle to pushbutton_move_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gets the slice names and currently selected value
names = get(handles.listbox_slice_order, 'String');
inds = get(handles.listbox_slice_order, 'Value');

% Switches the selected value with the next one up
if inds(1) > 1
    for i = inds
        names(i-1:i) = names(i:-1:i-1);
    end
    set(handles.listbox_slice_order, 'Value', inds-1);
end

% Updates the slices list
set(handles.listbox_slice_order, 'String', names);


% --- Executes on button press in pushbutton_move_down.
function pushbutton_move_down_Callback(hObj, eventdata, handles)
% hObj    handle to pushbutton_move_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Gets the slice names and currently selected value
names = get(handles.listbox_slice_order, 'String');
inds = get(handles.listbox_slice_order, 'Value');

% Switches the selected value with the next one up
if inds(end) < size(names, 1)
    for i = inds(end:-1:1)
        names(i:i+1) = names(i+1:-1:i);
    end
    set(handles.listbox_slice_order, 'Value', inds+1);
end

% Updates the slices list
set(handles.listbox_slice_order, 'String', names);


% --- Executes on button press in pushbutton_accept.
function pushbutton_accept_Callback(hObj, eventdata, handles)
% hObj    handle to pushbutton_accept (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.OverlaySliceOrder)