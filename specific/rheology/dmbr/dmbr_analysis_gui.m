function  varargout = dmbr_analysis_gui(varargin)  
% 3DFM function   
% Rheology
% last modified 03/21/08 (jcribb)
%  
% loads the GUI that analyzes driven microbead rheology data using
% calibration derived from the varforce experimental protocol for 3dfm (see
% varforcegui)
%
%   dmbr_analysis_gui; 
%

% dmbr_analysis_gui M-file for dmbr_analysis_gui.fig
%      dmbr_analysis_gui, by itself, creates a new dmbr_analysis_gui or raises the existing
%      singleton*.
%
%      H = dmbr_analysis_gui returns the handle to a new dmbr_analysis_gui or the handle to
%      the existing singleton*.
%
%      dmbr_analysis_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in dmbr_analysis_gui.M with the given input arguments.
%
%      dmbr_analysis_gui('Property','Value',...) creates a new dmbr_analysis_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dmbr_analysis_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property
%      application
%      stop.  All inputs are passed to dmbr_analysis_gui_OpeningFcn via
%      varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dmbr_analysis_gui

% Last Modified by GUIDE v2.5 29-Apr-2009 04:10:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dmbr_analysis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @dmbr_analysis_gui_OutputFcn, ...
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


% --- Executes just before dmbr_analysis_gui is made visible.
function dmbr_analysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)  %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dmbr_analysis_gui (see VARARGIN)

% Choose default command line output for dmbr_analysis_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dmbr_analysis_gui wait for user response (see UIRESUME)
% uiwait(handles.dmbr);


% --- Outputs from this function are returned to the command line.
function varargout = dmbr_analysis_gui_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
    
function edit_poleloc_x_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function edit_poleloc_y_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function edit_poletip_radius_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_buffer_points_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end    

% function edit_window_size_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
%     if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%         set(hObject,'BackgroundColor','white');
%     end    

function edit_calibfile_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_metafile_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function edit_trackerfile_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_save_filename_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function listbox_beadID_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    
function edit_BeadID_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function listbox_seqID_CreateFcn(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function listbox_voltages_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function popup_plottype_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function popupmenu_fit_type_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_tau_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
function edit_scale_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
      
function pushbutton_metafile_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end
    
    
function pushbutton_trackerfile_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end
    
    
function pushbutton_calibfile_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

    
function buffer_point_text_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end


function pole_location_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end


function text19_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end


function text17_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end


function text18_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function uipanel5_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function radio_use_avg_force_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function radio_use_disp_force_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_export_to_ws_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_plot_mean_creep_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_delete_selected_time_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_attach_CAP_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_fit_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_fit_all_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_plot_thinning_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_quickfit_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_compute_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_close_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end

function pushbutton_savefile_CreateFcn(hObject, eventdata, handles)
    if isunix
        set(hObject, 'BackgroundColor', [0.925 0.914 0.851]);
    end


function edit_poletip_radius_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>


function edit_buffer_points_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>


function edit_metafile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>


function edit_trackerfile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    
    
function edit_save_filename_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>


function edit_calibfile_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    

function checkbox_plotx_Callback(hObject, eventdata, handles)
      plot_data(hObject, eventdata, handles);

function checkbox_ploty_Callback(hObject, eventdata, handles)
      plot_data(hObject, eventdata, handles);

function checkbox_plotr_Callback(hObject, eventdata, handles)
      plot_data(hObject, eventdata, handles);

% function edit_window_size_Callback(hObject, eventdata, handles)
%       plot_data(hObject, eventdata, handles);

function edit_scale_Callback(hObject, eventdata, handles)

% % iterate across beads and sequences
% beads     = unique(rheo_table(:,ID))';
% sequences = unique(rheo_table(:,SEQ))';
% voltages  = unique(rheo_table(:,VOLTS))';

    % blah
    plot_data(hObject, eventdata, handles);

function edit_tau_Callback(hObject, eventdata, handles)
      plot_data(hObject, eventdata, handles);
    
    
% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles)  %#ok<INUSL,INUSD,DEFNU>

    if isfield(handles, 'mainfig');
        try
            close(handles.mainfig);
        catch
        end
    end

    if isfield(handles, 'meanJfig');
        try
            close(handles.meanJfig);
        catch
        end
    end

    if isfield(handles, 'meandispfig');
        try
            close(handles.meandispfig);
        catch
        end
    end

    close(dmbr_analysis_gui);


