function varargout = VE_fluid_model_app(varargin)
% VE_FLUID_MODEL_APP M-file for VE_fluid_model_app.fig
%      VE_FLUID_MODEL_APP, by itself, creates a new VE_FLUID_MODEL_APP or raises the existing
%      singleton*.
%
%      H = VE_FLUID_MODEL_APP returns the handle to a new VE_FLUID_MODEL_APP or the handle to
%      the existing singleton*.
%
%      VE_FLUID_MODEL_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VE_FLUID_MODEL_APP.M with the given input arguments.
%
%      VE_FLUID_MODEL_APP('Property','Value',...) creates a new VE_FLUID_MODEL_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VE_fluid_model_app_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VE_fluid_model_app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VE_fluid_model_app

% Last Modified by GUIDE v2.5 01-Sep-2004 12:40:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VE_fluid_model_app_OpeningFcn, ...
                   'gui_OutputFcn',  @VE_fluid_model_app_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before VE_fluid_model_app is made visible.
function VE_fluid_model_app_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VE_fluid_model_app (see VARARGIN)

% Choose default command line output for VE_fluid_model_app
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VE_fluid_model_app wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VE_fluid_model_app_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

im = imread('viscoelastic_liquid_model.bmp');
image(im);
axis off;


% --- Executes during object creation, after setting all properties.
function slider_D2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_D2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_D2_Callback(hObject, eventdata, handles)
% hObject    handle to slider_D2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

		K = get(handles.slider_K, 'Value');
		D1 = get(handles.slider_D1, 'Value');
        D2 = get(handles.slider_D2,'Value');
        
        set(handles.edit_D2,'String', D2);
        
        model_me(K, D1, D2);
        

% --- Executes during object creation, after setting all properties.
function slider_D1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_D1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_D1_Callback(hObject, eventdata, handles)
% hObject    handle to slider_D1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

		K = get(handles.slider_K, 'Value');
		D1 = get(handles.slider_D1, 'Value');
        D2 = get(handles.slider_D2,'Value');

        set(handles.edit_D1,'String', D1);
        set(handles.text_relaxtime, 'String', num2str(D1/K));

        model_me(K, D1, D2);
        
        
% --- Executes during object creation, after setting all properties.
function slider_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function slider_K_Callback(hObject, eventdata, handles)
% hObject    handle to slider_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

		K = get(handles.slider_K, 'Value');
		D1 = get(handles.slider_D1, 'Value');
        D2 = get(handles.slider_D2,'Value');

        set(handles.edit_K,'String', K);
        set(handles.text_relaxtime, 'String', num2str(D1/K));
        
        model_me(K, D1, D2);
        
        
% --- Executes during object creation, after setting all properties.
function edit_K_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_K_Callback(hObject, eventdata, handles)
% hObject    handle to edit_K (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_K as text
%        str2double(get(hObject,'String')) returns contents of edit_K as a double

    K = str2num(get(handles.edit_K, 'String'));
    set(handles.slider_K,'Value', K);


% --- Executes during object creation, after setting all properties.
function edit_D1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_D1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function edit_D1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_D1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_D1 as text
%        str2double(get(hObject,'String')) returns contents of edit_D1 as a double

    D1 = str2num(get(handles.edit_D1, 'String'));
    set(handles.slider_D1,'Value', D1);
    

% --- Executes during object creation, after setting all properties.
function edit_D2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_D2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function edit_D2_Callback(hObject, eventdata, handles)
% hObject    handle to edit_D2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_D2 as text
%        str2double(get(hObject,'String')) returns contents of edit_D2 as a double

    D2 = str2num(get(handles.edit_D2, 'String'));
    set(handles.slider_D2,'Value', D2);

    
function model_me(K, D1, D2)

	[t, ct, pulse] = VE_fluid_model(K, D1, D2);
	
	figure(2);
	plot(t, ct);
	title('Simple VE fluid model (X_2/F)');
	xlabel('time (sec)');
	ylabel('displacement (m)');
	pretty_plot;