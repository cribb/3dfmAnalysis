function varargout = ConfigureStageGUI(varargin)
% CONFIGURESTAGEGUI M-file for ConfigureStageGUI.fig
%      CONFIGURESTAGEGUI, by itself, creates a new CONFIGURESTAGEGUI or raises the existing
%      singleton*.
%
%      H = CONFIGURESTAGEGUI returns the handle to a new CONFIGURESTAGEGUI or the handle to
%      the existing singleton*.
%
%      CONFIGURESTAGEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONFIGURESTAGEGUI.M with the given input arguments.
%
%      CONFIGURESTAGEGUI('Property','Value',...) creates a new CONFIGURESTAGEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ConfigureStageGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ConfigureStageGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ConfigureStageGUI

% Last Modified by GUIDE v2.5 23-Nov-2003 17:11:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ConfigureStageGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ConfigureStageGUI_OutputFcn, ...
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


% --- Executes just before ConfigureStageGUI is made visible.
function ConfigureStageGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ConfigureStageGUI (see VARARGIN)

% Choose default command line output for ConfigureStageGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ConfigureStageGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ConfigureStageGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function editModelNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editModelNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editModelNo_Callback(hObject, eventdata, handles)
% hObject    handle to editModelNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editModelNo as text
%        str2double(get(hObject,'String')) returns contents of editModelNo as a double


% --- Executes during object creation, after setting all properties.
function editMicroscopeID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editMicroscopeID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editMicroscopeID_Callback(hObject, eventdata, handles)
% hObject    handle to editMicroscopeID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editMicroscopeID as text
%        str2double(get(hObject,'String')) returns contents of editMicroscopeID as a double


% --- Executes during object creation, after setting all properties.
function editSerialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSerialNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editSerialNo_Callback(hObject, eventdata, handles)
% hObject    handle to editSerialNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSerialNo as text
%        str2double(get(hObject,'String')) returns contents of editSerialNo as a double


% --- Executes during object creation, after setting all properties.
function editXunloaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editXunloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editXunloaded_Callback(hObject, eventdata, handles)
% hObject    handle to editXunloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editXunloaded as text
%        str2double(get(hObject,'String')) returns contents of editXunloaded as a double


% --- Executes during object creation, after setting all properties.
function editYunloaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editYunloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editYunloaded_Callback(hObject, eventdata, handles)
% hObject    handle to editYunloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editYunloaded as text
%        str2double(get(hObject,'String')) returns contents of editYunloaded as a double


% --- Executes during object creation, after setting all properties.
function editZunloaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editZunloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editZunloaded_Callback(hObject, eventdata, handles)
% hObject    handle to editZunloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editZunloaded as text
%        str2double(get(hObject,'String')) returns contents of editZunloaded as a double


% --- Executes during object creation, after setting all properties.
function editXloaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editXloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editXloaded_Callback(hObject, eventdata, handles)
% hObject    handle to editXloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editXloaded as text
%        str2double(get(hObject,'String')) returns contents of editXloaded as a double


% --- Executes during object creation, after setting all properties.
function editYloaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editYloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editYloaded_Callback(hObject, eventdata, handles)
% hObject    handle to editYloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editYloaded as text
%        str2double(get(hObject,'String')) returns contents of editYloaded as a double


% --- Executes during object creation, after setting all properties.
function editZloaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editZloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editZloaded_Callback(hObject, eventdata, handles)
% hObject    handle to editZloaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editZloaded as text
%        str2double(get(hObject,'String')) returns contents of editZloaded as a double


% --- Executes during object creation, after setting all properties.
function editCurrentLoad_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCurrentLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function editCurrentLoad_Callback(hObject, eventdata, handles)
% hObject    handle to editCurrentLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCurrentLoad as text
%        str2double(get(hObject,'String')) returns contents of editCurrentLoad as a double


