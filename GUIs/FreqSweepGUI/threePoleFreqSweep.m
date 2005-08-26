function varargout = threePoleFreqSweep(varargin)
% THREEPOLEFREQSWEEP M-file for threePoleFreqSweep.fig
%      THREEPOLEFREQSWEEP, by itself, creates a new THREEPOLEFREQSWEEP or raises the existing
%      singleton*.
%
%      H = THREEPOLEFREQSWEEP returns the handle to a new THREEPOLEFREQSWEEP or the handle to
%      the existing singleton*.
%
%      THREEPOLEFREQSWEEP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THREEPOLEFREQSWEEP.M with the given input arguments.
%
%      THREEPOLEFREQSWEEP('Property','Value',...) creates a new THREEPOLEFREQSWEEP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before threePoleFreqSweep_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to threePoleFreqSweep_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help threePoleFreqSweep

% Last Modified by GUIDE v2.5 12-Jul-2005 12:43:24  kvdesai

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @threePoleFreqSweep_OpeningFcn, ...
                   'gui_OutputFcn',  @threePoleFreqSweep_OutputFcn, ...
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


% --- Executes just before threePoleFreqSweep is made visible.
function threePoleFreqSweep_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to threePoleFreqSweep (see VARARGIN)

% Choose default command line output for threePoleFreqSweep
handles.output = hObject;
global version_str;
version_str = '1.1';
% Update handles structure
guidata(hObject, handles);
clc;
disp(['Welcome to Three Pole Frequency Sweep Generator ', version_str]);
edit_freqVec_Callback(handles.edit_freqVec,[], handles);
% UIWAIT makes threePoleFreqSweep wait for user response (see UIRESUME)
% uiwait(handles.threePoleFreqSweep);


% --- Outputs from this function are returned to the command line.
function varargout = threePoleFreqSweep_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in button_start.
function button_start_Callback(hObject, eventdata, handles)
% hObject    handle to button_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global AO fvec version_str
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
chA = str2double(get(handles.edit_coilA,'string'))-1;
chB = str2double(get(handles.edit_coilB,'string'))-1;
chC = str2double(get(handles.edit_coilC,'string'))-1;
chFlag = 7 - 1; %Channel 7 output is being read into tracking ADC, so put the sum of squares on this channel.

AOchannels = [chA, chB, chC, chFlag];
desired_sampleRate = 50000; % desired sampling rate for magnets D2A

% setup the output board
AO = analogoutput('nidaq', AOid);
Ochan = addchannel(AO, AOchannels);  
set(Ochan, 'OutputRange', [-10 10]);  

set(AO, 'TriggerType', 'Manual'); % use hardware manual trigger 
% set(AO, 'TriggerType', 'HwDigital'); % use hardware digital trigger 
srate = setverify(AO, 'SampleRate', desired_sampleRate); %default sample rate 

ampA = 0.5*get(handles.slider_pk2pkA,'value');
ampB = 0.5*get(handles.slider_pk2pkB,'value');
ampC = 0.5*get(handles.slider_pk2pkC,'value');

%For sinusoidal pulling (in 2D) three coil excitations should be separated
%by phase of 120 degree.
phaseA = 0;%in radians
phaseB = 2*pi/3;
phaseC = 4*pi/3;

Nrepeat = str2double(get(handles.edit_repeat,'string'));
tspan = str2double(get(handles.edit_period,'string'));
fcont = str2double(get(handles.edit_controlFreq,'string'));
% flag_cont = a flag to indicate how to incoroporate the control frequency excitation
%   i.e. do we superimpose the control-frequency ('superimpose') or do
%   we interleave it between test frequencies ('interleave') or do we
%   omit the control frequency alltogether ('nocontrol')
switch get(handles.menu_controlStrat,'value')
    case 1
        flag_cont = 'nocontrol';
    case 2
        flag_cont = 'interleave';
    case 3
        flag_cont = 'superimpose';
    otherwise
