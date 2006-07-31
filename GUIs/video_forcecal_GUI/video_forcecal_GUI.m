function varargout = video_forcecal_GUI(varargin)
% video_FORCECAL_GUI M-file for video_forcecal_GUI.fig
%      video_FORCECAL_GUI, by itself, creates a new video_FORCECAL_GUI or raises the existing
%      singleton*.
%
%      H = video_FORCECAL_GUI returns the handle to a new video_FORCECAL_GUI or the handle to
%      the existing singleton*.
%
%      video_FORCECAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in video_FORCECAL_GUI.M with the given input arguments.
%
%      video_FORCECAL_GUI('Property','Value',...) creates a new video_FORCECAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before video_forcecal_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to video_forcecal_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help video_forcecal_GUI

% Last Modified by GUIDE v2.5 13-Sep-2005 11:00:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @video_forcecal_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @video_forcecal_GUI_OutputFcn, ...
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


% --- Executes just before video_forcecal_GUI is made visible.
function video_forcecal_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to video_forcecal_GUI (see VARARGIN)

% Choose default command line output for video_forcecal_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes video_forcecal_GUI wait for user response (see UIRESUME)
% uiwait(handles.video_forcecal_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = video_forcecal_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edit_trackingfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trackingfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_trackingfile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trackingfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trackingfile as text
%        str2double(get(hObject,'String')) returns contents of edit_trackingfile as a double


% --- Executes during object creation, after setting all properties.
function edit_magfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_magfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_magfile_Callback(hObject, eventdata, handles)

function pushbutton_trackbrowse_Callback(hObject, eventdata, handles)
		[fname, pname] = uigetfile('*.mat');
		filename = strcat(pname, fname);
        logentry(['Setting Path to: ' pname]);
        cd(pname);
		set(handles.edit_trackingfile,'String', filename);

function pushbutton_magbrowse_Callback(hObject, eventdata, handles)
		[fname, pname] = uigetfile('*.mat');
		filename = strcat(pname, fname);
        logentry(['Setting Path to: ' pname]);
        cd(pname);
		set(handles.edit_magfile,'String', filename);

function edit_viscosity_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function edit_viscosity_Callback(hObject, eventdata, handles)


function edit_bead_radius_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_bead_radius_Callback(hObject, eventdata, handles)


function popupmenu_dompole_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end
	
		set(hObject, 'Value', 1);

function popupmenu_dompole_Callback(hObject, eventdata, handles)
        dp = num2str(get(hObject, 'Value'));
        logentry(['Setting Dominant Pole to: ' dp]);

function pushbutton_compute_Callback(hObject, eventdata, handles)
    trackfile = get(handles.edit_trackingfile, 'String');
    magfile = get(handles.edit_magfile, 'String');
    dominant_pole = get(handles.popupmenu_dompole, 'Value');
    bead_radius = str2num(get(handles.edit_bead_radius, 'String'));
    viscosity = str2num(get(handles.edit_viscosity, 'String'));
    granularity = str2num(get(handles.edit_granularity, 'String'));
    calib_um = str2num(get(handles.edit_microns_per_pixel, 'String'));
    window_size = str2num(get(handles.edit_window_size, 'String'));
    x = str2num(get(handles.edit_poleloc_x, 'String'));
    y = str2num(get(handles.edit_poleloc_y, 'String'));   
    poleloc = [x y];
    interp = 'on';
    
    logentry(['Viscosity is set to ' num2str(viscosity) ' [Pa s].']);
    logentry(['Bead radius is set to ' num2str(bead_radius) ' [um].']);
    
    force_cal = forcecal2d( trackfile, viscosity, bead_radius * 1e-6, ...
                    poleloc, calib_um, granularity, window_size, interp);
                
    assignin('base', 'force_cal', force_cal);

%     close(video_forcecal_GUI);

    
% --- Executes on button press in checkbox_subtract_drift.
function checkbox_subtract_drift_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_subtract_drift (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_subtract_drift


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    close(video_forcecal_GUI);

function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'video_forcecal_GUI: '];
     
     fprintf('%s%s\n', headertext, txt);


% --- Executes during object creation, after setting all properties.
function edit_poleloc_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_poleloc_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_poleloc_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_poleloc_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_poleloc_x as text
%        str2double(get(hObject,'String')) returns contents of edit_poleloc_x as a double


% --- Executes during object creation, after setting all properties.
function edit_poleloc_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_poleloc_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_poleloc_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_poleloc_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_poleloc_y as text
%        str2double(get(hObject,'String')) returns contents of edit_poleloc_y as a double


% --- Executes during object creation, after setting all properties.
function edit_microns_per_pixel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_microns_per_pixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_microns_per_pixel_Callback(hObject, eventdata, handles)
% hObject    handle to edit_microns_per_pixel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_microns_per_pixel as text
%        str2double(get(hObject,'String')) returns contents of edit_microns_per_pixel as a double


function edit_granularity_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end

function edit_granularity_Callback(hObject, eventdata, handles)


function edit_window_size_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function edit_window_size_Callback(hObject, eventdata, handles)
