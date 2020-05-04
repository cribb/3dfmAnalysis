function varargout = evt_GUI(varargin)
% EVT_GUI creates a new evt_GUI or raises the existing singleton
%
% 3DFM function
% GUIs/evt_GUI
% last modified 08/26/10
%
% evt_GUI M-filemenu for evt_GUI.fig
%      evt_GUI, by itself, creates a new evt_GUI or raises the existing
%      singleton*.
%
%      H = evt_GUI returns the handle to a new evt_GUI or the handle to
%      the existing singleton*.
%
%      evt_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in evt_GUI.M with the given input arguments.
%
%      evt_GUI('Property','Value',...) creates a new evt_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before evt_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evt_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evt_GUI

% Last Modified by GUIDE v2.5 27-Apr-2020 18:12:56

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @evt_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @evt_GUI_OutputFcn, ...
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

% Matlab lint ignores for this file    
%#ok<*INUSL>
%#ok<*DEFNU>
%#ok<*INUSD>
%#ok<*ASGLU>


function evt_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

	% Choose default command line output for evt_GUI
	handles.output = hObject;
    
    % Set initial/default values for tracking-related data   
	handles.CurrentBead = 0;
    
    handles.CurrentBeadRows = [];
    handles.TrackerList = [];
    handles.calibum = 1;
    handles.fps = 120;
    handles.numtaus = 30;
    
    % Assign initial "filter by" values 
    handles.filt.min_frames = 0;
    handles.filt.min_pixels = 0;
    handles.filt.max_pixels = Inf;
    handles.filt.tcrop = 0;
    handles.filt.xycrop = 0;
    handles.filt.min_sens = 0;
    handles.filt.deadzone = 0;
    handles.filt.overlapthresh = 0.1;        
    handles.filt.xyzunits = 'pixels';
    handles.filt.calibum = 1;

    % set default figure parameters
    handles.XYfig = figure('Units', 'Normalized', ...
                           'Position', [0.1 0.05 0.4 0.4], ...
                           'DoubleBuffer', 'on', ...
                           'BackingStore', 'off', ...
                           'Visible', 'on');
    handles.XTfig = figure('Units', 'Normalized', ...
                           'Position', [0.51 0.05 0.4 0.4], ...
                           'DoubleBuffer', 'on', ...
                           'BackingStore', 'off', ...
                           'Visible', 'on');
    handles.AUXfig = figure('Units', 'Normalized', ...
                           'Position', [0.51 0.525 0.4 0.4], ...
                           'DoubleBuffer', 'on', ...
                           'BackingStore', 'off', ...
                           'Visible', 'off');
    
    handles.AUXtype = 'OFF';
    

	% Update handles structure
	guidata(hObject, handles);
	

function varargout = evt_GUI_OutputFcn(hObject, eventdata, handles)
	% Get default command line output from handles structure
	varargout{1} = handles.output;

    
function evt_GUI_CloseRequestFcn(hObject, eventdata, handles)
    try
        close(handles.XYfig);
    catch
        logentry('XY figure was already closed.');
    end


    try
        close(handles.XTfig);
    catch
        logentry('XT figure was already closed.');
    end

    try
        close(handles.AUXfig);
    catch
        logentry('AUX figure was already closed.');
    end

	delete(hObject);

        
function radio_selected_dataset_Callback(hObject, eventdata, handles) 
	set(handles.radio_selected_dataset, 'Value', 1);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);

    
function radio_insideboundingbox_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 1);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);

    
function radio_outsideboundingbox_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 1);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);

    
function radio_deletetimebefore_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 1);
	set(handles.radio_deletetimeafter, 'Value', 0);

    
function radio_deletetimeafter_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 1);

    
function radio_XYfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 1);
    set(handles.radio_XTfig,  'Value', 0);    
    set(handles.radio_AUXfig, 'Value', 0);

    
function radio_XTfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 0);
    set(handles.radio_XTfig,  'Value', 1);
    set(handles.radio_AUXfig, 'Value', 0);

    
function radio_AUXfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 0);
    set(handles.radio_XTfig,  'Value', 0);
    set(handles.radio_AUXfig, 'Value', 1);    

      

function pushbutton_Edit_Data_Callback(hObject, eventdata, handles)

    if get(handles.radio_AUXfig, 'Value')
        logentry('AUXfigs are not allowed to delete data');
        return
    end
    
    set(handles.radio_selected_dataset,   'Enable', 'Off');
	set(handles.radio_insideboundingbox,  'Enable', 'Off');
	set(handles.radio_outsideboundingbox, 'Enable', 'Off');
    set(handles.radio_deletetimebefore,   'Enable', 'Off');
    set(handles.radio_deletetimeafter,    'Enable', 'Off');
    
    set(handles.radio_XTfig, 'Enable', 'off');
    set(handles.radio_XYfig, 'Enable', 'off');
    set(handles.radio_AUXfig,'Enable', 'off');
	

	if handles.radio_selected_dataset.Value
        handles = delete_selected_dataset(handles);
    elseif handles.radio_insideboundingbox.Value
        handles = delete_inside_boundingbox(handles);
    elseif handles.radio_outsideboundingbox.Value
        handles = delete_outside_boundingbox(handles);
    elseif handles.radio_deletetimebefore.Value
        handles = delete_data_before_time(handles);
    elseif handles.radio_deletetimeafter.Value
        handles = delete_data_after_time(handles);
    end
    
    
    set(handles.radio_XTfig, 'Enable', 'on');
    set(handles.radio_XYfig, 'Enable', 'on');
    set(handles.radio_AUXfig,'Enable', 'on');        

	set(handles.radio_selected_dataset,   'Enable', 'On');
	set(handles.radio_insideboundingbox,  'Enable', 'On');
	set(handles.radio_outsideboundingbox, 'Enable', 'On');
    set(handles.radio_deletetimebefore,   'Enable', 'On');
    set(handles.radio_deletetimeafter,    'Enable', 'On');
    
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    
    slider_BeadID_Callback(hObject, eventdata, handles);
    
    stk = dbstack;        
    disp([stk(1).name ', Height(TrackingTable)= ' num2str(height(handles.TrackingTable))]);    

    return
    
    
function edit_BeadID_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end
    

function slider_BeadID_CreateFcn(hObject, eventdata, handles)
	usewhitebg = 1;
	if usewhitebg
        set(hObject,'BackgroundColor',[.9 .9 .9]);
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end
    
    set(handles.slider_BeadID, 'Min', 1);                
    set(handles.slider_BeadID, 'Max', 2);
    set(handles.slider_BeadID, 'SliderStep', [1 1]);                
    set(handles.slider_BeadID, 'Value', 1);                
    
    

    
function edit_BeadID_Callback(hObject, eventdata, handles)
% Update the handles structure and beadID slider with the current bead 
% selection, and construct the filter vector for the current bead for the 
% trajectory table. Update the plots afterwards.
   
    desired_bead = round(str2double(get(handles.edit_BeadID, 'String')));
    beadList(:,1) = sort(unique(handles.TrackingTable.ID), 'ascend');
    
    [~,closest_beadIDX] = min( abs( desired_bead - beadList ));

    CurrentBead = beadList(closest_beadIDX(1));
    
    set(handles.slider_BeadID, 'Value', closest_beadIDX);                
    set(handles.edit_BeadID, 'String', num2str(CurrentBead));
    
    % separate the currently selected bead vs not the selected bead
    handles.CurrentBead = CurrentBead;
    handles = filter_bead_selection(handles);
    
    guidata(hObject, handles);
    plot_data(handles);
    

function slider_BeadID_Callback(hObject, eventdata, handles)
    
    Slider = handles.slider_BeadID;    
    
    beadList(:,1) = unique(handles.TrackingTable.ID);        
    N = numel(beadList);

    if Slider.Value <= 1
        Slider.Value = 1;
    elseif Slider.Value > N && N > 0
        Slider.Value = N;
    end
    
    if ~isempty(beadList)
        CurrentBead = beadList(Slider.Value);
    else
        CurrentBead = NaN;
    end
    
    if N > 1
        Slider.Min = 1;
        Slider.Max = N;
        Slider.SliderStep = [1/(N-1) 1/(N-1)];   
    elseif N <= 1
        Slider.Min = 1;
        Slider.Max = 2;
        Slider.SliderStep = [1 1];        
    end
    
    % Set the editbox for BeadID equal to the current beadID
    handles.edit_BeadID.String = num2str(CurrentBead, '%i');

    % separate the currently selected bead vs not the selected bead
    handles.CurrentBead = CurrentBead;
    handles = filter_bead_selection(handles);
    
    % Set the Slider changes into the handles structure
    handles.slider_BeadID = Slider;    
    guidata(hObject, handles);
    
    plot_data(handles);    

    
function pushbutton_Select_Closest_xydataset_Callback(hObject, eventdata, handles)
    
    if handles.radio_XTfig.Value
        logentry('Selecting closest dataset for XT plot does not make sense.  Resetting to XYplot');
        handles.radio_XTfig.Value = 0;
        handles.radio_XYfig.Value = 1;
    end
        
            
    if handles.radio_XYfig.Value
        
        figure(handles.XYfig);
        [xm, ym] = ginput(1);

        beadID = handles.TrackingTable.ID;    
        x = handles.TrackingTable.X;
        y = handles.TrackingTable.Y;