function edit_poleloc_x_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>

    px = str2num(get(handles.edit_poleloc_x, 'String')); %#ok<ST2NM>
    py = str2num(get(handles.edit_poleloc_y, 'String')); %#ok<ST2NM>

    if isnumeric(px) && isnumeric(py)
        params.poleloc = [px,py];
    end
    

function edit_poleloc_y_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
    px = str2num(get(handles.edit_poleloc_x, 'String')); %#ok<ST2NM>
    py = str2num(get(handles.edit_poleloc_y, 'String')); %#ok<ST2NM>

    if isnumeric(px) && isnumeric(py)
        params.poleloc = [px,py];
    end


% --- Executes on button press in pushbutton_metafile.
function pushbutton_metafile_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>

	warning off MATLAB:deblank:NonStringInput

    try
        [fname, pname] = uigetfile('*.vfd.mat');
    catch
        logentry('No metadata file found. No metadata file loaded.');
        return;
    end
    
    if sum(length(fname), length(pname)) <= 1
        logentry('No metadata file selected. No metadata file loaded.');
        return;
    end        
    
	filename = strcat(pname, fname);
    logentry(['Setting Path to ' pname]);
    cd(pname);

    handles.metafile = (filename);
	guidata(hObject, handles);

    set(handles.edit_metafile, 'String', fname);
    
    params = load(filename);
    
    if ~isfield(params, 'poleloc')
        % first, look for the poleloc.txt file that contains 
        % the pole location and try to automatically fill in 
        % the desired information
        pfile = dir('poleloc.txt');

        if ~isempty(pfile)
            poleloc = load('poleloc.txt');
            set(handles.edit_poleloc_x, 'String', num2str(poleloc(1)));
            set(handles.edit_poleloc_y, 'String', num2str(poleloc(2)));
            logentry(['poleloc.txt found.  Setting pole location to: [' num2str(poleloc) '].']);
        else
            logentry('Pole location file (poleloc.txt) not found.');
        end
    else
        poleloc = params.poleloc;
        set(handles.edit_poleloc_x, 'String', num2str(poleloc(1)));
        set(handles.edit_poleloc_y, 'String', num2str(poleloc(2)));
    end
    
    if isfield(params, 'trackfile')
        [pname, fname, ext] = fileparts(params.trackfile);
        trackfile = [fname,ext];
        set(handles.edit_trackerfile, 'String', trackfile);
        handles.trackfile = trackfile;
        guidata(hObject, handles);
    end
    
    if isfield(params, 'calibfile')
        [pname, fname, ext] = fileparts(params.calibfile);
        calibfile = [fname,ext];
        set(handles.edit_calibfile, 'String', calibfile);
        handles.calibfile = calibfile;
        guidata(hObject, handles);
    end
    
    logentry(['Loaded metafile, ' fname]);

    
% --- Executes on button press in pushbutton_trackerfile.
function pushbutton_trackerfile_Callback(hObject, eventdata, handles)  %#ok<INUSL,INUSD,DEFNU>

	warning off MATLAB:deblank:NonStringInput

    try
        [fname, pname] = uigetfile('*.evt.mat');
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

    handles.trackfile = filename;
	guidata(hObject, handles);

    set(handles.edit_trackerfile, 'String', fname);
    
    logentry(['Loaded tracker file, ' fname]);
    logentry('Setting savefile to default name.');

    % predict output filename that contains the computed calibration data
    outsfile = strrep(fname, '.mat', '');
    outsfile = [outsfile '.dmb.mat'];
    set(handles.edit_save_filename, 'String', outsfile);    
    
    return;
    
       
