function varargout = cap_gui(varargin)
% CAP_GUI M-file for cap_gui.fig
%      CAP_GUI, by itself, creates a new CAP_GUI or raises the existing
%      singleton*.
%
%      H = CAP_GUI returns the handle to a new CAP_GUI or the handle to
%      the existing singleton*.
%
%      CAP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CAP_GUI.M with the given input arguments.
%
%      CAP_GUI('Property','Value',...) creates a new CAP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before cap_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to cap_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help cap_gui

% Last Modified by GUIDE v2.5 17-Feb-2013 17:10:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cap_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @cap_gui_OutputFcn, ...
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


% --- Executes just before cap_gui is made visible.
function cap_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to cap_gui (see VARARGIN)

% Choose default command line output for cap_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes cap_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = cap_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu_xaxis.
function popupmenu_xaxis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_xaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_xaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_xaxis
    plot_data(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_xaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_xaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_y1axis.
function popupmenu_y1axis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_y1axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_y1axis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_y1axis
    plot_data(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_y1axis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_y1axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    


function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_browse.
function pushbutton_browse_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename = get(handles.edit_filename, 'String');

    if(isempty(filename))
		[fname, pname, fidx] = uigetfile({'*.cap.mat';'*exp.txt';'*.*'}, ...
                                         'Select File(s) to Open', ...
                                         'MultiSelect', 'off');
        
        if sum(length(fname), length(pname)) <= 1
            logentry('No cone and plate file selected. No file loaded.');
            return;
        end   
        
        filename = strcat(pname, fname);
        
        if iscell(filename) 
            set(handles.edit_filename,'String', 'Multiple Files loaded.');
        else
            set(handles.edit_filename,'String', filename);
        end
        
        cd(pname);
         
        % load the datafile
        logentry('Loading dataset... ');
        
        if strfind(filename, 'cap.mat')
            cap = load(filename);
        elseif strfind(filename, 'exp.txt')
            cap = ta2mat(filename);
        else
            error('File type is not understood.');
        end
        
    end
    
    % construct figure handles if they don't already exist
    if isfield(handles, 'fig01')
        fig01 = figure(handles.fig01);
    else
        fig01 = figure;
    end
    
    exptnames = fieldnames(cap.experiments);    
    set(handles.popupmenu_exptname, 'String', exptnames);
    
    % export important data to handles structure
    handles.fig01 = fig01;
    handles.cap   = cap;
    
    % Enable experiment popup controls now that data is loaded
    set(handles.pushbutton_newfigure , 'Enable', 'on');
    set(handles.text_exptname        , 'Enable', 'on');
    set(handles.popupmenu_exptname   , 'Enable', 'on');
    
    % finally, update gui variables before ending function
    guidata(hObject, handles);
    
    return;    
    
    
% --- Executes on button press in checkbox_neutx.
function checkbox_neutx_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_neutx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_neutx


% --- Executes on button press in checkbox_neuty1.
function checkbox_neuty1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_neuty1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_neuty1


% --- Executes on selection change in popupmenu_y2axis.
function popupmenu_y2axis_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_y2axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_y2axis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_y2axis


% --- Executes during object creation, after setting all properties.
function popupmenu_y2axis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_y2axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_neuty2.
function checkbox_neuty2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_neuty2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_neuty2


% --- Executes on button press in pushbutton_newfigure.
function pushbutton_newfigure_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_newfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbutton_newfigure


% --- Executes on button press in radiobutton_Hz.
function radiobutton_Hz_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_Hz


% --- Executes on button press in radiobutton_rad.
function radiobutton_rad_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_rad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_rad



% ==== non-GUI subfunctions (jac)
function plot_data(hObject, eventdata, handles)

expt = handles.expt;

x_selected = get(handles.popupmenu_xaxis,'Value');
% x_contents = cellstr(get(handles.popupmenu_xaxis,'String'));
x_contents = char(handles.headers(x_selected));
x_units    = char(handles.units(x_selected));

y1_selected = get(handles.popupmenu_y1axis,'Value');
% y1_contents = cellstr(get(handles.popupmenu_y1axis,'String'));
y1_contents = char(handles.headers(y1_selected));
y1_units    = char(handles.units(y1_selected));


fig01 = handles.fig01;

x_data = expt.table(:, x_selected);
y1_data = expt.table(:, y1_selected);

if get(handles.checkbox_xlog, 'Value')
    x_data = log10(x_data);
end

if get(handles.checkbox_y1log, 'Value')
    y1_data = log10(y1_data);
end

if get(handles.checkbox_y2log, 'Value')
    y2_data = log10(y2_data);
end


figure(fig01);
plot(x_data,y1_data, '.-');
xlabel([x_contents ', ' '[' x_units ']']);
ylabel([y1_contents ', ' '[' y1_units ']']);
pretty_plot;


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'cap_gui: '];
     
     fprintf('%s%s\n', headertext, txt);

     
% ==== non-GUI subfunctions END ====


% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(cap_gui);

% duplicate entry need to delete this
% % % % --- Executes on button press in pushbutton_newfigure.
% % % function pushbutton_newfigure_Callback(hObject, eventdata, handles)
% % % % hObject    handle to pushbutton_newfigure (see GCBO)
% % % % eventdata  reserved - to be defined in a future version of MATLAB
% % % % handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in popupmenu_exptname.
function popupmenu_exptname_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_exptname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_exptname contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_exptname
    contents = cellstr(get(hObject, 'String'));
    current_expt = contents{get(hObject, 'Value')};
    expt = getfield(handles.cap.experiments, current_expt);


    [headers, units] = get_TA_column_headers(expt);

    set(handles.popupmenu_xaxis, 'String', headers);
    set(handles.popupmenu_y1axis, 'String', headers);
    set(handles.popupmenu_y2axis, 'String', headers);

        % enable axes possibilities in popups because possibilities are defined
        set(handles.text_x               , 'Enable', 'on');
        set(handles.text_y1              , 'Enable', 'on');
        set(handles.text_y2              , 'Enable', 'on');
        set(handles.popupmenu_xaxis      , 'Enable', 'on');
        set(handles.popupmenu_y1axis     , 'Enable', 'on');
        set(handles.popupmenu_y2axis     , 'Enable', 'on');
        set(handles.checkbox_neutx       , 'Enable', 'on');    
        set(handles.checkbox_neuty1      , 'Enable', 'on');    
        set(handles.checkbox_neuty2      , 'Enable', 'on');    
        set(handles.radiobutton_Hz       , 'Enable', 'on');    
        set(handles.radiobutton_rad      , 'Enable', 'on');    

    % populate the data table shown on the GUI
    set(handles.uitable1, 'ColumnName', headers);
    set(handles.uitable1, 'Data', expt.table);

    handles.expt = expt;
    handles.headers = headers;
    handles.units   = units;
    guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function popupmenu_exptname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_exptname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_more_or_less.
function pushbutton_more_or_less_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_more_or_less (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_xlog.
function checkbox_xlog_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_xlog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_xlog
plot_data(hObject, eventdata, handles);

% --- Executes on button press in checkbox_y1log.
function checkbox_y1log_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_y1log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_y1log
plot_data(hObject, eventdata, handles);

% --- Executes on button press in checkbox_y2log.
function checkbox_y2log_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_y2log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_y2log
plot_data(hObject, eventdata, handles);