%         if handles.radio_microns.Value
%             calibum = str2double(handles.edit_calibum.String);
%             xm = xm / calibum;
%             ym = ym / calibum;
%         end        
% 
        xm = repmat(xm, length(x), 1);
        ym = repmat(ym, length(y), 1);

        dist = sqrt((x - xm).^2 + (y - ym).^2);

        [~, I] = min(dist);
        bead_to_select = beadID(I);

        beadList(:,1) = sort(unique(beadID), 'ascend');
        J = find(bead_to_select == beadList);
        
        handles.slider_BeadID.Value = J;
        guidata(hObject, handles);
        
        
        
    end
    
    if get(handles.radio_AUXfig, 'Value')
        
        AUXplottypes = get(handles.popup_AUXplot, 'String');
        AUXplotvalue = get(handles.popup_AUXplot, 'Value');
        
        myAUXplottype = AUXplottypes{AUXplotvalue};
        
        switch myAUXplottype
            case 'MSD'
                logentry('MSD selection needs reimplementation.');
%                 figure(handles.AUXfig);
%                 
%                 mymsd = handles.mymsd;
% 
%                 [xm, ym] = ginput(1);
% 
%                 
%                 xm = repmat(xm, size(mymsd.tau));
%                 ym = repmat(ym, size(mymsd.msd));
%         
%                 beadID = handles.TrackingTable.ID;    
%                 x = log10(mymsd.tau);
%                 y = log10(mymsd.msd);
% 
%                 dist = sqrt((x - xm).^2 + (y - ym).^2);
% 
%                 [mindist, bead_to_select] = min(min(dist));
% 
%                 bead_to_select = round(bead_to_select);
%                 
%                 set(handles.slider_BeadID, 'Value', bead_to_select-1);
%                 set(handles.edit_BeadID, 'Value', bead_to_select-1);
                       
            otherwise
                logentry('Select closest dataset not yet written for AUXplot type you chose');                
                return;
        end
    end
    
    % Updating the slider value and running the slider callback will replot
    slider_BeadID_Callback(hObject, eventdata, handles);
    

function pushbutton_select_drift_region_Callback(hObject, eventdata, handles)
    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end
    figure(active_fig);

    [xm, ym] = ginput(2);
   
    xlo = min(xm) + handles.mintime;
    xhi = max(xm) + handles.mintime;

    handles.drift_tzero = xlo;
	handles.drift_tend = xhi;
	guidata(hObject, handles);
    

function radio_com_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 1);
	set(handles.radio_linear, 'Value', 0);
    set(handles.radio_commonmode, 'Value', 0);


function radio_linear_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 0);
	set(handles.radio_linear, 'Value', 1);
    set(handles.radio_commonmode, 'Value', 0);


function radio_commonmode_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 0);
	set(handles.radio_linear, 'Value', 0);
    set(handles.radio_commonmode, 'Value', 1);


function radio_pixels_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 1);
    set(handles.radio_microns, 'Value', 0);
    
    handles.LengthUnits = 'pixels';
	guidata(hObject, handles);
    
    plot_data(handles);


function radio_microns_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 0);
    set(handles.radio_microns, 'Value', 1);

    handles.LengthUnits = 'microns';
	guidata(hObject, handles);
    
    plot_data(handles);


function edit_calibum_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end


function edit_calibum_Callback(hObject, eventdata, handles)
    handles.calibum = str2double(get(handles.edit_calibum, 'String'));
    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(handles);    


function pushbutton_remove_drift_Callback(hObject, eventdata, handles)
    if ~isfield(handles, 'drift_t0')
        start_time = [];
    else
        start_time = handles.drift_t0;
    end
    
    if ~isfield(handles, 'drift_tend')
        end_time = [];
    else
        end_time = handles.drift_tend;
    end
    
    oldmatrixdata = convert_Table_to_old_matrix(handles.TrackingTable);
    
    if get(handles.radio_linear, 'Value')
        logentry('Removing Drift via linear method.');
        [v,q] = remove_drift(oldmatrixdata, start_time, end_time, 'linear');
    elseif get(handles.radio_com, 'Value')
        logentry('Removing Drift via center-of-mass method.');
        [v,q] = remove_drift(oldmatrixdata, start_time, end_time, 'center-of-mass'); 
    elseif get(handles.radio_commonmode, 'Value')
        logentry('Removing Drift via common-mode method.');
        [v,q] = remove_drift(oldmatrixdata, start_time, end_time, 'common-mode');
    end
    
    TrackingTable = convert_old_matrix_to_Table(oldmatrixdata);
    
    handles.TrackingTable = TrackingTable;
    handles.recomputeMSD = 1;
	guidata(hObject, handles);

    plot_data(handles);
        

function checkbox_frame_rate_Callback(hObject, eventdata, handles)

    video_tracking_constants;
    TrackingTable = handles.TrackingTable;
    
    if get(hObject, 'Value')      
        set(handles.edit_frame_rate, 'Enable', 'on');

        TrackingTable.Time = TrackingTable.Frame / str2double(get(handles.edit_frame_rate, 'String'));
        mintime = min(TrackingTable.Time);
        maxtime = max(TrackingTable.Time);
	
        handles.TrackingTable = TrackingTable;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
    else
        set(handles.edit_frame_rate, 'Enable', 'off');

        handles.TrackingTable.Time = handles.tstamp_times;
        handles.mintime = min(handles.TrackingTable.Time);
        handles.maxtime = max(handles.TrackingTable.Time);
    end

    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(handles);


function edit_frame_rate_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_frame_rate_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    TrackingTable = handles.TrackingTable;

    if get(handles.checkbox_frame_rate, 'Value')
        TrackingTable.Time = TrackingTable.Frame / str2double(get(hObject, 'String'));
        mintime = min(TrackingTable.Time);
        maxtime = max(TrackingTable.Time);
	
        handles.TrackingTable = TrackingTable;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
        handles.recomputeMSD = 1;
        guidata(hObject, handles);
	
        plot_data(handles);
        drawnow;
    end
    

function radio_relative_Callback(hObject, eventdata, handles)
    set(handles.radio_relative, 'Value', 1);
    set(handles.radio_arb_origin, 'Value', 0);
    
    plot_data(handles);
    drawnow;

    
function radio_arb_origin_Callback(hObject, eventdata, handles)

    set(handles.radio_relative, 'Value', 0);
    set(handles.radio_arb_origin, 'Value', 1);

    arb_origin = str2num(get(handles.edit_arb_origin, 'String'));  %#ok<ST2NM>

    if length(arb_origin) ~= 2
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
        set(handles.radio_relative, 'Value', 1);
    else
        plot_data(handles);
    end


function edit_arb_origin_Callback(hObject, eventdata, handles)
    arb_origin = str2double(get(hObject, 'String'));

    if length(arb_origin) ~= 2
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
    else
        plot_data(handles);
    end
    

function edit_arb_origin_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function radio_AUXoff_CreateFcn(hObject, eventdata, handles)


function popup_AUXplot_Callback(hObject, eventdata, handles)
    contents = get(hObject, 'String');
    AUXtype = contents(get(hObject, 'Value'));
    
    handles.AUXtype = AUXtype{1};
    guidata(hObject, handles);
    
    plot_data(handles);

    

function popup_AUXplot_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function checkbox_msdmean_Callback(hObject, eventdata, handles)
    plot_data(handles);


function checkbox_msdall_Callback(hObject, eventdata, handles)
    plot_data(handles);

    
function checkbox_G_Callback(hObject, eventdata, handles)
    plot_data(handles);

    
function checkbox_Gstar_Callback(hObject, eventdata, handles)
    plot_data(handles);

    
function checkbox_eta_Callback(hObject, eventdata, handles)
    plot_data(handles);

    
function checkbox_etastar_Callback(hObject, eventdata, handles)
    plot_data(handles);
    
    
function edit_bead_diameter_um_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;     
    guidata(hObject, handles);

    plot_data(handles);


