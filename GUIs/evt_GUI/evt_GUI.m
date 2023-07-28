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

% Last Modified by GUIDE v2.5 31-Jan-2023 14:17:29

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
	handles.appData.CurrentBead = 0;   
    handles.appData.CurrentBeadRows = [];
    handles.appData.TrackerList = [];
    handles.appData.calibum = 1;
    handles.appData.fps = 120;
    handles.appData.numtaus = 30;
    handles.appData.mintime = 0;
    handles.appData.XYZoffsets = [ 0 0 0 ];
    handles.appData.LengthUnits = 'pixels';
    handles.appData.TimeUnits = 'sec';
    handles.appData.XYZorigin = [0,0,0];
    handles.appData.Viscosity_Pas = 0.001;
    handles.appData.BeadRadius_m = 0.5e-6;
    
    % Assign initial "filter by" values 
%     handles.appData.TrackingFilter.min_frames = 10;
    handles.appData.TrackingFilter.min_frames = 0;
    handles.appData.TrackingFilter.min_pixels = 0;
    handles.appData.TrackingFilter.max_pixels = Inf;
    handles.appData.TrackingFilter.tcrop = 0;
    handles.appData.TrackingFilter.xycrop = 0;
    handles.appData.TrackingFilter.height = 768;
    handles.appData.TrackingFilter.width  = 1024;
    handles.appData.TrackingFilter.min_sens = 0;
    handles.appData.TrackingFilter.min_intensity = 0;
    handles.appData.TrackingFilter.xyzunits = 'pixels';
    handles.appData.TrackingFilter.calibum = 1;

    % set default figure parameters
    handles = init_XTfig(handles);
    handles = init_XYfig(handles);
    handles = init_AUXfig(handles);
    
    handles.AUXtype = 'OFF';    
    handles.Activefig = handles.XYfig;
    
    set(handles.slider_BeadID, 'Min', 1);                
    set(handles.slider_BeadID, 'Max', 2);
    set(handles.slider_BeadID, 'SliderStep', [1 1]);                
    set(handles.slider_BeadID, 'Value', 1);                
    set(handles.edit_arb_origin, 'String', '0,0');
    
	% Update handles structure
	guidata(hObject, handles);
	setappdata(handles.output, 'appData', handles.appData);

function varargout = evt_GUI_OutputFcn(hObject, eventdata, handles)
	% Get default command line output from handles structure
	varargout{1} = handles.output;

    
function evt_GUI_CloseRequestFcn(hObject, eventdata, handles)
    handles.XYfig.CloseRequestFcn = 'closereq';
    delete(handles.XYfig);
    
    handles.XTfig.CloseRequestFcn = 'closereq';
    delete(handles.XTfig);

    handles.AUXfig.CloseRequestFcn = 'closereq';
    delete(handles.AUXfig);    

	delete(hObject);

        
function radio_selected_dataset_Callback(hObject, eventdata, handles) 

    
function radio_insideboundingbox_Callback(hObject, eventdata, handles)

    
function radio_outsideboundingbox_Callback(hObject, eventdata, handles)

    
function radio_deletetimebefore_Callback(hObject, eventdata, handles)

    
function radio_deletetimeafter_Callback(hObject, eventdata, handles)

    
function radio_XYfig_Callback(hObject, eventdata, handles)
    handles.Activefig = handles.XYfig;
    guidata(hObject, handles);
    
    
function radio_XTfig_Callback(hObject, eventdata, handles)
    handles.Activefig = handles.XTfig;
    guidata(hObject, handles);

    
function radio_AUXfig_Callback(hObject, eventdata, handles)
    handles.Activefig = handles.AUXfig;
    guidata(hObject, handles);

% --- Executes on button press in pushbutton_cliptwin.
function pushbutton_cliptwin_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cliptwin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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

    window_sec = 0.4;
    window_frames = window_sec .* handles.appData.fps;
    handles = delete_outside_time_window(handles, window_frames);
    
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
    setappdata(handles.output, 'appData', handles.appData);

    slider_BeadID_Callback(hObject, eventdata, handles);
    
    stk = dbstack;        
    disp([stk(1).name ', Height(TrackingTable)= ' num2str(height(handles.appData.TrackingTable))]);    

return
  

function handles = delete_outside_time_window(handles, window_frames)
    handles.Activefig = handles.XTfig;
    handles.radio_XTfig.Value = 1;

    current_bead = handles.appData.CurrentBead;
    
    figure(handles.XTfig);
    [fr, xm] = ginput(1);
    
    if handles.radio_seconds.Value
%         tm = frame2sec(tm);
        fr = sec2frame(fr);
    end

    frames = handles.appData.Bead.TrackingTable.Frame;

    % find the closest time point to mouse click
    dists = abs(frames - fr);    
    
    % identify time
    [~,minidx] = min(dists);

    
    T = handles.appData.TrackingTable;
   
    
    min_keepframe = minidx - window_frames;
    max_keepframe = minidx + window_frames;

    
    foo = T.Frame <= min_keepframe | T.Frame >= max_keepframe;

    idx = find( T.ID == current_bead & foo);
    
    handles = delete_data(handles, idx);
    
return
    

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
    setappdata(handles.output, 'appData', handles.appData);

    slider_BeadID_Callback(hObject, eventdata, handles);
    
    stk = dbstack;        
    disp([stk(1).name ', Height(TrackingTable)= ' num2str(height(handles.appData.TrackingTable))]);    

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
        
    
function edit_BeadID_Callback(hObject, eventdata, handles)
% Update the handles structure and beadID slider with the current bead 
% selection, and construct the filter vector for the current bead for the 
% trajectory table. Update the plots afterwards.
   
    desired_bead = round(str2double(get(handles.edit_BeadID, 'String')));
    beadList(:,1) = sort(unique(handles.appData.TrackingTable.ID), 'ascend');
    
    [~,closest_beadIDX] = min( abs( desired_bead - beadList ));

    CurrentBead = beadList(closest_beadIDX(1));
    
    set(handles.slider_BeadID, 'Value', closest_beadIDX);                
    set(handles.edit_BeadID, 'String', num2str(CurrentBead));
    
    % separate the currently selected bead vs not the selected bead
    handles.appData.CurrentBead = CurrentBead;
    handles = SelectBead(handles);
    
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);

    plot_data(handles);
    

function slider_BeadID_Callback(hObject, eventdata, handles)
    
    Slider = handles.slider_BeadID;    
    T = handles.appData.TrackingTable;

    beadList(:,1) = unique(sort(T.ID));
    N = numel(beadList);

    if Slider.Value <= 1
        Slider.Value = 1;
    elseif Slider.Value > N && N > 0
        Slider.Value = N;
    end
    
    if ~isempty(beadList)
        CurrentBead = beadList(round(Slider.Value));
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
    handles.appData.CurrentBead = CurrentBead;
    handles = SelectBead(handles);


    % Set the Slider changes into the handles structure
    handles.slider_BeadID = Slider;    
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    
    plot_data(handles);    

    
function pushbutton_Select_Closest_xydataset_Callback(hObject, eventdata, handles)
    
    if handles.radio_XTfig.Value
        logentry('Selecting closest dataset for XT plot does not make sense.  Resetting to XYplot');
        handles.radio_XTfig.Value = 0;
        handles.radio_XYfig.Value = 1;
    end
        
            
    if handles.radio_XYfig.Value
        
        beadID = handles.appData.TrackingTable.ID;    
        x = handles.appData.TrackingTable.X;
        y = handles.appData.TrackingTable.Y;

        figure(handles.XYfig);
        [xm, ym] = ginput(1);

        if get(handles.radio_microns, 'Value')
            [xm,ym] = um2pixel(xm,ym);
        end
        
        xm = repmat(xm, length(x), 1);
        ym = repmat(ym, length(y), 1);

        dist = sqrt((x - xm).^2 + (y - ym).^2);

        [~, I] = min(dist);
        bead_to_select = beadID(I);

        beadList(:,1) = sort(unique(beadID), 'ascend');
        J = find(bead_to_select == beadList);
        
        handles.slider_BeadID.Value = J;
        guidata(hObject, handles);
        setappdata(handles.output, 'appData', handles.appData);
        
        
    end
    
    if get(handles.radio_AUXfig, 'Value')
        
        AUXplottypes = get(handles.popup_AUXplot, 'String');
        AUXplotvalue = get(handles.popup_AUXplot, 'Value');
        
        myAUXplottype = AUXplottypes{AUXplotvalue};
        
        switch myAUXplottype
            case 'MSD'
                logentry('Displaying active bead in MSD selection needs reimplementation.');
%                 figure(handles.AUXfig);
%                 
%                 mymsd = handles.appData.mymsd;
% 
%                 [xm, ym] = ginput(1);
% 
%                 
%                 xm = repmat(xm, size(mymsd.tau));
%                 ym = repmat(ym, size(mymsd.msd));
%         
%                 beadID = handles.appData.TrackingTable.ID;    
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
    active_fig = handles.XTfig;
    handles.radio_XTfig.Value = 1;

    figure(active_fig);

    [xm, ym] = ginput(2);
   
    xlo = min(xm); % + handles.appData.mintime;
    xhi = max(xm); % + handles.appData.mintime;

    handles.appData.drift_tzero = xlo;
	handles.appData.drift_tend = xhi;
	guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);

function radio_com_Callback(hObject, eventdata, handles)

function radio_linear_Callback(hObject, eventdata, handles)

function radio_commonmode_Callback(hObject, eventdata, handles)


function radio_pixels_Callback(hObject, eventdata, handles)
    handles.LengthUnits = 'pixels';
	guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    
    plot_data(handles);


function radio_microns_Callback(hObject, eventdata, handles)
    handles.LengthUnits = 'microns';
	guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    
    plot_data(handles);


function radio_frames_Callback(hObject, eventdata, handles)
    handles.TimeUnits = 'frames';
	guidata(hObject, handles);    
    setappdata(handles.output, 'appData', handles.appData);
    
    plot_data(handles);


function radio_seconds_Callback(hObject, eventdata, handles)
    handles.TimeUnits = 'seconds';
	guidata(hObject, handles);    
    setappdata(handles.output, 'appData', handles.appData);
    
    plot_data(handles);


function edit_calibum_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end


function edit_calibum_Callback(hObject, eventdata, handles)
    handles.appData.calibum = str2double(handles.edit_calibum.String);
    handles.appData.VidTable.Calibum = str2double(handles.edit_calibum.String);    
    handles.recomputeMSD = 1;
	
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    
    plot_data(handles);    


function pushbutton_remove_drift_Callback(hObject, eventdata, handles)
    if ~isfield(handles, 'drift_t0')
        start_time = [];
    else
        start_time = handles.appData.drift_t0;
    end
    
    if ~isfield(handles, 'drift_tend')
        end_time = [];
    else
        end_time = handles.appData.drift_tend;
    end    
    
    if get(handles.radio_linear, 'Value')
        logentry('Removing Drift via linear method.');
        [v,q] = vst_remove_drift(handles.appData.TrackingTable, start_time, end_time, 'linear');
    elseif get(handles.radio_com, 'Value')
        logentry('Removing Drift via center-of-mass method.');
        [v,q] = vst_remove_drift(handles.appData.TrackingTable, start_time, end_time, 'center-of-mass'); 
    elseif get(handles.radio_commonmode, 'Value')
        logentry('Removing Drift via common-mode method.');
        [v,q] = vst_remove_drift(handles.appData.TrackingTable, start_time, end_time, 'common-mode');
    end
    
    handles.appData.TrackingTable = v;
    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);

    plot_data(handles);
        

function edit_frame_rate_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_frame_rate_Callback(hObject, eventdata, handles)
    
    % Rescale time in the tracking table
    handles.appData.fps = str2double(get(hObject, 'String'));
    handles.appData.VidTable.fps = str2double(get(hObject, 'String'));

    handles.recomputeMSD = 1;

    handles = SelectBead(handles);
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
	
    % Update the plots
    plot_data(handles);

    

function radio_relative_Callback(hObject, eventdata, handles)
    set(handles.radio_relative, 'Value', 1);
    set(handles.radio_arb_origin, 'Value', 0);
    
    plot_data(handles);
    drawnow;

    
function radio_arb_origin_Callback(hObject, eventdata, handles)

    set(handles.radio_relative, 'Value', 0);
    set(handles.radio_arb_origin, 'Value', 1);

    edit_arb_origin_Callback(hObject, eventdata, handles);  %#ok<ST2NM>
    
    if length(handles.appData.XYZorigin) ~= 3
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
        set(handles.radio_relative, 'Value', 1);
    else
        plot_data(handles);
    end


