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

% Last Modified by GUIDE v2.5 05-Oct-2005 13:49:44

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
global AO version_str;
version_str = '2.1';
% Update handles structure
guidata(hObject, handles);
clc;
disp(['Welcome to Three Pole Frequency Sweep Generator ', version_str]);
button_defaults_Callback(handles.button_defaults, [], handles)
setupDACboard;
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

function param = read_settings(handles);

%On Hercules, Hardware channel# = coil# -1
param.chA = str2double(get(handles.edit_coilA,'string'))-1;
param.chB = str2double(get(handles.edit_coilB,'string'))-1;
param.chC = str2double(get(handles.edit_coilC,'string'))-1;
param.chFlag = 7 - 1; %Channel 7 output is being read into tracking ADC, so put the sum of squares on this
param.ampA = 0.5*get(handles.slider_pk2pkA,'value');
param.ampB = 0.5*get(handles.slider_pk2pkB,'value');
param.ampC = 0.5*get(handles.slider_pk2pkC,'value');

param.dwell = str2double(get(handles.edit_dwell,'string'));
param.nCycles = str2double(get(handles.edit_nCycles,'string'));
param.fcont = str2double(get(handles.edit_controlFreq,'string'));
param.Nrepeat = 0; % 0 times repeat the frquency sweep. Add edit-box on UI in future if needed.
%For sinusoidal pulling (in 2D) three coil excitations should be separated
%by phase of 120 degree. HARD CODED.
param.phaseA = 0;%in radians
param.phaseB = 2*pi/3;
param.phaseC = 4*pi/3;
fmin = str2double(get(handles.edit_freqMin,'string'));
fmax = str2double(get(handles.edit_freqMax,'string'));
fstep = str2double(get(handles.edit_freqStep,'string'));
param.fvec = fmin:fstep:fmax;
param.docontrol = get(handles.check_control,'value');
%------------------------------------------------------------------------
function promptuser(str,handles)
set(handles.text_message,'string',str);
disp(str);
function setupDACboard(varargin)
global AO
AOname = 'PCI-6713';
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
AO = analogoutput('nidaq', AOid);

% --- Executes on button press in button_start ---------------------------
function button_start_Callback(hObject, eventdata, handles)
% hObject    handle to button_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global AO version_str
p = read_settings(handles);
AOchannels = [p.chA, p.chB, p.chC, p.chFlag];
if(~exist('AO'))
    setupDACboard;
end

if ~isempty(get(AO,'channel'))
    delete(AO.Channel(:));
end
Ochan = addchannel(AO, AOchannels);
set(Ochan, 'OutputRange', [-10 10]);
desired_sampleRate = max([1000,max(p.fvec)*10]);
   % we don't wanna sample too higher rate and eat memory
set(AO, 'TriggerType', 'Manual'); % use hardware manual trigger 

p.srate = setverify(AO, 'SampleRate', desired_sampleRate); %default sample rate 
promptuser('Now synthesizing the drive signal',handles);
outData = synthesizer(p);
% Now fill the output buffer but do not start sending the data yet
set(AO,'RepeatOutput',p.Nrepeat); 
putdata(AO, outData); % send the data
start(AO); % ready but not triggered
%-----------   THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
trigger(AO); % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
tim = clock; % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
%----------    THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
data.info.Name = datestr(tim,30);
data.info.version = version_str;
% disp(['Magnet Operation STARTED::',data.info.Name]);
promptuser('Started frquency sweep...',handles);
data.info.exactSec = tim(6);
if(get(handles.check_logData,'value'))
    data.outData = outData;
end
%-----------            THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
waittilstop(AO,2*length(outData)/p.srate);%   THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
tend = clock;%          THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
%-----------            THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
promptuser('Completed last frequency sweep...',handles);

data.info.pole_geometry = 'ThreePolesInPlane';
data.info.param = p;
data.info.tend = datestr(tend,30);
data.info.endSec = tend(6);
save([data.info.Name,'_freqSweep.mat'],'data');
% --------------------- Synthesize the drive signal -------
function d = synthesizer(p)
rawA = [];    rawB = []; rawC = [];
for c = 1:length(p.fvec)
    % how long should we do this frequency to apply Ncycles
    tt = 0:1/p.srate:(p.nCycles/p.fvec(c));        
    tgap = zeros(1,ceil(p.srate*p.dwell/p.fvec(c)));        
    tsinebase = sin(2*pi*p.fvec(c)*tt); %zero phase sine
    % Now shift the sinebase up/down to apply appropriate phase.
    % doing this way ensures that all sinewaves on all 3 coils
    % start and stop at exactly zero. Desired for Amplifier.
    % Pad zeros if needed, to make all vectors equal length.
    N_percycle = ceil(p.srate/p.fvec(c));
    preA = ceil(N_percycle*p.phaseA/(2*pi)); postA = N_percycle - preA;
    preB = ceil(N_percycle*p.phaseB/(2*pi)); postB = N_percycle - preB;
    preC = ceil(N_percycle*p.phaseC/(2*pi)); postC = N_percycle - preC;
    tsineA = [zeros(1,preA),tsinebase,zeros(1,postA)];
    tsineB = [zeros(1,preB),tsinebase,zeros(1,postB)];
    tsineC = [zeros(1,preC),tsinebase,zeros(1,postC)];
    % Made vectors for this particular frequency, now append it to the 
    % main excitation vector. Also interleave the control frequency cycles 
    % if we are told to do so
    if(p.docontrol == 0)  
        rawA = [rawA, tsineA, tgap];
        rawB = [rawB, tsineB, tgap];
        rawC = [rawC, tsineC, tgap];        
    else        %control frquency betwn each test freq          
        ct = 0:1/p.srate:(p.nCycles/p.fcont);
        cgap = zeros(1,ceil(p.srate*p.dwell/p.fcont));
        csinebase = sin(2*pi*p.fcont*ct); 
        cN_percycle = p.srate/p.fcont;
        cpreA = ceil(cN_percycle*p.phaseA/(2*pi)); cpostA = cN_percycle - cpreA;
        cpreB = ceil(cN_percycle*p.phaseB/(2*pi)); cpostB = cN_percycle - cpreB;
        cpreC = ceil(cN_percycle*p.phaseC/(2*pi)); cpostC = cN_percycle - cpreC;
        csineA = [zeros(1,cpreA),csinebase,zeros(1,cpostA)];
        csineB = [zeros(1,cpreB),csinebase,zeros(1,cpostB)];
        csineC = [zeros(1,cpreC),csinebase,zeros(1,cpostC)];
        
        rawA = [rawA, tsineA, tgap, csineA, cgap]; 
        rawB = [rawB, tsineB, tgap, csineB, cgap];
        rawC = [rawC, tsineC, tgap, csineC, cgap];        
    end