end
rawA = [];    rawB = []; rawC = [];
t = 0:1/srate:tspan;
% HARDCODED VALUES: gap time = 1 second, control frequency time = 1 second.
GAP_TIME = 1;
FCONT_TIME = 1;
tgap = 0:1/srate:GAP_TIME;
tcont = 0:1/srate:FCONT_TIME;
gaps = zeros(1,length(tgap));
for i = 1:length(fvec)
    % For three pole case, the force frequency is twice the excitation
    % frequency. So divide the supplied frquencies by two.
    tsineA = sin(2*pi*fvec(i)*0.5*t + phaseA);
    csineA = sin(2*pi*fcont*0.5*tcont + phaseA);
    tsineB = sin(2*pi*fvec(i)*0.5*t + phaseB);
    csineB = sin(2*pi*fcont*0.5*tcont + phaseB);
    tsineC = sin(2*pi*fvec(i)*0.5*t + phaseC);
    csineC = sin(2*pi*fcont*0.5*tcont + phaseC);
    
    if(strcmpi(flag_cont,'interleave'))  %control frquency betwn each test freq      
        rawA = [rawA, tsineA, gaps, csineA, gaps]; 
        rawB = [rawB, tsineB, gaps, csineB, gaps];
        rawC = [rawC, tsineC, gaps, csineC, gaps];            
    elseif(strcmpi(flag_cont,'superimpose')) %control freq simultaneous with test freq
        rawA = [rawA, tsineA + csineA, gaps];
        rawB = [rawB, tsineB + csineB, gaps];
        rawC = [rawC, tsineC + csineC, gaps];
    elseif(strcmpi(flag_cont,'nocontrol')) %no control applied
        rawA = [rawA, tsineA, gaps];
        rawB = [rawB, tsineB, gaps];
        rawC = [rawC, tsineC, gaps];        
    else
        errordlg('UnRecognized Control Strategy. Programming Error!');
    end
end
coilA = ampA*rawA;
coilB = ampB*rawB;
coilC = ampC*rawC;
dFlag = 0.01*(coilA.^2 + coilB.^2 + coilC.^2);
outData = [[coilA';0.0], [coilB';0.0], [coilC';0.0], [dFlag';0.0]];
% Now fill the output buffer but do not start sending the data yet

set(AO,'RepeatOutput',Nrepeat); 
putdata(AO, outData); % send the data
start(AO); % ready but not triggered
%-----------   THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
trigger(AO); % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
tim = clock; % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
%----------    THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
data.info.Name = datestr(tim,30);
data.info.version = version_str;
disp(['Magnet Operation STARTED::',data.info.Name]);
data.info.exactSec = tim(6);
data.info.chan = AOchannels;
data.info.pole_geometry = 'ThreePolesInPlane';
data.info.srateHz = srate;
data.info.amplitudeV = [ampA ampB ampC];
data.info.phaseRad = [phaseA phaseB phaseC];
data.info.freqHz = fvec;
data.info.control_freq = fcont;
data.info.control_stratety = flag_cont;
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
save([data.info.Name,'_freqSweep.mat'],'data');

% --- Executes on button press in button_stop.
function button_stop_Callback(hObject, eventdata, handles)
% hObject    handle to button_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global AO
if (exist('AO') & ~isempty(AO))
    if(strcmpi(get(AO,'Running'),'On'))
        stop(AO);
    end
    putsample(AO,[0 0 0]);
end
% --- Executes on button press in button_close.
function button_close_Callback(hObject, eventdata, handles)
% hObject    handle to button_close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global AO
if (exist('AO') & ~isempty(AO))
    if(strcmpi(get(AO,'Running'),'On'))
        stop(AO);
    end
    putsample(AO,[0 0 0]);
    clear AO
    delete AO
end
daqreset;
close(handles.threePoleFreqSweep);

% --- Executes on button press in button_defaultFreq.
function button_defaultFreq_Callback(hObject, eventdata, handles)
global fvec;
default_fvec = [4000 3400 3000 2600 2050 1680 1100 800 700 500 300 110 80 70 45 25 17 8 5 2]; 
default_fcont = 125;%it is usually desirable that first 3 harmonics of fcont are not in fvec
fvec = default_fvec;
set(handles.edit_freqVec,'string',num2str(default_fvec));
set(handles.edit_controlFreq,'string',num2str(default_fcont));

% function slider_period_Callback(hObject, eventdata, handles)
% user_input = get(hObject,'value');
% val = round(user_input);
% set(hObject,'value');
% set(handles.edit_period,'string',num2str(val));
% updateAO;

function edit_controlFreq_Callback(hObject, eventdata, handles)
user_input = num2str(get(hObject,'string'));

function menu_controlStrat_Callback(hObject, eventdata, handles)

function edit_freqVec_Callback(hObject, eventdata, handles)
global fvec
str = get(hObject,'string');
fvec = parsemyarray(str);
set(handles.edit_freqVec,'string',num2str(fvec));
return;
%--------------------------------------------------------------------------
%This function parses the comma separated list of frequencies and extracts
%out the numbers from that. It is flexible enough that as long as user
%puts one comma AND/OR one space between consequtive frequencies, it works.
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
%------------------------------------------------------------------
function edit_period_Callback(hObject, eventdata, handles)
% check_editval(hObject, handles.slider_period);
updateAO;