function edit_arb_origin_Callback(hObject, eventdata, handles)

    arb_origin = get(handles.edit_arb_origin, 'String');
    arb_origin = strsplit(arb_origin,',');
    arb_origin = cellfun(@str2double, arb_origin, 'UniformOutput', false);
    arb_origin = cell2mat(arb_origin);      
        
    if numel(arb_origin) == 2
        arb_origin = [arb_origin(:);0]';
    end
    
    if length(arb_origin) ~= 3
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
        set(handles.radio_relative, 'Value', 1);
%         handles.appData.RadialTable = CalculateRadialLocations(handles.appData.TrackingTable);
    else
        handles.appData.XYZorigin = arb_origin;
        handles.appData.RadialTable = CalculateRadialLocations(handles.appData.TrackingTable, arb_origin);        
%         handles.appData.VelocityTable = CalculateVelocity(handles.appData.TrackingTable);
        smooth_factor = handles.edit_smoothness.Value;
        handles.appData.VelocityTable = vst_CalculateVelocity(TrackingTable, smooth_factor);
%         handles.appData.VelocityTable = CalculateVelocity(handles.appData.TrackingTable);
    end
    plot_data(handles);
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    
return

function edit_arb_origin_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function radio_AUXoff_CreateFcn(hObject, eventdata, handles)


function popup_AUXplot_Callback(hObject, eventdata, handles)
    contents = get(hObject, 'String');
    AUXtype = contents(get(hObject, 'Value'));
    
    handles.AUXtype = AUXtype{1};
    
    
    plot_data(handles);
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    

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
    handles.appData.BeadRadius_m = str2double(get(hObject, 'String'))/2 * 1e-6;
    handles.appData.ForceScale = calculate_ForceScale(handles);
    
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);

    plot_data(handles);


function edit_bead_diameter_um_CreateFcn(hObject, eventdata, handles)
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox_visc.
function checkbox_visc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_visc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_visc



function edit_customviscPas_Callback(hObject, eventdata, handles)
    handles.appData.Viscosity_Pas = str2double(get(hObject,'String'));
    handles.appData.ForceScale = calculate_ForceScale(handles);
    
    guidata(hObject, handles);    
    setappdata(handles.output, 'appData', handles.appData);
    plot_data(handles);
    

% --- Executes during object creation, after setting all properties.
function edit_customviscPas_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function checkbox_neutoffsets_Callback(hObject, eventdata, handles)

    handles = SelectBead(handles);    
    guidata(hObject, handles);   
    setappdata(handles.output, 'appData', handles.appData);
    plot_data(handles);


function checkbox_plotz_Callback(hObject, eventdata, handles)
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
    
    handles.appData.numtaus = numtaus;
    handles.appData.taulist = taulist;
    handles.recomputeMSD = 1;     
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    
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
    setappdata(handles.output, 'appData', handles.appData);

    plot_data(handles);

    
function checkbox_2p5Mmsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);

    plot_data(handles);

    
function checkbox_2Mmsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);

    plot_data(handles);


function checkbox_lockfps_Callback(hObject, eventdata, handles)


function checkbox_lockum_Callback(hObject, eventdata, handles)


function FileMenu_Callback(hObject, eventdata, handles)    


function FileMenuOpen_Callback(hObject, eventdata, handles)

    % reset the Active Bead to 0
    set(handles.edit_BeadID, 'String', '0');
    set(handles.slider_BeadID, 'Value', 1);   
    set(handles.text_status, 'String', {''});

    [File, Path, fidx] = uigetfile({'*.evt.mat;*.csv';'*.evt.mat';'*.csv';'*.*'}, ...
                                      'Select File(s) to Open', ...
                                      'MultiSelect', 'off');
%                                       'MultiSelect', 'on');

    if sum(length(File), length(Path)) <= 1
        logentry('No tracking file selected. No tracking file loaded.');
        return;
    end        

%     Path = 'C:\Dropbox\prof\Lab\Superfine Lab\expts\bead_adhesion_assay\data\adhesion\2020.03.12__MultiBead&MultiSurface_cone_lidded_plate2';
%     File = '02_B-PEG_S-BSA_NoInt_1024x768x7625_uint16.csv';
%     Path = 'C:\Dropbox\prof\Lab\dev-sandbox';
%     File = 'diff3 exp25 1.csv';
%     Path = 'C:\Dropbox\prof\Lab\Hill Lab\Water';
%     File = 'saltwater_0005.vrpn.mat';
%     File = 'sim_beads.vrpn.mat';
%     Path = 'E:\microrheo\2020.08.12__HBE_1um_SurfaceStudy1';
%     File = 'well29_pass01_1024x768x1200_uint8.csv';

    filename = fullfile(Path, File);
    S.Fid = evt_makeFid;
    S.Path = Path;
    S.Vidfile = 0;
    S.TrackingFiles = File;
    S.Fps = handles.appData.fps;
    S.Calibum = handles.appData.calibum;
    S.Width = 1024;
    S.Height = 768;
%     S.Width = 648;
%     S.Height = 484;
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

    if contains(filename, '.tpy.csv')
        TrackingTable = tpy_load_tracking(filename);
    else
        TrackingTable = vst_load_tracking(VidTable);
    end
    
    % Update the filter with height and width information
    handles.appData.TrackingFilter.height = VidTable.Height;
    handles.appData.TrackingFilter.width  = VidTable.Width;
%     handles.appData.TrackingFilter.min_frames = 5;
%     handles.appData.TrackingFilter.tcrop = 5;
    
    [TrackingTable, Trash] = vst_filter_tracking(TrackingTable, handles.appData.TrackingFilter);
    
    
    
    RadialTable = CalculateRadialLocations(TrackingTable);
        
%     VelocityTable = CalculateVelocity(TrackingTable); 
    VelocityTable = vst_CalculateVelocity(TrackingTable);


    if isempty(TrackingTable)
        msgbox('No data exists in this fileset!');
        return;
    end

    logentry('Dataset(s) successfully loaded...');
        
    MIPfile = strrep(filenameroot, '_TRACKED', '');
    MIPfile = strrep(MIPfile, 'video', 'FLburst');
    MIPfile = [MIPfile, '*mip*'];
    MIPfile = dir(MIPfile);
    
    % If the background MIP image exists, attach it to handles structure.
    % If it doesn't exist, replace with half-tone grayscale.
    if ~isempty(MIPfile)
        handles.appData.im = imread(MIPfile(1).name);
    else
        try
            tmp(:,:,1) = imread([filenameroot, '.00001.pgm']);
            tmp(:,:,2) = imread([filenameroot, '.07625.pgm']);
            tmp(:,:,3) = 0;
%             handles.appData.im = squeeze(max(tmp,[],3));
            handles.appData.im = tmp;
        catch
            handles.appData.im = 0.5 * ones(ceil(max(TrackingTable.Y)),ceil(max(TrackingTable.X)));
%             handles.appData.ImageWidth = max(TrackingTable.X) * 1.05;
%             handles.appData.ImageHeight = max(TrackingTable.Y) * 1.05;
        end
    end
        handles.appData.ImageWidth  = size(handles.appData.im,2);
        handles.appData.ImageHeight = size(handles.appData.im,1);

    % export important data to handles structure
    handles.appData.Filename = filename;
%     myUI = findall(0, 'Tag', 'evt_GUI');
%     handles = guihandles(myUI);
%     setappdata(handles.appData, 'Filename', filename);
    handles.appData.VidTable = VidTable;
    handles.appData.TrackingTable = TrackingTable;
    handles.appData.RadialTable = RadialTable;
    handles.appData.VelocityTable = VelocityTable;
    handles.appData.Trash = Trash;    
    handles.appData.recomputeMSD = 1;   
    handles.appData.calibum = VidTable.Calibum;

    handles.appData.rheo = calc_viscosity_stds(hObject, eventdata, handles);

    handles.appData.CurrentBead = min(TrackingTable.ID);       
    
    handles.appData.ForceScale = calculate_ForceScale(handles);
    
    handles = SelectBead(handles);    
    
    % Enable some controls now that data is loaded
    set(handles.edit_frame_rate                     , 'Enable', 'on');
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
    set(handles.radio_frames                        , 'Enable', 'on');
    set(handles.radio_seconds                       , 'Enable', 'on'); 
    set(handles.radio_pixels                        , 'Enable', 'on');
    set(handles.radio_microns                       , 'Enable', 'on');
    set(handles.edit_calibum                        , 'Enable', 'on');
    set(handles.text_calibum                        , 'Enable', 'on');
    set(handles.edit_customviscPas                  , 'Enable', 'on');
    set(handles.edit_smoothness                     , 'Enable', 'on');
    set(handles.checkbox_visc                       , 'Enable', 'on');    
    set(handles.checkbox_lockum                     , 'Enable', 'on');    
    set(handles.checkbox_msdmean                    , 'Value',   1);
    set(handles.edit_bead_diameter_um               , 'Enable', 'on');
    
    % The slider calls the plot_data function
    slider_BeadID_Callback(hObject, eventdata, handles);
    guidata(hObject, handles);           
    setappdata(handles.output, 'appData', handles.appData);
        
    return


    
function FileMenuAdd_Callback(hObject, eventdata, handles)


function FileMenuSaveAs_Callback(hObject, eventdata, handles)

    [pname, outfile] = fileparts(handles.appData.Filename);

    rootdir = pwd;

    outfile = strrep(outfile, '.raw', '');
    outfile = strrep(outfile, '.csv', '');
    outfile = strrep(outfile, '.vrpn', '');
    outfile = strrep(outfile, '.mat', '');
    outfile = strrep(outfile, '.evt', '');

    suggested_outfile = [outfile, '.evt.mat'];

    [outfile, outpath, outindx] = uiputfile({'*.evt.mat;*.csv';'*.evt.mat';'*.csv';'*.*'}, ...
                                      'Generate Save File Name...', suggested_outfile);
    if outfile == 0
     return
    end

    calibum = str2double(get(handles.edit_calibum, 'String'));
    fps = str2double(get(handles.edit_frame_rate, 'String'));
    trajdata = convert_Table_to_old_matrix(handles.appData.TrackingTable, handles.appData.fps);
    cd(outpath);
    save_evtfile(outfile, trajdata, 'pixels', calibum, fps, 'mat');
    cd(rootdir);
    logentry(['New tracking file, ' outfile ', saved...']);
    
function FileMenuSave_Callback(hObject, eventdata, handles)
        
    save_datafile(handles.appData);
%     [pname, outfile] = fileparts(handles.appData.Filename);
% 
%     logentry(['Setting Path to: ' pname]);
%     cd(pname);
% 
%     outfile = strrep(outfile, '.raw', '');
%     outfile = strrep(outfile, '.csv', '');
%     outfile = strrep(outfile, '.vrpn', '');
%     outfile = strrep(outfile, '.mat', '');
%     outfile = strrep(outfile, '.evt', '');
%     
%     calibum = str2double(get(handles.edit_calibum, 'String'));
%     fps = str2double(get(handles.edit_frame_rate, 'String'));
%     trajdata = convert_Table_to_old_matrix(handles.appData.TrackingTable, handles.appData.fps);
%     save_evtfile(outfile, trajdata, 'pixels', calibum, fps, 'mat');
%     logentry(['New tracking file, ' outfile ', saved...']);
    

function FileMenuClose_Callback(hObject, eventdata, handles)


function FileMenuQuit_Callback(hObject, eventdata, handles)
    evt_GUI_CloseRequestFcn(hObject, eventdata, handles)

    
function EditMenu_Callback(hObject, eventdata, handles)


function EditMenu_AddBkgd_Callback(hObject, eventdata, handles)
    [File, Path, fidx] = uigetfile({'*.pgm;*.png;*.tif;*.tiff';'*.*'}, ...
                                      'Select Background Image (e.g. MIP)', ...
                                      'MultiSelect', 'on');
    File = fullfile(Path, File);
    handles.appData.im = imread(File);
    [handles.appData.ImageHeight, handles.appData.ImageWidth] = size(handles.appData.im);    
    guidata(hObject, handles);                                    
    setappdata(handles.output, 'appData', handles.appData);
                                  
    plot_data(handles);



function EditMenuFilter_Callback(hObject, eventdata, handles)


function EditMenu_SubtractDrift_Callback(hObject, eventdata, handles)


function MeasureMenu_Callback(hObject, eventdata, handles)