end
coilA = p.ampA*rawA;
coilB = p.ampB*rawB;
coilC = p.ampC*rawC;
dFlag = 0.01*(coilA.^2 + coilB.^2 + coilC.^2);
d = [[coilA';0.0], [coilB';0.0], [coilC';0.0], [dFlag';0.0]];
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
    putsample(AO,zeros(1,length(get(AO,'Channel'))));
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
    if(length(get(AO,'channel')))
        putsample(AO,zeros(1,length(get(AO,'Channel'))));
    end
    clear AO
    delete AO
end
daqreset;
close(handles.threePoleFreqSweep);

% --- Executes on button press in button_defaults.
function button_defaults_Callback(hObject, eventdata, handles)

default.fmin = 1;
default.fmax = 100;
default.fstep = 5;
default.fcont = 125;%it is usually desirable that first 3 harmonics of fcont are not in fvec
default.nCycles = 10;
default.dwell = 10;

set(handles.edit_freqMin,'string',num2str(default.fmin));
set(handles.edit_freqMax,'string',num2str(default.fmax));
set(handles.edit_freqStep,'string',num2str(default.fstep));
set(handles.edit_controlFreq,'string',num2str(default.fcont));
set(handles.edit_nCycles,'string',num2str(default.nCycles));
set(handles.edit_dwell,'string',num2str(default.dwell));

%-----------------OBSOLETE BUT COOL---CAN USE SOMEWHERE ELSE-----------------------
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
function edit_controlFreq_Callback(hObject, eventdata, handles)
set(hObject,'string',num2str(floor(str2double(get(hObject,'string')))));
update_estimated_time(handles);
%------------------------------------------------------------------
function edit_nCycles_Callback(hObject, eventdata, handles)
set(hObject,'string',num2str(floor(str2double(get(hObject,'string')))));
update_estimated_time(handles);
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
function edit_freqStep_Callback(hObject, eventdata, handles)
finest = 0.1;
if(abs(str2double(get(hObject,'string'))) < finest)
    errordlg(['Can''t do that fine resolution man...',num2str(finest),' is the best I can do']);
    set(hObject,'string',num2str(finest));
end
update_estimated_time(handles);
%-------------------------------------------------------------------
function edit_freqMax_Callback(hObject, eventdata, handles)
maxf = 5000;
if(str2double(get(hObject,'string')) > maxf)
    errordlg(['Can''t do that high frequency man...',num2str(maxf),' is the best I can do']);
    set(hObject,'string',num2str(maxf));
end
update_estimated_time(handles);
%-------------------------------------------------------------------
function edit_freqMin_Callback(hObject, eventdata, handles)
minf = 0.01;
if(str2double(get(hObject,'string')) < minf)
    errordlg(['Can''t do that low frequency man...',num2str(minf),' is the best I can do']);
    set(hObject,'string',num2str(minf));
end
update_estimated_time(handles);
%-------------------------------------------------------------------
function edit_dwell_Callback(hObject, eventdata, handles)
set(hObject,'string',num2str(floor(str2double(get(hObject,'string')))));
update_estimated_time(handles);
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
%-------------------------------------------------------------------
function update_estimated_time(handles)
p = read_settings(handles);
span = sum(1./p.fvec)*(p.nCycles+1 + p.dwell);
%                               1 added since the 1 cycle is added for
%                               phase adjustment
if (p.docontrol == 1)
    %span would be double since control frequency would be interleaved with
    %dwell
    span = 2*span;
end
set(handles.text_estimate,'string',num2str(ceil(span)));
%-------------------------------------------------------------------
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
function edit_nCycles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_nCycles (see GCBO)
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
function edit_freqMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_freqMin (see GCBO)
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
function edit_dwell_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_dwell (see GCBO)
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
function edit_freqStep_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_freqStep (see GCBO)
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
function edit_freqMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_freqMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on button press in check_logData.
function check_logData_Callback(hObject, eventdata, handles)
% hObject    handle to check_logData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_logData


% --- Executes on button press in check_control.
function check_control_Callback(hObject, eventdata, handles)
% hObject    handle to check_control (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_estimated_time(handles);
% Hint: get(hObject,'Value') returns toggle state of check_control


