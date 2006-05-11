function varargout = threePoleFreqSweep(varargin)
% 3DFM GUI tool
% This tool is used for performing three pole frequency sweep experiments. 
% In theory, the bead is pulled in circles (2D sinusoids) at the
% frequencies input by user.
% Last modified: 05/11/06   kvdesai
% Created: July 2005    kvdesai
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

% Last Modified by GUIDE v2.5 11-May-2006 11:32:55

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
version_str = '2.2';
% Update handles structure
guidata(hObject, handles);
clc;
disp(['Welcome to Three Pole Frequency Sweep Generator ', version_str]);
button_defaults_Callback(handles.button_defaults, [], handles)
grabDACboard;
handle_sweep_param_change(handles);
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

% --- gather the parameters for frequency sweep.
function param = read_settings(handles);
coilConfig = get(handles.menu_coilConfig,'value');
switch coilConfig       % Hardware channel# = coil# -1
    case 1 % Coils# 1 3 5
        param.chA = 0; param.chB = 2; param.chC = 4;
    case 2 % Coils# 2 4 6
        param.chA = 1; param.chB = 3; param.chC = 5;
    otherwise
        promptuser('Unrecognized coil configuration. Tell some programmer to fix.', handles,1);
end
param.chFlag = 7 - 1; %Channel 7 output is being read into tracking ADC, so put the sum of squares on this
param.amp = get(handles.slider_amp,'value');

param.nCycles = str2double(get(handles.edit_nCycles,'string'));
param.dwell = str2double(get(handles.edit_dwell,'string'));

param.docontrol = get(handles.check_control,'value');
param.fcont = str2double(get(handles.edit_controlFreq,'string'));

fmin = str2double(get(handles.edit_freqMin,'string'));
fmax = str2double(get(handles.edit_freqMax,'string'));
fstep = str2double(get(handles.edit_freqStep,'string'));
param.fvec = fmin:fstep:fmax;

param.Nrepeat = 0; % 0 times repeat the frquency sweep. Add edit-box on UI in future if needed.

%PHASE HARD CODED. For sinusoidal pulling (in 2D) three coil 
% excitations should be separated by phase of 120 degree.
param.phaseA = 0;%in radians
param.phaseB = 2*pi/3;
param.phaseC = 4*pi/3;

%------------------------------------------------------------------------
function promptuser(str,handles,dodisp)
set(handles.text_message,'string',str);
if dodisp
    disp(str);
end

%----------------Get access of the DAC board that drives magnets---------
function grabDACboard(varargin)
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

% --- Executes on button press in button_synthesize.
function button_synthesize_Callback(hObject, eventdata, handles)
% This function does three tasks
% 1. Sets up the DACboard and makes it ready to go
% 2. synthesizes the drive signal
% 3. Enables the 'GO' button.
global AO
p = read_settings(handles);
AOchannels = [p.chA, p.chB, p.chC, p.chFlag];
if(~exist('AO'))
    grabDACboard;
end

if ~isempty(get(AO,'channel'))
    delete(AO.Channel(:));
end
Ochan = addchannel(AO, AOchannels);
set(Ochan, 'OutputRange', [-10 10]);
desired_sampleRate = max([1000,max(p.fvec)*10]);
   % we don't wanna sample too higher rate and eat memory
set(AO, 'TriggerType', 'Manual'); % use hardware manual trigger 

p.srate = setverify(AO, 'SampleRate', desired_sampleRate); 
promptuser('Now synthesizing the drive signal...',handles,0);
outData = synthesizer(p);
set(AO,'RepeatOutput',p.Nrepeat); 
% Now store the data on to the UserData space of the Go button
set(handles.button_go,'UserData',outData); clear outData; pack;
% Now enable the 'GO' button
set(handles.button_go,'Enable','On');
promptuser('Press GO to start frequency sweep',handles,0);
% Now store the parameters in UserData so that everyone can see it
set(hObject,'UserData',p);

