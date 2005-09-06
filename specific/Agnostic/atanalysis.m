function varargout = atanalysis(varargin)
% ATANALYSIS M-file for atanalysis.fig
%      ATANALYSIS, by itself, creates a new ATANALYSIS or raises the existing
%      singleton*.
%
%      H = ATANALYSIS returns the handle to a new ATANALYSIS or the handle to
%      the existing singleton*.
%
%      ATANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ATANALYSIS.M with the given input arguments.
%
%      ATANALYSIS('Property','Value',...) creates a new ATANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before atanalysis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to atanalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help atanalysis

% Last Modified by GUIDE v2.5 30-Aug-2005 11:36:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @atanalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @atanalysis_OutputFcn, ...
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

% --- Executes just before atanalysis is made visible.
function atanalysis_OpeningFcn(hObject, eventdata, handles, varargin)
global lastpath
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to atanalysis (see VARARGIN)

% Choose default command line output for atanalysis
handles.output = hObject;
lastpath = pwd;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes atanalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = atanalysis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in button_brTracking.
function button_brTracking_Callback(hObject, eventdata, handles)
global d lastpath
% hObject    handle to button_brTracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
curdir = pwd;
cd (lastpath);

[fname, pname] = uigetfile('*.mat');
lastpath = pname;
if (fname(1) == 0 | pname(1) == 0);
    disp('Either no file was selected or, some error occured while parsing the path');
    set(hObject,'string','Click here to browse for tracking file');
    return;