% --- Executes on button press in pushbutton_calibfile.
function pushbutton_calibfile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    warning off MATLAB:deblank:NonStringInput;

    try
        [fname, pname] = uigetfile('*.vfc.mat');
    catch
        logentry('No calibration file found. Nothing loaded.');
        return;
    end
    
    if sum(length(fname), length(pname)) <= 1
        logentry('No calibration file selected. Nothing loaded.');
        return;
    end        
    
	filename = strcat(pname, fname);
    logentry(['Setting Path to ' pname]);
    cd(pname);

    handles.calibfile = (filename);
	guidata(hObject, handles);

    set(handles.edit_calibfile, 'String', fname);
    
    logentry(['Loaded calibration file, ' fname]);
    

% --- Executes on button press in pushbutton_savefile.
function pushbutton_savefile_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

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

        
% --- Executes on button press in pushbutton_compute.
function pushbutton_compute_Callback(hObject, eventdata, handles)  %#ok<INUSD,DEFNU>

    if isfield(handles, 'edit_buffer_points');
        input_params.num_buffer_points = str2num(get(handles.edit_buffer_points, 'String'));
    else
        logentry('no buffer point number specified. Varforce_run will default to removing zero points');
    end  
    
    if isfield(handles, 'edit_poleloc_x');
        input_params.poleloc(:,1) = str2num(get(handles.edit_poleloc_x, 'String'));
    else
        logentry('no pole location specified. dmbr will not work without one');
    end

    if isfield(handles, 'edit_poleloc_y');
        input_params.poleloc(:,2) = str2num(get(handles.edit_poleloc_y, 'String'));
    else
        logentry('no pole location specified. dmbr will not work without one');
    end
    
    if isfield(handles, 'popupmenu_fit_type');
        contents = get(handles.popupmenu_fit_type,'String');
        input_params.fit_type = contents{get(hObject,'Value')};
    else 
        logentry('no fitting type entered.');
    end
    
    if isfield(handles, 'edit_scale');
        input_params.scale = str2num(get(handles.edit_scale, 'String'));
    else         
        logentry('no scale selected.  defaulting to 0.5 stdev.');
        input_params.scale = 0.5;
        set(handles.edit_scale, 'String', num2str(input_params.scale));
    end
    
    if isfield(handles, 'edit_tau');
        tau = str2num(get(handles.edit_tau, 'String'));
        input_params.tau  = tau;
    end
    
    if isfield(handles, 'trackfile');
        input_params.trackfile = handles.trackfile;
    else
         logentry('no trackfile entered. dmbr will not work without it');
    end
    
    
    input_params.metafile = handles.metafile;    
    input_params.calibfile = handles.calibfile;
    input_params.poletip_radius = str2num(get(handles.edit_poletip_radius, 'String'));
    
    if get(handles.radio_use_avg_force, 'Value')
        input_params.force_type = 'avg';
    else
        input_params.force_type = 'disp';
    end
    
%    input_params.wn = str2num(get(handles.edit_window_size, 'String'));
    
    
    % sends structure to dmbr_run for analysis
    v = dmbr_run(input_params);

    dmbr_constants;

    handles.v = v;
    handles.params     = v.params;
    handles.rheo_table = v.raw.rheo_table;
    
    set(handles.dmbr, 'Units', 'Normalized');
    guipos = get(handles.dmbr, 'Position');
    
    if ~isfield(handles, 'mainfig');
        handles.mainfig = figure;
    end
    
    if ~isfield(handles, 'plot_type');
        handles.plot_type = 'displacement';
    end
    
    guidata(hObject, handles); 
    
    try
        set(handles.mainfig, 'Units', 'Normalized');
    catch
        handles.mainfig = figure;
        set(handles.mainfig, 'Units', 'Normalized');
    end
    
    figpos = get(handles.mainfig, 'Position');    
    set(handles.mainfig, 'Position', [sum(guipos([1 3])+0.005) figpos(2:4)]);
    