% --- Executes on button press in button_go ---------------------------
function button_go_Callback(hObject, eventdata, handles)
global AO version_str

p = get(handles.button_synthesize,'UserData');
outData = get(hObject,'UserData');
putdata(AO, outData); % queue the data

start(AO); % ready but not triggered
%-----------   THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
trigger(AO); % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
tim = clock; % THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
%----------    THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
data.info.Name = datestr(tim,30);
data.info.version = version_str;
promptuser('Started frquency sweep...',handles,1);
data.info.exactSec = tim(6);
if(get(handles.check_logData,'value'))
    data.outData = outData;
end
%-----------            THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
wait(AO,2*str2double(get(handles.text_estimate,'string')));%  
tend = clock;%          THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
%-----------            THIS TWO STATEMENTS SHOULD BE AS CLOSE AS POSSIBLE
promptuser('Completed last frequency sweep...',handles,1);

data.info.pole_geometry = 'ThreePolesInPlane';
data.info.param = p;
data.info.tend = datestr(tend,30);
data.info.endSec = tend(6);
savepath = pwd;
save(fullfile(savepath,[data.info.Name,'_freqSweep.mat']),'data');
promptuser(['Logfile saved at ', savepath],handles,1);

% --------------------- Synthesize the drive signal -------
function d = synthesizer(p)
persistent lastp rawA rawB rawC

partp = rmfield(p,'amp');
% Don't resynthesize if none of the parameters (except amplitude) has
% changed. Saves valuable seconds.
if ~isequal(lastp, partp);
    rawA = [];    rawB = []; rawC = [];
    for c = 1:length(p.fvec)
        % how long should we do this frequency to apply Ncycles
        tt = 0:1/p.srate:(p.nCycles/p.fvec(c));
        tgap = zeros(1,ceil(p.srate*p.dwell/p.fvec(c)));
        tsinebase = sin(2*pi*p.fvec(c)*tt); %zero phase sine
        % Now shift the sinebase back/forth to apply appropriate phase.
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

        % Made vectors for this particular frequency, now store it in the cell
        % array that has excitation vectors for each frequency. Matlab profiler
        % says that array catenation is extremely time consuming. So instead of
        % appending each excitation vector as it is computed, we will catenate all
        % excitation vectors at once. Also interleave the control frequency cycles
        % if we are told to do so
        if(p.docontrol == 0)
            app.A{c} = [tsineA, tgap];
            app.B{c} = [tsineB, tgap];
            app.C{c} = [tsineC, tgap];
        else        %interleave control frequency betwn each test freq
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

            app.A{c} = [tsineA, tgap, csineA, cgap];
            app.B{c} = [tsineB, tgap, csineB, cgap];
            app.C{c} = [tsineC, tgap, csineC, cgap];
        end
    end
    rawA = horzcat(app.A{:});
    rawB = horzcat(app.B{:});
    rawC = horzcat(app.C{:});
end

coilA = p.amp*rawA;
coilB = p.amp*rawB;
coilC = p.amp*rawC;

dFlag = 0.05*(coilA.^2 + coilB.^2 + coilC.^2); % Magnet-synchronizer signal

d = [coilA', coilB', coilC', dFlag'];
d(end,:) = [0 0 0 0];
lastp = partp;
% --- Executes on button press in button_abort.
function button_abort_Callback(hObject, eventdata, handles)
% hObject    handle to button_abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global AO
if (exist('AO') & ~isempty(AO))
    if(strcmpi(get(AO,'Running'),'On'))
        stop(AO);
        promptuser('Frequency sweep was aborted',handles,1);
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
    delete(AO);
    clear AO;   
end
daqreset;
close(handles.threePoleFreqSweep);

% --- Executes on button press in button_defaults.
function button_defaults_Callback(hObject, eventdata, handles)

default.fmin = 10;
default.fstep = 5;
default.fmax = 2000;
default.fcont = 125;
default.nCycles = 10;
default.dwell = 10;