function edit_bead_diameter_um_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_bead_diameter_um (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function checkbox_neutoffsets_Callback(hObject, eventdata, handles)
    plot_data(handles);


function checkbox_overlayxy_Callback(hObject, eventdata, handles)
    plot_data(handles);


function edit_numtaus_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
function edit_numtaus_Callback(hObject, eventdata, handles)
    percent_duration = 1;
    numtaus = str2double(get(handles.edit_numtaus, 'String'));
    taulist = msd_gen_taus(a,numtaus,percent_duration);
    
    handles.numtaus = numtaus;
    handles.taulist = taulist;
    handles.recomputeMSD = 1;     
    guidata(hObject, handles);
    
    plot_data(handles);   
        

function edit_temp_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_temp_Callback(hObject, eventdata, handles)


function edit_filename_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_filename_Callback(hObject, eventdata, handles)


function edit_chosentau_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function edit_chosentau_Callback(hObject, eventdata, handles)
    plot_data(handles);

    
function checkbox_watermsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    plot_data(handles);

    
function checkbox_2p5Mmsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    plot_data(handles);

    
function checkbox_2Mmsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    plot_data(handles);


function checkbox_lockfps_Callback(hObject, eventdata, handles)


function checkbox_lockum_Callback(hObject, eventdata, handles)


function FileMenu_Callback(hObject, eventdata, handles)    


function FileMenuOpen_Callback(hObject, eventdata, handles)

    % reset the Active Bead to 0
    set(handles.edit_BeadID, 'String', '0');
    set(handles.slider_BeadID, 'Value', 1);   
    
%     [File, Path, fidx] = uigetfile({'*.mat;*.csv';'*.mat';'*.csv';'*.*'}, ...
%                                       'Select File(s) to Open', ...
%                                       'MultiSelect', 'on');
% 
%     if sum(length(File), length(Path)) <= 1
%         logentry('No tracking file selected. No tracking file loaded.');
%         return;
%     end        

    Path = 'C:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\data\adhesion\2020.03.12__MultiBead&MultiSurface_cone_lidded_plate2';
    File = '02_B-PEG_S-BSA_NoInt_1024x768x7625_uint16.csv';
    
    filename = fullfile(Path, File);
    S.Fid = evt_makeFid;
    S.Path = Path;
    S.Vidfile = 0;
    S.TrackingFiles = File;
    S.Fps = handles.fps;
    S.Calibum = handles.calibum;
    S.Width = 648;
    S.Height = 484;
    S.Firstframefile = '';
    S.Mipfile = '';
    
    VidTable = struct2table(S, 'AsArray', true);

    logentry(['Setting Path to: ' Path]);
    cd(Path);

    filenameroot = strrep(filename,     '.raw', '');
    filenameroot = strrep(filenameroot, '.csv', '');
    filenameroot = strrep(filenameroot, '.vrpn', '');
    filenameroot = strrep(filenameroot, '.mat', '');
    filenameroot = strrep(filenameroot, '.evt', '');

    logentry('Loading dataset... ');

    TrackingTable = vst_load_tracking(VidTable);
    [TrackingTable, Trash] = vst_filter_tracking(TrackingTable, handles.filt);
    
    TrackingTable = AddVelocity2Table(TrackingTable);
    Trash = AddVelocity2Table(Trash);

    if isempty(TrackingTable)
        msgbox('No data exists in this fileset!');
        return;
    end

    logentry(['Dataset(s) successfully loaded...']);
    
    
    MIPfile = strrep(filenameroot, '_TRACKED', '');
    MIPfile = strrep(MIPfile, 'video', 'FLburst');
    MIPfile = [MIPfile, '*mip*'];
    MIPfile = dir(MIPfile);
    
    % If the background MIP image exists, attach it to handles structure.
    % If it doesn't exist, replace with half-tone grayscale.
    if ~isempty(MIPfile)
        handles.im = imread(MIPfile(1).name);
        handles.ImageWidth  = size(handles.im,2);
        handles.ImageHeight = size(handles.im,1);
    else
        handles.im = 0.5 * ones(ceil(max(TrackingTable.Y)),ceil(max(TrackingTable.X)));
        handles.ImageWidth = max(TrackingTable.X) * 1.05;
        handles.ImageHeight = max(TrackingTable.Y) * 1.05;
    end
    
    
    % export important data to handles structure
    handles.Filename = filename;
    handles.VidTable = VidTable;
    handles.TrackingTable = TrackingTable;
    handles.Trash = Trash;    
%     handles.mintime = min(TrackingTable.Time);
%     handles.maxtime = max(TrackingTable.Time);
%     handles.tstamp_times = TrackingTable.Time;
    handles.recomputeMSD = 1;   
    handles.calibum = VidTable.Calibum;
    handles.rheo = calc_viscosity_stds(hObject, eventdata, handles);
    handles.CurrentBead = min(TrackingTable.ID);           
    handles = filter_bead_selection(handles);    
    
    if get(handles.radio_pixels, 'Value')
        handles.LengthUnits = 'pixels';
    elseif get(handles.radio_microns, 'Value')
        handles.LengthUnits = 'microns';
    end
    

    
    % Enable some controls now that data is loaded
    set(handles.checkbox_frame_rate                 , 'Enable', 'on');
    set(handles.text_frame_rate                     , 'Enable', 'on');
    set(handles.checkbox_lockfps                    , 'Enable', 'on');
    set(handles.edit_BeadID                         , 'Enable', 'on');
    set(handles.slider_BeadID                       , 'Enable', 'on');
    set(handles.pushbutton_Select_Closest_xydataset , 'Enable', 'on');
    set(handles.radio_XYfig                         , 'Enable', 'on');
    set(handles.radio_XTfig                         , 'Enable', 'on');
    set(handles.radio_AUXfig                        , 'Enable', 'on');
    set(handles.checkbox_neutoffsets                , 'Enable', 'on');
    set(handles.checkbox_overlayxy                  , 'Enable', 'on');
    set(handles.radio_selected_dataset              , 'Enable', 'on');
    set(handles.radio_insideboundingbox             , 'Enable', 'on');
    set(handles.radio_outsideboundingbox            , 'Enable', 'on');
    set(handles.radio_deletetimebefore              , 'Enable', 'on');
    set(handles.radio_deletetimeafter               , 'Enable', 'on');
    set(handles.pushbutton_Edit_Data                , 'Enable', 'on');
    set(handles.popup_AUXplot                       , 'Enable', 'on');
    set(handles.radio_relative                      , 'Enable', 'on');
    set(handles.radio_arb_origin                    , 'Enable', 'on');
    set(handles.edit_arb_origin                     , 'Enable', 'on');
    set(handles.radio_com                           , 'Enable', 'on');
    set(handles.radio_linear                        , 'Enable', 'on');
    set(handles.radio_commonmode                    , 'Enable', 'on');
    set(handles.pushbutton_select_drift_region      , 'Enable', 'on');
    set(handles.pushbutton_remove_drift             , 'Enable', 'on');
    set(handles.radio_pixels                        , 'Enable', 'on');
    set(handles.radio_microns                       , 'Enable', 'on');
    set(handles.edit_calibum                        , 'Enable', 'on');
    set(handles.text_calibum                        , 'Enable', 'on');
    set(handles.checkbox_lockum                     , 'Enable', 'on');    
    set(handles.checkbox_msdmean                    , 'Value',   1);

    % The slider calls the plot_data function
    slider_BeadID_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);           
        


    
function FileMenuAdd_Callback(hObject, eventdata, handles)


function FileMenuSaveAs_Callback(hObject, eventdata, handles)

    suggested_outfile = '';
    [outfile, outpath, outindx] = uiputfile();


    
function FileMenuSave_Callback(hObject, eventdata, handles)
    video_tracking_constants;
        
    outfile = handles.Filename;

    logentry(['Setting Path to: ' pname]);
    cd(pname);

    outfile = strrep(outfile, '.raw', '');
    outfile = strrep(outfile, '.csv', '');
    outfile = strrep(outfile, '.vrpn', '');
    outfile = strrep(outfile, '.mat', '');
    outfile = strrep(outfile, '.evt', '');
    
    calibum = str2double(get(handles.edit_calibum, 'String'));
    fps = str2double(get(handles.edit_frame_rate, 'String'));
    trajdata = convert_Table_to_old_matrix(handles.TrackingTable);
    save_evtfile(outfile, trajdata, 'pixels', calibum, fps, 'mat');
    logentry(['New tracking file, ' outfile ', saved...']);
    

function FileMenuClose_Callback(hObject, eventdata, handles)


function FileMenuQuit_Callback(hObject, eventdata, handles)
    evt_GUI_CloseRequestFcn(hObject, eventdata, handles)

    
function EditMenu_Callback(hObject, eventdata, handles)


function EditMenu_AddMip_Callback(hObject, eventdata, handles)
    [File, Path, fidx] = uigetfile({'*.pgm';'*.png';'*.tif;*.tiff';'*.*'}, ...
                                      'Select Background Image (e.g. MIP)', ...
                                      'MultiSelect', 'on');
    File = fullfile(Path, File);
    handles.im = imread(File);
    [handles.Width, handles.Height] = size(handles.im);    
    guidata(hObject, handles);                                    
                                  
    plot_data(handles);



function EditMenuFilter_Callback(hObject, eventdata, handles)


function EditMenu_SubtractDrift_Callback(hObject, eventdata, handles)


function MeasureMenu_Callback(hObject, eventdata, handles)


function MeasureMenu_XYdistance_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    figure(handles.XYfig);
	[xm, ym] = ginput(2);
    li = line(xm,ym);
    set(li, 'Color', 'k');
    set(li, 'Marker', 'o');
    set(li, 'MarkerSize', 8);
    
    if get(handles.radio_microns, 'Value')
        calibum = handles.calibum;
        
%         xm = xm / calibum;
%         ym = ym / calibum;
        units = 'um';
    else
        units = 'pixels';
    end        
        
    dist = sqrt((xm(2) - xm(1)).^2 + (ym(2) - ym(1)).^2);
    
    diststr = [num2str(round(dist)) ' ' units];
    set(handles.text_distance, 'String', diststr);

    
function ExportMenu_Callback(hObject, eventdata, handles)


function ExportMenu_CurrentBead_Callback(hObject, eventdata, handles)
    video_tracking_constants;
% 
%     CurrentBead = handles.CurrentBead;
%     beadID = handles.TrackingTable.ID;
%
    idx = handles.CurrentBeadRows;

    bead.t      = handles.TrackingTable.Time(idx);
    bead.t      = bead.t - min(handles.TrackingTable.Time);
    bead.x      = handles.TrackingTable.X(idx);
    bead.y      = handles.TrackingTable.Y(idx);
    if isfield(bead, 'yaw')
        bead.yaw    = handles.TrackingTable.Yaw(idx);
    end
    
    assignin('base', ['bead' num2str(CurrentBead)], bead);

    
function ExportMenu_AllBeads_Callback(hObject, eventdata, handles)
    video_tracking_constants;    
    vidtable = convert_Table_to_old_matrix(handles.TrackingTable);
    bead = convert_vidtable_to_beadstruct(vidtable);    
    assignin('base', 'beads', bead);
    return
   
    
function ConfigureMenu_Callback(hObject, eventdata, handles)