%     set(handles.mainfig, 'Position', [0.4 0.55 figpos(3:4)]);
    
    avail_beads = unique(handles.rheo_table(:,ID));
    set(handles.listbox_beadID, 'String', num2str(avail_beads));
    listbox_beadID_Callback(hObject, eventdata, handles);

    avail_seqs  = unique(handles.rheo_table(:,SEQ));
    set(handles.listbox_seqID, 'String', num2str(avail_seqs));
    listbox_seqID_Callback(hObject, eventdata, handles);
    
    avail_volts = unique(handles.rheo_table(:,VOLTS));
    set(handles.listbox_voltages, 'String', num2str(avail_volts));
    listbox_voltages_Callback(hObject, eventdata, handles);
    
    assignin('base', 'rheo', handles.v);

    logentry('Finished.');
    
    return;
    

% --- Executes on change in listbox value.
function listbox_beadID_Callback(hObject, eventdata, handles) %#ok<DEFNU>
% Hints: contents = get(hObject,'String') returns listbox_beadID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_beadID

    dmbr_constants;

    contents_beadID = str2num(get(handles.listbox_beadID,'String')); %#ok<ST2NM>
    idx_beadID = get(handles.listbox_beadID,'Value');
    selected_beadID = contents_beadID(idx_beadID);
    handles.current_bead = selected_beadID;
    guidata(hObject, handles);
        
    plot_data(hObject, eventdata, handles);
    

% --- Executes on selection change in listbox_seqID.
function listbox_seqID_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_seqID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox_seqID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_seqID

    dmbr_constants;

    contents_seqID = str2num(get(handles.listbox_seqID,'String')); %#ok<ST2NM>
    idx_seqID = get(handles.listbox_seqID,'Value');
    selected_seqID = contents_seqID(idx_seqID);
    handles.current_seq = selected_seqID;
    guidata(hObject, handles);
      
    plot_data(hObject, eventdata, handles);

    
% --- Executes on selection change in listbox_voltages.
function listbox_voltages_Callback(hObject, eventdata, handles)

    voltages = str2num(get(hObject, 'String'));
    volt_idx = get(hObject,'Value');
    
    plot_data(hObject, eventdata, handles);
    
    
% --- Executes on button press in pushbutton_plot_mean_creep.
function pushbutton_plot_mean_creep_Callback(hObject, eventdata, handles)

    dmbr_constants;

    table = handles.rheo_table;
    
    % filter out all but current bead
    filtered_table = dmbr_filter_table();
%     beadID = str2double(get(handles.edit_BeadID, 'String'));
%     idx = find(table(:,ID) == beadID);
%     filtered_table = table(idx,:);
    
    v = dmbr_mean_creep_curve(filtered_table, 3);

    
    handles.meanJfig = figure;
    plot(v.t, v.j, '.');
    xlabel('time [s]');
    ylabel('compliance, J {Pa^{-1}]');
    title('Mean Compliance');
    drawnow;
    
    handles.meandispfig = figure;
    plot(v.t, v.x*1e6, '.');
    xlabel('time [s]');
    ylabel('displacement [\mum]');
    title('Mean displacement');
    drawnow;
    
    guidata(hObject, handles);
    
    
% --- Executes on button press in checkbox_beadfilt.
function checkbox_beadfilt_Callback(hObject, eventdata, handles)

    if get(hObject, 'Value')
        set(handles.listbox_beadID, 'Enable', 'on');
    else
        set(handles.listbox_beadID, 'Enable', 'off');
    end

    plot_data(hObject, eventdata, handles);

    return;

    
% --- Executes on button press in checkbox_seqfilt.
function checkbox_seqfilt_Callback(hObject, eventdata, handles)

    if get(hObject, 'Value')
        set(handles.listbox_seqID, 'Enable', 'on');
    else
        set(handles.listbox_seqID, 'Enable', 'off');
    end

    plot_data(hObject, eventdata, handles);

    return;
    
    
