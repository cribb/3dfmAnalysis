function varargout = varforcegui(varargin)
% VARFORCEGUI M-file for varforcegui.fig
%      VARFORCEGUI, by itself, creates a new VARFORCEGUI or raises the existing
%      singleton*.
%
%      H = VARFORCEGUI returns the handle to a new VARFORCEGUI or the handle to
%      the existing singleton*.
%
%      VARFORCEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VARFORCEGUI.M with the given input arguments.
%
%      VARFORCEGUI('Property','Value',...) creates a new VARFORCEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before varforcegui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to varforcegui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above lbl_calib_visc to modify the response to help varforcegui

% Last Modified by GUIDE v2.5 13-Jun-2006 10:15:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @varforcegui_OpeningFcn, ...
                   'gui_OutputFcn',  @varforcegui_OutputFcn, ...
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


% --- Executes just before varforcegui is made visible.
function varforcegui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to varforcegui (see VARARGIN)

    % Choose default command line output for varforcegui
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes varforcegui wait for user response (see UIRESUME)
    % uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = varforcegui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;



function edit_calibrator_viscosity_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_calibrator_viscosity_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_maxforce_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_maxforce_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_daqboard.
function popupmenu_daqboard_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_daqboard_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in pushbutton_confirmDAq.
function pushbutton_confirmDAq_Callback(hObject, eventdata, handles)


function edit_daq_frequency_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_daq_frequency_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function lbl_duration_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function lbl_duration_CreateFcn(hObject, eventdata, handles)

% --- Executes on button press in pushbutton_autopulse.
function pushbutton_autopulse_Callback(hObject, eventdata, handles)

% --- Executes on selection change in listbox_voltages.
function listbox_voltages_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox_voltages_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in listbox_pulsewidths.
function listbox_pulsewidths_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox_pulsewidths_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)

    DAQid = get(handles.popupmenu_daqboard, 'String');
    DAQid_idx = get(handles.popupmenu_daqboard, 'Value'); 
    myDAQid = char(DAQid(DAQid_idx));
    
    DAQ_sampling_rate = str2num(get(handles.edit_daq_frequency, 'String'));
    NRepeats = str2num(get(handles.edit_sequences, 'String')) - 1; % 1 sequence means no repeats
    
    pole_geometry = get(handles.popupmenu_geometry, 'String');
    pole_geometry_idx = get(handles.popupmenu_geometry, 'Value');
    my_pole_geometry = char(pole_geometry(pole_geometry_idx));
    
    voltages = str2num(get(handles.edit_voltages, 'String'));
    pulse_widths = str2num(get(handles.edit_pulsewidths, 'String'));

    duration = str2num(get(handles.lbl_duration, 'String'));

    negation = get(handles.popupmenu_negation, 'String');
    negation_idx = get(handles.popupmenu_negation, 'Value');
    my_negation = char(negation(negation_idx));
    
    calibrator_viscosity = str2num(get(handles.edit_calibrator_viscosity, 'String'));
    bead_radius = str2num(get(handles.edit_bead_radius, 'String'));  
    calibum = str2num(get(handles.edit_calibum, 'String'));
    

    [start_time, sent_signal, pulseID, dominant_coil] = ...
                 varforce_drive(myDAQid, ...
                                    DAQ_sampling_rate, ...
                                    NRepeats, ...
                                    my_pole_geometry, ...
                                    voltages, ...
                                    pulse_widths, ...
                                    my_negation);
                                
    logentry('Starting DAC run...');    
    if ~strcmp(myDAQid, 'daqtest')
        pause(duration);
        zerodaq([0 0 0 0 0 0 0 0]);
        logentry('DAC channels are zeroed.');
    end    
    logentry('DAC run is finished.');
    
    if get(handles.checkbox_save_metadata, 'Value')
        filename = get(handles.edit_filename, 'String');
        
        save(filename, 'myDAQid', ...
                       'DAQ_sampling_rate', ...
                       'NRepeats', ...
                       'my_pole_geometry', ...
                       'voltages', ...
                       'pulse_widths', ...
                       'my_negation', ...
                       'start_time', ...
                       'sent_signal', ...
                       'pulseID', ...
                       'calibrator_viscosity', ...
                       'bead_radius', ...
                       'dominant_coil', ...
                       'calibum');
                   
        logentry(['Saving metadata to file: ' filename '.']);

    end                                

% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)
        close(varforcegui);
        
function edit_voltages_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_voltages_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_pulsewidths_Callback(hObject, eventdata, handles)
    duration = sum(str2num(get(handles.edit_pulsewidths, 'String')));
    numSequences = str2num(get(handles.edit_sequences, 'String'));
    set(handles.lbl_duration, 'String', num2str(duration*numSequences));

% --- Executes during object creation, after setting all properties.
function edit_pulsewidths_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_calibrators.
function popupmenu_calibrators_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_calibrators_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_temperature_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_temperature_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_bead_radius_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_bead_radius_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_maxdist_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_maxdist_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_noisefloor_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_noisefloor_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_desiredSNR_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_desiredSNR_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_geometry.
function popupmenu_geometry_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_geometry_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on selection change in popupmenu_negation.
function popupmenu_negation_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_negation_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_sequences_Callback(hObject, eventdata, handles)
    duration = sum(str2num(get(handles.edit_pulsewidths, 'String')));
    numSequences = str2num(get(handles.edit_sequences, 'String'));
    set(handles.lbl_duration, 'String', num2str(duration*numSequences));

% --- Executes during object creation, after setting all properties.
function edit_sequences_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in checkbox_save_metadata.
function checkbox_save_metadata_Callback(hObject, eventdata, handles)

function edit_filename_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% =========================================================================
% Everything below this point are functions related to computation and data
% handling/display, and not the gui (although the handles structure is used).
% =========================================================================

function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'varforcegui: '];
     
     fprintf('%s%s\n', headertext, txt);

   




function edit_calibum_Callback(hObject, eventdata, handles)
% hObject    handle to edit_calibum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_calibum as text
%        str2double(get(hObject,'String')) returns contents of edit_calibum as a double


% --- Executes during object creation, after setting all properties.
function edit_calibum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_calibum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