function MeasureMenu_XYdistance_Callback(hObject, eventdata, handles)

    figure(handles.XYfig);
	[xm, ym] = ginput(2);
    li = line(xm,ym);
    set(li, 'Color', 'k');
    set(li, 'Marker', 'o');
    set(li, 'MarkerSize', 8);
    
    if get(handles.radio_microns, 'Value')
        calibum = handles.appData.calibum;
        
%         xm = xm / calibum;
%         ym = ym / calibum;
        units = 'um';
    else
        units = 'pixels';
    end        
        
    dist = sqrt((xm(2) - xm(1)).^2 + (ym(2) - ym(1)).^2);
    
    diststr = [num2str(round(dist)) ' ' units];
    set(handles.appData.text_distance, 'String', diststr);

    
function ExportMenu_Callback(hObject, eventdata, handles)


function ExportMenu_CurrentBead_Callback(hObject, eventdata, handles)

    if ~isfield(handles,'TrackingTable')
        logentry('Error: No tracking data loaded yet to export.')
        return
    else
        CurrentBead = handles.appData.CurrentBead;
        idx = handles.appData.CurrentBeadRows;
        
        TrackingTable = handles.appData.TrackingTable;
        BeadTable = TrackingTable(idx,:);

        bead.t      = TrackingTable.Frame(idx) / handles.appData.fps;
        bead.t      = bead.t - min(bead.t);
        bead.frame  = TrackingTable.Frame(idx);
        bead.x      = TrackingTable.X(idx);
        bead.y      = TrackingTable.Y(idx);
        if isfield(bead, 'yaw')
            bead.yaw    = TrackingTable.Yaw(idx);
        end
    end    

    beadname = ['bead' num2str(CurrentBead)];
    beadTname = ['BeadT' num2str(CurrentBead)];
    assignin('base', beadname, bead);
    assignin('base', beadTname, BeadTable);
    logentry(['Bead ', num2str(CurrentBead), ' exported to base workspace as ''' beadname '''.']);
    return
    
function ExportMenu_AllBeads_Callback(hObject, eventdata, handles)

    if ~isfield(handles,'TrackingTable')
        logentry('Error: No tracking data loaded yet to export.')
        return
    else
        vidtable = convert_Table_to_old_matrix(handles.appData.TrackingTable, handles.appData.fps);
        bead = convert_vidtable_to_beadstruct(vidtable);    
        assignin('base', 'beads', bead);
        assignin('base', 'TrackingTable', handles.appData.TrackingTable);
        logentry(['All beads exported to base workspace as ''beads''.']);
        return
    end
   
    
function ExportMenu_PlotData_Callback(hObject, eventdata, handles)
    assignin('base', 'evtPlotData', handles.appData.plots);
    logentry('Plot data exported to base workspace.');

    
function ConfigureMenu_Callback(hObject, eventdata, handles)


function checkbox_min_sens_Callback(hObject, eventdata, handles)

    
function pushbutton_FilterConfig_Callback(hObject, eventdata, handles)
    % Set waiting flag in appdata
%     setappdata(handles.evt_GUI,'waiting',1);
    
    handles.appData.TESTfilter = evt_FilterConfig('evt_GUI', handles);    
    guidata(hObject, handles);
    setappdata(handles.output, 'appData', handles.appData);
    
    return


% --- Executes on button press in checkbox_smoothness.
function checkbox_smoothness_Callback(hObject, eventdata, handles)


function edit_smoothness_Callback(hObject, eventdata, handles)
    handles.appData.smooth_factor = str2double(get(hObject,'String'));
    handles.appData.VelocityTable = vst_CalculateVelocity(handles.appData.TrackingTable, handles.appData.smooth_factor);
    
    guidata(hObject, handles);    
    setappdata(handles.output, 'appData', handles.appData);

    plot_data(handles);

% --- Executes during object creation, after setting all properties.
function edit_smoothness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_smoothness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    

    
% =========================================================================
% Everything below this point are functions related to computation and data
% handling/display, and not the gui (though the handles structure is used).
% =========================================================================

function save_datafile(appData)
    [pname, outfile] = fileparts(appData.Filename);

    logentry(['Setting Path to: ' pname]);
    cd(pname);

    outfile = strrep(outfile, '.raw', '');
    outfile = strrep(outfile, '.csv', '');
    outfile = strrep(outfile, '.vrpn', '');
    outfile = strrep(outfile, '.mat', '');
    outfile = strrep(outfile, '.evt', '');
          
    trajdata = convert_Table_to_old_matrix(appData.TrackingTable, appData.fps);
    save_evtfile(outfile, trajdata, 'pixels', appData.calibum, appData.fps, 'mat');
    logentry(['New tracking file, ' outfile ', saved...']);
return  


function handles = SelectBead(handles)
    
    CurrentBead = handles.appData.CurrentBead;    
    
    % separate the currently selected bead vs not the selected bead
    idx = (handles.appData.TrackingTable.ID == CurrentBead);

    Tbead = handles.appData.TrackingTable(idx,:);
    
    handles.appData.Bead.TrackingTable = Tbead;
    handles.appData.Bead.RadialTable = handles.appData.RadialTable(idx,:);
    handles.appData.Bead.VelocityTable = handles.appData.VelocityTable(idx,:);

    handles.appData.CurrentBeadRows = idx;
    handles.appData.mintime = min(Tbead.Frame) / handles.appData.fps;
    
    
    if handles.checkbox_neutoffsets.Value && ~isempty(Tbead)
        handles.appData.XYZoffsets = [Tbead.X(1), Tbead.Y(1) Tbead.Z(1)];
    else
        handles.appData.XYZoffsets = zeros(1,3);
    end
    
function handles = init_AUXfig(handles)
    handles.AUXfig = figure('Units', 'Normalized', ...
       'Position', [0.51 0.525 0.4 0.4], ...
       'DoubleBuffer', 'on', ...
       'BackingStore', 'off', ...
       'Visible', 'off');
    handles.AUXfig.KeyPressFcn = @keys;
    handles.AUXfig.CloseRequestFcn = 'set(gcf,"Visible","off");';
   
return


function handles = init_XYfig(handles)
    handles.XYfig = figure('Units', 'Normalized', ...
                       'Position', [0.1 0.05 0.4 0.4], ...
                       'DoubleBuffer', 'on', ...
                       'BackingStore', 'off', ...
                       'Visible', 'on');
    handles.XYfig.KeyPressFcn = @keys;
    handles.XYfig.CloseRequestFcn = 'set(gcf,"Visible","off");';
    drawnow;

return


function handles = init_XTfig(handles)
    handles.XTfig = figure('Units', 'Normalized', ...
                           'Position', [0.51 0.05 0.4 0.4], ...
                           'DoubleBuffer', 'on', ...
                           'BackingStore', 'off', ...
                           'Visible', 'on');
    handles.XTfig.KeyPressFcn = @keys;
    handles.XTfig.CloseRequestFcn = 'set(gcf,"Visible","off");';
return

function keys(src,event)
    myUI = findall(0, 'Tag', 'evt_GUI');
    appData = getappdata(myUI, 'appData');  
    handles = guihandles(myUI);
%     eventdata = [];
%     hObject = gcbo;

%    disp(event.Key);
%    disp(event.Modifier);

   if size(event.Modifier) == 1 & isequal(event.Modifier{1},'alt')
       switch(event.Key)
           case 's'
               disp('Saving the multiverse one day at a time.')
               save_datafile(appData);
       end
   end

%    switch(event.Key)
%        case 'c'
% 
%        case 'v'
%    end
return

function Plot_XYfig(handles)

    ImageWidth = handles.appData.ImageWidth;
    ImageHeight = handles.appData.ImageHeight;
    LengthUnits = handles.appData.LengthUnits;
    im = handles.appData.im;    

    x = handles.appData.TrackingTable.X;
    y = handles.appData.TrackingTable.Y;
    imx = [0 ImageWidth ];
    imy = [0 ImageHeight];

    if get(handles.radio_microns, 'Value')
        [x, y, imx, imy] = pixel2um(x, y, imx, imy);
    end        
    
    idx = handles.appData.CurrentBeadRows;
           
    figure(handles.XYfig);
    imagesc(imx, imy, im);
        
    colormap(gray);
    if get(handles.checkbox_overlayxy, 'Value')
        hold on;
            plot(x(~idx), y(~idx), '.', ...
                 x(idx),  y(idx),  'm.');
        hold off;
    end
    
    xlabel(['displacement [' LengthUnits ']']);
    ylabel(['displacement [' LengthUnits ']']);    
    xlim(imx);
    ylim(imy);
    
    if isfield(handles, 'plots') && isfield(handles.appData.plots, 'PoleLocation')
        polex = handles.appData.plots.PoleLocation(1);
        poley = handles.appData.plots.PoleLocation(2);        
        
        if get(handles.radio_microns, 'Value')
            [polex, poley] = pixel2um(polex,poley);
%             poley = poley * calibum;            
        end
        
        hold on;
            plot(polex, poley, 'r+', 'MarkerSize', 24);
            plot(polex, poley, 'ro', 'MarkerSize', 24);
        hold off;
    end
    axis image
    pretty_plot;
return


function Plot_XTfig(handles)
% 
% PLOTTING XY&Z vs T
%

    XYZoffsets = handles.appData.XYZoffsets;
    idx = handles.appData.CurrentBeadRows;

    Tbead = handles.appData.TrackingTable(idx,:);

    frames = Tbead.Frame;
    xyz = [Tbead.X, Tbead.Y, Tbead.Z];

    L = size(xyz,1);

    XYZoffsets = repmat(XYZoffsets, L, 1);

    % XXX TODO Fix, as this assumes a length scale value for x, y, and z.
    if get(handles.radio_microns, 'Value')        
        [xyz, XYZoffsets] = pixel2um(xyz, XYZoffsets);
    end

    if get(handles.checkbox_plotz, 'Value')
        displacements = xyz - XYZoffsets;
        mylegend = {'x', 'y', 'z'};
        yaxislabel = 'XYZ';
    else
        displacements = xyz(:,1:2) - XYZoffsets(:,1:2);
        mylegend = {'x', 'y'};
        yaxislabel = 'XY';
    end
    
    yunits = handles.appData.LengthUnits;

    if get(handles.radio_frames, 'Value')
        t = frames;
        mintime = sec2frame(handles.appData.mintime);
        Xaxis_Label = 'Frame #';
    elseif get(handles.radio_seconds, 'Value')
        t = frame2sec(frames);
        mintime = handles.appData.mintime;
        Xaxis_Label = 'time [s]';
    end

    figure(handles.XTfig);
%     plot(t - mintime, displacements, '.-');
    if ~isempty(t)
        plot(t, displacements, '.-');
        xlabel(Xaxis_Label);
        ylabel([yaxislabel ' bead position [', yunits, ']']);
        legend(mylegend, 'Location', 'northwest');    
        set(handles.XTfig, 'Units', 'Normalized');
%         set(handles.XTfig, 
        grid on
    %     set(handles.XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    else
        clf;
    end

    drawnow;
    pretty_plot;
    
    
function Plot_AUXfig(handles)
    AUXfig = handles.AUXfig;         
    AUXtype = handles.AUXtype;
    
    if ~strcmp(AUXtype,'OFF')
        try
            set(AUXfig, 'Visible', 'on');            
        catch
            handles = init_AUXfig(handles);
            set(handles.AUXfig, 'Visible', 'on');            
        end
        
        clf(handles.AUXfig);
    end        
    
    switch handles.AUXtype
        case 'OFF'
            set(AUXfig, 'Visible', 'off');

        case 'radial vector'
            handles.appData.plots.radial = prep_radial_vector_plot(handles);            
            plot_radial_vector(handles.appData.plots.radial, handles.appData.LengthUnits, AUXfig);
            
        case 'sensitivity (SNR)'
            handles.appData.plots.sens = calculate_sensitivity(handles);
            plot_sensitivity(handles.appData.plots.sens, AUXfig);
        
        case 'center intensity'            
            handles.appData.plots.CenterIntensity = calculate_center_intensity(handles);
            plot_center_intensity(handles.appData.plots.CenterIntensity, AUXfig);

        case 'velocity'
            handles.appData.plots.Velocity = prep_velocity_plot(handles);
            plot_velocity(handles.appData.plots.Velocity, AUXfig);
            
        case 'velocity magnitude'
            handles.appData.plots.VelMag = prep_velmag_plot(handles);
            plot_velocity_magnitude(handles.appData.plots.VelMag, AUXfig);

        case 'velocity rosehist (active)'
            handles.appData.plots.VelRoseHist = prep_velocity_rosehistogram_plot(handles);
            plot_velocity_rosehistograms(handles.appData.plots.VelRoseHist, AUXfig, true);
            
        case 'velocity rosehist (all)'
            handles.appData.plots.VelRoseHistAll = prep_velocity_rosehistogram_plot(handles);
            plot_velocity_rosehistograms(handles.appData.plots.VelRoseHistAll, AUXfig);

        case 'velocity histograms (xy)'
            handles.appData.plots.VelHist = prep_velocity_histogram_plot(handles);
            plot_velocity_histograms(handles.appData.plots.VelHist, AUXfig);
            
        case 'velocity scatter (all)'
            handles.appData.plots.VelScatterAll = prep_VelScatter_plot(handles);
            plot_velocity_scatter(handles.appData.plots.VelScatterAll, AUXfig);
            
        case 'velocity scatter (active)'            
            handles.appData.plots.VelScatterActive = prep_VelScatter_plot(handles);
            plot_velocity_scatter(handles.appData.plots.VelScatterActive, AUXfig, true);

        case 'velocity vectorfield'            
            handles.appData.plots.VelField = prep_VelField_plot(handles);
            plot_VelField(handles.appData.plots.VelField, AUXfig);
            
        case 'velocity curl'
            handles.appData.plots.VelCurl = calculate_curl(handles);
            plot_curl(handles.appData.plots.VelCurl, AUXfig);
   
        case 'vel. mag. scalarfield'            
            handles.appData.plots.VelMag = prep_VelMagScalarField_plot(handles);
            plot_VelMagScalarField(handles.appData.plots.VelMag, AUXfig);
            
        case 'forceXY'
            handles.appData.plots.ForceXY = prep_forceXY_plot(handles);
            plot_forceXY(handles.appData.plots.ForceXY, AUXfig);
            
        case 'force magnitude'
            handles.appData.plots.ForceMag = prep_forceMag_plot(handles);
            plot_force_magnitude(handles.appData.plots.ForceMag, AUXfig);
            
        case 'force vs distance (all)'
            handles.appData.plots.ForceVsDistanceAll = prep_ForceVsDistance_plot(handles);
            plot_forcevsdistance(handles.appData.plots.ForceVsDistanceAll, AUXfig);                                   

        case 'force vs distance (active)'
            handles.appData.plots.ForceVsDistanceActive = prep_ForceVsDistance_plot(handles);
            plot_forcevsdistance(handles.appData.plots.ForceVsDistanceActive, AUXfig, true);            
        
        case 'force scatter (all)'
            handles.appData.plots.ForceScatterAll = prep_ForceScatter_plot(handles);
            plot_force_scatter(handles.appData.plots.ForceScatterAll, AUXfig);            
        
        case 'force scatter (active)'
            handles.appData.plots.ForceScatterActive = prep_ForceScatter_plot(handles);
            plot_force_scatter(handles.appData.plots.ForceScatterActive, AUXfig, true);            
        
        case 'force vectorfield'
            handles.appData.plots.ForceVectorField = prep_ForceVectorField_plot(handles);
            plot_force_vectorfield(handles.appData.plots.ForceVectorField, AUXfig);            

            
%         case 'displacement hist'        
        case 'old MSD (fast)'
            if handles.appData.recomputeMSD
                handles.appData.plots.MSD = prep_old_MSD_plot(handles);
            end
            plot_old_MSD(handles.appData.plots.MSD, AUXfig);
            handles.appData.recomputeMSD = 0;

        case 'new MSD (slow)'
            if handles.appData.recomputeMSD
                handles.appData.plots.MSD = prep_new_MSD_plot(handles);
            end
            plot_new_MSD(handles.appData.plots.MSD, AUXfig);
            handles.appData.recomputeMSD = 0;
            
        case 'GSER'
            if handles.appData.recomputeMSD
                handles.appData.plots.MSD = prep_old_MSD_plot(handles);
            end
            plot_GSER(handles.appData.plots.MSD, AUXfig);
            handles.appData.recomputeMSD = 0;
            
        case 'RMS displacement'
            if handles.appData.recomputeMSD
                handles.appData.plots.MSD = prep_old_MSD_plot(handles);
            end
            %plot_GSER(handles.appData.plots.MSD, AUXfig);
            evt_plot_rmsdisp(handles.appData.plots.MSD, AUXfig);
            handles.appData.recomputeMSD = 0;
            
        case 'alpha vs tau'   
            if handles.appData.recomputeMSD
                handles.appData.plots.MSD = prep_old_MSD_plot(handles);
            end
            evt_plot_alphatau(handles.appData.plots.MSD, AUXfig);
            handles.appData.recomputeMSD = 0;
            
        case 'alpha histogram'
            if handles.appData.recomputeMSD
                handles.appData.plots.MSD = prep_old_MSD_plot(handles);
            end
            evt_plot_alphadist(handles.appData.plots.MSD, AUXfig)
            handles.appData.recomputeMSD = 0;
            
        case 'MSD histogram'
            logentry('Not yet implemented, or implementation is deprecated.');
        case 'Diffusivity @ a tau'
            logentry('Not yet implemented, or implementation is deprecated.');
        case 'Diffusivity vs. tau'
            logentry('Not yet implemented, or implementation is deprecated.');
        case 'temporal MSD'
            logentry('Not yet implemented, or implementation is deprecated.');
        case 'PSD'        
            logentry('Not yet implemented, or implementation is deprecated.');
        case 'Integrated Disp'                 
            logentry('Not yet implemented, or implementation is deprecated.');
            
        case 'pole locator'
%             logentry('Not yet implemented, or implementation is deprecated.');
            handles.appData.plots.PoleLocation = calculate_pole_location(handles);
            str_poleloc = [num2str(handles.appData.plots.PoleLocation(1)), ',', ...
                           num2str(handles.appData.plots.PoleLocation(2))];
            logentry(['Pole located at: (', num2str(pixel2um(handles.appData.plots.PoleLocation)), ') [microns]']);
            set(handles.radio_arb_origin, 'Value', 1);
            set(handles.radio_relative, 'Value', 0);
            set(handles.edit_arb_origin, 'String', str_poleloc);
            Plot_XYfig(handles);
            
            
            
        case 'tracker avail'
            handles.appData.plots.TrackerAvail = calculate_tracker_availability(handles);
            plot_tracker_availability(handles.appData.plots.TrackerAvail, AUXfig)

        case '2pt MSD ~~not implemented yet~~'

    end
    
    pretty_plot;
    
    assignin('caller', 'handles', handles);
        
    return    
    

function handles = delete_selected_dataset(handles)
    
    OldTrackingHeight = height(handles.appData.TrackingTable);
    OldTrashHeight = height(handles.appData.Trash);
    
    bead_to_remove = handles.appData.CurrentBead;    
    
    k = (handles.appData.TrackingTable.ID == bead_to_remove);
    

%     NewTrash = handles.appData.TrackingTable(k,:);
%     
%     handles.appData.Trash = [handles.appData.Trash; NewTrash];
    handles.appData.TrackingTable(k,:) = [];        
    
%     NewTrackingHeight = height(handles.appData.TrackingTable);
%     NewTrashHeight = height(handles.appData.Trash);
%     
%     disp([' height(TrackingTable)=', num2str(OldTrackingHeight), ...
%          ', height(Trash)= ', num2str(OldTrashHeight), ...
%          ', Deleting beadID= ', num2str(bead_to_remove), ...
%          ', NumRowsRemoved= ', num2str(sum(k)), ...
%          ', height(NewTrash)= ', num2str(NewTrashHeight), ...
%          ', height(NewTrackingTable)= ', num2str(NewTrackingHeight), ...
%          '. ']);


%     handles = delete_data(handles,k);
    

    return


function selection = select_by_boundingbox(handles)

    % First, determine which figure is active.
    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    else
        logentry('Deleting data from the AUXplot is not (yet) allowed.');
        return
    end
         
    % Select the active figure from which we will collect the mouse-locations
    figure(active_fig);

    % Extract the bounds of the box based on selected units
    % xm, ym = xmouseclick, ymouseclick
    [clickX, clickY] = ginput(2);
    
    % If the figures are in their default units t in [s] and xy in
    % [pixels], then there is no need to scale the clicks.
    Xedges = clickX;
    Yedges = clickY;

    %
    % If we are using the XT fig, and its time units are in 'frames', 
    % then covert the click to be in "seconds" (because, unfortunately, 
    % that's the base unit in evt_GUI until someone changes it.
    if handles.radio_XTfig.Value && handles.radio_frames.Value
        Xedges = frame2sec(Xedges);
    end

    % In the XY plot, if the clicks are in [microns], convert them to
    % [pixels].
    if handles.radio_XYfig.Value && handles.radio_microns.Value
        [Xedges, Yedges] = um2pixel(Xedges, Yedges);
    end    

    % Now that everything is scaled properly, we can deconstruct the edges
    % of the box for proper selection
    Xedge_lo = min(Xedges);
    Xedge_hi = max(Xedges);
    Yedge_lo = min(Yedges);
    Yedge_hi = max(Yedges);
    
    % debug output
    fprintf('clickX = [%4.1f, %4.1f], Xedges = [%4.1f, %4.1f]\n', clickX(1), clickX(2), Xedge_lo, Xedge_hi);
    fprintf('clickX = [%4.1f, %4.1f], Xedges = [%4.1f, %4.1f]\n', clickY(1), clickY(2), Yedge_lo, Yedge_hi);

    % At least for now, the selection should only apply to the current bead
    currentbead = handles.appData.CurrentBead;
    
    % The XT plot, uses neutralized time, so add back the offset
    t = handles.appData.TrackingTable.Frame / handles.appData.fps; % [sec]
    x = handles.appData.TrackingTable.X; % [pixels]
    y = handles.appData.TrackingTable.Y; % [pixels]

    if get(handles.radio_XYfig, 'Value')
        k = ( x > Xedge_lo & x < Xedge_hi & ...
              y > Yedge_lo & y < Yedge_hi & ...
              handles.appData.TrackingTable.ID == currentbead);
    elseif get(handles.radio_XTfig, 'Value')
        k = ( t > Xedge_lo & t < Xedge_hi )   & ...
              handles.appData.TrackingTable.ID == currentbead;
    elseif get(handles.radio_AUXfig, 'Value')
        logentry('Deleting data from AUX plot is not allowed.');
        return
    end

    selection = k;
    

function handles = delete_inside_boundingbox(handles)    

    sel = select_by_boundingbox(handles);
    
%     NewTrash = handles.appData.TrackingTable(sel,:);
%     handles.appData.Trash = [handles.appData.Trash; NewTrash];
%     
%     if isempty(handles.appData.Trash)
%         handles.appData.Trash = NewTrash;
%     else
%         handles.appData.Trash = [handles.appData.Trash; NewTrash];
%     end
    
    handles = delete_data(handles, sel);
return


function handles = delete_data(handles, sel)
    
%     NewTrash = handles.appData.TrackingTable(sel,:);        
%     handles.appData.Trash = [handles.appData.Trash; NewTrash];
    
    handles.appData.TrackingTable(sel,:) = [];
    handles.appData.RadialTable(sel,:) = [];
    handles.appData.VelocityTable(sel,:) = [];
    
        
%     NewTrackingHeight = height(handles.appData.TrackingTable);
%     NewTrashHeight = height(handles.appData.Trash);
%     
%         disp([' height(TrackingTable)=', num2str(OldTrackingHeight), ...
%          ', height(Trash)= ', num2str(OldTrashHeight), ...
%          ', Deleting beadID= ', num2str(bead_to_remove), ...
%          ', NumRowsRemoved= ', num2str(sum(k)), ...
%          ', height(NewTrash)= ', num2str(NewTrashHeight), ...
%          ', height(NewTrackingTable)= ', num2str(NewTrackingHeight), ...
%          '. ']);
     
    handles = SelectBead(handles);
return
        
    

function handles = delete_outside_boundingbox(handles)

    sel = select_by_boundingbox(handles);

    T = handles.appData.TrackingTable;
%     Trash = handles.appData.Trash;

    
    % The data to keep is what's inside the bounding box. 
    %
    % For XY, this means that ANYTHING outside that box is deleted.
    if handles.radio_XYfig.Value
        NewTrash = T(~sel,:);
%         Trash = vertcat(Trash, NewTrash);   
        T(~sel,:) = [];
    end

    % For XT, the currentbead matters. Delete anything outside the box for
    % THAT BEAD ONLY
    if handles.radio_XTfig.Value

        % The selection is a subset of points in the original table.
        BeadPointsToKeep = T(sel,:);

        % The points should always be constrained to a single beadID since
        % that's all we ever plot in the XTfig.
        ThisBeadID = unique(BeadPointsToKeep.ID);

        % Pull out the entire bead of interest from the original table
        Tbead = T( T.ID == ThisBeadID, :);

        % Remove the entire bead from the original table. We'll add back a
        % segment of it later.
        T = T(T.ID ~= ThisBeadID,:);

        % List all the frames that this original bead path owned
        AllFrames = unique(Tbead.Frame);

        % List the frames we want to keep
        FramesToKeep = unique(BeadPointsToKeep.Frame);

        % To partition all the points in Tbead, look for the intersection.
        % ia contains the locations for the points that do intersect 
        % ib contains locations where they do NOT intersect 
        [~, ia, ib] = intersect(Tbead.Frame, FramesToKeep);
        Tkeep = Tbead(ia,:);
        Ttoss = Tbead(ib,:);
        
        % concatenate everything back together properly and resort
%         Trash = vertcat(Trash, Ttoss);
        T = [T; Tkeep];
        T = sortrows(T, {'Fid', 'Frame', 'ID'});

    end

%     handles = delete_data(handles
    handles.appData.TrackingTable = T;
%     handles.appData.Trash = Trash;


function closest_time = select_time_from_XTfig(handles) 
    handles.appData.Activefig = handles.XTfig;
    handles.radio_XTfig.Value = 1;

    figure(handles.XTfig);
    [tm, xm] = ginput(1);
    
    if handles.radio_frames.Value
        tm = frame2sec(tm);
    end

    time = handles.appData.Bead.TrackingTable.Frame / handles.appData.fps; % [sec]

    % find the closest time point to mouse click
    dists = abs(time - tm);    
    
    % identify time
    [~,idx] = min(dists);
    closest_time = time(idx(1));


function handles = delete_data_before_time(handles)
 
    closest_time = select_time_from_XTfig(handles);    
        
    time = handles.appData.TrackingTable.Frame / handles.appData.fps;
    
    % remove any points in the TrackingTable that have times earlier than our
    % prescribed beginning time point
    idx = (time <= closest_time);    
    
    handles = delete_data(handles, idx);
    

    
function handles = delete_data_after_time(handles)

    closest_time = select_time_from_XTfig(handles);    
        
    time = handles.appData.TrackingTable.Frame / handles.appData.fps;
    
    % remove any points in the TrackingTable that have times earlier than our
    % prescribed beginning time point
    idx = (time >= closest_time);    
    
    handles = delete_data(handles, idx);
    
    

function rheo = calc_viscosity_stds(hObject, eventdata, handles) 
    kB = 1.3806e-23; % [m^2 kg s^-2 K^-1];
    temp_K = 296; % [K]
        
    numtaus = str2double(get(handles.edit_chosentau, 'String'));
    framemax = max(handles.appData.TrackingTable.Frame);
    tau = msd_gen_taus(framemax, numtaus, 1);
    
    bead_radius_m = handles.appData.BeadRadius_m;
    
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



function RadialTable = CalculateRadialLocations(TrackingTable, XYZo)


    if nargin < 2
        XYZo = zeros(0,3);
    end
    
    if ~isempty(XYZo) && numel(XYZo) ~= 3
        error('Something is incorrect about the origin of the coordinates.');
    end

    
    
    g = findgroups(TrackingTable(:, {'Fid', 'ID'}));
    rout = splitapply(@(x1,x2,x3,x4){sa_calc_rad_vecs(x1,x2,x3,x4,XYZo)}, ...
                                                          TrackingTable.Fid, ...
                                                          TrackingTable.ID, ...
                                                          TrackingTable.Frame, ...
                                                         [TrackingTable.X, ...
                                                          TrackingTable.Y, ...
                                                          TrackingTable.Z], ...
                                                          g);           
     rout = cell2mat(rout);
     
     RadialTable = table(rout(:,1), rout(:,2), rout(:,3), rout(:,4));
     RadialTable.Properties.VariableNames = {'Fid', 'ID', 'Frame', 'Rxyz'};

return


function outs = sa_calc_rad_vecs(fid, id, frame, XYZ, XYZorigin)

    if nargin<5 || isempty(XYZorigin)
        XYZorigin = XYZ(1,:);
    end

    rout = sqrt( sum( (XYZ - XYZorigin).^2, 2 ) );    
    
    outs = [fid, id, frame, rout];
return


% function VelocityTable = CalculateVelocity(TrackingTable)
% % Outputs the velocities in the default format, which is [pixels/frame] and
% % leaves the scaling to the invidual functions as needed.
% 
% % XXX TODO: Add a smoothing scale to UI and CreateGaussScaleSpace call.
% 
%     if isempty(TrackingTable)
%         VelocityTable = init_velocity_table;
%         return
%     end
%     
%     [g, gT] = findgroups(TrackingTable.Fid, TrackingTable.ID);    
%     
%     smooth_factor = 1;
%     if ~isempty(g)
%         Vel = splitapply(@(x1,x2,x3,x4){vst_CalcVel(x1,x2,x3,x4,smooth_factor)}, ...
%                                                               TrackingTable.Fid, ...            
%                                                               TrackingTable.Frame, ...
%                                                               TrackingTable.ID, ...
%                                                              [TrackingTable.X, ...
%                                                               TrackingTable.Y, ...
%                                                               TrackingTable.Z], ...
%                                                               g);
%         Vel = cell2mat(Vel);
%     else
%         Vel = NaN(0,5);
%     end
%         
%     VelTable.Fid   = Vel(:,1);
%     VelTable.Frame = Vel(:,2);
%     VelTable.ID    = Vel(:,3);
%     VelTable.Vx    = Vel(:,4);
%     VelTable.Vy    = Vel(:,5);
%     VelTable.Vz    = Vel(:,6);
%     VelTable.Vr    = calculate_mag(Vel(:,4:6));
%     VelTable.Vtheta = calculate_angle(Vel(:,4:6));
%     VelTable.Vclr = Calculate_Velocity_ColorMap(VelTable.Vr);
%     
%     VelocityTable = struct2table(VelTable);    
%     
%      
%     
% return


    
    
function NativeXYZ = RemoveXYScaleAndOffset(xyz, handles)
    % XYZoffsets = the neutralization offsets for the XT plot
    XYZoffsets = handles.appData.XYZoffsets;
    calibum = handles.appData.calibum;
   
    if size(xyz,2) < 3
        C = size(xyz,2);
        xyz(:, C:3) = 0;
    end

    xyz = xyz + XYZoffsets;
%     zm = zm + XYZoffsets(3);
    xyz = xyz / calibum;
        
    NativeXYZ = xyz;

    return


function varargout = pixel2um(varargin)
    myUI = findall(0, 'Tag', 'evt_GUI');
    handles = guihandles(myUI);
    calibum = str2double(get(handles.edit_calibum, 'String'));
    varargout = cellfun(@(x)(x .* calibum), varargin, 'UniformOutput', false);
return


function varargout = um2pixel(varargin)
    myUI = findall(0, 'Tag', 'evt_GUI');
    handles = guihandles(myUI);
    calibum = str2double(get(handles.edit_calibum, 'String'));
    varargout = cellfun(@(x)(x ./ calibum), varargin, 'UniformOutput', false);
return


function varargout = frame2sec(varargin)
    myUI = findall(0, 'Tag', 'evt_GUI');
    handles = guihandles(myUI);
    fps = str2double(get(handles.edit_frame_rate, 'String'));
    varargout = cellfun(@(x) (x ./ fps), varargin, 'UniformOutput', false);
return


function varargout = sec2frame(varargin)
    myUI = findall(0, 'Tag', 'evt_GUI');
    handles = guihandles(myUI);
    fps = str2double(handles.edit_frame_rate.String);
    varargout = cellfun(@(x) (x .* fps), varargin, 'UniformOutput', false);
return


function radial = prep_radial_vector_plot(handles)

    Tbead = handles.appData.Bead.TrackingTable; % [pixels]
    Rbead = handles.appData.Bead.RadialTable.Rxyz;

    mintime = handles.appData.mintime;
    
    units = 'pixels';
    
    if isempty(Tbead)
        radial.t = [];
        radial.r = [];
        return
    end
    
    t = Tbead.Frame / handles.appData.fps; 
    t = t - mintime;

    if handles.radio_microns.Value         
        Rbead = pixel2um(Rbead);            
        units = 'microns';
    end

    radial.t = t;
    radial.r = Rbead;
    radial.TimeUnits = 'fix the code here';
    radial.LengthUnits = units;

return

function plot_radial_vector(radial, LengthUnits, h)    
    
    figure(h);
    plot(radial.t, radial.r, '.-');
    xlabel('time (s)');
    ylabel(['radial displacement [' LengthUnits ']']);
    drawnow;
 return

 
function outs = calculate_sensitivity(handles)
    mintime = handles.appData.mintime;
    t = handles.appData.TrackingTable.Frame / handles.appData.fps;
    s = handles.appData.TrackingTable.Sensitivity;
    idx = handles.appData.CurrentBeadRows;
    
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
 

function outs = calculate_tracker_availability(handles)
    
    CurrentBeadRows = handles.appData.CurrentBeadRows;
    
    outs.CurrentBead.Frame = handles.appData.TrackingTable.Frame(CurrentBeadRows);
    outs.CurrentBead.ID = handles.appData.TrackingTable.ID(CurrentBeadRows);
    outs.OtherBeads.Frame = handles.appData.TrackingTable.Frame(~CurrentBeadRows);
    outs.OtherBeads.ID = handles.appData.TrackingTable.ID(~CurrentBeadRows);
return


function plot_tracker_availability(TrackerAvail, h)
    figure(h);
    clf;
    hold on;
        plot(TrackerAvail.CurrentBead.Frame, ...
             TrackerAvail.CurrentBead.ID, 'r.');
         
        plot(TrackerAvail.OtherBeads.Frame, ...
             TrackerAvail.OtherBeads.ID, 'b.');
    hold off;    
    xlabel('Frame#');
    ylabel('Tracker ID');
    drawnow;
return


function outs = calculate_center_intensity(handles)

    t = handles.appData.TrackingTable.Frame / handles.appData.fps;
    c = handles.appData.TrackingTable.CenterIntensity;
    
    idx = handles.appData.CurrentBeadRows;
    
    mintime = handles.appData.mintime;
        
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


function outs = prep_velocity_plot(handles, reqTimeUnits, reqLengthUnits)
% "requested Time Units" and "requested Length Units"    
%     LengthUnits = 'pixels';
%     LengthUnits = 'microns';
%     TimeUnits = 'frames';
%     TimeUnits = 'seconds';

%     idx = handles.appData.CurrentBeadRows;    

    tmpTable = innerjoin(handles.appData.Bead.RadialTable, handles.appData.Bead.VelocityTable, 'Keys', {'Fid', 'ID', 'Frame'});
        
    Frame = tmpTable.Frame;
    Rxyz = tmpTable.Rxyz;
    VelX = tmpTable.Vx;
    VelY = tmpTable.Vy;
    VelZ = tmpTable.Vz;
    VelR = tmpTable.Vr;
%     VelTheta = tmpTable.Vtheta;
    Velclr = Calculate_Velocity_ColorMap(VelR);
    
    % Get the velocities into the desired units
    
    % First, length scales
    if (nargin < 3 || isempty(reqLengthUnits)) && handles.radio_microns.Value
        reqLengthUnits = 'microns';
    elseif (nargin < 3 || isempty(reqLengthUnits))        
        reqLengthUnits = 'pixels';
    end
        
    switch reqLengthUnits
        case 'microns'
            [rxyz, vX, vY, vZ] = pixel2um(Rxyz, VelX, VelY, VelZ);
            Rxyz = rxyz; VelX = vX; VelY = vY; VelZ = vZ;
            LengthUnits = 'microns';            
        case 'pixels'
            LengthUnits = 'pixels';
        otherwise
            error('Undefined Length Unit.');
    end

    
    % Next, time scales
    if (nargin < 2 || isempty(reqTimeUnits)) && handles.radio_seconds.Value
        reqTimeUnits = 'seconds';
    elseif (nargin < 2 || isempty(reqTimeUnits))
        reqTimeUnits = 'frames';
    end

    switch reqTimeUnits
        case 'seconds'
            % This is a velocity, where "frames" is in the denominator. For a
            % clean conversion (and not screw up numerator conversions later,
            % we need to invert before we convert and then reinvert after the
            % conversion is made. Really screwy way to do this, so maybe the
            % best thing to do is create separate scaling functions?
            [Time, iX, iY, iZ] = frame2sec(Frame, 1./VelX, 1./VelY, 1./VelZ);
            VelX = 1./iX; VelY = 1./iY; VelZ = 1./iZ;
            TimeUnits = '[s]';
            VelTimeUnits = 's';        
        case 'frames'
            Time = Frame;
            TimeUnits = '[frames]';
            VelTimeUnits = 'frame';
        otherwise
            error('Undefined time scale unit.');
    end
    
    
    outs.Time = Time;
    outs.Rxyz = Rxyz;
    outs.VelX = VelX;
    outs.VelY = VelY;
    outs.VelZ = VelZ;
%     outs.VelR = VelR;
%     outs.VelTheta = VelTheta;
    outs.Velclr = Velclr;
    
    outs.LengthUnits = LengthUnits;
    outs.TimeUnits = TimeUnits;
    outs.VelUnits = ['[', LengthUnits, '/', VelTimeUnits, ']'];
    
    logentry(['Velocity, mean +/- SD, ', outs.VelUnits, ': ', num2str(mean([outs.VelX(:), outs.VelY(:)])), std([outs.VelX(:), outs.VelY(:)])]);
return


function plot_velocity(Velocity, h)
    figure(h);
    clf;
    plot(Velocity.Time, [Velocity.VelX Velocity.VelY], '.-');
    xlabel(['time, ' Velocity.TimeUnits]);
    ylabel(['velocity, ' Velocity.VelUnits]);
    legend('x', 'y');
    grid on;
    drawnow;
return


function outs = prep_velmag_plot(handles)

    vel = prep_velocity_plot(handles);
    outs = vel;
        
    outs.VelMag = calculate_mag([vel.VelX, vel.VelY, vel.VelZ]);
    outs.VelTheta = calculate_angle([vel.VelX, vel.VelY]);
return

function outs = prep_velocity_rosehistogram_plot(handles)

    vel = prep_VelScatter_plot(handles);
    outs = vel;
    
return

function plot_velocity_rosehistograms(VelScatter, h, ActiveOnlyTF)
    if nargin < 3 || isempty(ActiveOnlyTF)
        ActiveOnlyTF = false;
    end

    
    idx = VelScatter.idx;
    
    if ActiveOnlyTF
        vr = VelScatter.vr(idx);
        vtheta = VelScatter.vtheta(idx);       
    else
        vr = VelScatter.vr;
        vtheta = VelScatter.vtheta;
    end
    
    figure(h);
    clf;    
    h = polarhistogram(vtheta);
    h.DisplayStyle = 'stairs';
    h.Normalization = 'pdf';
    hold on;
    
    clrmap = lines(6);
    
    vtheta_mean = mean(vtheta);
    vmag_mean = mean(vr);
    
    
%     vals = mag/2 .* h.Values ./ max(h.Values);
%     h.Values = vals;
    
    hold on
    
    polarscatter(vtheta, vr, '.', 'MarkerEdgeColor', clrmap(3,:));
    q = polarplot([0 vtheta_mean], [0 vmag_mean], 'r', 'LineWidth', 2);
    grid on;
    drawnow;   
return


function plot_velocity_magnitude(Velocity, h)
    figure(h);
    clf;
    plot(Velocity.Time, Velocity.VelMag, '.-');
    xlabel(['time, ' Velocity.TimeUnits]);
    ylabel(['|v|, ' Velocity.VelUnits]);    
    grid on;
    drawnow;
return

function outs = prep_velocity_histogram_plot(handles)
    
    T = handles.appData.VelocityTable;

    outs.Vx = T.Vx * 0.692 * 50; % [pixels/frame -> um/sec]
    outs.Vy = T.Vy * 0.692 * 50; % [pixels/frame -> um/sec]
    
    logentry(['X velocity (median ± MAD): ' num2str(median(outs.Vx)) ' ± ' num2str(mad(outs.Vx)) ]);
    logentry(['Y velocity (median ± MAD): ' num2str(median(outs.Vy)) ' ± ' num2str(mad(outs.Vy)) ]);
                    
return


function plot_velocity_histograms(Velocity, h)
    figure(h);
    clf;
    histogram(Velocity.Vx)
    hold on;
    histogram(Velocity.Vy)
    hold off
    xlabel('velocity, [\mum/s]');
    ylabel('counts');    
    legend('X', 'Y');
    xlim([-80 80])
    grid on;
    drawnow;
return

function outs = prep_VelScatter_plot(handles, reqTimeUnits, reqLengthUnits)
    
    CurrentBead = handles.appData.CurrentBead;
    
    im = handles.appData.im;
    xr = [0 size(im,2)];
    yr = [0 size(im,1)];
    
    % separate the currently selected bead vs not the selected bead
    
    T = innerjoin(handles.appData.TrackingTable, handles.appData.RadialTable);
    T = innerjoin(T, handles.appData.VelocityTable);
    
% %     % Filter out the first and last velocity value (avoids edge effects in
% %     % the visualization.
% %     filt.tcrop = 2;
% %     
% %     T = vst_filter_tracking(T, filt);

    % XXX TODO Change all of these weird structures into tables derived
    % from the TrackingTable, or subtables tied to the TrackingTable. This
    % should help to minimize cross-function recalculation.
    %
    
    % Pull out relevant info. Defaults units are pixels/frame
    Frame = T.Frame;
    X = T.X;
    Y = T.Y;
    Z = T.Z;
    R = T.Rxyz;
    Vx = T.Vx;
    Vy = T.Vy;
    Vz = T.Vz;
    Vr = T.Vr;
    
    % Get the velocities into the desired units ...
    
    % First, length scales
    if (nargin < 3 || isempty(reqLengthUnits)) && handles.radio_microns.Value
        reqLengthUnits = 'microns';
    elseif (nargin < 3 || isempty(reqLengthUnits))        
        reqLengthUnits = 'pixels';
    end
    
    switch reqLengthUnits
        case 'microns'
            [X, Y, Z, R, xr, yr, Vx, Vy, Vz, Vr] = pixel2um(X, Y, Z, R, xr, yr, Vx, Vy, Vz, Vr);
            LengthUnits = 'microns';
        case 'pixels'
            LengthUnits = 'pixels';    
        otherwise
            error('Undefined Length Scale');
    end
    
%     if handles.radio_microns.Value
%     else
%     end
    
    % Next, time scales
    if (nargin < 2 || isempty(reqTimeUnits)) && handles.radio_seconds.Value
        reqTimeUnits = 'seconds';
    elseif (nargin < 2 || isempty(reqTimeUnits))
        reqTimeUnits = 'frames';
    end
    
    switch reqTimeUnits
        case 'seconds'
            % This is a velocity, where "frames" is in the denominator. For a
            % clean conversion (and not screw up numerator conversions later,
            % we need to invert before we convert and then reinvert after the
            % conversion is made. Really screwy way to do this, so maybe the
            % best thing to do is create separate scaling functions?
            [Time, ix, iy, iz, ir] = frame2sec(Frame, 1./Vx, 1./Vy, 1./Vz, 1./Vr);
            Vx = 1./ix; Vy = 1./iy; Vz = 1./iz; Vr = 1./ir;
            TimeUnits = '[s]';
            VelTimeUnits = 's';                   
        case 'frames'
            Time = Frame;
            TimeUnits = '[frames]';
            VelTimeUnits = 'frame';
        otherwise
            error('Undefined time scale unit.');
    end
    
%     if handles.radio_seconds.Value
%     else
%     end
    
    Vclr = Calculate_Velocity_ColorMap(Vr);
    
    outs.im   = handles.appData.im;   
    outs.xrange = xr;
    outs.yrange = yr;
    outs.id   = categorical(T.ID);
    outs.idx  = (T.ID == CurrentBead);
    outs.x    = X;
    outs.y    = Y;
    outs.z    = Z;
    outs.r    = R;
    outs.vx   = Vx;
    outs.vy   = Vy;
    outs.vz   = Vz;
    outs.vr   = Vr;
    outs.vtheta = calculate_angle([Vx Vy]);
    outs.vclr = Vclr;
    outs.LengthUnits = LengthUnits;
    outs.VelUnits = ['[', LengthUnits, '/', VelTimeUnits, ']'];
    
    assignin('base', 'TrackerVelocitiesFromEVT', outs);
    logentry(['Velocity, mean +/- SD, ', outs.VelUnits, ': [', num2str(mean([Vx(:), Vy(:)])), '], ', '[', num2str(std([Vx(:), Vy(:)])), '].']);
return


function plot_velocity_scatter(VelScatter, h, ActiveOnlyTF)

    im = VelScatter.im;
    idx = VelScatter.idx;
    
    if nargin < 3 || isempty(ActiveOnlyTF)
        ActiveOnlyTF = false;
    end
    
    figure(h);
    clf;
    imagesc(VelScatter.xrange, VelScatter.yrange, im);
    colormap(gray(256));
    hold on;

   [g, gT] = findgroups(VelScatter.id);


    if ActiveOnlyTF
%             plot(VelScatter.x(~idx), VelScatter.y(~idx), 'b.');
        scatter(VelScatter.x(idx), VelScatter.y(idx), 10, VelScatter.vclr(idx,:), 'filled');
    else
        splitapply(@(x1,x2)plot(x1, x2, 'w-'), VelScatter.x, VelScatter.y, g);
        scatter(VelScatter.x, VelScatter.y, 10, VelScatter.vclr, 'filled');
    end
        
    hold off;
    xlabel(['X, ' VelScatter.LengthUnits]);
    ylabel(['Y, ' VelScatter.LengthUnits]);
    
    
    minVr = min(VelScatter.vr);
    maxVr = max(VelScatter.vr);
    set(gca, 'YDir', 'reverse');            
    
    manual_colorbar(log10([minVr maxVr]));
    title(['log_{10}(velocity), ' VelScatter.VelUnits]);

    disp(['Minimum Velocity = ' num2str(minVr) ' ' VelScatter.VelUnits '.']);
    disp(['Maximum Velocity = ' num2str(maxVr) ' ' VelScatter.VelUnits '.']);

    
    drawnow;

return

function outs = prep_VelField_plot(handles, reqTimeUnits, reqLengthUnits)
        
    NGridX = floor(25*1.33);
    NGridY = 25;
    
    im = handles.appData.im;
    
    [imy, imx] = size(im);
    
    VideoStruct.xDim = imx;
    VideoStruct.yDim = imy;
    
    % First, length scales
    if (nargin < 3 || isempty(reqLengthUnits)) && handles.radio_microns.Value
        reqLengthUnits = 'microns';
    elseif (nargin < 3 || isempty(reqLengthUnits))        
        reqLengthUnits = 'pixels';
    end
    
    switch reqLengthUnits
        case 'microns'
            VideoStruct.pixelsPerMicron = 1 / handles.appData.calibum;            
            LengthUnits = 'microns';
        case 'pixels'
            VideoStruct.pixelsPerMicron = 1;
            LengthUnits = 'pixels';    
        otherwise
            error('Undefined Length Scale');
    end
    
    
    % Next, time scales
    if (nargin < 2 || isempty(reqTimeUnits)) && handles.radio_seconds.Value
        reqTimeUnits = 'seconds';
    elseif (nargin < 2 || isempty(reqTimeUnits))
        reqTimeUnits = 'frames';
    end
    
    switch reqTimeUnits
        case 'seconds'
            VideoStruct.fps = handles.appData.fps;
            TimeUnits = 'seconds';
        case 'frames'
            VideoStruct.fps = 1;
            TimeUnits = 'frames';
        otherwise
            error('Undefined time scale unit.');
    end
    
    
    TrackingTable = handles.appData.TrackingTable;
    trajdata = convert_Table_to_old_matrix(TrackingTable, handles.appData.fps);

    VelField = vel_field(trajdata, NGridX, NGridY, VideoStruct);
    
%     VelField.Xgrid = (1:NGridX)*(VideoStruct.xDim/NGridX/VideoStruct.pixelsPerMicron);
%     VelField.Ygrid = (1:NGridY)*(VideoStruct.yDim/NGridY/VideoStruct.pixelsPerMicron);
% 
%     VelField.Xvel = reshape(VelField.sectorX, NGridX, NGridY);
%     VelField.Yvel = reshape(VelField.sectorY, NGridX, NGridY);
    
    outs.VelField = VelField;
    outs.LengthUnits = LengthUnits;
    outs.TimeUnits = TimeUnits;
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

function outs = calculate_curl(handles)
    tmp = prep_VelField_plot(handles);
    VelField = tmp.VelField;
    VideoStruct = tmp.VideoStruct;
    
%     X = repmat(VelField.Xgrid(:)', size(VelField.Ygrid(:)));
%     Y = repmat(VelField.Ygrid(:),  size(VelField.Xgrid(:)')); 
% 
%     Vx = VelField.Xvel;
%     Vy = VelField.Yvel;
    
%      P = [VelField.X,    VelField.Y];
%      V = [VelField.Velx, VelField.Vely];

     outs.VelField = VelField;
     outs.VideoStruct = VideoStruct;
     outs.Curl = curl(VelField.X, VelField.Y, VelField.Vx, VelField.Vy);
     assignin('base', 'VelocityField', outs);
     return

     
function plot_curl(CurlPlot, h)
	
    figure(h);    
%     pcolor(CurlPlot.VelField.X, CurlPlot.VelField.Y, CurlPlot.Curl);	
%     shading interp
    imagesc(CurlPlot.VelField.X(1,:), CurlPlot.VelField.Y(:,1), CurlPlot.Curl);	
    colormap(hot);
    colorbar;

    hold on;
    quiver(CurlPlot.VelField.X, CurlPlot.VelField.Y, CurlPlot.VelField.Vx, CurlPlot.VelField.Vy, 1, 'k');
    set(gca,'YDir','reverse');    
    hold off;
    
    myhot = [ones(128,1), linspace(0,1,128)', linspace(0,1,128)'];
    mycold = flipud(fliplr(myhot));
    hotcold = [myhot ; mycold(2:end,:)];
    hotcold = flipud(hotcold);
    colormap(hotcold);
    cmax = max(abs(CurlPlot.Curl(:)));    
    caxis([-cmax cmax]);
    xlim([CurlPlot.VelField.X(1,1) CurlPlot.VideoStruct.xDim]);
    ylim([CurlPlot.VelField.Y(1,1) CurlPlot.VideoStruct.yDim]);
    
    return

        
function VelMag = prep_VelMagScalarField_plot(handles)
    VelMag = prep_VelField_plot(handles);
    VelMag = VelMag.VelField;
    
    Vmag = sqrt(VelMag.Vx.^2 + VelMag.Vy.^2);        
    Vmag(Vmag<0.001) = NaN;
    Vmag(isnan(Vmag)) = min(Vmag(~isnan(Vmag)));
    
    VelMag.Vmag = Vmag;
return


function plot_VelMagScalarField(VelMag, h)    
    figure(h);
    imagesc(VelMag.X(1,:), VelMag.Y(:,1), log10(VelMag.Vmag')); 
    colormap(hot);
    xlabel('\mum')
    ylabel('\mum')
    title('Vel. [microns/s]');
    colorbar;
    pretty_plot;   
return


function PoleLoc = calculate_pole_location(handles)
    PoleLoc = pole_locator(handles.appData.TrackingTable, [], 'y', handles.AUXfig);
return


function outs = prep_forceXY_plot(handles)

    Velocity = prep_velocity_plot(handles, 'seconds', 'microns');
       
    outs = Velocity;
    outs.Viscosity_Pas = handles.appData.Viscosity_Pas;
    outs.BeadRadius_m = handles.appData.BeadRadius_m;
    outs.ForceScale = handles.appData.ForceScale;
    [outs.ForceX, outs.ForceY] = calculate_forces(handles.appData.ForceScale, Velocity.VelX, Velocity.VelY);
    outs.ForceUnits = 'N';

return

function plot_forceXY(ForceXY, h)
    figure(h);
    clf;
    plot(ForceXY.Time, [ForceXY.ForceX, ForceXY.ForceY]*1e9, '.-');
    xlabel(['time, ' ForceXY.TimeUnits]);
    ylabel(['force, [nN]']);
    legend('x', 'y');
return


function outs = prep_forceMag_plot(handles)
    outs = prep_forceXY_plot(handles);      
    
    outs.ForceMag = calculate_mag([outs.ForceX, outs.ForceY]);
return


function plot_force_magnitude(Force, h)
    figure(h);
    clf;
    plot(Force.Time, Force.ForceMag*1e9, '.-');
    xlabel(['time, ' Force.TimeUnits]);
    ylabel(['|F|, [nN]']);    
    grid on;
    drawnow;
return

        
function outs = prep_ForceVsDistance_plot(handles)
    
    F = prep_ForceScatter_plot(handles);     
    
    mindist = min(F.r);
    maxdist = max(F.r);
    
    [g,gT] = findgroups(F.id);
    interp_grid(:,1) = linspace(mindist, maxdist, 100);

    interp_Force = splitapply(@(x,y){sa_interp_forces(x,y,interp_grid)}, F.r, F.Fr, g);
    
    Fmat = cell2mat(interp_Force');
    
    outs.idx = F.idx;
    outs.Distance = F.r;
    outs.LengthUnits = F.LengthUnits;
    outs.ForceMag = F.Fr;
    outs.ForceUnits = F.ForceUnits;
    outs.DistanceGrid = interp_grid;
    outs.meanForce = mean(Fmat,2,'omitnan');
    outs.medianForce = median(Fmat, 2, 'omitnan');
    outs.stdForce = std(Fmat, [], 2, 'omitnan');
    outs.errForce = stderr(Fmat,[],2,'omitnan');
return
    
    
function plot_forcevsdistance(ForceVsDistance, h, ActiveOnlyTF)

    F = ForceVsDistance;
    
    if nargin < 3 || isempty(ActiveOnlyTF)
        ActiveOnlyTF = false;
    end
    
    figure(h);
    clf;
    hold on;
    
    % Find the current bead data
    bkgdgray = [0.8 0.8 0.8];
    limegreen = [0.3 0.8 0.3];       
    darkred = [0.8 0.3 0.3];
    cornflower = [0.45 0.74 1];
    cerulean = [0.302 0.7451 0.9333];    
    tangerine = [1 0.412 0.161];
    melon = [0.9294 0.6941 0.1255];
    
    
    plot(F.Distance, F.ForceMag*1e9, 'Marker', '.', 'MarkerEdgeColor', bkgdgray, ...
                                                'MarkerFaceColor', bkgdgray, ...                                                    
                                                'LineStyle', 'none');
    errorbar(F.DistanceGrid(1:5:end), F.meanForce(1:5:end)*1e9, F.stdForce(1:5:end)*1e9, ...
            'Marker', 'none', 'LineStyle', 'none', 'LineWidth', 2, 'Color', cerulean);
    errorbar(F.DistanceGrid(1:5:end), F.meanForce(1:5:end)*1e9, F.errForce(1:5:end)*1e9, ...
            'Marker', 'none', 'LineStyle', 'none', 'LineWidth', 2, 'Color', 'b');
    plot(F.DistanceGrid, F.medianForce*1e9, 'Marker', 'none', 'LineStyle', '--', 'LineWidth', 2, 'Color', melon);
    plot(F.DistanceGrid, F.meanForce*1e9, 'Marker', 'none', 'LineStyle', '-', 'LineWidth', 2, 'Color', 'b');
    leg = legend({'force on bead', 'stdev', 'stderr', 'median', 'mean'});
    
    if ActiveOnlyTF
        plot(F.Distance(F.idx), F.ForceMag(F.idx)*1e9, 'Marker', '*', 'MarkerEdgeColor', darkred, ...
                                                       'MarkerFaceColor', darkred, ...    
                                                       'MarkerSize', 6, ...
                                                       'LineStyle', 'none');           
        leg.String{numel(leg.String)} = 'active bead';
    end
                
    
%     xlabel(['distance from poletip, ' ForceVsDistance.LengthUnits]);
    xlabel(['distance from "monopole" [\mum]']);
    ylabel(['|F| [nN]']);    
    grid on;
    drawnow;
    hold off;
return


function outs = prep_ForceScatter_plot(handles)    
    
    V = prep_VelScatter_plot(handles, 'seconds', 'microns');                   
    
    
    Fs = handles.appData.ForceScale;
    [Fx, Fy, Fz, Fr] = calculate_forces(Fs, V.vx, V.vy, V.vz, V.vr);

    F = V;
    F.BeadRadius_m = handles.appData.BeadRadius_m;
    F.Viscosity_Pas = handles.appData.Viscosity_Pas;
    F.ForceScale = handles.appData.ForceScale;
    F.Fx = Fx;
    F.Fy = Fy;
    F.Fz = Fz;
    F.Fr = Fr;
    F.Fclr = F.vclr;
    
    F.ForceUnits = 'N';
    
    outs = F;
    
return


function plot_force_scatter(ForceScatter, h, ActiveOnlyTF) 

    im = ForceScatter.im;
    idx = ForceScatter.idx;
    
    if nargin < 3 || isempty(ActiveOnlyTF)
        ActiveOnlyTF = false;
    end
    
    figure(h);
    clf;
    imagesc(ForceScatter.xrange, ForceScatter.yrange, im);
    colormap(gray(256));
    hold on;

   [g, gT] = findgroups(ForceScatter.id);


    if ActiveOnlyTF
        scatter(ForceScatter.x(idx), ForceScatter.y(idx), 10, ForceScatter.fclr(idx,:), 'filled');
    else
        splitapply(@(x1,x2)plot(x1, x2, 'w-'), ForceScatter.x, ForceScatter.y, g);
        scatter(ForceScatter.x, ForceScatter.y, 10, ForceScatter.Fclr, 'filled');
    end
        
    hold off;
    xlabel(['X, ' ForceScatter.LengthUnits]);
    ylabel(['Y, ' ForceScatter.LengthUnits]);
    
        
    minFr = min(ForceScatter.Fr)*1e9;
    maxFr = max(ForceScatter.Fr)*1e9;
    set(gca, 'YDir', 'reverse');            
    
    manual_colorbar(log10([minFr maxFr]));
    title('log_{10}(force), [nN]');
%     title(['log_{10}(force), ' ForceScatter.ForceUnits]);

    disp(['Minimum Force = ' num2str(minFr) ' n' ForceScatter.ForceUnits '.']);
    disp(['Maximum Force = ' num2str(maxFr) ' n' ForceScatter.ForceUnits '.']);

    
    drawnow;

return


function ForceVectorField = prep_ForceVectorField_plot(handles)
    V = prep_VelField_plot(handles, 'seconds', 'microns');
    F.X = V.VelField.X;
    F.Y = V.VelField.Y;
    F.Vx = V.VelField.Vx;
    F.Vy = V.VelField.Vy;
    [F.Fx, F.Fy] = calculate_forces(handles.appData.ForceScale, F.Vx, F.Vy);  
    F.LengthUnits = V.LengthUnits;
    F.TimeUnits = V.TimeUnits;
    F.ForceUnits = '[N]';
    ForceVectorField = F;
   
return


function plot_force_vectorfield(ForceVectorField, h)

    S = ForceVectorField;
        
    figure(h);
    quiver(S.X, S.Y, S.Fx*1e9, S.Fy*1e9, 1);
    set(gca,'YDir','reverse'); 
    xlim([0 max(S.X(1,:))]);
    ylim([0 max(S.Y(:,1))]);
    
    xlabel('X [\mum]');
    ylabel('Y [\mum]')
    title('Force Vectors [nN]');
    pretty_plot;
return

function outs = prep_old_MSD_plot(handles)
    TrackingTable = handles.appData.TrackingTable;
    framemax = max(TrackingTable.Frame);
    numtaus = handles.appData.numtaus;
    fps = handles.appData.fps;
    calibum = handles.appData.calibum;
    bead_diameter_um = str2double(handles.edit_bead_diameter_um.String);
    
    duration_fraction = 0.5;
    taulist = msd_gen_taus(framemax, numtaus, duration_fraction);
    window_at_1_sec = floor(fps);    
    taulist = [taulist; window_at_1_sec - 1; window_at_1_sec; window_at_1_sec+1];
    taulist = unique(taulist); % to eliminate the possibility of repeats after adding a special set to default
    taulist = sort(taulist);
    
%     DataIn.VidTable = handles.appData.VidTable;
%     DataIn.TrackingTable = TrackingTable;
    
    video_tracking_constants;
    trajectories = convert_Table_to_old_matrix(handles.appData.TrackingTable, fps);    
    trajectories(:,X:Y) = trajectories(:,X:Y) .* calibum .* 1e-6;
    
    mymsd = video_msd(trajectories, taulist, fps, calibum, 'n', 'n');
    myve = ve(mymsd, bead_diameter_um*1e-6/2, 'f', 'n');
    myD = mymsd.msd ./ (4 .* mymsd.tau);
    outs.mymsd = mymsd;
    outs.myve  = myve;
    outs.myD   = myD;
        
return


function outs = prep_new_MSD_plot(handles)
    TrackingTable = handles.appData.TrackingTable;
    framemax = max(TrackingTable.Frame);
    numtaus = handles.appData.numtaus;
    duration_fraction = 0.5;
    
    taulist = msd_gen_taus(framemax, numtaus, duration_fraction);
    
    DataIn.VidTable = handles.appData.VidTable;
    DataIn.TrackingTable = TrackingTable;
    
    diffTable = vst_difftau(DataIn, taulist);
    msdTable = vst_msd(DataIn, taulist);
    outs.MsdTable = join(diffTable, msdTable);
    outs.MsdEnsemble = vst_msdEnsemble(outs);
    outs.taulist = taulist;

% 
%         msdID   = unique(TrackingTable.ID)';    
%         mymsd   = handles.appData.mymsd;
%         myve    = handles.appData.myve;
%         myD     = handles.appData.myD;
%         tau = mymsd.tau;
%         msd = mymsd.msd;
%         
%         q  = find(msdID  == CurrentBead);        
        
return

function plot_new_MSD(MSDdata, h)
    beads = MSDdata.MsdTable;
    ensemble = MSDdata.MsdEnsemble;
    
    gb = findgroups(beads.ID);    
    ge = findgroups(ensemble.Tau);
    
    figure(h);
    hold on;
        gscatter(beads.Tau_s, beads.MsdX, gb, [0.7 0.7 0.7]);
        gscatter(ensemble.Tau_s, 10.^(ensemble.logmsdX), ge, 'k');
        ax = gca;
        ax.XScale = 'log';
        ax.YScale = 'log';
        xlabel('time scale, \tau [s]');
        ylabel('MSD.x, <x^2> []');
        grid on;
        legend off;
    hold off;    
return


function plot_old_MSD(MSDdata, h)
    plot_msd(MSDdata.mymsd, h, 'ame')
return


function plot_GSER(MSDdata, h)
%     AUXfig = handles.AUXfig;
%     myve = handles.appData.myve;
%     
%     plotG       = get(handles.checkbox_G, 'Value');
%     ploteta     = get(handles.checkbox_eta, 'Value');
%     plotGstar   = get(handles.checkbox_Gstar, 'Value');
%     plotetastar = get(handles.checkbox_etastar, 'Value');
% 
%     plotstring = [];
% 
%     if plotG
%         plotstring = [plotstring 'Gg'];
%     end
% 
%     if ploteta
%         plotstring = [plotstring 'Nn'];
%     end
% 
%     if plotGstar
%         plotstring = [plotstring 'S'];
%     end
% 
%     if plotetastar
%         plotstring = [plotstring 's'];                
%     end
    plotstring = 'Nn';
    plot_ve(MSDdata.myve, 'f', h, plotstring);                
return

function evt_plot_rmsdisp(MSDdata, h)
    plotstring = 'ame';
    plot_rmsdisp(MSDdata.mymsd, h, plotstring);
return
    
function evt_plot_alphatau(MSDdata,h)
    plotstring = 'ame';
    plot_alphavstau(MSDdata.myve, h, plotstring);
return

function evt_plot_alphadist(MSDdata, h)
    plot_alphadist(MSDdata.myve.alpha, h);
return

function plot_data(handles)

    handles = SelectBead(handles);
    
    Plot_XYfig(handles);
    Plot_XTfig(handles);
    Plot_AUXfig(handles);
    
    assignin('caller', 'handles', handles);
    
return


function handles = filter_tracking(handles)    
    % To avoid cumulative changes to the TrackingTable start by combining
    % the FilteredTable and the Trash back into the TrackingTable;
    TrackingTable = [handles.appData.TrackingTable; handles.appData.Trash];
    
    [handles.appData.TrackingTable, handles.appData.Trash] = vst_filter_tracking(TrackingTable, handles.appData.TrackingFilter);
    
    handles = SelectBead(handles);
    
    handles.appData.RadialTable = CalculateRadialLocations(handles.appData.TrackingTable);
   

    smooth_factor = 1;
%     handles.appData.VelocityTable = CalculateVelocity(handles.appData.TrackingTable);  
    handles.appData.VelocityTable = vst_CalculateVelocity(TrackingTable, smooth_factor);
    
    plot_data(handles);
return


function mag = calculate_mag(matrix)
    mag = sqrt( sum( matrix.^2, 2 ) );
return

function angle = calculate_angle(matrix)
    angle = atan2(-matrix(:,2), matrix(:,1));    
return

function ForceScale = calculate_ForceScale(handles)
    ForceScale = 6*pi*handles.appData.BeadRadius_m*handles.appData.Viscosity_Pas;
return


function varargout = calculate_forces(ForceScale_umPas, varargin)
    % varargin in here is a list of arguments that are velocities in [um/s]
    
    % The velocity unit input is um/s but the ForceScale is in meters. Need to
    % scale the velocity by 1e-6 to get it into meters/s.
    Force_N  = cellfun(@(v)(ForceScale_umPas .* v .* 1e-6), varargin, 'UniformOutput', false);    
    varargout = Force_N;
return




function bayes = run_bayes_model_selection(hObject, eventdata, handles)
    video_tracking_constants;

    vidtable = convert_Table_to_old_matrix(handles.appData.TrackingTable, handles.appData.fps);

    calibum = str2double(get(handles.edit_calibum, 'String'));

    % Set up filter settings for trajectory data
    
    filt.min_frames = 300; % DEFAULT
    filt.xyzunits   = 'm';
    filt.calibum   = calibum;

%     metadata.num_subtraj = 60;
    metadata.num_subtraj = 30;
    metadata.fps         = str2double(get(handles.edit_frame_rate, 'String'));
    metadata.calibum     = calibum;
    metadata.bead_radius = handles.appData.BeadRadius_m;
    metadata.numtaus     = str2double(get(handles.edit_numtaus, 'String'));
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

    agg_msdcalc = handles.appData.mymsd;
    
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

     handles.appData.bayes = struct;

     handles.appData.bayes.metadata = metadata;
     handles.appData.bayes.filt = filt;
     handles.appData.bayes.results = bayes_output;
     handles.appData.bayes.name = myfile;     
     guidata(hObject, handles);
     
     bayes = handles.appData.bayes;

     guidata(hObject, handles);
     setappdata(handles.output, 'appData', handles.appData);

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
    
    vidtable = convert_Table_to_old_matrix(handles.appData.TrackingTable, handles.appData.fps);

    % max_tau_s is the maximum time scale the user wants the bayesian
    % modeling code to consider when binning MSD curves.
    max_tau_s = 1;
        
    % fraction_for_subtrajectories provides the shortest total trajectory
    % length we can get away with for the number of subtrajectories we
    % want.
    fraction_for_subtraj = 0.75;

    fps = str2double(get(handles.edit_frame_rate, 'String'));
    bead_radius = handles.appData.BeadRadius_m;
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
     
    agg_msdcalc = handles.appData.mymsd;

    % The shortest trajectory we will want to consider depends on the
    % longest time scale (max_tau_s) we want to see in the MSD and the 
    % amount of sampling we want for that longest time scale 
    % (fraction_for_subtraj)
    max_tau_frames = floor(max_tau_s * fps);
    shortest_traj_s = max_tau_s / fraction_for_subtraj;
    shortest_traj_frames = floor(shortest_traj_s * fps);
    
    num_subtraj = floor(frame_max / max_tau_frames);
    
    logentry(['Minimum frames in Bayesian model selection set to ' num2str(shortest_traj_frames) ' frames.']);

    
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

     handles.appData.bayes = struct;
     handles.appData.bayes.metadata = metadata;
     handles.appData.bayes.filt = filt;
     handles.appData.bayes.results = bayes_output;
     handles.appData.bayes.name = myfile;     

     bayes = handles.appData.bayes;

     guidata(hObject, handles);
     setappdata(handles.output, 'appData', handles.appData);

return


% function TrackingTable = convert_old_matrix_to_Table(data, fid)
%     video_tracking_constants;
%     
%     v.fid  = data(:,FID);
%     v.t = data(:,TIME);
%     v.id= data(:,ID);    
%     v.frame = data(:,FRAME);
%     v.x = data(:,X);
%     v.y = data(:,Y);
%     v.z = data(:,Z);		
%     v.roll = data(:,ROLL);    
%     v.pitch= data(:,PITCH);   
%     v.yaw  = data(:,YAW);     
%     v.area = data(:,AREA);    
%     v.sens = data(:,SENS);    
%     v.centints = data(:,CENTINTS);  
%     v.well = data(:,WELL);    
%     v.pass = data(:,PASS);    
%     
% 
%     TrackingTable = struct2table(v);
%     TrackingTable.Properties.VariableNames = { 'Fid', 'Time', 'ID', 'Frame', ...
%                                                'X', 'Y', 'Z', ...
%                                                'Roll', 'Pitch', 'Yaw', ...
%                                                'Area', 'Sensitivity', 'CenterIntensity', ...
%                                                'Well', 'Pass' };
%     TrackingTable.Properties.VariableUnits = { '', 's', '', 'frame', ...
%                                                'pixels', 'pixels', 'pixels', ...
%                                                'unknown', 'unknown', 'unknown', ...
%                                                'pixels^2', '', '', ...
%                                                '', '' };
% 
                                           
function d = convert_Table_to_old_matrix(TrackingTable, fps)

    iscolumn = @(TableName, ColumnName)(sum(ismember(ColumnName, TableName.Properties.VariableNames)));

    video_tracking_constants;
    
    d(:,TIME) = (TrackingTable.Frame - 1) / fps;
    d(:,ID) = TrackingTable.ID;
    d(:,FRAME) = TrackingTable.Frame;
    d(:,X) = TrackingTable.X;
    d(:,Y) = TrackingTable.Y;
    d(:,Z) = TrackingTable.Z;
    
    if iscolumn(TrackingTable, 'Roll')        
        d(:,ROLL) = TrackingTable.Roll;
    else
        d(:,ROLL) = 0;
    end
    
    if iscolumn(TrackingTable, 'Pitch')        
        d(:,PITCH) = TrackingTable.Pitch;
    else
        d(:,PITCH) = 0;
    end
    
    if iscolumn(TrackingTable, 'Yaw')        
        d(:,YAW) = TrackingTable.Yaw;
    else
        d(:,YAW) = 0;
    end
        
    if iscolumn(TrackingTable, 'Area')        
        d(:,AREA) = TrackingTable.Area;
    else
        d(:,AREA) = 0;
    end
    
    if iscolumn(TrackingTable, 'Sensitivity')        
        d(:,SENS) = TrackingTable.Sensitivity;
    else
        d(:,SENS) = 0;
    end
    
    if iscolumn(TrackingTable, 'CenterIntensity')        
        d(:,CENTINTS) = TrackingTable.CenterIntensity;
    else
        d(:,CENTINTS) = 0;
    end
    
    if iscolumn(TrackingTable, 'Well')        
        d(:,WELL) = TrackingTable.Well;
    else
        d(:,WELL) = 0;
    end
    
    if iscolumn(TrackingTable, 'Pass')        
        d(:,PASS) = TrackingTable.Pass;
    else
        d(:,PASS) = 0;
    end

    if iscolumn(TrackingTable, 'Fid')
        d(:,FID) = TrackingTable.Fid;
    else
        d(:,FID) = 0;
    end
    
return


function logentry(txt)

    logtime = clock;
    
    % dbstack pulls the stack of function calls that got us here
    stk = dbstack;
    
    % This function is stk(1).name and its calling function is stk(2).name
    calling_func = stk(2).name;
    
    logtimetext = [ '(' num2str(logtime(1),        '%04i') '.' ...
                        num2str(logtime(2),        '%02i') '.' ...
                        num2str(logtime(3),        '%02i') ', ' ...
                        num2str(logtime(4),        '%02i') ':' ...
                        num2str(logtime(5),        '%02i') ':' ...
                        num2str(round(logtime(6)), '%02i') ') '];
    headertext = [logtimetext calling_func ': '];
     
    fprintf('%s%s\n', headertext, txt);

    % Putting status onto the gui
    myUI = findall(0, 'Tag', 'evt_GUI');
    handles = guihandles(myUI);
    set(handles.text_status, 'String', [headertext, txt]);
return
   

function interp_Forces = sa_interp_forces(radial_loc, radial_force, interp_grid)

    data = [radial_loc(:) radial_force(:)];
    [~,ia,ic] = unique(data(:,1));
    data = data(ia,:);
%     interp_Forces = interp1(data(:,1), data(:,2), interp_grid, 'pchip', 'extrap');
    interp_Forces = interp1(data(:,1), data(:,2), interp_grid);
return

  
    