% --- Executes on button press in checkbox_voltfilt.
function checkbox_voltfilt_Callback(hObject, eventdata, handles)

    if get(hObject, 'Value')
        set(handles.listbox_voltages, 'Enable', 'on');
    else
        set(handles.listbox_voltages, 'Enable', 'off');
    end

    plot_data(hObject, eventdata, handles);

    return;
    
    
% --- Executes on button press in radio_use_avg_force.
function radio_use_avg_force_Callback(hObject, eventdata, handles)
    return;



% --- Executes on selection change in popup_plottype.
function popup_plottype_Callback(hObject, eventdata, handles)
    contents = get(hObject,'String');
    
    handles.plot_type = contents{get(hObject,'Value')};
    guidata(hObject, handles);

    plot_data(hObject, eventdata, handles); 
    
    
% --- Executes on button press in radio_logspace.
function radio_logspace_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles); 

    
% --- Executes on button press in radio_lin_space.
function radio_lin_space_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles); 


% --- Executes on button press in pushbutton_fit.
function pushbutton_fit_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    dmbr_constants;

    table = filter_table(hObject, eventdata, handles);
    
    if isempty(table)
        return;
    end
    
    t = table(:,TIME);
    t = t - t(1);
    ct = table(:,J); %#ok<NASGU>
    
      [G, eta, ct_fit, R_square] = dmbr_fit(table, handles.fit_type);
      
      format long g;
      if length(eta) == 1
          fprintf('%g\t%g\tNaN\t%g\n', G, eta(1), R_square);
      end      
      if length(eta) == 2
          fprintf('%g\t%g\t%g\t%g\n', G, eta(1), eta(2), R_square);
      end      
      plot_data(hObject, eventdata, handles);

      figure(handles.mainfig); 
      hold on;
          plot(t(1:length(ct_fit)), ct_fit, 'k--', 'LineWidth', 2);
%           plot(t, ct, 'k--', 'LineWidth', 2);
      hold off;
              

% --- Executes on button press in pushbutton_fit_all.
function pushbutton_fit_all_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>

    fits = dmbr_fit_all(handles.rheo_table, handles.fit_type);

    handles.v.fits = fits;
    guidata(hObject, handles);

    assignin('base', 'rheo', handles.v);   

% --- Executes on button press in pushbutton_export_to_ws.
function pushbutton_export_to_ws_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    assignin('base', 'rheo', handles.v);

    
% --- Executes on button press in checkbox_plot_smoothed.
function checkbox_plot_smoothed_Callback(hObject, eventdata, handles)
      plot_data(hObject, eventdata, handles);


% --- Executes on selection change in popupmenu_fit_type.
function popupmenu_fit_type_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
    contents = get(hObject,'String');
    
    handles.fit_type = contents{get(hObject,'Value')};
    guidata(hObject, handles);

    
% --- Executes on button press in pushbutton_quickfit.
function pushbutton_quickfit_Callback(hObject, eventdata, handles)
    dmbr_constants;
    
    table = filter_table(hObject, eventdata, handles);

    [t, ct, idx] = select_data_in_box(handles.mainfig);
    num_points = length(t);

    rel_t_start = min(t)/(max(table(:,TIME))-min(table(:,TIME)));
    
    [r,c] = size(table);
    min_idx = 1 + floor(rel_t_start * r);
    max_idx = min_idx + num_points - 1;
   
    table = table(min_idx:max_idx,:);
    
    % get max shear rate
    [vd, shear_max] = dmbr_max_shear(table, handles.params);
    
    % rheology fit
    [G, eta, ct_fit, R_square] = dmbr_fit(table, handles.fit_type);

    format long g;
    
    if length(eta) == 1
        eta(2) = NaN;
    end;
    
    fprintf('%g\t%g\t%g\t%g, shear rate max: %g\n', G, eta(1), eta(2), R_square, shear_max);
    
      plot_data(hObject, eventdata, handles);

      figure(handles.mainfig); 
      hold on;
          plot(t, ct_fit, 'r-');
      hold off;