% --- Coil A settings%------------------------------------------
% --- Peak To Peak amplitude in volts
function slider_pk2pkA_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.1
update_allpk2pk(handles,val);
updateAO;
function edit_pk2pkA_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_pk2pkA);
update_allpk2pk(handles,str2double(get(hObject,'string')));
updateAO;
% --- Hardware channel assigned to coil A 
function edit_coilA_Callback(hObject, eventdata, handles)
val = str2num(get(hObject,'string'));
if val < 1 | val > 6
    errordlg('Error: Allowed values for coilA channel are 1 to 6');
    set(hObject, 'string','1'); %set to default value
elseif val == str2num(get(handles.edit_coilB,'string'))
    errordlg('Error: CoilA channel can not be same as CoilB channel');
    set(hObject, 'string','1'); %set to default value
elseif val == str2num(get(handles.edit_coilC,'string'))
    errordlg('Error: CoilA channel can not be same as CoilC channel');
    set(hObject, 'string','1'); %set to default value
end
   
% --- Coil B settings%------------------------------------------
% --- Peak To Peak amplitude in volts
function slider_pk2pkB_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.1
update_allpk2pk(handles,val);
updateAO;
function edit_pk2pkB_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_pk2pkB);
update_allpk2pk(handles,str2double(get(hObject,'string')));
updateAO;
% --- Hardware channel assigned to coil B 
function edit_coilB_Callback(hObject, eventdata, handles)
val = str2num(get(hObject,'string'));
if val < 1 | val > 6
    errogdlg('Error: Allowed values for coilB channel are 1 to 6');
    set(hObject, 'string','3'); %set to default value
elseif val == str2num(get(handles.edit_coilA,'string'))
    errordlg('Error: CoilB channel can not be same as CoilA channel');
    set(hObject, 'string','3'); %set to default value
elseif val == str2num(get(handles.edit_coilC,'string'))
    errordlg('Error: CoilB channel can not be same as CoilC channel');
    set(hObject, 'string','3'); %set to default value
end

% --- Coil C settings%------------------------------------------
% --- Peak To Peak amplitude in volts
function slider_pk2pkC_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.1
update_allpk2pk(handles,val);
updateAO;
function edit_pk2pkC_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_pk2pkC);
update_allpk2pk(handles,str2double(get(hObject,'string')));
updateAO;
% --- Hardware channel assigned to coil C 
function edit_coilC_Callback(hObject, eventdata, handles)
val = str2num(get(hObject,'string'));
if val < 1 | val > 6
    errogdlg('Error: Allowed values for coilC channel are 1 to 6');
    set(hObject, 'string','3'); %set to default value
elseif val == str2num(get(handles.edit_coilA,'string'))
    errordlg('Error: CoilC channel can not be same as CoilA channel');
    set(hObject, 'string','3'); %set to default value
elseif val == str2num(get(handles.edit_coilB,'string'))
    errordlg('Error: CoilC channel can not be same as CoilB channel');
    set(hObject, 'string','3'); %set to default value
end

%-------------------------------------------------------------------
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
%-------------------------------------------------------------------
function update_allpk2pk(handles,val)

set(handles.slider_pk2pkA,'value',val);
set(handles.slider_pk2pkB,'value',val);
set(handles.slider_pk2pkC,'value',val);
set(handles.edit_pk2pkA,'string',num2str(val));
set(handles.edit_pk2pkB,'string',num2str(val));
set(handles.edit_pk2pkC,'string',num2str(val));

function updateAO(varargin)%does nothing at this point
return

%##########################################################################
%#########  EVERYTHING BELOW IS THE CREATE FUNCTION. DONT PUT   ###########
%#########          ACTUAL CODE BEYOND THIS POINT.              ###########
%##########################################################################

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
function edit_coilC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_coilC (see GCBO)
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
function edit_pk2pkB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pk2pkB (see GCBO)
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
function slider_pk2pkC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_pk2pkC (see GCBO)
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
function edit_pk2pkC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pk2pkC (see GCBO)
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
function slider_pk2pkB_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_pk2pkB (see GCBO)
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
function slider_pk2pkA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_pk2pkA (see GCBO)
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
% function slider_period_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to slider_period (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: slider controls usually have a light gray background, change
% %       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
% usewhitebg = 1;
% if usewhitebg
%     set(hObject,'BackgroundColor',[.9 .9 .9]);
% else
%     set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
% end
% --- Executes during object creation, after setting all properties.
function edit_pk2pkA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_pk2pkA (see GCBO)
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





