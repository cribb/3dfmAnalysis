function varargout = MCLfungenGUI(varargin)
% MCLFUNGENGUI M-file for MCLfungenGUI.fig
%      MCLFUNGENGUI, by itself, creates a new MCLFUNGENGUI or raises the existing
%      singleton*.
%
%      H = MCLFUNGENGUI returns the handle to a new MCLFUNGENGUI or the handle to
%      the existing singleton*.
%
%      MCLFUNGENGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MCLFUNGENGUI.M with the given input arguments.
%
%      MCLFUNGENGUI('Property','Value',...) creates a new MCLFUNGENGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MCLfungenGUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MCLfungenGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MCLfungenGUI

% Last Modified by GUIDE v2.5 24-Nov-2003 14:42:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MCLfungenGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MCLfungenGUI_OutputFcn, ...
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



% --- Executes just before MCLfungenGUI is made visible.
function MCLfungenGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MCLfungenGUI (see VARARGIN)

% Choose default command line output for MCLfungenGUI
handles.output = hObject;

% UIWAIT makes MCLfungenGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

    % Initialize some variables here.
    handles.SINE = 1;    
    handles.CUSTOM = 2;  
    handles.NONE = 3;    
    handles.custom_waveform = 0;

    % Update handles structure
    guidata(hObject, handles);
    
    % Initializes Pulnix Camera
 %%%%!C:\EDT\pdv\initcam -v -u 0 -f C:\EDT\pdv\camera_config\ptm6710.cfg

% --- Outputs from this function are returned to the command line.
function varargout = MCLfungenGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Get default command line output from handles structure
	varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function popupWaveform_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupWaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


