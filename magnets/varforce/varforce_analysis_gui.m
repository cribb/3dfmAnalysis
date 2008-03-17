function     varargout = varforce_analysis_gui(varargin)  
% 3DFM function  
% Magnetics/varforce
% last modified 08/01/06 
%
% loads the GUI that analyzes and plots the variable force calibration data
% derived from the varforce experimental protocol for 3dfm (see
% varforcegui)
%
%   varforce_analysis_gui; 
%

% varforce_analysis_gui M-file for varforce_analysis_gui.fig
%      varforce_analysis_gui, by itself, creates a new varforce_analysis_gui or raises the existing
%      singleton*.
%
%      H = varforce_analysis_gui returns the handle to a new varforce_analysis_gui or the handle to
%      the existing singleton*.
%
%      varforce_analysis_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in varforce_analysis_gui.M with the given input arguments.
%
%      varforce_analysis_gui('Property','Value',...) creates a new varforce_analysis_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before varforce_analysis_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to varforce_analysis_gui_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help varforce_analysis_gui

% Last Modified by GUIDE v2.5 30-Aug-2006 14:18:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @varforce_analysis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @varforce_analysis_gui_OutputFcn, ...
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


% --- Executes just before varforce_analysis_gui is made visible.
function varforce_analysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to varforce_analysis_gui (see VARARGIN)

% Choose default command line output for varforce_analysis_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes varforce_analysis_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = varforce_analysis_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popup_calibration_type.
function popup_calibration_type_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popup_calibration_type_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_poleloc_x_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_poleloc_x_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_error_tolerance_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_error_tolerance_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in pushbutton_metafile.
function pushbutton_metafile_Callback(hObject, eventdata, handles)

	warning off MATLAB:deblank:NonStringInput

    try
        [fname, pname] = uigetfile('*.vfd.mat');
    catch
        logentry('No magnet file found. No metadata file loaded.');
        return;
    end
    
    if sum(length(fname), length(pname)) <= 1
        logentry('No magnet file selected. No metadata file loaded.');
        return;
    end        
    
	filename = strcat(pname, fname);
    logentry(['Setting Path to ' pname]);
    cd(pname);

    handles.metafile = (filename);
	guidata(hObject, handles);

    set(handles.edit_metadata, 'String', fname);
    
    logentry(['Loaded metafile, ' fname]);


% --- Executes on button press in pushbutton_tracker.
function pushbutton_tracker_Callback(hObject, eventdata, handles)

	warning off MATLAB:deblank:NonStringInput

    try
        [fname, pname] = uigetfile('*evt.mat');
    catch
        logentry('No magnet file found. No tracker file loaded.');
        return;
    end
    
    if sum(length(fname), length(pname)) <= 1
        logentry('No tracker file selected. No tracker file loaded.');
        return;
    end        
    
	filename = strcat(pname, fname);
    logentry(['Setting Path to ' pname]);
    cd(pname);

    handles.trackfile = (filename);
	guidata(hObject, handles);

    set(handles.edit_trackerfile, 'String', fname);
    
    logentry(['Loaded tracker file, ' fname]);
    logentry(['Setting savefile to default name.']);

    % predict output filename that contains the computed calibration data
    outsfile = strrep(fname, '.mat', '');
    outsfile = [outsfile '.vfc.mat'];
    set(handles.edit_save_filename, 'String', outsfile);
    
    % look for the poleloc.txt file that contains the pole location and try
    % to automatically fill in the desired information
    pfile = dir('poleloc.txt');
    
    if length(pfile) > 0
        poleloc = load('poleloc.txt');
        set(handles.edit_poleloc_x, 'String', num2str(poleloc(1)));
        set(handles.edit_poleloc_y, 'String', num2str(poleloc(2)));
        logentry(['poleloc.txt found.  Setting pole location to: [' num2str(poleloc) '].']);
    else
        logentry('Pole location file (poleloc.txt) not found.');
    end
    
    return;


% --- Executes on button press in checkbox_drift.
function checkbox_drift_Callback(hObject, eventdata, handles)


function edit_buffer_points_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_buffer_points_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_metadata_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_metadata_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_trackerfile_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_trackerfile_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_granularity_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_granularity_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_window_size_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_window_size_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes on button press in checkbox_inst.
function checkbox_inst_Callback(hObject, eventdata, handles)
if get(handles.checkbox_inst, 'Value') == 1
	set(handles.edit_window_size, 'Enable', 'On');
    set(handles.edit_granularity, 'Enable', 'On');
else
    set(handles.edit_window_size, 'Enable', 'Off');
    set(handles.edit_granularity, 'Enable', 'Off');
end


