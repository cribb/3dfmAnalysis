function varargout = bioforceGUI(varargin)
% BIOFORCEGUI M-file for bioforceGUI.fig
%      BIOFORCEGUI, by itself, creates a new BIOFORCEGUI or raises the existing
%      singleton*.
%
%      H = BIOFORCEGUI returns the handle to a new BIOFORCEGUI or the handle to
%      the existing singleton*.
%
%      BIOFORCEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIOFORCEGUI.M with the given input arguments.
%
%      BIOFORCEGUI('Property','Value',...) creates a new BIOFORCEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bioforceGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bioforceGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bioforceGUI

% Last Modified by GUIDE v2.5 05-Jul-2006 11:29:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bioforceGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @bioforceGUI_OutputFcn, ...
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


% --- Executes just before bioforceGUI is made visible.
function bioforceGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bioforceGUI (see VARARGIN)

% Choose default command line output for bioforceGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bioforceGUI wait for user response (see UIRESUME)
% uiwait(handles.CISMM_BioforceGUI);


% --- Outputs from this function are returned to the command line.
function varargout = bioforceGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    


% --- Executes on button press in pushbutton_Select_Data_In_Box.
function pushbutton_Select_Data_In_Box_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Select_Data_In_Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    fig = get(handles.edit_ActiveFigure, 'String');
    fig = str2num(fig);
    
	[xout, yout] = select_data_in_box(fig);    
    
    handles.x = xout;
    handles.y = yout;
    
    assignin('base', 'xout', xout);
    assignin('base', 'yout', yout);
    
	guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_ActiveFigure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ActiveFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit_ActiveFigure_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ActiveFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ActiveFigure as text
%        str2double(get(hObject,'String')) returns contents of edit_ActiveFigure as a double


% --- Executes on button press in pushbutton_relaxtime.
function pushbutton_relaxtime_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_relaxtime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    x = handles.x;
    y = handles.y;
    n = str2num(get(handles.edit_num_modes, 'String'));

    [J,tau,R_square] = relaxation_time(x, y, n);

    set(handles.text_relaxtime, 'String', num2str(tau));
    set(handles.text_relaxtime_r2, 'String', num2str(R_square));


% --- Executes on button press in pushbutton_percent_recovery.
function pushbutton_percent_recovery_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_percent_recovery (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    x = handles.x;
    y = handles.y;
    
    [pr, xmax, xrec] = percent_recovery(y);

    set(handles.text_maximum_displacement, 'String', num2str(xmax));
    set(handles.text_recovered_displacement, 'String', num2str(xrec));
    set(handles.text_percent_recovery, 'String', num2str(pr));


% --- Executes on button press in pushbutton_slope.
function pushbutton_slope_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_slope (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    fig = get(handles.edit_ActiveFigure, 'String');
    fig = str2num(fig);
    
    x = handles.x;
    y = handles.y;

	fit = polyfit(x, y, 1);
	fity = polyval(fit, x);
	
	slope = fit(1);
	icept = fit(2);
    R2 = corrcoef(x, y);
    R2 = R2(1,2);
    
    set(handles.text_slope, 'String', num2str(slope));
    set(handles.text_slope_R2, 'String', num2str(R2));
    set(handles.text_lblR2_1, 'Visible', 'on');
    set(handles.text_lblR2_2, 'Visible', 'on');
    
    
    fprintf('Statistics\n');
	fprintf('x-range: %d \ny-range: %d \n', range(x), range(y));
	fprintf('slope = %g, icept = %g', slope, icept);
    
    figure(fig);
    hold on;
    plot(x, fity, 'r');


% --- Executes on button press in pushbutton_DNA.
function pushbutton_DNA_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_DNA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    r = handles.x;
    F = handles.y;
    
    L = wlc(r, F);
    
    set(handles.text_persistence_length, 'String', num2str(L.Lp * 1e9));
    set(handles.text_contour_length, 'String', num2str(L.Lc * 1e6));
    set(handles.text_offset, 'String', num2str(L.offset * 1e6));    


% --- Executes on button press in pushbutton_range.
function pushbutton_range_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_range (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    fig = get(handles.edit_ActiveFigure, 'String');
    fig = str2num(fig);

    y = handles.y;
    
    set(handles.text_range, 'String', range(y));
    
    figure(fig);
    drawlines(gca, [], [], [], [min(y) max(y)], 'r')
    



function edit_num_modes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_num_modes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_num_modes as text
%        str2double(get(hObject,'String')) returns contents of edit_num_modes as a double


% --- Executes during object creation, after setting all properties.
function edit_num_modes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_num_modes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


