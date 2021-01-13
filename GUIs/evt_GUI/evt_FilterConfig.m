function varargout = evt_FilterConfig(varargin)
% EVT_FILTERCONFIG MATLAB code for evt_FilterConfig.fig
%      EVT_FILTERCONFIG, by itself, creates a new EVT_FILTERCONFIG or raises the existing
%      singleton*.
%
%      H = EVT_FILTERCONFIG returns the handle to a new EVT_FILTERCONFIG or the handle to
%      the existing singleton*.
%
%      EVT_FILTERCONFIG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVT_FILTERCONFIG.M with the given input arguments.
%
%      EVT_FILTERCONFIG('Property','Value',...) creates a new EVT_FILTERCONFIG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before evt_FilterConfig_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evt_FilterConfig_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evt_FilterConfig

% Last Modified by GUIDE v2.5 13-Jan-2021 10:51:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @evt_FilterConfig_OpeningFcn, ...
                   'gui_OutputFcn',  @evt_FilterConfig_OutputFcn, ...
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

% hObject    handle to edit_MinPixels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

% --- Executes just before evt_FilterConfig is made visible.
function evt_FilterConfig_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to evt_FilterConfig (see VARARGIN)

    handles.evtHandles = varargin{2};
    handles.evtFiltConfig = handles.evtHandles.TrackingFilter;
    
    % Choose default command line output for evt_FilterConfig
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);




% --- Outputs from this function are returned to the command line.
function varargout = evt_FilterConfig_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = handles.output;
varargout{1} = handles.evtFiltConfig;
% delete(hObject);


%     setappdata(0,'evtFiltConfig',handles.evtFiltConfig);
%     close(evt_FilterConfig);
%#ok<*INUSD>
%#ok<*DEFNU>

function edit_MinFrames_CreateFcn(hObject, eventdata, handles) 
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_MinPixels_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_CropTime_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_CropBorder_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_MaxPixels_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_CameraDeadZone_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
function edit_MinSens_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
function edit_MinPixIntens_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    
function pushbutton_close_Callback(hObject, eventdata, handles) 
    handles.evtHandles.TrackingFilter = handles.evtFiltConfig;
    guidata(hObject, handles);
    evt_GUI('filter_tracking', handles.evtHandles);
%     setappdata(0,'evtFiltConfig',handles.evtFiltConfig);
    closereq;


function pushbutton_apply_Callback(hObject, eventdata, handles)
    handles.evtHandles.TrackingFilter = handles.evtFiltConfig;
    guidata(hObject, handles);
    evt_GUI('filter_tracking', handles.evtHandles);
    

function checkbox_MinFrames_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_MinFrames, 'enable', 'on');
    else
        set(handles.edit_MinFrames, 'enable', 'off');
    end

    
function checkbox_MinPixels_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_MinPixels, 'enable', 'on');
    else
        set(handles.edit_MinPixels, 'enable', 'off');
    end
    
    
function checkbox_CropTime_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_CropTime, 'enable', 'on');
    else
        set(handles.edit_CropTime, 'enable', 'off');
    end


function checkbox_CropBorder_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_CropBorder, 'enable', 'on');
    else
        set(handles.edit_CropBorder, 'enable', 'off');
    end

    
function checkbox_MaxPixels_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_MaxPixels, 'enable', 'on');
    else
        set(handles.edit_MaxPixels, 'enable', 'off');
    end


function checkbox_CameraDeadZone_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_CameraDeadZone, 'enable', 'on');
    else
        set(handles.edit_CameraDeadZone, 'enable', 'off');
    end


function checkbox_MinSens_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_MinSens, 'enable', 'on');
    else
        set(handles.edit_MinSens, 'enable', 'off');
    end


function checkbox_MinPixIntens_Callback(hObject, eventdata, handles)
    if get(hObject, 'Value')
        set(handles.edit_MinPixIntens, 'enable', 'on');
    else
        set(handles.edit_MinPixIntetns, 'enable', 'off');
    end
    

function edit_MinFrames_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.min_frames = str2double(hObject.String);
    guidata(hObject, handles);

    
function edit_MinPixels_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.min_pixels = str2double(hObject.String);
    guidata(hObject, handles);


function edit_CropTime_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.tcrop = str2double(hObject.String);
    guidata(hObject, handles);

    
function edit_CropBorder_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.xycrop = str2double(hObject.String);
    guidata(hObject, handles);

    
function edit_MaxPixels_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.max_pixels = str2double(hObject.String);
    guidata(hObject, handles);

    
function edit_CameraDeadZone_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.deadzone = str2double(hObject.String);
    guidata(hObject, handles);

    
function edit_MinSens_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.min_sens = str2double(hObject.String);
    guidata(hObject, handles);


function edit_MinPixIntens_Callback(hObject, eventdata, handles)
    handles.evtFiltConfig.min_intensity = str2double(hObject.String);
    guidata(hObject, handles);

    