% --- Executes on button press in checkbox_linefit.
function checkbox_linefit_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_compute.
function pushbutton_compute_Callback(hObject, eventdata, handles)

    %  creates input structure for varforce_run
    if isfield(handles, 'checkbox_linefit');
        if get(handles.checkbox_linefit, 'value')
            input_params.compute_linefit = 'on';
        else
            input_params.compute_linefit = 'off';
        end
    end

    if isfield(handles, 'checkbox_inst');
        if get(handles.checkbox_inst, 'value')
            input_params.compute_inst = 'on';
        else
            input_params.compute_inst = 'off';
        end
    end

    if isfield(handles, 'edit_buffer_points');
        input_params.num_buffer_points = str2num(get(handles.edit_buffer_points, 'String'));
    else
      logentry('no buffer point number specified. Varforce_run will default to removing zero points');
    end  
    
    if isfield(handles, 'edit_error_tolerance');
        input_params.error_tol = str2num(get(handles.edit_error_tolerance, 'String'));
    else
      logentry('no error tolerance specified. Varforce_run will default to .5');
    end  
       
    if isfield(handles, 'checkbox_drift');
        if get(handles.checkbox_drift, 'Value') == 1;
            input_params.drift_remove='on';
        else
            input_params.drift_remove='off';
        end
    else
        logentry('no drift removal preference specified. Varforce_run will default to using drift removal');
    end
    
    if isfield(handles, 'edit_poleloc_x');
        poleloc(:,1) = str2num(get(handles.edit_poleloc_x, 'String'));
        poleloc(:,2) = str2num(get(handles.edit_poleloc_y, 'String'));
        input_params.poleloc = poleloc;
    else
        logentry('no pole location specified. Varforce_run will not work without one');
    end
    
    if isfield(handles, 'trackfile');
        input_params.trackfile = handles.trackfile;
    else
         logentry('no trackfile entered. Varforce_run will not work without it');
    end
    
    input_params.metafile = handles.metafile;    
    input_params.window_size = str2num(get(handles.edit_window_size, 'String'));
    input_params.granularity = str2num(get(handles.edit_granularity, 'String'));
    input_params.poletip_radius = str2num(get(handles.edit_poletip_radius, 'String'));
    
    % sends structure to varforce_run for analysis
    handles.v = varforce_run(input_params);
    guidata(hObject, handles);
    
  
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% --- Executes on button press in button_spatial_plot.
function button_spatial_plot_Callback(hObject, eventdata, handles)


% --- Executes on button press in button_saturation_plot.
function button_saturation_plot_Callback(hObject, eventdata, handles)

    varforce_plot_sat_data(handles.v.forcecal.results);

    
% --- Executes on button press in button_log_fits.
function button_log_fits_Callback(hObject, eventdata, handles)

    data    = handles.v.forcecal.data;
    results = handles.v.forcecal.results;

    varforce_plot_force_power_law(data, results);
    
    
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'varforce_analysis_gui: '];
     
     fprintf('%s%s\n', headertext, txt);

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
  

% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)

    close(varforce_analysis_gui);


% --- Executes on button press in pushbutton_force_distance_plot.
function pushbutton_force_distance_plot_Callback(hObject, eventdata, handles)

    data    = handles.v.forcecal.data;
    results = handles.v.forcecal.results;
    
    varforce_plot_force_distance(data, results);


% --- Executes on button press in pushbutton_remanence_FD_plot.
function pushbutton_remanence_FD_plot_Callback(hObject, eventdata, handles)
    
    data    = handles.v.remanence.data;
    results = handles.v.remanence.results;
    
    varforce_plot_force_distance(data, results);


% --- Executes on button press in pushbutton_remanence_logfit.
function pushbutton_remanence_logfit_Callback(hObject, eventdata, handles)

    data  = handles.v.remanence.data;
    results = handles.v.remanence.results;

    varforce_plot_force_power_law(data, results);


% --- Executes on button press in pushbutton_plot_drift_vectors.
function pushbutton_plot_drift_vectors_Callback(hObject, eventdata, handles)
    
    varforce_plot_drift_vectors(handles.v.drift);

    
% --- Executes during object creation, after setting all properties.
function pushbutton_plot_drift_vectors_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_drift_force_distance.
function pushbutton_drift_force_distance_Callback(hObject, eventdata, handles)

    data    = handles.v.drift.data;
    results = handles.v.drift.results;
    
    varforce_plot_force_distance(data, results);


% --- Executes on button press in pushbutton_drift_log_fit.
function pushbutton_drift_log_fit_Callback(hObject, eventdata, handles)

    data  = handles.v.drift.data;
    results = handles.v.drift.results;

    varforce_plot_force_power_law(data, results);


% --- Executes on button press in pushbutton_plot_powerlaw_current.
function pushbutton_plot_powerlaw_current_Callback(hObject, eventdata, handles)

    data  = handles.v.forcecal.data;
    results = handles.v.forcecal.results;

    varforce_plot_powerlaw_vs_current(data, results);


function edit_save_filename_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_save_filename_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in pushbutton_load_calib.
function pushbutton_load_calib_Callback(hObject, eventdata, handles)

	warning off MATLAB:deblank:NonStringInput

    try
        [fname, pname] = uigetfile('*.vfc.mat');
    catch
        logentry('No calibration file found. No metadata file loaded.');
        return;
    end
    
    if sum(length(fname), length(pname)) <= 1
        logentry('No calibration file selected. No metadata file loaded.');
        return;
    end        
    
	filename = strcat(pname, fname);

    logentry(['Setting Path to ' pname]);
    cd(pname);

    handles.calibfile = (filename);
    handles.v = load(filename);
	guidata(hObject, handles);

    set(handles.edit_calibfile, 'String', fname);
        
    logentry(['Loaded calibration file, ' fname]);
    
    

function edit_calibfile_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_calibfile_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_poleloc_y_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_poleloc_y_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_poletip_radius_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_poletip_radius_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in pushbutton_savefile.
function pushbutton_savefile_Callback(hObject, eventdata, handles)

        outsfile = get(handles.edit_save_filename, 'String');
        
        if length(outsfile) < 1

            fname = get(handles.edit_trackerfile, 'String');
            outsfile = strrep(fname, '.mat', '');
            outsfile = [outsfile '.vfc.mat'];

            set(handles.edit_save_filename, 'String', outsfile);

            logentry('No filename specified.  Using automatic default.');

        end
        
        v = handles.v;
        save(outsfile, '-struct', 'v');
        logentry(['Saved calibration file to:  ' outsfile]);
        

        