% --- Executes on button press in pushbutton_plot_thinning.
function pushbutton_plot_thinning_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot_thinning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    figure(1013); 
    plot(log10(handles.v.max_shear), log10(handles.v.fits(:,3)), '.');
    xlabel('log_{10}( max shear rate [1/s] )');
    ylabel('log_{10}( \eta [Pa s] )');
    pretty_plot;


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %    
%    sub functions
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


function v = filter_table(hObject, eventdata, handles)

    dmbr_constants;    
    
    %
    if get(handles.checkbox_beadfilt, 'Value')
        contents_bead = str2num(get(handles.listbox_beadID,'String'));
        selected_beadID = contents_bead(get(handles.listbox_beadID,'Value'));
    else
        selected_beadID = [];
    end

    %
    if get(handles.checkbox_seqfilt, 'Value')
        contents_seq = str2num(get(handles.listbox_seqID,'String')); %#ok<ST2NM>
        selected_seqID = contents_seq(get(handles.listbox_seqID,'Value'));
    else
        selected_seqID = [];
    end
    
    %
    if get(handles.checkbox_voltfilt, 'Value')
        contents_voltages = str2num(get(handles.listbox_voltages, 'String')); %#ok<NASGU,ST2NM>
        Vidx = get(handles.listbox_voltages,'Value');
        selected_voltage = contents_voltages(Vidx); %#ok<NASGU>
    else
        selected_voltage = [];        
    end
    
    v = dmbr_filter_table(handles.rheo_table, selected_beadID, selected_seqID, selected_voltage);

    return;


% sets up interaction between GUI and plotting code.
function plot_data(hObject, eventdata, handles)
    dmbr_constants;    

    % 
    if get(handles.checkbox_beadfilt, 'Value')
        contents_bead = str2num(get(handles.listbox_beadID,'String')); %#ok<ST2NM>
        selected_beadID = contents_bead(get(handles.listbox_beadID,'Value'));
    else
        selected_beadID = [];
    end

    %
    if get(handles.checkbox_seqfilt, 'Value')
        contents_seq = str2num(get(handles.listbox_seqID,'String')); %#ok<ST2NM>
        selected_seqID = contents_seq(get(handles.listbox_seqID,'Value'));
    else
        selected_seqID = [];
    end
    
    %
    if get(handles.checkbox_voltfilt, 'Value')
        contents_voltages = str2num(get(handles.listbox_voltages, 'String')); %#ok<ST2NM>
        selected_voltage = contents_voltages(get(handles.listbox_voltages,'Value'));
    else
        selected_voltage = [];        
    end

    % generate selection identifier
    selection.beadID  = selected_beadID;
    selection.seqID   = selected_seqID;
    selection.voltage = selected_voltage;
    
    % construct/refresh plot options structure
    plot_opts.figure_handle = handles.mainfig;
    plot_opts.plot_smoothed = get(handles.checkbox_plot_smoothed, 'Value');
    plot_opts.plotx = get(handles.checkbox_plotx, 'Value');
    plot_opts.ploty = get(handles.checkbox_ploty, 'Value');
    plot_opts.plotr = get(handles.checkbox_plotr, 'Value');
    plot_opts.logspace = get(handles.radio_logspace, 'Value');
    plot_opts.stack = get(handles.checkbox_seqstack, 'Value');

    plot_opts.plot_type = handles.plot_type;

    dmbr_plot_data(handles.v, handles.params, selection, plot_opts);
    
    return;
    
    
function logentry(txt)

    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_analysis_gui: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;

     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 



% --- Executes on button press in checkbox_seqstack.
function checkbox_seqstack_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_seqstack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_seqstack






% --- Executes on button press in pushbutton_delete_selected_time.
function pushbutton_delete_selected_time_Callback(hObject, eventdata, handles)

    params = load(handles.metafile);
    
    if isfield(params, 'time_selected')        
        params = rmfield(params, 'time_selected');        
        save(handles.metafile, '-struct', 'params');      
        logentry('Removed time break-point between sequences.');
    end
        


% --- Executes on button press in pushbutton_attach_CAP.
function pushbutton_attach_CAP_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_attach_CAP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)