end
set(hObject,'string',[pname(1:25), '.....\', fname]);
filename = strcat(pname, fname);
disp(['*************************************************************']);
disp(['Now parsing ',filename]);
cd (curdir);

d = load_agnostic_tracking(filename,1,0);
figure(1);
plot(d.t,d.ssense - repmat(d.ssense(1,:),size(d.ssense,1),1));
if (isfield(d,'ji2nd'))
    for (c = 1:length(d.ji2nd))        
        drawlines(gca,d.ji2nd(c).tblip);
    end
end
if (isfield(d,'jilin'))
    for (c = 1:length(d.jilin))        
        drawlines(gca,d.jilin(c).tblip);
    end
end
if (isfield(d,'jacold'))
    for (c = 1:length(d.jacold))        
        drawlines(gca,d.jacold(c).tblip);
    end
end

set(handles.edit_FitStart,'string',num2str(d.t(1)));
set(handles.edit_FitEnd,'string',num2str(d.t(end)));
set(handles.edit_TestStart,'string',num2str(d.t(1)));
set(handles.edit_TestEnd,'string',num2str(d.t(end)));
% --- Executes on button press in buttpn_clearMemory.
function buttpn_clearMemory_Callback(hObject, eventdata, handles)
global d
% hObject    handle to buttpn_clearMemory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_FitStart,'string',num2str(d.t(1)));
set(handles.edit_FitEnd,'string',num2str(d.t(end)));
set(handles.edit_TestStart,'string',num2str(d.t(1)));
set(handles.edit_TestEnd,'string',num2str(d.t(end)));
% --- Executes on button press in buttpn_Export.
function buttpn_Export_Callback(hObject, eventdata, handles)
% hObject    handle to buttpn_Export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
[settings flags] = read_settings_and_flags(handles);
dex.info = d.info;

istart = min([max(find(d.t <= settings.fitrange(1,1))), max(find(d.t <= settings.testrange(1,1)))]);
iend = max([max(find(d.t <= settings.fitrange(1,2))), max(find(d.t <= settings.testrange(1,2)))]);
dex.t = d.t(istart:iend);
dex.ssense = d.ssense(istart:iend,1:3);
dex.qpd = d.qpd(istart:iend,1:4);

icstart = min([max(find(d.stageCom.t <= settings.fitrange(1,1))), max(find(d.stageCom.t <= settings.testrange(1,1)))]);
icend = max([max(find(d.stageCom.t <= settings.fitrange(1,2))), max(find(d.stageCom.t <= settings.testrange(1,2)))]);
dex.stageCom.t = d.stageCom.t(icstart:icend);
dex.stageCom.xyz = d.stageCom.xyz(icstart:icend,1:3);
assignin('base','d',dex);
assignin('base','settings',settings);
assignin('base','flags',flags);
disp('Variables ''d'', ''settings'' and ''flags'' were exported to base workspace');
% --- Executes on button press in button_Compute.
function button_Compute_Callback(hObject, eventdata, handles)
% hObject    handle to button_Compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global d
[settings, flags] = read_settings_and_flags(handles);
res = atcore(d, settings, flags);
disp(['|-----------Fit  [', num2str(settings.fitrange(1,1)), ' to ',num2str(settings.fitrange(1,2)), ...
        ']  ==> Test  [', num2str(settings.testrange(1,1)), ' to ', num2str(settings.testrange(1,2)), ']  ----------|']);
disp(flags); disp(settings);
disp('Results:');
disp(res);
%------------------------------------------------------------
function [settings, flags] = read_settings_and_flags(handles);
flags.fixskew = get(handles.check_Skew,'value');
settings.order = get(handles.slider_JacOrder,'value');
flags.usereciprocals = get(handles.check_Reciprocals,'value');
flags.usesumdiff = get(handles.check_SumDiff,'Value');
flags.LPstage = get(handles.check_LPfilterStage,'value');
flags.LPqpd = get(handles.check_LPfilterQPD,'value');
flags.LPresid = get(handles.check_LPfilterResid,'value');
settings.LPhz = get(handles.slider_LPfilter,'value');
settings.fitrange = [str2double(get(handles.edit_FitStart, 'string')), ...
        str2double(get(handles.edit_FitEnd, 'string'))];
settings.testrange = [str2double(get(handles.edit_TestStart,'string')), ...
        str2double(get(handles.edit_TestEnd,'string'))];
flags.HPstage = get(handles.check_HPfilterStage,'value');
flags.HPqpd = get(handles.check_HPfilterQPD,'value');
settings.HPhz = get(handles.slider_HPfilter,'value');
% --- Executes on button press in button_SelectFit.
function button_SelectFit_Callback(hObject, eventdata, handles)
% hObject    handle to button_SelectFit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(1);
[x,y] = ginput(2);
x = sort(x);
set(handles.edit_FitStart,'string',num2str(x(1,1)));
set(handles.edit_FitEnd,'string',num2str(x(2,1)));
% drawlines(handles.axes_times,[
% --- Executes on button press in button_SelectTest.
function button_SelectTest_Callback(hObject, eventdata, handles)
% hObject    handle to button_SelectTest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure(1);
[x,y] = ginput(2);
x = sort(x);
set(handles.edit_TestStart,'string',num2str(x(1,1)));
set(handles.edit_TestEnd,'string',num2str(x(2,1)));

% --- Executes on slider movement.
function slider_JacOrder_Callback(hObject, eventdata, handles)
% hObject    handle to slider_JacOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_JacOrder,'string',num2str(get(hObject,'value')));

function edit_JacOrder_Callback(hObject, eventdata, handles)
% hObject    handle to edit_JacOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_editval(hObject, handles.slider_JacOrder);

% --- Executes on button press in check_Skew.
function check_Skew_Callback(hObject, eventdata, handles)
% hObject    handle to check_Skew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in check_HPfilterStage.
function check_HPfilterStage_Callback(hObject, eventdata, handles)
% hObject    handle to check_HPfilterStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in check_HPfilterQPD.
function check_HPfilterQPD_Callback(hObject, eventdata, handles)
% hObject    handle to check_HPfilterQPD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in check_LPfilterResid.
function check_LPfilterResid_Callback(hObject, eventdata, handles)
% hObject    handle to check_LPfilterResid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on slider movement.
function slider_HPfilter_Callback(hObject, eventdata, handles)
% hObject    handle to slider_HPfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_HPfilter,'string',num2str(get(hObject,'value')));

function edit_HPfilter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_HPfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_editval(hObject, handles.slider_HPfilter);

% --- Executes on button press in check_LPfilterStage.
function check_LPfilterStage_Callback(hObject, eventdata, handles)
% hObject    handle to check_LPfilterStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in check_LPfilterQPD.
function check_LPfilterQPD_Callback(hObject, eventdata, handles)
% hObject    handle to check_LPfilterQPD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_LPfilter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_LPfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
check_editval(hObject, handles.slider_LPfilter);

% --- Executes on slider movement.
function slider_LPfilter_Callback(hObject, eventdata, handles)
% hObject    handle to slider_LPfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.edit_LPfilter,'string',num2str(get(hObject,'value')));
% --- Executes on button press in check_Reciprocals.
function check_Reciprocals_Callback(hObject, eventdata, handles)
% hObject    handle to check_Reciprocals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in check_SumDiff.
function check_SumDiff_Callback(hObject, eventdata, handles)
% hObject    handle to check_SumDiff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in button_ClearMemory.
function button_ClearMemory_Callback(hObject, eventdata, handles)
% hObject    handle to button_ClearMemory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_FitEnd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FitEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_TestEnd_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TestEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_FitStart_Callback(hObject, eventdata, handles)
% hObject    handle to edit_FitStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function edit_TestStart_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TestStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%--------------------------------------------------------
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'atanalysis: '];
     
     fprintf('%s%s\n', headertext, txt);
% --------------------------------------------------------------------
function check_editval(h,h_slider)
% Checks whether the value entered in "edit" object (h)is compatible to the
% corresponding slider object (h_slider) settings
user_entry = get(h,'string');
value = str2double(user_entry);
if isnan(value)
    errordlg('You must enter a numeric value','Bad Input','modal')
end
max = get(h_slider,'Max');
min = get(h_slider,'Min');
if (value > max | value < min) % out of bounds
    value = get(h_slider,'value');  % set the last value
    set(h,'string',num2str(value));
    errordlg(['You must enter a numeric value between ',num2str(min),' and ',num2str(max)],'Bad Input','modal')
else
    set(h_slider,'Value', value);
end
% --- Executes during object creation, after setting all properties.
function edit_HPfilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_HPfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function menu_JacOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_JacOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function slider_JacOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_JacOrder (see GCBO)
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

% --- Executes during object creation, after setting all properties.
function edit_JacOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_JacOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function slider_HPfilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_HPfilter (see GCBO)
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

% --- Executes during object creation, after setting all properties.
function slider_LPfilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_LPfilter (see GCBO)
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

% --- Executes during object creation, after setting all properties.
function edit_LPfilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_LPfilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function edit_FitStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FitStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function edit_FitEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_FitEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function edit_TestStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TestStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function edit_TestEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TestEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



