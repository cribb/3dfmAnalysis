function varargout = mysignal(varargin)
% MYSIGNAL M-file for mysignal.fig
%      MYSIGNAL, by itself, creates a new MYSIGNAL or raises the existing
%      singleton*.
%
%      H = MYSIGNAL returns the handle to a new MYSIGNAL or the handle to
%      the existing singleton*.
%
%      MYSIGNAL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MYSIGNAL.M with the given input arguments.
%
%      MYSIGNAL('Property','Value',...) creates a new MYSIGNAL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before mysignal_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to mysignal_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mysignal

% Last Modified by GUIDE v2.5 06-Apr-2005 05:01:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mysignal_OpeningFcn, ...
                   'gui_OutputFcn',  @mysignal_OutputFcn, ...
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
return; 
% --- Executes just before mysignal is made visible.
function mysignal_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to mysignal (see VARARGIN)

% Choose default command line output for mysignal
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% assign initial value to frquency vector
clc;
edit_freqVec_Callback(handles.edit_freqVec,[], handles);
% UIWAIT makes mysignal wait for user response (see UIRESUME)
% uiwait(handles.mysignal);

% --- Outputs from this function are returned to the command line.
function varargout = mysignal_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in button_start.
function button_start_Callback(hObject, eventdata, handles)
global AO fvec
% hObject    handle to button_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
AOname = 'PCI-6713';   %id = 1
% find the board ids that go with the names
hwinfo = daqhwinfo('nidaq');
AOid = -1;

for i=1:length(hwinfo.BoardNames)
  if strcmp(char(hwinfo.BoardNames(i)), AOname)
    AOid = i;
  end
end
if AOid < 0
  error('Analog output board not found')
end
%On Hercules, Hardware channel# = coil# -1
ch1 = str2double(get(handles.edit_coilA,'string'))-1;
ch2 = str2double(get(handles.edit_coilB,'string'))-1;
AOchannels = [ch1 ,ch2];
srate = 40000; % sampling rate for magents D2A

amp1 = 0.5*get(handles.slider_pkTOpk1,'value');
amp2 = 0.5*get(handles.slider_pkTOpk2,'value');
offset1 = get(handles.slider_offset1,'value');
offset2 = get(handles.slider_offset2,'value');
phase1 = str2double(get(handles.edit_phase1,'string'))*pi/180;%in radians
phase2 = str2double(get(handles.edit_phase2,'string'))*pi/180;
Nrepeat = str2double(get(handles.edit_repeat,'string'));
tspan = str2double(get(handles.edit_period,'string'));
fcont = str2double(get(handles.edit_controlFreq,'string'));
% flag_cont = a flag to indicate how to incoroporate the control frequency excitation
%   i.e. do we superimpose the control-frequency ('superimpose') or do
%   we intervene it between test frequencies ('intervene') or do we
%   omit the control frequency alltogether ('nocontrol')
switch get(handles.menu_controlStrat,'value')
    case 1
        flag_cont = 'nocontrol';
    case 2
        flag_cont = 'intervene';
    case 3
        flag_cont = 'superimpose';
    otherwise
end

    raw1 = [];
    raw2 = [];
    t = 0:1/srate:tspan;
    for i = 1:length(fvec)
        if(strcmpi(flag_cont,'intervene'))        
            raw1 = [raw1, sin(2*pi*fvec(i)*t), sin(2*pi*fcont*t)]; %intervene fcont instead of superimposing it
            raw2 = [raw2, sin(2*pi*fvec(i)*t), sin(2*pi*fcont*t)];            
        elseif(strcmpi(flag_cont,'superimpose'))
            raw1 = [raw1, sin(2*pi*fvec(i)*t) + sin(2*pi*fcont*t)];
            raw2 = [raw2, sin(2*pi*fvec(i)*t) + sin(2*pi*fcont*t)];
        elseif(strcmpi(flag_cont,'nocontrol'))
            raw1 = [raw1, sin(2*pi*fvec(i)*t)];
            raw2 = [raw2, sin(2*pi*fvec(i)*t)];
        else
        end
    end
%     % Add amalgum of all frequencies to both: start and end
%     amalg = sin(2*pi*fcont*t);
%     for i = 1:length(fvec)
%         amalg = amalg + sin(2*pi*fvec(i)*t);
%     end
%     raw1 = [0.4*amalg,raw1,0.1*amalg];
%     raw2 = [0.4*amalg,raw2,0.1*amalg];
    coil1 = amp1*raw1 + offset1;
    coil2 = amp2*raw2 + offset2;