% --- Executes on selection change in popupWaveform.
function popupWaveform_Callback(hObject, eventdata, handles)
% hObject    handle to popupWaveform (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: contents = get(hObject,'String') returns popupWaveform contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from popupWaveform
	switch get(hObject, 'Value')
        case handles.CUSTOM
            set(handles.popupWorkspace, 'Enable', 'On');
            set(handles.txtWorkspace,'Enable', 'On');
        otherwise
            set(handles.popupWorkspace, 'Enable', 'Off');
            set(handles.txtWorkspace,'Enable', 'Off');
    end
    
    handles.selection = 0;
    guidata(hObject, handles);
    
    setup_waveform(hObject, eventdata, handles);

% --- Executes on button press in checkLinkAxes.
function checkLinkAxes_Callback(hObject, eventdata, handles)
% hObject    handle to checkLinkAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of checkLinkAxes
    if get(hObject, 'Value')
        set(handles.radioXaxis, 'Enable', 'Off');
        set(handles.radioYaxis, 'Enable', 'Off');
        set(handles.radioZaxis, 'Enable', 'Off');
    else
        set(handles.radioXaxis, 'Enable', 'On');
        set(handles.radioYaxis, 'Enable', 'On');
        set(handles.radioZaxis, 'Enable', 'On');
    end        

    
% --- Executes on button press in radioXaxis.
function radioXaxis_Callback(hObject, eventdata, handles)
% hObject    handle to radioXaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of radioXaxis
    if get(hObject, 'Value')
        set(handles.radioYaxis, 'Value', 0);
        set(handles.radioZaxis, 'Value', 0);
        
        handles.CurrentPlot = 1;
        guidata(hObject, handles);
        
    end

    
% --- Executes on button press in radioYaxis.
function radioYaxis_Callback(hObject, eventdata, handles)
% hObject    handle to radioYaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of radioYaxis
    if get(hObject, 'Value')
        set(handles.radioXaxis, 'Value', 0);
        set(handles.radioZaxis, 'Value', 0);
        
        handles.CurrentPlot = 2;
        guidata(hObject, handles);

    end
  
    
% --- Executes on button press in radioZaxis.
function radioZaxis_Callback(hObject, eventdata, handles)
% hObject    handle to radioZaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of radioZaxis
    if get(hObject, 'Value')
        set(handles.radioXaxis, 'Value', 0);
        set(handles.radioYaxis, 'Value', 0);
        
        handles.CurrentPlot = 3;
        guidata(hObject, handles);
        
        setup_waveform(hObject, eventdata, handles);
    end



% --- Executes during object creation, after setting all properties.
function popupWorkspace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: popupmenu controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end
	
    % Set the string for the Workspace pop-up equal to the variables found
    % in the 'base' workspace.
	vars = evalin('base','who');
	set(hObject,'String',vars);
    

% --- Executes on selection change in popupWorkspace.
function popupWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to popupWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: contents = get(hObject,'String') returns popupWorkspace contents as cell array
	%        contents{get(hObject,'Value')} returns selected item from popupWorkspace
	 vars = get(hObject, 'String');
     index= get(hObject, 'Value');

     custom_waveform = evalin('base',vars{index});
     [rows cols] = size(custom_waveform);
     
     if cols ~= 2
         errordlg(['Custom waveforms MUST have two columns.  ' ...
                   'Column #1 is the timestamp while column #2 is the waveform value.  ' ...
                   'Custom waveform will be set to zero.'], ...
                   'Error choosing waveform type.', ...
                   'modal');
               
         custom_waveform = [0 0];
     end
     
     handles.custom_waveform = custom_waveform;
     handles.selection = 1;
     guidata(hObject, handles);
     
     setup_waveform(hObject, eventdata, handles);

     
% --- Executes during object creation, after setting all properties.
function editFrequency_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function editFrequency_Callback(hObject, eventdata, handles)
% hObject    handle to editFrequency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of editFrequency as text
	%        str2double(get(hObject,'String')) returns contents of editFrequency as a double
    setup_waveform(hObject, eventdata, handles);

    
% --- Executes during object creation, after setting all properties.
function editAmplitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function editAmplitude_Callback(hObject, eventdata, handles)
% hObject    handle to editAmplitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of editAmplitude as text
	%        str2double(get(hObject,'String')) returns contents of editAmplitude as a double
    setup_waveform(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function editOffset_Callback(hObject, eventdata, handles)
% hObject    handle to editOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of editOffset as text
	%        str2double(get(hObject,'String')) returns contents of editOffset as a double

    setup_waveform(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function editDuration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function editDuration_Callback(hObject, eventdata, handles)
% hObject    handle to editDuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of editDuration as text
	%        str2double(get(hObject,'String')) returns contents of editDuration as a double
    Duration  = handles.Duration;
    StageFreq = handles.StageFreq;
    
    handles.time      = [1/StageFreq : 1/StageFreq : Duration];
    handles.waveform  = zeros(length(handles.time), 3);
    guidata(hObject, handles);
    
    setup_waveform(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function editStageFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStageFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function editStageFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editStageFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of editStageFreq as text
	%        str2double(get(hObject,'String')) returns contents of editStageFreq as a double
	Duration  = str2num(get(handles.editDuration, 'String'));
	StageFreq = str2num(get(handles.editStageFreq, 'String'));

    handles.time      = 1/StageFreq : 1/StageFreq : Duration;
    handles.waveform  = zeros(length(handles.time), 3);
    guidata(hObject, handles);
    
    setup_waveform(hObject, eventdata, handles);


% --- Executes on button press in btnConfigStage.
function btnConfigStage_Callback(hObject, eventdata, handles)
% hObject    handle to btnConfigStage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function editSaveDataFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSaveDataFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end



function editSaveDataFilename_Callback(hObject, eventdata, handles)
% hObject    handle to editSaveDataFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of editSaveDataFilename as text
	%        str2double(get(hObject,'String')) returns contents of editSaveDataFilename as a double


% --- Executes on button press in btnAttach2Axis.
function btnAttach2Axis_Callback(hObject, eventdata, handles)
% hObject    handle to btnAttach2Axis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    setup_waveform(hObject, eventdata, handles);
    
    
% --- Executes on button press in btnSendSignals.
function btnSendSignals_Callback(hObject, eventdata, handles)
% hObject    handle to btnSendSignals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    if get(handles.checkboxUsePulnix, 'Value')
        !C:\nsrg\Bin\EDT_DirectShow_Camera_Driver_v01.03\edt_raw_video_store.exe -N 300 -l 1200 -~ -b D:\jcribb\data\pulnix_120fps_swap_10sec.raw &
    end

    
% --- Executes on button press in checkboxUsePulnix.
function checkboxUsePulnix_Callback(hObject, eventdata, handles)
% hObject    handle to checkboxUsePulnix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of checkboxUsePulnix


    
% --- Subfunction
function setup_waveform(hObject, eventdata, handles)
% hObject    handle to btnSendSignals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	Amplitude = str2num(get(handles.editAmplitude,'String'));
    Frequency = str2num(get(handles.editFrequency, 'String'));
	Offset    = str2num(get(handles.editOffset, 'String'));
	Duration  = str2num(get(handles.editDuration, 'String'));
	StageFreq = str2num(get(handles.editStageFreq, 'String'));
	DataFile  =         get(handles.editSaveDataFilename, 'String');
    WaveType  =         get(handles.popupWaveform,'Value');
    time      = handles.time;
    
    switch WaveType
        case handles.SINE
            wavename = 'Sine';
            waveform = [Amplitude * sin(2*pi*Frequency*time) + Offset]';
            
            plot(time, waveform);

        case handles.CUSTOM
            wavename = 'Custom';
            
            if handles.selection
                [time, waveform] = condition_waveform(hObject, eventdata, handles);
                plot(time, waveform);
            end
            
        case handles.NONE
            wavename = 'None';

            time     = [0 1];
            waveform = [0 0];

            plot(time, waveform);

        otherwise
            wavename = 'None';
            
            time     = [0 1];
            waveform = [0 0];

            plot(time, waveform);
    end
    
    handles.time = time;
    handles.outputWaveform(:, handles.CurrentPlot) = waveform;
    guidata(hObject, handles);
    
    %size(waveform)
    fprintf('%s \t %d \t %d \t %d \t %d \t %d \n', wavename, Amplitude, Frequency, Offset, Duration, StageFreq);


% --- Subfunction
function [time, waveform] = condition_waveform(hObject, eventdata, handles)
% hObject    handle to btnSendSignals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	old_waveform = handles.custom_waveform;
    
    [rows cols] = size(old_waveform);
    
    time  = old_waveform(:,1);
    value = old_waveform(:,2);
    
%     % retrofit the time_steps to 1 second.
%     time = time / max(time);
%     
%     % retrofit the amplitude to 1 micron.
%     value = value / max(abs(value));
%     
%     new_waveform = repmat(value, frequency, 1);
    
        