function checkbox_min_sens_Callback(hObject, eventdata, handles)

    
function pushbutton_FilterConfig_Callback(hObject, eventdata, handles)
    handles.filtconfig = evt_FilterConfig;
    guidata(hObject, handles);
    return

    

    
% =========================================================================
% Everything below this point are functions related to computation and data
% handling/display, and not the gui (though the handles structure is used).
% =========================================================================
function handles = filter_bead_selection(handles)
    
    CurrentBead = handles.CurrentBead;
    beadID = handles.TrackingTable.ID;
    
    % separate the currently selected bead vs not the selected bead
    handles.CurrentBeadRows = (beadID == CurrentBead);
    
    
function Plot_XYfig(handles)

    calibum = handles.calibum;
    ImageWidth = handles.ImageWidth;
    ImageHeight = handles.ImageHeight;
    im = handles.im;
    
    
    if get(handles.radio_pixels, 'Value')
        x = handles.TrackingTable.X;
        y = handles.TrackingTable.Y;
        imx = [0 ImageWidth ];
        imy = [0 ImageHeight];
    elseif get(handles.radio_microns, 'Value')
        x = handles.TrackingTable.X * calibum;
        y = handles.TrackingTable.Y * calibum;
        imx = [0 ImageWidth ] * calibum;
        imy = [0 ImageHeight] * calibum;
    end
        
    
    idx = handles.CurrentBeadRows;
    
    ylabel_unit = handles.LengthUnits;
    
    figure(handles.XYfig);
    imagesc(imx, imy, im);
        
    colormap(gray);
    if get(handles.checkbox_overlayxy, 'Value')
        hold on;
            plot(x(~idx), y(~idx), '.', ...
                 x(idx),  y(idx),  'r.');
        hold off;
    end
    
    xlabel(['displacement [' ylabel_unit ']']);
    ylabel(['displacement [' ylabel_unit ']']);    
    xlim(imx);
    ylim(imy);
    set(handles.XYfig, 'Units', 'Normalized');
%     set(handles.XYfig, 'Position', [0.1 0.05 0.4 0.4]);
    set(handles.XYfig, 'DoubleBuffer', 'on');
    set(handles.XYfig, 'BackingStore', 'off');
    drawnow;
    
%     if isfield(handles, 'poleloc')
%         polex = handles.poleloc(1);
%         poley = handles.poleloc(2);
%         circradius = 50;
%         
%         if get(handles.radio_microns, 'Value')
%             polex = polex * calibum;
%             poley = poley * calibum;
%             circradius = circradius * calibum;
%         end
%         
%         hold on;
%             plot(polex, poley, 'r+', 'MarkerSize', 36);
%             circle(polex, poley, circradius, 'r');
%         hold off;
%     end

return


function Plot_XTfig(handles)
% 
% PLOTTING XY&Z vs T
%
    calibum = handles.calibum;
    
    t = handles.TrackingTable.Frame ./ handles.fps;
    mintime = min(t);
    
    if get(handles.radio_pixels, 'Value')
        x = handles.TrackingTable.X;
        y = handles.TrackingTable.Y;
        z = handles.TrackingTable.Z;
    elseif get(handles.radio_microns, 'Value')
        x = handles.TrackingTable.X * calibum;
        y = handles.TrackingTable.Y * calibum;
        z = handles.TrackingTable.Z;
    end
    
    idx = handles.CurrentBeadRows;
    
    t = t(idx);
    x = x(idx); 
    y = y(idx); 
    z = z(idx);
    
    ylabel_unit = handles.LengthUnits;
    
    figure(handles.XYfig);
    if get(handles.checkbox_neutoffsets, 'Value')
        x1 = x(1);
        y1 = y(1);
        z1 = z(1);
    else
        [x1, y1, z1] = deal(zeros(1,3));
    end
        
    figure(handles.XTfig);
    plot(t - mintime, [x-x1 y-y1 z-z1], '.-');
    xlabel('time [s]');
    ylabel(['displacement [' ylabel_unit ']']);
    legend('x', 'y', 'z', 'Location', 'northwest');    
    set(handles.XTfig, 'Units', 'Normalized');