set(handles.edit_freqMin,'string',num2str(default.fmin));
set(handles.edit_freqMax,'string',num2str(default.fmax));
set(handles.edit_freqStep,'string',num2str(default.fstep));
set(handles.edit_controlFreq,'string',num2str(default.fcont));
set(handles.edit_nCycles,'string',num2str(default.nCycles));
set(handles.edit_dwell,'string',num2str(default.dwell));
set(handles.check_control,'value',0); % Do not interleave any control freq

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

% --- Excitation amplitude in volts
function slider_amp_Callback(hObject, eventdata, handles)
user_input = get(hObject,'value');
val = 0.1*round(user_input*10);%the value can be only in multiples of 0.1
set(handles.edit_amp,'string',num2str(val));

function edit_amp_Callback(hObject, eventdata, handles)
check_editval(hObject, handles.slider_amp);

% ***************    SWEEP PARAMETERS PANEL       *********************
%------------------------------------------------------------------
function edit_controlFreq_Callback(hObject, eventdata, handles)
set(hObject,'string',num2str(floor(str2double(get(hObject,'string')))));
handle_sweep_param_change(handles);
%------------------------------------------------------------------
function edit_nCycles_Callback(hObject, eventdata, handles)
set(hObject,'string',num2str(floor(str2double(get(hObject,'string')))));
handle_sweep_param_change(handles);

%-------------------------------------------------------------------
function edit_freqStep_Callback(hObject, eventdata, handles)
finest = 0.1;
if(abs(str2double(get(hObject,'string'))) < finest)
    errordlg(['Can''t do that fine resolution man...',num2str(finest),' is the best I can do']);
    set(hObject,'string',num2str(finest));
end
handle_sweep_param_change(handles);
%-------------------------------------------------------------------
function edit_freqMax_Callback(hObject, eventdata, handles)
maxf = 5000;
if(str2double(get(hObject,'string')) > maxf)
    errordlg(['Can''t do that high frequency man...',num2str(maxf),' is the best I can do']);
    set(hObject,'string',num2str(maxf));
end
handle_sweep_param_change(handles);
%-------------------------------------------------------------------
function edit_freqMin_Callback(hObject, eventdata, handles)
minf = 0.01;
if(str2double(get(hObject,'string')) < minf)
    errordlg(['Can''t do that low frequency man...',num2str(minf),' is the best I can do']);
    set(hObject,'string',num2str(minf));
end
handle_sweep_param_change(handles);
%-------------------------------------------------------------------
function edit_dwell_Callback(hObject, eventdata, handles)
set(hObject,'string',num2str(floor(str2double(get(hObject,'string')))));
handle_sweep_param_change(handles);

% --- Executes on button press in check_control.
function check_control_Callback(hObject, eventdata, handles)
handle_sweep_param_change(handles);

%-------------------------------------------------------------------
function handle_sweep_param_change(handles)
% One or more of the sweep parameters have changed, so the drive signal
% must be re-synthesized before sweep can be executed. So, disable 'GO' button
set(handles.button_go,'Enable','Off');
% Now reestimate the time for sweep
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
set(handles.button_go,'UserData',[]); % free old memory
promptuser('Re-synthesize the drive signal and then press GO', handles,0);
% ***************    SWEEP PARAMETERS PANEL COMPLETE    *******************

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
function updateAO(varargin)%does nothing at this point
return

%##########################################################################
%#########  EVERYTHING BELOW IS THE CREATE FUNCTION. DONT PUT   ###########
%#########          ACTUAL CODE BEYOND THIS POINT.              ###########
%##########################################################################

% --- Executes during object creation, after setting all properties.
function slider_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_amp (see GCBO)
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
function edit_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_amp (see GCBO)
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

% --- Executes on selection change in menu_coilConfig.
function menu_coilConfig_Callback(hObject, eventdata, handles)
% hObject    handle to menu_coilConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menu_coilConfig contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_coilConfig


% --- Executes during object creation, after setting all properties.
function menu_coilConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_coilConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