% plot(t,coil1,'b',t,coil2,'r');
outData = [[coil1';0.0], [coil2';0.0]];
% setup the output
AO = analogoutput('nidaq', AOid);
Ochan = addchannel(AO, AOchannels); % 
set(Ochan, 'OutputRange', [-10 10]); % doesn't matter for pci-6733. unipolar range is not available

set(AO, 'TriggerType', 'Manual'); % use hardware manual trigger 
% set(AO, 'TriggerType', 'HwDigital'); % use hardware digital trigger 
set(AO, 'SampleRate', srate); %default sample rate 
set(AO,'RepeatOutput',Nrepeat); %go on for 10 minutes
putdata(AO, outData); % send the data
start(AO); % ready but not triggered
%-----------   THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
trigger(AO); % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
tim = clock; % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
%----------    THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
data.info.Name = datestr(tim,30);
disp(['Magnet Operation STARTED::',data.info.Name]);
data.info.exactSec = tim(6);
data.info.chan = AOchannels;
data.info.pole_geometry = 'ThreePolesInPlane';
data.info.control_freq = fcont;
data.info.srateHz = srate;
data.info.amplitudeV = [amp1 amp2];
data.info.offsetV = [offset1 offset2];
data.info.phaseRad = [phase1 phase2];
data.info.control_stratety = flag_cont;
data.info.freqHz = fvec;
data.info.tspan = tspan;
data.info.Nrepeat = Nrepeat;
data.outData = outData;
%-----------            THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
waittilstop(AO,600);%   THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
tend = clock;%          THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
%-----------            THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
disp(['Magnet Operation COMPLETED::',data.info.Name]);
data.info.tend = datestr(tend,30);
data.info.endSec = tend(6);
save([data.info.Name,'.magui.mat'],'data');

% --- Executes on button press in button_stop.
function button_stop_Callback(hObject, eventdata, handles)
% hObject    handle to button_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global AO
if(strcmpi(get(AO,'Running'),'On'))
    stop(AO);
end
putsample(AO,[0 0]);

% --- Executes on button press in button_close.
function button_close_Callback(hObject, eventdata, handles)
% hObject    handle to button_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global AO
if(strcmpi(get(AO,'Running'),'On'))
    stop(AO);
end
putsample(AO,[0 0]);
clear AO
delete AO
daqreset;
close(handles.mysignal);
% % ---Whether do frequency sweep or not
% function check_freqSweep_Callback(hObject, eventdata, handles)
% if(get(hObject,'value'))
%     set(handles.edit_period,'Enable','Off');
%     set(handles.slider_period,'Enable','Off');
% else
%     set(handles.edit_period,'Enable','On');
%     set(handles.slider_period,'Enable','On');
% end


function edit_repeat_Callback(hObject, eventdata, handles)

% --- Executes on button press in button_defaultFreq.
function button_defaultFreq_Callback(hObject, eventdata, handles)
global fvec;
default_fvec = [4000 3400 3000 2600 2050 1680 1100 800 700 500 300 110 80 70 45 25 8 5]; 
default_fcont = 150;%it is usually desirable that harmonics of fcont are not in fvec
fvec = default_fvec;
set(handles.edit_freqVec,'string',num2str(default_fvec));
set(handles.edit_controlFreq,'string',num2str(default_fcont));

function slider_period_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = round(user_input);
set(hObject,'value');
set(handles.edit_period,'string',num2str(val));
updateAO;

function edit_controlFreq_Callback(hObject, eventdata, handles)
user_input = num2str(get(hObject,'string'));
function menu_controlStrat_Callback(hObject, eventdata, handles)

function edit_freqVec_Callback(hObject, eventdata, handles)
global fvec
str = get(hObject,'string');
fvec = parsemyarray(str);
set(handles.edit_freqVec,'string',num2str(fvec));
return;

function numerVec = parsemyarray(str)
if(isempty(str))
    error('Error: Frequency vector can not be left empty');
elseif isempty(str2num(str(1)))
    error('Error: First element of the string must be numeric (check for whitespace)');