%     set(handles.XTfig, 'Position', [0.4039 0.5025 0.1474 0.1755]);
    set(handles.XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    drawnow;
    
    
function handles = delete_selected_dataset(handles)

    
    OldTrackingHeight = height(handles.TrackingTable);
    OldTrashHeight = height(handles.Trash);
    
    bead_to_remove = handles.CurrentBead;    
    
    k = (handles.TrackingTable.ID == bead_to_remove);
    
    NewTrash = handles.TrackingTable(k,:);
    
    handles.Trash = [handles.Trash; NewTrash];
    handles.TrackingTable(k,:) = [];        
    
    NewTrackingHeight = height(handles.TrackingTable);
    NewTrashHeight = height(handles.Trash);
    
    disp([' height(TrackingTable)=', num2str(OldTrackingHeight), ...
         ', height(Trash)= ', num2str(OldTrashHeight), ...
         ', Deleting beadID= ', num2str(bead_to_remove), ...
         ', NumRowsRemoved= ', num2str(sum(k)), ...
         ', height(NewTrash)= ', num2str(NewTrashHeight), ...
         ', height(NewTrackingTable)= ', num2str(NewTrackingHeight), ...
         '. ']);
         
         
%     if (bead_max ~= bead_to_remove) % otherwise I don't have to rearrange beadIDs
%         for m = (bead_to_remove + 1) : bead_max
%             q = (TrackingTable.ID == m);
%             TrackingTable.ID(q) = m-1;
%         end
%     end
%     
%     if (bead_to_remove == 0)
%         set(handles.slider_BeadID, 'Value', bead_to_remove+1);
%         set(handles.edit_BeadID, 'String', num2str(bead_to_remove+1));
%     else
%     	set(handles.slider_BeadID, 'Value', bead_to_remove-1);
%         set(handles.edit_BeadID, 'String', num2str(bead_to_remove-1));        
%     end
%     
%     if bead_max <= 1
%         set(handles.slider_BeadID, 'Max', bead_max-1);
%         set(handles.slider_BeadID, 'SliderStep', [0 1]);
%     else
%         set(handles.slider_BeadID, 'Max', bead_max);
%         set(handles.slider_BeadID, 'SliderStep', [1/(bead_max) 1/(bead_max)]);
%     end
    

    
    return

    
function handles = delete_inside_boundingbox(handles)    

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    else
        logentry('Deleting data from the AUXplot is not allowed.');
        return
    end
    
    
    figure(active_fig);
    
    currentbead = handles.CurrentBead;
    beadID = handles.TrackingTable.ID;
    t = handles.TrackingTable.Time - handles.mintime;
    x = handles.TrackingTable.X;
    y = handles.TrackingTable.Y;
    
    
    [xm, ym] = ginput(2);
    
%     if get(handles.radio_microns, 'Value')
%         calibum = str2double(get(handles.edit_calibum, 'String'));
%         
%         if(get(handles.radio_XYfig, 'Value'))
%             xm = xm / calibum;
%             ym = ym / calibum;
%         elseif(get(handles.radio_XTfig, 'Value'))
%             ym = ym / calibum;
%         end
%         
%     end
    
    xlo = min(xm);
    xhi = max(xm);
    ylo = min(ym);
    yhi = max(ym);
    
    if get(handles.radio_XYfig, 'Value')
        k = find(~(x > xlo & x < xhi & y > ylo & y < yhi & beadID == currentbead));
    elseif get(handles.radio_XTfig, 'Value')
        k = find(~( ( (x > ylo & x < yhi) | (y > ylo & y < yhi) ) & ...
                      (t > xlo & t < xhi) & (beadID == currentbead)));
    elseif get(handles.radio_AUXfig, 'Value')
        logentry('Deleting data from AUX plot is not allowed.');
    end
    
    NewTrash = handles.TrackingTable(k,:);
    handles.Trash = [handles.Trash; NewTrash];
    
    handles.TrackingTable(k,:) = [];
    
%     handles.tstamp_times = handles.tstamp_times(k);


function handles = delete_outside_boundingbox(handles)

    
    % xyzk1 = the neutralization offsets for the XT plot
    if ~isfield(handles, 'xyzk1')
        xyzk1 = [ 0 0 0 ];
    end

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
        xyzk1 = [ 0 0 0 ];
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    else
        logentry('Deleting data from the AUXplot is not allowed.');
        return;
    end
    
    figure(active_fig);
    TrackingTable = handles.TrackingTable;
    
    beadID = TrackingTable.ID;
    t = TrackingTable.Time - handles.mintime;
    x = TrackingTable.X;
    y = TrackingTable.Y;
    z = TrackingTable.Z;
    currentbead = handles.CurrentBead;
    
    [xm, ym] = ginput(2);
    
    if get(handles.checkbox_neutoffsets, 'Value')
        xm = xm + xyzk1(1);
        ym = ym + xyzk1(2);
%         zm = zm + xyzk1(3);
    end
    
    if get(handles.radio_microns, 'Value')
        calibum = str2double(get(handles.edit_calibum, 'String'));
        
        if(get(handles.radio_XYfig, 'Value'))
            xm = xm / calibum;
            ym = ym / calibum;
        elseif(get(handles.radio_XTfig, 'Value'))
            xm = xm / calibum;
            ym = ym / calibum;            
            %%% XXX add separate z-step calibration value.
        end
        
    end
    
    xlo = min(xm);
    xhi = max(xm);
    ylo = min(ym);
    yhi = max(ym);
    
    if get(handles.radio_XYfig, 'Value')
        k = find( (x > xlo & x < xhi & y > ylo & y < yhi ) & beadID == currentbead);

        handles.TrackingTable = TrackingTable(k,:);
        handles.tstamp_times = handles.tstamp_times(k);

    elseif get(handles.radio_XTfig, 'Value')
        k = find( ~(t > xlo & t < xhi ) & beadID == currentbead );

        TrackingTable(k,:) = [];
        handles.tstamp_times(k) = [];
        handles.TrackingTable = TrackingTable;

    elseif get(handles.radio_AUXfig, 'Value')
        logentry('Deleting data from AUX plot is not allowed.');
    end
    
    guidata(hObject, handles);

    
function handles = delete_data_before_time(handles) 
    
    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    TrackingTable = handles.TrackingTable;    

    t = TrackingTable.Time - handles.mintime;
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify time
    idx = find(dists == min(dists));
    closest_time = mean(t(idx));
    
    % remove any points in the TrackingTable that have times eariler than our
    % prescribed beginning time point
    idx = find(TrackingTable.Time > (closest_time + handles.mintime));
    TrackingTable = TrackingTable(idx,:);
    
    handles.TrackingTable = TrackingTable;
    handles.mintime = min(TrackingTable.Time);
    guidata(hObject, handles);

    
function delete_data_after_time(hObject, eventdata, handles)

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    TrackingTable = handles.TrackingTable;

    t = TrackingTable.Time - handles.mintime;
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify index value that corresponds to this time
    idx = find(dists == min(dists));
    closest_time = t(idx);

    % remove any points in the TrackingTable that are greater than the time value
    % selected by the mouse-click.
    idx = find(t <= closest_time(1));
    TrackingTable = TrackingTable(idx,:);
    
    handles.TrackingTable = TrackingTable;
    guidata(hObject, handles);


function rheo = calc_viscosity_stds(hObject, eventdata, handles) 
    video_tracking_constants;
    kB = 1.3806e-23; % [m^2 kg s^-2 K^-1];
    temp_K = 296; % [K]
    
    TrackingTable = handles.TrackingTable;
    numtaus = str2double(get(handles.edit_chosentau, 'String'));
    framemax = max(TrackingTable.Frame);
    tau = msd_gen_taus(framemax, numtaus, 1);
    bead_diameter_um = get(handles.edit_bead_diameter_um, 'String');
    bead_radius_m = str2double(bead_diameter_um)/2 * 1e-6;
    
    % visc.water = 0.001; % [Pa s]
    visc.water = sucrose_viscosity(0, temp_K, 'K');
    visc.sucrose_2M = sucrose_viscosity(2, temp_K, 'K');
    visc.sucrose_2p5M = sucrose_viscosity(2.5, temp_K, 'K');

    D.water = kB * temp_K / (6 * pi * visc.water * bead_radius_m);
    D.sucrose_2M = kB * temp_K / (6 * pi * visc.sucrose_2M * bead_radius_m);
    D.sucrose_2p5M = kB * temp_K / (6 * pi * visc.sucrose_2p5M * bead_radius_m);

    stdMSD.water = 4 * D.water * tau;
    stdMSD.sucrose_2M = 4 * D.sucrose_2M * tau;
    stdMSD.sucrose_2p5M = 4 * D.sucrose_2p5M * tau;

    rheo.visc = visc;
    rheo.D = D;
    rheo.stdMSD = stdMSD;   
    
    return


function NewTrackingTable = AddVelocity2Table(TrackingTable)
% XXX TODO: Add a smoothing scale to UI and CreateGaussScaleSpace call.

%     if isempty(TrackingTable)
%         NewTrackingTable = TrackingTable;
%         
%         return
%     end
    
    [g, gT] = findgroups(TrackingTable.ID);    
    
    if ~isempty(g)
        Vel = splitapply(@(x1,x2,x3){sa_CalcVel(x1,x2,x3,1)}, ...
                                                              TrackingTable.ID, ...
                                                              TrackingTable.Frame, ...
                                                             [TrackingTable.X, ...
                                                              TrackingTable.Y, ...
                                                              TrackingTable.Z], ...
                                                              g);
        Vel = cell2mat(Vel);
    else
        Vel = NaN(0,5);
    end

    
    
    VelTable.ID    = Vel(:,1);
    VelTable.Frame = Vel(:,2);
    VelTable.Vx    = Vel(:,3);
    VelTable.Vy    = Vel(:,4);
    VelTable.Vz    = Vel(:,5);
    VelTable.Vr    = sqrt( sum( Vel(:,3:5).^2, 2 ) );

    VelTable = struct2table(VelTable);
            
    
    %
    % Mapping the logged-velocities to colors for scatter-point color-mapping
    %   
    % Obvious first steps:
    % 1. Get the magnitude of the velocity vectors 
    % 2. Set any NaN to zero.
    % 3. Take the log. We need to keep the original non-shifted logvr
    %    separate from the shifted/color-mapped ones    
    vr = VelTable.Vr;
    vr(vr < 0.001) = NaN;
    logvr = log10(vr);


    % Set any number that is set to -inf or NaN to the *non-infinite* minimum value.
    % We are just setting colors in the colormap. Anything with zero 
    % (or "less") velocity will just be black anyway. We need to keep the
    % original (non-infinite) non-shifted logvr separate from the 
    % shifted/color-mapped one.
    tst = isfinite(logvr);
    logvr(~tst) = min(logvr(tst));

    % We want to normalize the velocities to the colormap, where 1 is the
    % highest colormap value and 0 the lowest. To do that we add the minimum
    % value. If that minimum value is negative, we'll subtract is out
    % anyway. Once this operation is over the minimum value should be zero
    % and the maximum value should be one.      
    lvr = logvr;
    lvr = lvr - min(lvr);   
    normvr = lvr ./ max(lvr);
   
    vals = floor(normvr * 255);
    heatmap = hot(256);
    velclr = heatmap(vals+1,:);

    VelTable.Vclr = velclr;
    
    NewTrackingTable = innerjoin(TrackingTable, VelTable);    
    
return


function NewTrackingTable = ScaleTrackingTable(hObject, eventdata, handles)

%     TrackingTable = handles.TrackingTable;
%     Scales = handles.Scales;
% 
%     Xunits = TrackingTable.Properties.VariableUnits{'X'};
%     
%     
%     if strcmp(Xunits, 'pixels') && strcmp(toXunits, 'um')
%         TrackingTable.X = TrackingTable.X / calibum;
%         TrackingTable.Y = TrackingTable.Y / calibum;
%         TrackingTable.Z = TrackingTable.Z / calibum;
%     end
%     
%     if strcmp(Xunits, 'um') && strcmp(toXunits, 'pixels')
%         TrackingTable.X = TrackingTable.X * calibum;
%         TrackingTable.Y = TrackingTable.Y * calibum;
%         TrackingTable.Z = TrackingTable.Z * calibum;
%     end
%     
%    NewTrackingTable = 0;
   
return


function outs = sa_CalcVel(id, frame, xyz, sfactor)    
    if isempty(frame)
        outs = zeros(0,3);
        return
    end
    
    dxyz = CreateGaussScaleSpace(xyz,1,1);
    outs = [id, frame, dxyz];
return


function radial = calculate_radial_vector(hObject, eventdata, handles)
    
    idx = handles.CurrentBeadRows;
    
    t = handles.TrackingTable.Time(idx);
    x = handles.TrackingTable.X(idx);
    y = handles.TrackingTable.Y(idx);
    z = handles.TrackingTable.Z(idx);
    r = sqrt(x.^2 + y.^2 + z.^2);

    mintime = handles.mintime;
    
    radial.t = t - mintime;
    radial.r = r;
    
%     %
%     % Handle origins, scalings, and offsets
%     %
%     arb_origin = str2double(get(handles.edit_arb_origin, 'String'));      
%     if get(handles.radio_relative, 'Value')
%         xinit = x(k); 
%         if ~isempty(xinit)
%             xinit = xinit(1); 
%         end
%         
%         yinit = y(k); 
%         if ~isempty(yinit)
%             yinit = yinit(1); 
%         end
%         
%         zinit = z(k); 
%         if ~isempty(zinit)
%             zinit = zinit(1); 
%         end
%     elseif get(handles.radio_arb_origin, 'Value')            
%         xinit = arb_origin(1);
%         yinit = arb_origin(2);
%         zinit = arb_origin(3);
% 
%         % handle the case where 'microns' are selected
%         if get(handles.radio_microns, 'Value')
%             xinit = xinit * calibum;
%             yinit = yinit * calibum;                
%             zinit = zinit * calibum;
%         end                        
%     end    
    

    return
    
function plot_radial_vector(radial, LengthUnits, h)    
    
    figure(h);
    plot(radial.t, radial.r, '.-');
    xlabel('time (s)');
    ylabel(['radial dispacement [' LengthUnits ']']);
    drawnow;
 return

 
function outs = calculate_sensitivity(hObject, eventdata, handles)
    mintime = handles.mintime;
    t = handles.TrackingTable.Time;
    s = handles.TrackingTable.Sensitivity;
    idx = handles.CurrentBeadRows;
    
    outs.t = t(idx) - mintime;
    outs.s = s(idx);   
return


function plot_sensitivity(sens, h)
    
    figure(h);
    clf;
    plot(sens.t, sens.s, '.-');
    xlabel('time (s)');
    ylabel('Tracking Sensitivity');
    drawnow;
return
 

function outs = calculate_tracker_availability(hObject, eventdata, handles)
    outs.Frame = handles.TrackingTable.Frame;
    outs.ID = handles.TrackingTable.ID;
return


function plot_tracker_availability(TrackerAvail, CurrentBeadRows, h)
    figure(h);
    clf;
    hold on;
        plot(TrackerAvail.Frame(~CurrentBeadRows), ...
             TrackerAvail.ID(~CurrentBeadRows), 'b.');
        plot(TrackerAvail.Frame(CurrentBeadRows), ...
             TrackerAvail.ID(CurrentBeadRows), 'r.');
    hold off;    
    xlabel('frame number');
    ylabel('Tracker ID');
    drawnow;
return


function outs = calculate_center_intensity(hObject, eventdata, handles)

    t = handles.TrackingTable.Time;
    c = handles.TrackingTable.CenterIntensity;
    
    idx = handles.CurrentBeadRows;
    
    mintime = handles.mintime;
        
    outs.t  = t(idx) - mintime; 
    outs.ci = c(idx) ./ max(c(idx));
    
return


function plot_center_intensity(CenterIntensity, h)
    figure(h);
    clf;
    plot(CenterIntensity.t, CenterIntensity.ci, '.-');
    xlabel('time (s)');
    ylabel('Center Intensity (frac of max)');                
    drawnow;
return


function outs = prep_velocity_plot(hObject, eventdata, handles)
    
    dt = 1/handles.fps;
    
    idx = handles.CurrentBeadRows;
    
    outs.Time = handles.TrackingTable.Time(idx);
    outs.VelX = handles.TrackingTable.Vx(idx) / dt;
    outs.VelY = handles.TrackingTable.Vy(idx) / dt;
    outs.VelZ = handles.TrackingTable.Vz(idx) / dt;
return


function plot_velocity(Velocity, LengthUnits, h)
    figure(h);
    clf;
    plot(Velocity.Time, [Velocity.VelX Velocity.VelY], '.-');
    xlabel('time (s)');
    ylabel(['velocity [' LengthUnits '/s]']);
    legend('x', 'y');
    drawnow;
return


function outs = prep_velmag_plot(hObject, eventdata, handles)

    vel = prep_velocity_plot(hObject, eventdata, handles);
   
    outs.Time = vel.Time;
    outs.VelMag = sqrt(vel.VelX .^2 + vel.VelY .^2 + vel.VelZ .^2);
    
return


function plot_velocity_magnitude(Velocity, LengthUnits, h)
    figure(h);
    clf;
    plot(Velocity.Time, Velocity.VelMag, '.-');
    xlabel('time (s)');
    ylabel(['|v| [' LengthUnits '/s]']);    
    grid on;
    drawnow;
return


function outs = prep_VelScatter_plot(hObject, eventdata, handles)

    
    CurrentBead = handles.CurrentBead;

    
    % separate the currently selected bead vs not the selected bead

    
    T = handles.TrackingTable;

    % Filter out the first and last velocity value (avoids edge effects in
    % the visualization.
    filt.tcrop = 1;
    
    T = vst_filter_tracking(T, filt);

    outs.im   = handles.im;   
    outs.id   = T.ID;
    outs.idx  = (T.ID == CurrentBead);
    outs.x    = T.X;
    outs.y    = T.Y;
    outs.z    = T.Z;
    outs.vx   = T.Vx;
    outs.vy   = T.Vy;
    outs.vz   = T.Vz;
    outs.vr   = T.Vr;
    outs.vclr = T.Vclr;
    outs.Units = 'pixels/frame';
    
return


function plot_velocity_scatter(VelScatter, h, ActiveOnlyTF)

    im = VelScatter.im;
    idx = VelScatter.idx;
    
    if nargin < 3 || isempty(ActiveOnlyTF)
        ActiveOnlyTF = false;
    end
    
    
    [imx, imy] = size(im);    
    
    [g, gT] = findgroups(VelScatter.id);

    figure(h);
    clf;
    imagesc([0 imx], [0 imy], im);
    colormap(gray(256));
    hold on;
        
        if ActiveOnlyTF
%             plot(VelScatter.x(~idx), VelScatter.y(~idx), 'b.');
            scatter(VelScatter.x(idx), VelScatter.y(idx), 10, VelScatter.vclr(idx,:), 'filled');
        else
            splitapply(@(x1,x2)plot(x1, x2, 'w-'), VelScatter.x, VelScatter.y, g);
            scatter(VelScatter.x, VelScatter.y, 10, VelScatter.vclr, 'filled');
        end
        
    hold off;
    
    minVr = min(VelScatter.vr);
    maxVr = max(VelScatter.vr);
    set(gca, 'YDir', 'reverse');            
    manual_colorbar(log10([minVr maxVr]));
    

    disp(['Minimum Velocity = ' num2str(minVr) ' ' VelScatter.Units '.']);
    disp(['Maximum Velocity = ' num2str(maxVr) ' ' VelScatter.Units '.']);

    drawnow;

return

function outs = prep_VelField_plot(hObject, eventdata, handles)
        
    NGridX = 50;
    NGridY = 50;
    
    im = handles.im;
    
    [imy, imx] = size(im);
    
    VideoStruct.xDim = imx;
    VideoStruct.yDim = imy;
    VideoStruct.pixelsPerMicron = 1 / handles.calibum;
    VideoStruct.fps = handles.fps;
    
    TrackingTable = handles.TrackingTable;
    trajdata = convert_Table_to_old_matrix(TrackingTable);

    VelField = vel_field(trajdata, NGridX, NGridY, VideoStruct);
    
    VelField.Xgrid = (1:NGridX)*(VideoStruct.xDim/NGridX/VideoStruct.pixelsPerMicron);
    VelField.Ygrid = (1:NGridY)*(VideoStruct.yDim/NGridY/VideoStruct.pixelsPerMicron);

    VelField.Xvel = reshape(VelField.sectorX, NGridX, NGridY);
    VelField.Yvel = reshape(VelField.sectorY, NGridX, NGridY);
    
    outs.VelField = VelField;
    outs.VideoStruct = VideoStruct;
    
return

function plot_VelField(VelFieldPlot, h)

    VelField = VelFieldPlot.VelField;
    VideoStruct = VelFieldPlot.VideoStruct;

    plot_vel_field(VelField, VideoStruct, h);
    xlabel('\mum')
    ylabel('\mum')
    title('Velocity Field');
    pretty_plot;
return

function VelMag = prep_VelMagScalarField_plot(hObject, eventdata, handles)
    VelMag = prep_VelField_plot(hObject, eventdata, handles);
    VelMag = VelMag.VelField;
    

    
    Vmag = sqrt(VelMag.Xvel.^2 + VelMag.Yvel.^2);        
    Vmag(Vmag<0.001) = NaN;
    Vmag(isnan(Vmag)) = min(Vmag(~isnan(Vmag)));
    
    VelMag.Vmag = Vmag;
return

function plot_VelMagScalarField(VelMag, h)
    
    figure(h);
    imagesc(VelMag.Xgrid, VelMag.Ygrid, log10(VelMag.Vmag')); 
    colormap(hot);
    xlabel('\mum')
    ylabel('\mum')
    title('Vel. [\mum/s]');
    colorbar;
    pretty_plot;   
return

function outs = prep_MSD_plot(hObject, eventdata, handles)
    TrackingTable = handles.TrackingTable;
    framemax = max(TrackingTable.Frame);
    numtaus = handles.numtaus;
    duration_fraction = 0.5;
    
    taulist = msd_gen_taus(framemax, numtaus, duration_fraction);
    
    DataIn.VidTable = handles.VidTable;
    DataIn.TrackingTable = TrackingTable;
    
%     if handles.recomputeMSD

        diffTable = vst_difftau(DataIn, taulist);
        msdTable = vst_msd(DataIn, taulist);
        outs.MsdTable = join(diffTable, msdTable);
        outs.MsdEnsemble = vst_msdEnsemble(outs);
        outs.taulist = taulist;
%     end
        
%         myve = ve(mymsd, bead_diameter_um*1e-6/2, 'f', 'n');
%         myD = mymsd.msd ./ (4 .* mymsd.tau);
%         handles.mymsd = mymsd;
%         handles.myve  = myve;
%         handles.myD   = myD;
%         handles.recomputeMSD = 0;
%      end
% 
%         msdID   = unique(TrackingTable.ID)';    
%         mymsd   = handles.mymsd;
%         myve    = handles.myve;
%         myD     = handles.myD;
%         tau = mymsd.tau;
%         msd = mymsd.msd;
%         
%         q  = find(msdID  == CurrentBead);
        
        
return

function plot_MSD_evt(MSDdata, h)
    T = MSDdata.MsdTable;
    figure(h);
    pause(0.1);
return

function plot_GSER(hObject, eventdata, handles)
    AUXfig = handles.AUXfig;
    myve = handles.myve;
    
    plotG       = get(handles.checkbox_G, 'Value');
    ploteta     = get(handles.checkbox_eta, 'Value');
    plotGstar   = get(handles.checkbox_Gstar, 'Value');
    plotetastar = get(handles.checkbox_etastar, 'Value');

    plotstring = [];

    if plotG
        plotstring = [plotstring 'Gg'];
    end

    if ploteta
        plotstring = [plotstring 'Nn'];
    end

    if plotGstar
        plotstring = [plotstring 'S'];
    end

    if plotetastar
        plotstring = [plotstring 's'];                
    end

    plot_ve(myve, 'f', AUXfig, plotstring);                
return

    
function plot_data(handles)

    stk = dbstack;
    disp(['In ' stk(1).name ', and ' stk(2).name ' called me.']);
    

    T = handles.TrackingTable;    
    H = height(T);
    N = numel(unique(T.ID));

    disp(['nTableRows=', num2str(H), ...
          ', nBeads=' num2str(N), ...
          ', CurrentBead=' num2str(handles.CurrentBead) ...
          ', nPoints=' num2str(sum(handles.CurrentBeadRows)), ...
          ', LengthUnits=' handles.LengthUnits ...
          ', Calibum=', num2str(handles.calibum)]);
    
%     handles.TrackingTable  = ScaleTrackingTable(handles.TrackingTable);
    
    Plot_XYfig(handles);
    Plot_XTfig(handles);
    
    
    AUXfig = handles.AUXfig;         
    AUXtype = handles.AUXtype;
    
    if ~strcmp(AUXtype,'OFF')
        set(AUXfig, 'Visible', 'on');            
        clf(AUXfig);
    end        
    
    switch handles.AUXtype
        case 'OFF'
            set(AUXfig, 'Visible', 'off');

        case 'radial vector'
            handles.plots.radial = calculate_radial_vector(hObject, eventdata, handles);            
            plot_radial_vector(handles.plots.radial, handles.LengthUnits, AUXfig);
            
        case 'sensitivity (SNR)'
            handles.plots.sens = calculate_sensitivity(hObject, eventdata, handles);
            plot_sensitivity(handles.plots.sens, AUXfig);
        
        case 'center intensity'            
            handles.plots.CenterIntensity = calculate_center_intensity(hObject, eventdata, handles);
            plot_center_intensity(handles.plots.CenterIntensity, handles.AUXfig);

        case 'velocity'
            handles.plots.Velocity = prep_velocity_plot(hObject, eventdata, handles);
            plot_velocity(handles.plots.Velocity, handles.LengthUnits, AUXfig);
            
        case 'velocity magnitude'
            handles.plots.VelMag = prep_velmag_plot(hObject, eventdata, handles);
            plot_velocity_magnitude(handles.plots.VelMag, handles.LengthUnits, AUXfig);
            
        case 'velocity scatter (all)'
            handles.plots.VelScatter = prep_VelScatter_plot(hObject, eventdata, handles);
            plot_velocity_scatter(handles.plots.VelScatter, AUXfig);
            
        case 'velocity scatter (active)'            
            handles.plots.VelScatter = prep_VelScatter_plot(hObject, eventdata, handles);
            plot_velocity_scatter(handles.plots.VelScatter, AUXfig, true);

        case 'velocity vectorfield'            
            handles.plots.VelField = prep_VelField_plot(hObject, eventdata, handles);
            plot_VelField(handles.plots.VelField, AUXfig);
   
        case 'vel. mag. scalarfield'            
            handles.plots.VelMag = prep_VelMagScalarField_plot(hObject, eventdata, handles);
            plot_VelMagScalarField(handles.plots.VelMag, AUXfig);
                        
%         case 'displacement hist'        
        case 'MSD'
            handles.plots.MSD = prep_MSD_plot(hObject, eventdata, handles);
            plot_MSD_evt(handles.plots.MSD, AUXfig);
            
        case 'GSER'
        case 'RMS displacement'
        case 'alpha vs tau'            
        case 'alpha histogram'
        case 'MSD histogram'
        case 'Diffusivity @ a tau'
        case 'Diffusivity vs. tau'
        case 'temporal MSD'
        case 'PSD'        
        case 'Integrated Disp'                 
        case 'pole locator'
        case 'tracker avail'
            handles.plots.TrackerAvail = calculate_tracker_availability(hObject, eventdata, handles);
            plot_tracker_availability(handles.plots.TrackerAvail, handles.CurrentBeadRows, AUXfig)

        case '2pt MSD ~~not implemented yet~~'

    end


    
     

function bayes = run_bayes_model_selection(hObject, eventdata, handles)
    video_tracking_constants;

    vidtable = convert_Table_to_old_matrix(handles.TrackingTable);

    calibum = str2double(get(handles.edit_calibum, 'String'));

    % Set up filter settings for trajectory data
    
    filt.min_frames = 300; % DEFAULT
    filt.xyzunits   = 'm';
    filt.calibum   = calibum;

%     metadata.num_subtraj = 60;
    metadata.num_subtraj = 30;
    metadata.fps         = str2double(get(handles.edit_frame_rate, 'String'));
    metadata.calibum     = calibum;
    metadata.bead_radius = str2double(get(handles.edit_bead_diameter_um, 'String'))*1e-6/2;
    metadata.numtaus     = str2num(get(handles.edit_numtaus, 'String'));
    metadata.sample_names= {' '};
    metadata.models      = {'N', 'D', 'DA', 'DR', 'V'}; % avail. models are {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};
    metadata.refdata     = 1;

     opened_file = get(handles.edit_outfile, 'String');
     [~,myfile,~] = fileparts(opened_file);

     prd    = strfind(myfile,'.');
     myname = myfile(1:prd-1);
     
    % set up text-box for 'remaining time' display
    [timefig,timetext] = init_timerfig;

    [vidtable, filtout] = filter_video_tracking(vidtable, filt); 

    agg_msdcalc = handles.mymsd;
    
    tracker_IDlist = unique(vidtable(:,ID));

    bayes_output.name = myname;
    bayes_output.filename = myfile;

    
    N = length(tracker_IDlist);
    for k = 1:N
         tic;
         
         single_curve = get_bead(vidtable, tracker_IDlist(k));
         [subtraj_matrix, subtraj_duration] = break_into_subtraj(single_curve, ...
                                             metadata.fps, metadata.num_subtraj); 
         frame_max = max(subtraj_matrix(:,FRAME));
         subtraj_framemax = floor(frame_max / metadata.num_subtraj); 
         window = msd_gen_taus(subtraj_framemax, metadata.numtaus, 0.9);
         
         msdcalc = video_msd(subtraj_matrix, window, metadata.fps, calibum, 'n'); 
         
         bayes_results = msd_curves_bayes(msdcalc.tau(:,1), ...
                                          msdcalc.msd*1e12, metadata); % computes Bayesian statistics on MSDs of matrix of subtrajectories         
         [model, prob] = bayes_assign_model(bayes_results);      % assigns each single curve a model and assocaited probability

         
         bayes_output.trackerID(k,:) = tracker_IDlist(k);
         bayes_output.model{k,:} = model;
         bayes_output.prob(k,:) = prob;
         bayes_output.results(k,:) = bayes_results;
         bayes_output.num_subtraj = metadata.num_subtraj;
         bayes_output.subtraj_msd(k,:) = msdcalc;
         bayes_output.orig_msd = agg_msdcalc;
    
            % handle timer
            itertime = toc;
            if k == 1
                totaltime = itertime;
            else
                totaltime = totaltime + itertime;
            end    
            meantime = totaltime / k;
            timeleft = (N-k) * meantime;
            outs = [num2str(timeleft, '%5.0f') ' sec.'];
            set(timetext, 'String', outs);
            drawnow;

%             model_curve_struct.N_curve_struct = 
%                 N  = model_curve_struct.N_curve_struct;
%                 D  = model_curve_struct.D_curve_struct;
%                 DA = model_curve_struct.DA_curve_struct;
%                 DR = model_curve_struct.DR_curve_struct;
%                 V  = model_curve_struct.V_curve_struct;
    end
     

     close(timefig)
     
%      [bayes_model_output] = bayes_model_analysis(bayes_output);    

     handles.bayes = struct;
     guidata(hObject, handles);
     
     handles.bayes.metadata = metadata;
     handles.bayes.filt = filt;
     handles.bayes.results = bayes_output;
     handles.bayes.name = myfile;     
     guidata(hObject, handles);
     
     bayes = handles.bayes;
              
return


function bayes = run_bayes_model_selection_general(hObject, eventdata, handles)
    video_tracking_constants;

    
    % % original settings
    % num_subtraj  = 60;
    % filt.min_frames = 800; % DEFAULT
    % metadata.numtaus     = 15;

    % set up text-box for 'remaining time' display
    [timefig,timetext] = init_timerfig;
    
    % % USER INPUTS FOR FUNCTION
    
    vidtable = convert_Table_to_old_matrix(handles.TrackingTable);

    % max_tau_s is the maximum time scale the user wants the bayesian
    % modeling code to consider when binning MSD curves.
    max_tau_s = 1;
        
    % fraction_for_subtrajectories provides the shortest total trajectory
    % length we can get away with for the number of subtrajectories we
    % want.
    fraction_for_subtraj = 0.75;

    fps = str2double(get(handles.edit_frame_rate, 'String'));
    bead_radius = str2double(get(handles.edit_bead_diameter_um, 'String'))*1e-6/2;
    calibum = str2double(get(handles.edit_calibum, 'String'));
    num_taus = str2double(get(handles.edit_numtaus, 'String'));
    opened_file = get(handles.edit_outfile, 'String');
    
    % DERIVED VALUES    
    tracksum = summarize_tracking(vidtable);    
    frame_max = tracksum.framemax;

    % tag for data comes out of the filename
    [~,myfile,~] = fileparts(opened_file);
    prd    = strfind(myfile,'.');
    myname = myfile(1:prd-1);
     
    agg_msdcalc = handles.mymsd;

    % The shortest trajectory we will want to consider depends on the
    % longest time scale (max_tau_s) we want to see in the MSD and the 
    % amount of sampling we want for that longest time scale 
    % (fraction_for_subtraj)
    max_tau_frames = floor(max_tau_s * fps);
    shortest_traj_s = max_tau_s / fraction_for_subtraj;
    shortest_traj_frames = floor(shortest_traj_s * fps);
    
    num_subtraj = floor(frame_max / max_tau_frames);
    
    logentry(['Minimum frames in Bayesian model selection set to ' num2str(shortest_traj_frames) ' frames.']);

%     min_frames = floor( fraction_for_subtraj * frame_max);    
%     num_subtraj = floor( (frame_max - min_frames - 1 ) * 0.5);
    
%     if num_subtraj > 60 %i.e. max_N_subtraj
%         num_subtraj = 60;
%     end
    
    % Set up filter settings for trajectory data
    filt.min_frames = floor(max_tau_frames * num_subtraj);
    filt.xyzunits   = 'm';
    filt.calibum   = calibum;

    metadata.num_subtraj = num_subtraj;
    metadata.fps         = fps;
    metadata.calibum     = calibum;
    metadata.bead_radius = bead_radius; 
    metadata.numtaus     = num_taus;
    metadata.sample_names= {' '};
    metadata.models      = {'N', 'D', 'DA', 'DR', 'V'}; % avail. models are {'N', 'D', 'DA', 'DR', 'V', 'DV', 'DAV', 'DRV'};
    metadata.refdata     = 1;

    bayes_output.name = myname;
    bayes_output.filename = myfile;

    % EVERYTHING is all set. Now we can get down to business...
    [filtvidtable, filtout] = filter_video_tracking(vidtable, filt); 
    filt_tracksum = summarize_tracking(filtvidtable);
    N = filt_tracksum.Ntrackers;
    tracker_IDlist = filt_tracksum.IDs;

    for k = 1:N
         tic;
         
         single_curve = get_bead(filtvidtable, tracker_IDlist(k));
         [subtraj_matrix, subtraj_duration] = break_into_subtraj(single_curve, ...
                                             metadata.fps, metadata.num_subtraj); 
         st_frame_max = max(subtraj_matrix(:,FRAME));
         subtraj_framemax = floor(st_frame_max / metadata.num_subtraj); 
         mywindow = msd_gen_taus(subtraj_framemax, metadata.numtaus, 0.9);
         
         msdcalc = video_msd(subtraj_matrix, mywindow, metadata.fps, calibum, 'n'); 
         
         bayes_results = msd_curves_bayes(msdcalc.tau(:,1), ...
                                          msdcalc.msd*1e12, metadata); % computes Bayesian statistics on MSDs of matrix of subtrajectories         
         [model, prob] = bayes_assign_model(bayes_results);      % assigns each single curve a model and assocaited probability

         
         bayes_output.trackerID(k,:) = tracker_IDlist(k);
         bayes_output.model{k,:} = model;
         bayes_output.prob(k,:) = prob;
         bayes_output.results(k,:) = bayes_results;
         bayes_output.num_subtraj = metadata.num_subtraj;
         bayes_output.subtraj_msd(k,:) = msdcalc;
         bayes_output.orig_msd = agg_msdcalc;
    
            % handle timer
            itertime = toc;
            if k == 1
                totaltime = itertime;
            else
                totaltime = totaltime + itertime;
            end    
            meantime = totaltime / k;
            timeleft = (N-k) * meantime;
            outs = [num2str(timeleft, '%5.0f') ' sec.'];
            set(timetext, 'String', outs);
            drawnow;

    end
     

     close(timefig)
     
%      [bayes_model_output] = bayes_model_analysis(bayes_output);    

     handles.bayes = struct;
     guidata(hObject, handles);
     
     handles.bayes.metadata = metadata;
     handles.bayes.filt = filt;
     handles.bayes.results = bayes_output;
     handles.bayes.name = myfile;     
     guidata(hObject, handles);
     
%      bayes = handles.bayes;
%      
         
return


function TrackingTable = convert_old_matrix_to_Table(data)
    video_tracking_constants;
    
    v.t = data(:,TIME);
    v.id= data(:,ID);    
    v.frame = data(:,FRAME);
    v.x = data(:,X);
    v.y = data(:,Y);
    v.z = data(:,Z);		
    v.roll = data(:,ROLL);    
    v.pitch= data(:,PITCH);   
    v.yaw  = data(:,YAW);     
    v.area = data(:,AREA);    
    v.sens = data(:,SENS);    
    v.centints = data(:,CENTINTS);  
    v.well = data(:,WELL);    
    v.pass = data(:,PASS);    

    TrackingTable = struct2table(v);
    TrackingTable.Properties.VariableNames = { 'Time', 'ID', 'Frame', ...
                                               'X', 'Y', 'Z', ...
                                               'Roll', 'Pitch', 'Yaw', ...
                                               'Area', 'Sensitivity', 'CenterIntensity', ...
                                               'Well', 'Pass' };
    TrackingTable.Properties.VariableUnits = { 's', '', 'frame', ...
                                               'pixels', 'pixels', 'pixels', ...
                                               'unknown', 'unknown', 'unknown', ...
                                               'pixels^2', '', '', ...
                                               '', '' };

                                           
function d = convert_Table_to_old_matrix(TrackingTable)
    video_tracking_constants;
    
    d(:,TIME) = TrackingTable.Time;
    d(:,ID) = TrackingTable.ID;
    d(:,FRAME) = TrackingTable.Frame;
    d(:,X) = TrackingTable.X;
    d(:,Y) = TrackingTable.Y;
    d(:,Z) = TrackingTable.Z;
    
    if isfield(TrackingTable, 'Roll')        
        d(:,ROLL) = TrackingTable.Roll;
    else
        d(:,ROLL) = 0;
    end
    
    if isfield(TrackingTable, 'Pitch')        
        d(:,PITCH) = TrackingTable.Pitch;
    else
        d(:,PITCH) = 0;
    end
    
    if isfield(TrackingTable, 'Yaw')        
        d(:,YAW) = TrackingTable.Yaw;
    else
        d(:,YAW) = 0;
    end
    
    
    if isfield(TrackingTable, 'Area')        
        d(:,AREA) = TrackingTable.Area;
    else
        d(:,AREA) = 0;
    end
    
    if isfield(TrackingTable, 'Sensitivity')        
        d(:,SENS) = TrackingTable.Sensitivity;
    else
        d(:,SENS) = 0;
    end
    
    if isfield(TrackingTable, 'CenterIntensity')        
        d(:,CENTINTS) = TrackingTable.CenterIntensity;
    else
        d(:,CENTINTS) = 0;
    end
    
    if isfield(TrackingTable, 'Well')        
        d(:,WELL) = TrackingTable.Well;
    else
        d(:,WELL) = 0;
    end
    
    if isfield(TrackingTable, 'Pass')        
        d(:,PASS) = TrackingTable.Pass;
    else
        d(:,PASS) = 0;
    end
    
return
    
function logentry(txt)
    logtime = clock;
    
    % dbstack pulls the stack of function calls that got us here
    stk = dbstack;
    
    % This function is stk(1).name and its calling function is stk(2).name
    calling_func = stk(2).name;
    
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext calling_func ': '];
     
     fprintf('%s%s\n', headertext, txt);
 

     
% function old_popup_AUXplot_Callback(hObject, eventdata, handles)
%     contents = get(hObject, 'String');
%     AUXtype = contents(get(hObject, 'Value'));
%     
%     handles.AUXtype = AUXtype{1};
%     guidata(hObject, handles);
% 
%     switch handles.AUXtype
%         case 'OFF'
%             set(handles.radio_relative       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin      ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall      ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             
%         case 'radial vector'
%             set(handles.radio_relative    ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.radio_arb_origin  ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.edit_arb_origin   ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%             plot_radial_vector(hObject, eventdata, handles)
%             
%         case 'PSD'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');                        
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
%         
%         case 'Integrated Disp'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');                        
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
% %         case 'displacement hist'
% %             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
% %             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
%         
%         case 'MSD'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_msdall   ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_numtaus         ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.edit_numtaus         ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'on', 'Enable', 'on');
%         
%         case 'alpha vs tau'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             
%         case 'alpha histogram'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'on', 'Enable', 'on');
%             set(handles.text_chosentau       , 'Visible', 'on', 'Enable', 'on');
%             set(handles.text_chosentau_value , 'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case 'MSD histogram'
%             set(handles.radio_relative       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin      ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall      ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'on', 'Enable', 'on');
%             set(handles.text_chosentau       , 'Visible', 'on', 'Enable', 'on');
%             set(handles.text_chosentau_value , 'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case 'Diffusivity @ a tau'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case 'Diffusivity vs. tau'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case 'temporal MSD'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case 'GSER'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G       ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_Gstar   ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_eta      ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.checkbox_etastar  ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.edit_bead_diameter_um,  'Visible', 'on', 'Enable', 'on');
%             set(handles.text_bead_diameter,  'Visible', 'on', 'Enable', 'on');
%             set(handles.text_numtaus         ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.edit_numtaus         ,  'Visible', 'on', 'Enable', 'on');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case 'pole locator'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case 'tracker avail'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%         case '2pt MSD ~~not implemented yet~~'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'on', 'Enable', 'on');
%             set(handles.text_bead_diameter,  'Visible', 'on', 'Enable', 'on');
%             set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_temp           , 'Visible', 'on', 'Enable', 'on');
%             set(handles.text_temp           , 'Visible', 'on', 'Enable', 'on');
%             set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
%             set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
% 
%     end
%     
%     plot_data(handles);
%     
     
