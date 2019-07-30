function varargout = ba_collectUI(varargin)
% BA_COLLECTUI MATLAB code for ba_collectUI.fig
%      BA_COLLECTUI, by itself, creates a new BA_COLLECTUI or raises the existing
%      singleton*.
%
%      H = BA_COLLECTUI returns the handle to a new BA_COLLECTUI or the handle to
%      the existing singleton*.
%
%      BA_COLLECTUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BA_COLLECTUI.M with the given input arguments.
%
%      BA_COLLECTUI('Property','Value',...) creates a new BA_COLLECTUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ba_collectUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ba_collectUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ba_collectUI

% Last Modified by GUIDE v2.5 18-Jul-2019 12:44:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ba_collectUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ba_collectUI_OutputFcn, ...
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


% --- Executes just before ba_collectUI is made visible.
function ba_collectUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ba_collectUI (see VARARGIN)

% Choose default command line output for ba_collectUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ba_collectUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ba_collectUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_fid_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fid as text
%        str2double(get(hObject,'String')) returns contents of edit_fid as a double


% --- Executes during object creation, after setting all properties.
function edit_fid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_gain_Callback(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_gain as text
%        str2double(get(hObject,'String')) returns contents of edit_gain as a double


% --- Executes during object creation, after setting all properties.
function edit_gain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_gain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_SubstrateSurface.
function popup_SubstrateSurface_Callback(hObject, eventdata, handles)
% hObject    handle to popup_SubstrateSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_SubstrateSurface contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_SubstrateSurface


% --- Executes during object creation, after setting all properties.
function popup_SubstrateSurface_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_SubstrateSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_SubstrateSize.
function popup_SubstrateSize_Callback(hObject, eventdata, handles)
% hObject    handle to popup_SubstrateSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_SubstrateSize contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_SubstrateSize


% --- Executes during object creation, after setting all properties.
function popup_SubstrateSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_SubstrateSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_BeadSurface.
function popup_BeadSurface_Callback(hObject, eventdata, handles)
% hObject    handle to popup_BeadSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popup_BeadSurface contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_BeadSurface


% --- Executes during object creation, after setting all properties.
function popup_BeadSurface_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_BeadSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_BeadDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BeadDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_BeadDiameter as text
%        str2double(get(hObject,'String')) returns contents of edit_BeadDiameter as a double


% --- Executes during object creation, after setting all properties.
function edit_BeadDiameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BeadDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_PSFbrowse.
function button_PSFbrowse_Callback(hObject, eventdata, handles)
% hObject    handle to button_PSFbrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