end
itrue = 1;
waiting_for_char = 1;
first_dig_index = 1;
for i = 2:length(str)
    if isempty(str2num(str(i)))%this means the element is not a numeric character
        if waiting_for_char 
            numerVec(itrue) = str2num(str(first_dig_index:i-1));
            waiting_for_char = 0;
            itrue = itrue+1;
        end
    else
        if ~waiting_for_char %atleast one char before, so this is the first digit 
            first_dig_index = i;
            waiting_for_char = 1;
        end
    end
end
if(waiting_for_char)%this means last element is numeric character
    numerVec(itrue) = str2num(str(first_dig_index:end));
end

function edit_period_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_period);

updateAO;
% --- Channel 1 settings
% --- Peak To Peak amplitude in volts
function slider_pkTOpk1_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.1
set(hObject,'value');
set(handles.edit_pkTOpk1,'string',num2str(val));
updateAO;
function edit_pkTOpk1_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_pkTOpk1);
updateAO;
% --- Offset in volts
function slider_offset1_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.25
set(hObject,'value');
set(handles.edit_offset1,'string',num2str(val));
updateAO;
function edit_offset1_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_offset1);
updateAO;
function edit_phase1_Callback(hObject, eventdata, handles)
updateAO;
function edit_coilA_Callback(hObject, eventdata, handles)
val = str2num(get(hObject,'string'));
if val < 1 | val > 6
    disp('Error: Allowed values for coilA number are 1 to 6');
    set(hObject, 'string','1'); %set to default value
elseif val == str2num(get(handles.edit_coilB,'string'))
    disp('Error: CoilA number can not be same as CoilB number');
    set(hObject, 'string','1'); %set to default value
end
   
function edit_coilB_Callback(hObject, eventdata, handles)
val = str2num(get(hObject,'string'));
if val < 1 | val > 6
    disp('Error: Allowed values for coilB number are 1 to 6');
    set(hObject, 'string','4'); %set to default value
elseif val == str2num(get(handles.edit_coilA,'string'))
    disp('Error: CoilB number can not be same as CoilA number');
    set(hObject, 'string','4'); %set to default value
end

% --- Channel 1 settings
% --- Peak To Peak amplitude in volts
function slider_pkTOpk2_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.25
set(hObject,'value');
set(handles.edit_pkTOpk2,'string',num2str(val));
updateAO;
function edit_pkTOpk2_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_pkTOpk2);
updateAO;
% --- Executes on slider movement.
function slider_offset2_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.25
set(hObject,'value');
set(handles.edit_offset2,'string',num2str(val));
updateAO;
function edit_offset2_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_offset2);
updateAO;
function edit_phase2_Callback(hObject, eventdata, handles)
updateAO;

function check_editval(h,h_slider)
% Checks whether the value entered in "edit" object (h)is compatible to the
% corresponding slider object (h_slider) settings
user_entry = get(h,'string');
value = str2double(user_entry);
max = get(h_slider,'Max');
min = get(h_slider,'Min');
if isnan(value)
    errordlg('You must enter a numeric value','Bad Input','modal')
end
if (value > max | value < min) % out of bounds
    errordlg(['Value must be between ',str2double(min),' and ',str2double(max)],'Bad Input','modal')
    value = get(h_slider,'value');  % set the last value
    set(h,'string',num2str(value));
end
set(h_slider,'Value', value);

function updateAO(varargin)

% --- Executes during object creation, after setting all properties.
function edit_phase1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_phase1 (see GCBO)
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
function edit_coilB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_coilB (see GCBO)
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
function edit_phase2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_phase2 (see GCBO)
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
function edit_offset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_offset2 (see GCBO)
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
function edit_pkTOpk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pkTOpk2 (see GCBO)
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
function slider_pkTOpk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_pkTOpk2 (see GCBO)
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
function slider_pkTOpk1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_pkTOpk1 (see GCBO)
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
function edit_coilA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_coilA (see GCBO)
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
function edit_period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_period (see GCBO)
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
function edit_offset1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_offset1 (see GCBO)
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
function slider_period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_period (see GCBO)
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
function edit_pkTOpk1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pkTOpk1 (see GCBO)
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
function slider_offset1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_offset1 (see GCBO)
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
function slider_offset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_offset2 (see GCBO)
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
function edit_freqVec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_freqVec (see GCBO)
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
function menu_controlStrat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_controlStrat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end
% --- Executes during object creation, after setting all properties.
function edit_controlFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_controlFreq (see GCBO)
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
function edit_repeat_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




