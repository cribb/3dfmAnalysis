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

% Last Modified by GUIDE v2.5 13-Dec-2019 13:30:28

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
	handles.currentBead = 0;
    handles.calib_um = 1;
    
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
    handles.filt.calib_um = 1;
    
	% Update handles structure
	guidata(hObject, handles);
	

function varargout = evt_GUI_OutputFcn(hObject, eventdata, handles)
	% Get default command line output from handles structure
	varargout{1} = handles.output;

    
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


function pushbutton_savefile_Callback(hObject, eventdata, handles)
    video_tracking_constants;

	outfile = get(handles.edit_outfile, 'String');
    
    if (isempty(outfile))
        msgbox('No filename specified for output.', 'Error.');
        return
    end
    
    calib_um = str2double(get(handles.edit_calib_um, 'String'));
    fps = str2double(get(handles.edit_frame_rate, 'String'));
    save_evtfile(outfile, handles.trajdata, 'pixels', calib_um, fps, 'mat');
    logentry(['New tracking file, ' outfile ', saved...']);
    
    set(handles.edit_outfile, 'String', '');    

       
function edit_outfile_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_outfile_Callback(hObject, eventdata, handles)


function pushbutton_Edit_Data_Callback(hObject, eventdata, handles)

    if get(handles.radio_AUXfig, 'Value')
        logentry('AUXfigs are not allowed to delete data');
        return;
    end
    
    set(handles.radio_selected_dataset,   'Enable', 'Off');
	set(handles.radio_insideboundingbox,  'Enable', 'Off');
	set(handles.radio_outsideboundingbox, 'Enable', 'Off');
    set(handles.radio_deletetimebefore,   'Enable', 'Off');
    set(handles.radio_deletetimeafter,    'Enable', 'Off');
    
	
	if (get(handles.radio_selected_dataset, 'Value'))
        set(handles.radio_XTfig, 'Enable', 'off');
        set(handles.radio_XYfig, 'Enable', 'off');
        set(handles.radio_AUXfig,'Enable', 'off');
        
        delete_selected_dataset(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig,'Enable', 'on');        
        
    elseif (get(handles.radio_insideboundingbox, 'Value'))
        set(handles.radio_XTfig, 'Enable', 'off');
        set(handles.radio_XYfig, 'Enable', 'off');
        set(handles.radio_AUXfig,'Enable', 'off');
        
        delete_inside_boundingbox(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig,'Enable', 'on');       
        
    elseif (get(handles.radio_outsideboundingbox, 'Value'))
        set(handles.radio_XTfig, 'Enable', 'off');
        set(handles.radio_XYfig, 'Enable', 'off');
        set(handles.radio_AUXfig,'Enable', 'off');
        
        delete_outside_boundingbox(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig,'Enable', 'on');  
        
    elseif (get(handles.radio_deletetimebefore, 'Value'))
        set(handles.radio_XTfig, 'Value', 1, 'Enable', 'off');
        set(handles.radio_XYfig, 'Value', 0, 'Enable', 'off');
        set(handles.radio_AUXfig, 'Value', 0, 'Enable', 'off');

        delete_data_before_time(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig, 'Enable', 'on');
        
    elseif (get(handles.radio_deletetimeafter, 'Value'))
        set(handles.radio_XTfig, 'Value', 1, 'Enable', 'off');
        set(handles.radio_XYfig, 'Value', 0, 'Enable', 'off');
        set(handles.radio_AUXfig, 'Value', 0, 'Enable', 'off');

        delete_data_after_time(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');
        set(handles.radio_AUXfig, 'Enable', 'on');
        
	else
        msgbox('One of the data handling methods must be selected.', ...
               'Error.');
    end

	set(handles.radio_selected_dataset,   'Enable', 'On');
	set(handles.radio_insideboundingbox,  'Enable', 'On');
	set(handles.radio_outsideboundingbox, 'Enable', 'On');
    set(handles.radio_deletetimebefore,   'Enable', 'On');
    set(handles.radio_deletetimeafter,    'Enable', 'On');
    
    handles.recomputeMSD = 1;
    
    plot_data(hObject, eventdata, handles);
    
    guidata(hObject, handles);
    
    
function slider_BeadID_CreateFcn(hObject, eventdata, handles)
	usewhitebg = 1;
	if usewhitebg
        set(hObject,'BackgroundColor',[.9 .9 .9]);
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function slider_BeadID_Callback(hObject, eventdata, handles)
	handles.currentBead = round(get(handles.slider_BeadID, 'Value'));
    guidata(hObject, handles);
    set(handles.edit_BeadID, 'String', num2str(handles.currentBead));
    
    filter_bead_selection(hObject, eventdata, handles);    
    plot_data(hObject, eventdata, handles);
    

function edit_BeadID_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_BeadID_Callback(hObject, eventdata, handles)
    handles.currentBead = round(str2double(get(handles.edit_BeadID, 'String')));
    guidata(hObject, handles);    
    set(handles.slider_BeadID, 'Value', handles.currentBead);    
    
    video_tracking_constants;
    currentBead = round(get(handles.slider_BeadID, 'Value'));
    
    beadID = handles.trajdata(:,ID);
    
    % separate the currently selected bead vs not the selected bead
    handles.CurrentBeadIDX = find(beadID == currentBead);
    handles.NotCurrentBeadIDX = find(beadID ~= currentBead);
    guidata(hObject, handles);
    
%     filter_bead_selection(hObject, eventdata, handles);
%     plot_data(hObject, eventdata, handles);

    
function pushbutton_Select_Closest_xydataset_Callback(hObject, eventdata, handles)
    video_tracking_constants;
    
    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.AUXfig;
    end

    if get(handles.radio_XYfig, 'Value') || get(handles.radio_XTfig, 'Value')
        
        if get(handles.radio_XTfig, 'Value')
            logentry('Selecting closest dataset for XT plot does not make sense.  Resetting to XYplot');
            set(handles.radio_XTfig, 'Value', 0);
            set(handles.radio_XYfig, 'Value', 1);
        end
        
        figure(handles.XYfig);
        [xm, ym] = ginput(1);

        if get(handles.radio_microns, 'Value')
            calib_um = str2double(get(handles.edit_calib_um, 'String'));
            xm = xm / calib_um;
            ym = ym / calib_um;
        end        

        beadID = handles.trajdata(:,ID);    
        x = handles.trajdata(:,X);
        y = handles.trajdata(:,Y);

        xval = repmat(xm, length(x), 1);
        yval = repmat(ym, length(y), 1);

        dist = sqrt((x - xval).^2 + (y - yval).^2);

        bead_to_select = beadID(find(dist == min(dist)));

        set(handles.slider_BeadID, 'Value', round(bead_to_select));
        set(handles.edit_BeadID, 'String', num2str(round(bead_to_select)));
    end
    
    if get(handles.radio_AUXfig, 'Value')
        
        AUXplottypes = get(handles.popup_AUXplot, 'String');
        AUXplotvalue = get(handles.popup_AUXplot, 'Value');
        
        myAUXplottype = AUXplottypes{AUXplotvalue};
        
        switch myAUXplottype
            case 'MSD'
                figure(handles.AUXfig);
                
                mymsd = handles.mymsd;

                [xm, ym] = ginput(1);

                
                xval = repmat(xm, size(mymsd.tau));
                yval = repmat(ym, size(mymsd.msd));
        
                beadID = handles.trajdata(:,ID);    
                x = log10(mymsd.tau);
                y = log10(mymsd.msd);

                dist = sqrt((x - xval).^2 + (y - yval).^2);

                [mindist, bead_to_select] = min(min(dist));

                bead_to_select = round(bead_to_select);
                
                set(handles.slider_BeadID, 'Value', bead_to_select-1);
                set(handles.edit_BeadID, 'Value', bead_to_select-1);
                       
            otherwise
                logentry('Select closest dataset not yet written for AUXplot type you chose');                
                return;
        end
    end
    
    
    plot_data(hObject, eventdata, handles);
    


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

    diststr = get(handles.text_distance, 'String');
    
    if contains(diststr, 'um')
    elseif contains(diststr, 'pixels')
    else
    end
    
    plot_data(hObject, eventdata, handles);


function radio_microns_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 0);
    set(handles.radio_microns, 'Value', 1);

    plot_data(hObject, eventdata, handles);


function edit_calib_um_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
    end


function edit_calib_um_Callback(hObject, eventdata, handles)
    handles.calib_um = str2double(get(handles.edit_calib_um, 'String'));
    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(hObject, eventdata, handles);    


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
    
    if get(handles.radio_linear, 'Value')
        logentry('Removing Drift via linear method.');
        [v,q] = remove_drift(handles.trajdata, start_time, end_time, 'linear');
    elseif get(handles.radio_com, 'Value')
        logentry('Removing Drift via center-of-mass method.');
        [v,q] = remove_drift(handles.trajdata, start_time, end_time, 'center-of-mass'); 
    elseif get(handles.radio_commonmode, 'Value')
        logentry('Removing Drift via common-mode method.');
        [v,q] = remove_drift(handles.trajdata, start_time, end_time, 'common-mode');
    end
    
    handles.trajdata = v;
    handles.recomputeMSD = 1;
	guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
        

function checkbox_frame_rate_Callback(hObject, eventdata, handles)

    video_tracking_constants;
    trajdata = handles.trajdata;
    
    if get(hObject, 'Value')      
        set(handles.edit_frame_rate, 'Enable', 'on');

        trajdata(:,TIME) = trajdata(:,FRAME) / str2double(get(handles.edit_frame_rate, 'String'));
        mintime = min(trajdata(:,TIME));
        maxtime = max(trajdata(:,TIME));
	
        handles.trajdata = trajdata;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
    else
        set(handles.edit_frame_rate, 'Enable', 'off');

        handles.trajdata(:,TIME) = handles.tstamp_times;
        handles.mintime = min(handles.trajdata(:,TIME));
        handles.maxtime = max(handles.trajdata(:,TIME));
    end

    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(hObject, eventdata, handles);


function edit_frame_rate_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_frame_rate_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    trajdata = handles.trajdata;

    if get(handles.checkbox_frame_rate, 'Value')
        trajdata(:,TIME) = trajdata(:,FRAME) / str2double(get(hObject, 'String'));
        mintime = min(trajdata(:,TIME));
        maxtime = max(trajdata(:,TIME));
	
        handles.trajdata = trajdata;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
        handles.recomputeMSD = 1;
        guidata(hObject, handles);
	
        plot_data(hObject, eventdata, handles);
        drawnow;
    end
    

function radio_relative_Callback(hObject, eventdata, handles)
    set(handles.radio_relative, 'Value', 1);
    set(handles.radio_arb_origin, 'Value', 0);
    
    plot_data(hObject, eventdata, handles);
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
        plot_data(hObject, eventdata, handles);
    end


function edit_arb_origin_Callback(hObject, eventdata, handles)
    arb_origin = str2double(get(hObject, 'String'));

    if length(arb_origin) ~= 2
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
    else
        plot_data(hObject, eventdata, handles);
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

    switch handles.AUXtype
        case 'OFF'
        case 'radial vector'
            calculate_radial_vector(hObject, eventdata, handles)
            plot_radial_vector(hObject, eventdata, handles)
            
        case 'PSD'
        
        case 'Integrated Disp'
            
        case 'sensitivity (SNR)'
            plot_sensitivity(hObject, eventdata, handles)
%         case 'displacement hist'
        
        case 'MSD'
        
        case 'alpha vs tau'
            
        case 'alpha histogram'

        case 'MSD histogram'

        case 'Diffusivity @ a tau'

        case 'Diffusivity vs. tau'

        case 'temporal MSD'

        case 'GSER'

        case 'pole locator'

        case 'tracker avail'

        case '2pt MSD ~~not implemented yet~~'

    end

function old_popup_AUXplot_Callback(hObject, eventdata, handles)
    contents = get(hObject, 'String');
    AUXtype = contents(get(hObject, 'Value'));
    
    handles.AUXtype = AUXtype{1};
    guidata(hObject, handles);

    switch handles.AUXtype
        case 'OFF'
            set(handles.radio_relative       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
            
        case 'radial vector'
            set(handles.radio_relative    ,  'Visible', 'on', 'Enable', 'on');
            set(handles.radio_arb_origin  ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_arb_origin   ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

            plot_radial_vector(hObject, eventdata, handles)
            
        case 'PSD'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');                        
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
        
        case 'Integrated Disp'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');                        
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

%         case 'displacement hist'
%             set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_G       ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.checkbox_eta      ,  'Visible', 'off', 'Enable', 'off');
%             set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
%             set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
        
        case 'MSD'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_msdall   ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_numtaus         ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_2Mmsd   , 'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'on', 'Enable', 'on');
        
        case 'alpha vs tau'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');
            
        case 'alpha histogram'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'on', 'Enable', 'on');
            set(handles.text_chosentau       , 'Visible', 'on', 'Enable', 'on');
            set(handles.text_chosentau_value , 'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case 'MSD histogram'
            set(handles.radio_relative       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall      ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'on', 'Enable', 'on');
            set(handles.text_chosentau       , 'Visible', 'on', 'Enable', 'on');
            set(handles.text_chosentau_value , 'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case 'Diffusivity @ a tau'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case 'Diffusivity vs. tau'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case 'temporal MSD'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case 'GSER'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G       ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_Gstar   ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_eta      ,  'Visible', 'on', 'Enable', 'on');
            set(handles.checkbox_etastar  ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_bead_diameter_um,  'Visible', 'on', 'Enable', 'on');
            set(handles.text_bead_diameter,  'Visible', 'on', 'Enable', 'on');
            set(handles.text_numtaus         ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_numtaus         ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case 'pole locator'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');            
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case 'tracker avail'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

        case '2pt MSD ~~not implemented yet~~'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdmean  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_msdall   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_G           ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_Gstar       ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_eta         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_etastar     ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'on', 'Enable', 'on');
            set(handles.text_bead_diameter,  'Visible', 'on', 'Enable', 'on');
            set(handles.text_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_numtaus         ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'on', 'Enable', 'on');
            set(handles.text_temp           , 'Visible', 'on', 'Enable', 'on');
            set(handles.edit_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau       , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_chosentau_value , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_watermsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2Mmsd   , 'Visible', 'off', 'Enable', 'off');
            set(handles.checkbox_2p5Mmsd   , 'Visible', 'off', 'Enable', 'off');

    end
    
    plot_data(hObject, eventdata, handles);
    

function popup_AUXplot_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function checkbox_msdmean_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


function checkbox_msdall_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

    
function checkbox_G_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

    
function checkbox_Gstar_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

    
function checkbox_eta_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

    
function checkbox_etastar_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);
    
    
function edit_bead_diameter_um_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;     
    guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);


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
    plot_data(hObject, eventdata, handles);


function checkbox_overlayxy_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


function edit_numtaus_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
function edit_numtaus_Callback(hObject, eventdata, handles)
    percent_duration = 1;
    numtaus = str2double(get(handles.edit_numtaus, 'String'));
    tau = msd_gen_taus(a,numtaus,percent_duration);
    
    handles.tau = tau;
    handles.recomputeMSD = 1;     
    guidata(hObject, handles);
    
    plot_data(hObject, eventdata, handles);   
        

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
    plot_data(hObject, eventdata, handles);

    
function checkbox_watermsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    plot_data(hObject, eventdata, handles);

function checkbox_2p5Mmsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    plot_data(hObject, eventdata, handles);

function checkbox_2Mmsd_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
    guidata(hObject, handles);
    plot_data(hObject, eventdata, handles);






function checkbox_lockfps_Callback(hObject, eventdata, handles)

function checkbox_lockum_Callback(hObject, eventdata, handles)

function FileMenu_Callback(hObject, eventdata, handles)    

function FileMenuOpen_Callback(hObject, eventdata, handles)

    video_tracking_constants;

    % reset the Active Bead to 0
    set(handles.edit_BeadID, 'String', '0');
    set(handles.slider_BeadID, 'Value', 0);   
    
    [fname, pname, fidx] = uigetfile({'*.mat;*.csv';'*.mat';'*.csv';'*.*'}, ...
                                      'Select File(s) to Open', ...
                                      'MultiSelect', 'on');

    if sum(length(fname), length(pname)) <= 1
        logentry('No tracking file selected. No tracking file loaded.');
        return;
    end        

    filename = strcat(pname, fname);

    logentry(['Setting Path to: ' pname]);
    cd(pname);

%     set(handles.edit_outfile, 'String', '');

    filenameroot = strrep(filename,     '.raw', '');
    filenameroot = strrep(filenameroot, '.csv', '');
    filenameroot = strrep(filenameroot, '.vrpn', '');
    filenameroot = strrep(filenameroot, '.mat', '');
    filenameroot = strrep(filenameroot, '.evt', '');

    % load the datafile
    logentry('Loading dataset... ');

    % EXPERIMENTAL AND UNUSED RIGHT NOW
     [d, calout] = load_video_tracking(filename, [], [], [], 'absolute', 'yes', 'struct');
     d = filter_video_tracking(d, handles.filt);
     TrackingTable = struct2table(d);
     TrackingTable.Properties.VariableNames = { 'Time', 'ID', 'Frame', ...
                                                'X', 'Y', 'Z', ...
                                                'Roll', 'Pitch', 'Yaw', ...
                                                'Area', 'Sensitivity', 'CenterIntensity', ...
                                                'Well', 'Pass'};

    
    
    
    [d, calout] = load_video_tracking(filename, [], [], [], 'absolute', 'yes', 'table');
     d = filter_video_tracking(d, handles.filt);
        
    
    if ~isempty(calout)
        if ~get(handles.checkbox_lockum, 'Value') && length(unique(calout)) == 1
            set(handles.edit_calib_um, 'String', num2str(calout(1)));
        elseif get(handles.checkbox_lockum, 'Value')
            logentry('Calib Lock set when loading new files. Overriding calibum set in file.');            
        else
            msgbox('evt_GUI cannot load multiple files with multiple calibration factors at this time.', 'Error.', 'error');
            return;
        end        
    end    

    if isempty(d)
        msgbox('No data exists in this fileset!');
        return;
    end
    
    
    if iscell(filename)
        logentry('Multiple datasets successfully loaded...');
    else
        logentry(['Dataset, ' filename ', successfully loaded...']);
    end
    
    MIPfile = strrep(filenameroot, '_TRACKED', '');
    MIPfile = strrep(MIPfile, 'video', 'FLburst');

    MIPfile = [MIPfile, '*mip*'];
    MIPfile = dir(MIPfile);
    
%     rawfile = [filenameroot '.RAW'];
%     im = raw2img(rawfile, 'BMP', 1, 1);
%     fimfile = [filenameroot, '.00001.pgm'];
%     MIPfile = [filenameroot, '.MIP.bmp'];
%     MIPfile = [filenameroot, '.vrpn.composite.tif'];
    
    % If the background MIP image exists, attach it to handles structure.
    % If it doesn't exist, replace wiht half-tone grayscale.
    if ~isempty(MIPfile)
        handles.im = imread(MIPfile(1).name);
    else
        handles.im = 0.5 * ones(ceil(max(d(:,Y))),ceil(max(d(:,X))));
    end
    
    % set the default output filename
    outfile = get(handles.edit_outfile, 'String');
    if isempty(outfile)
        if iscell(filename)
            outfile = [pname 'multiple_files.' 'evt.mat'];
        else
            outfile = [pname fname(1:end-3) 'evt.mat'];
        end
        
        set(handles.edit_outfile, 'String', outfile);
    end
    
%     if iscell(filename)
%         set(handles.edit_outfile, 'TooltipString', 'Multiple files loaded.');
%     else
%         set(handles.edit_outfile, 'TooltipString', outfile);
%     end
    
    % assign data variables    
    trajdata = d;
    mintime = min(trajdata(:,TIME));
    maxtime = max(trajdata(:,TIME));
    beadID = trajdata(:,ID);

    % update fps editbox so there is an indicator of real timesteps
    if get(handles.checkbox_lockfps, 'Value')
        logentry('FPS Lock set when loading new files. Overriding FPS set in file.');
        tsfps = str2double(get(handles.edit_frame_rate, 'String'));
    else
        idx = (beadID == 0);
        tsfps = round(1/mean(diff(trajdata(idx,TIME))));
        logentry(['Setting frame rate to ' num2str(tsfps) ' fps.']);
        set(handles.edit_frame_rate, 'String', num2str(tsfps));
    end
    
    % construct figure handles if they don't already exist
    if isfield(handles, 'XYfig')
        XYfig = figure(handles.XYfig);
    else
        XYfig = figure;
    end
    
    if isfield(handles, 'XTfig')
        XTfig = figure(handles.XTfig);
    else
        XTfig = figure;
    end

    if isfield(handles, 'AUXfig')
        AUXfig = figure(handles.AUXfig);
    else            
        AUXfig = figure;         
        set(AUXfig, 'Visible', 'off');
    end    
    
    if ~isfield(handles, 'AUXtype')
        handles.AUXtype = 'OFF';
    end    

    % set default figure parameters
    set(XYfig, 'Units', 'Normalized');
    set(XYfig, 'Position', [0.1 0.05 0.4 0.4]);    
    set(XYfig, 'DoubleBuffer', 'on');
    set(XYfig, 'BackingStore', 'off');
    
    set(XTfig, 'Units', 'Normalized');
    set(XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    set(XTfig, 'DoubleBuffer', 'on');
    set(XTfig, 'BackingStore', 'off');   
    
    set(AUXfig, 'Units', 'Normalized');
    set(AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
    set(AUXfig, 'DoubleBuffer', 'on');
    set(AUXfig, 'BackingStore', 'off');  

    % handle peculiarities of sliders (still not perfected)
	slider_max = max(beadID);
	slider_min = 0;
    if slider_min == slider_max
        slider_max = slider_min + 1;
    end
    
	slider_step = 1/(slider_max - slider_min);
    	
	set(handles.slider_BeadID, 'Min', slider_min);
	set(handles.slider_BeadID, 'Max', slider_max);
	set(handles.slider_BeadID, 'SliderStep', [slider_step slider_step]);

    % export important data to handles structure
    handles.XYfig = XYfig;
    handles.XTfig = XTfig;
    handles.AUXfig = AUXfig;
    handles.trajdata = trajdata;
    handles.mintime = mintime;
    handles.maxtime = maxtime;
    handles.tstamp_times = trajdata(:,TIME);
    handles.recomputeMSD = 1;
    
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
    set(handles.edit_calib_um                       , 'Enable', 'on');
    set(handles.text_calib_um                       , 'Enable', 'on');
    set(handles.checkbox_lockum                     , 'Enable', 'on');    
    set(handles.checkbox_msdmean                    , 'Value',   1);
    
    compute_viscosity_stds(hObject, eventdata, handles);
    
    plot_data(hObject, eventdata, handles);
    guidata(hObject, handles);

    
    
function FileMenuAdd_Callback(hObject, eventdata, handles)

function FileMenuSaveAs_Callback(hObject, eventdata, handles)

    suggested_outfile = '';
    [outfile, outpath, outindx] = uiputfile();
    set(handles.edit_outfile, 'String', '');
        
function FileMenuSave_Callback(hObject, eventdata, handles)

function FileMenuClose_Callback(hObject, eventdata, handles)

function FileMenuQuit_Callback(hObject, eventdata, handles)
    if isfield(handles, 'XYfig')
        try
            close(handles.XYfig);
        catch
            logentry('XY figure was already closed.');
        end
    end

    if isfield(handles, 'XTfig')
        try
            close(handles.XTfig);
        catch
            logentry('XT figure was already closed.');
        end
    end

    if isfield(handles, 'AUXfig')
        try
            close(handles.AUXfig);
        catch
            logentry('AUX figure was already closed.');
        end
    end

	delete(evt_GUI);
    
function EditMenu_Callback(hObject, eventdata, handles)

function EditMenu_AddMip_Callback(hObject, eventdata, handles)

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
        calib_um = handles.calib_um;
        
%         xm = xm / calib_um;
%         ym = ym / calib_um;
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

    currentBead = handles.currentBead;
    beadID = handles.trajdata(:,ID);

    k = find(beadID == currentBead);

    bead.t      = handles.trajdata(k,TIME);
    bead.t      = bead.t - min(handles.trajdata(:,TIME));
    bead.x      = handles.trajdata(k,X);
    bead.y      = handles.trajdata(k,Y);
    if isfield(bead, 'yaw')
        bead.yaw    = handles.trajdata(idx,YAW);
    end
    
    assignin('base', ['bead' num2str(currentBead)], bead);

function ExportMenu_AllBeads_Callback(hObject, eventdata, handles)
    video_tracking_constants;    
    bead = convert_vidtable_to_beadstruct(handles.trajdata);    
    assignin('base', 'beads', bead);
   
function ConfigureMenu_Callback(hObject, eventdata, handles)

function checkbox_min_sens_Callback(hObject, eventdata, handles)

    
function pushbutton_FilterConfig_Callback(hObject, eventdata, handles)
    foo = evt_FilterConfig    
    filt = getappdata(0, 'evtFiltConfig');
    pause(1);
    

    
% =========================================================================
% Everything below this point are functions related to computation and data
% handling/display, and not the gui (though the handles structure is used).
% =========================================================================
function filter_bead_selection(hObject, eventdata, handles)
    video_tracking_constants;
    currentBead = round(get(handles.slider_BeadID, 'Value'));
    
    beadID = handles.trajdata(:,ID);
    
    % separate the currently selected bead vs not the selected bead
    handles.CurrentBeadIDX = find(beadID == currentBead);
    handles.NotCurrentBeadIDX = find(beadID ~= currentBead);
    guidata(hObject, handles);
    
    
function delete_selected_dataset(hObject, eventdata, handles)
    video_tracking_constants;   
    trajdata = handles.trajdata;
    bead_to_remove = handles.currentBead;    
    bead_max = max(trajdata(:,ID));

	k = (trajdata(:,ID) ~= bead_to_remove);
    
    trajdata = trajdata(k,:);
    
    if (bead_max ~= bead_to_remove) % otherwise I don't have to rearrange beadIDs
        for m = (bead_to_remove + 1) : bead_max
            q = (trajdata(:,ID) == m);
            trajdata(q,ID) = m-1;
        end
    end
    
    if (bead_to_remove == 0)
        set(handles.slider_BeadID, 'Value', bead_to_remove+1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove+1));
    else
    	set(handles.slider_BeadID, 'Value', bead_to_remove-1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove-1));        
    end
    
    if bead_max <= 1
        set(handles.slider_BeadID, 'Max', bead_max-1);
        set(handles.slider_BeadID, 'SliderStep', [0 1]);
    else
        set(handles.slider_BeadID, 'Max', bead_max);
        set(handles.slider_BeadID, 'SliderStep', [1/(bead_max) 1/(bead_max)]);
    end
    
    handles.trajdata = trajdata;
	guidata(hObject, handles);

    
function delete_inside_boundingbox(hObject, eventdata, handles)    
    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    else
        logentry('Deleting data from the AUXplot is not allowed.');
        return;
    end
    
    figure(active_fig);
    
    trajdata = handles.trajdata;
    
    beadID = trajdata(:,ID);
    t = trajdata(:,TIME) - handles.mintime;
    x = trajdata(:,X);
    y = trajdata(:,Y);
    currentbead = handles.currentBead;
    
    [xm, ym] = ginput(2);
    
    if get(handles.radio_microns, 'Value')
        calib_um = str2double(get(handles.edit_calib_um, 'String'));
        
        if(get(handles.radio_XYfig, 'Value'))
            xm = xm / calib_um;
            ym = ym / calib_um;
        elseif(get(handles.radio_XTfig, 'Value'))
            ym = ym / calib_um;
        end
        
    end
    
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
    handles.trajdata = trajdata(k,:);
    handles.tstamp_times = handles.tstamp_times(k);
    guidata(hObject, handles);


function delete_outside_boundingbox(hObject, eventdata, handles)    
    video_tracking_constants;
    
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
    
    trajdata = handles.trajdata;
    
    beadID = trajdata(:,ID);
    t = trajdata(:,TIME) - handles.mintime;
    x = trajdata(:,X);
    y = trajdata(:,Y);
    z = trajdata(:,Z);
    currentbead = get(handles.slider_BeadID, 'Value');
    
    [xm, ym] = ginput(2);
    
    if get(handles.checkbox_neutoffsets, 'Value')
        xm = xm + xyzk1(1);
        ym = ym + xyzk1(2);
%         zm = zm + xyzk1(3);
    end
    
    if get(handles.radio_microns, 'Value')
        calib_um = str2double(get(handles.edit_calib_um, 'String'));
        
        if(get(handles.radio_XYfig, 'Value'))
            xm = xm / calib_um;
            ym = ym / calib_um;
        elseif(get(handles.radio_XTfig, 'Value'))
            xm = xm / calib_um;
            ym = ym / calib_um;            
            %%% XXX add separate z-step calibration value.
        end
        
    end
    
    xlo = min(xm);
    xhi = max(xm);
    ylo = min(ym);
    yhi = max(ym);
    
    if get(handles.radio_XYfig, 'Value')
        k = find( (x > xlo & x < xhi & y > ylo & y < yhi ) & beadID == currentbead);

        handles.trajdata = trajdata(k,:);
        handles.tstamp_times = handles.tstamp_times(k);

    elseif get(handles.radio_XTfig, 'Value')
        k = find( ~(t > xlo & t < xhi ) & beadID == currentbead );

        trajdata(k,:) = [];
        handles.tstamp_times(k) = [];
        handles.trajdata = trajdata;

    elseif get(handles.radio_AUXfig, 'Value')
        logentry('Deleting data from AUX plot is not allowed.');
    end
    
    guidata(hObject, handles);

    
function delete_data_before_time(hObject, eventdata, handles) 
    
    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    trajdata = handles.trajdata;    

    t = trajdata(:,TIME) - handles.mintime;
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify time
    idx = find(dists == min(dists));
    closest_time = mean(t(idx));
    
    % remove any points in the trajdata that have times eariler than our
    % prescribed beginning time point
    idx = find(trajdata(:,TIME) > (closest_time + handles.mintime));
    trajdata = trajdata(idx,:);
    
    handles.trajdata = trajdata;
    handles.mintime = min(trajdata(:,TIME));
    guidata(hObject, handles);

    
function delete_data_after_time(hObject, eventdata, handles)

    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    trajdata = handles.trajdata;

    t = trajdata(:,TIME) - handles.mintime;
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify index value that corresponds to this time
    idx = find(dists == min(dists));
    closest_time = t(idx);

    % remove any points in the trajdata that are greater than the time value
    % selected by the mouse-click.
    idx = find(t <= closest_time(1));
    trajdata = trajdata(idx,:);
    
    handles.trajdata = trajdata;
    guidata(hObject, handles);


function compute_stuff_for_plots(hObject, eventdata, handles)
    
    trajdata   = handles.trajdata;
    im         = handles.im;
    mintime    = handles.mintime;

    beadID = trajdata(:,ID);
    frame  = trajdata(:,FRAME);
    x      = trajdata(:,X) * calib_um;
    y      = trajdata(:,Y) * calib_um;
    z      = trajdata(:,Z);
    t      = trajdata(:,TIME);
    sens   = trajdata(:,SENS);
    cent   = trajdata(:,CENTINTS);
    
    if size(im,1) > 1
        [imy, imx, imc] = size(im);
    else
        imy = ceil(max(y));% * 1.1;
        imx = ceil(max(x));% * 1.1;
    end

    if get(handles.radio_microns, 'Value')
        x = x * calib_um;
        y = y * calib_um;
    end

    % Pull stuff off the UI
    AUXfig = handles.AUXfig;         
    AUXtype = handles.AUXtype;
    currentBead = round(get(handles.slider_BeadID, 'Value'));
    arb_origin = str2double(get(handles.edit_arb_origin, 'String'));      
    frame_rate = str2double(get(handles.edit_frame_rate, 'String'));
    calib_um   = str2double(get(handles.edit_calib_um, 'String'));
    bead_diameter_um = str2double(get(handles.edit_bead_diameter_um, 'String'));
    numtaus = round(str2double(get(handles.edit_numtaus, 'String')));
    
    % separate the currently selected bead vs not the selected bead
	k  = find(beadID == (currentBead));
	nk = find(beadID ~= (currentBead));
    
    dt = 1 ./ frame_rate;    

    %
    % Handle origins, scalings, and offsets
    %
    if get(handles.radio_relative, 'Value')
        xinit = x(k); 
        if ~isempty(xinit)
            xinit = xinit(1); 
        end
        
        yinit = y(k); 
        if ~isempty(yinit)
            yinit = yinit(1); 
        end
        
        zinit = z(k); 
        if ~isempty(zinit)
            zinit = zinit(1); 
        end
    elseif get(handles.radio_arb_origin, 'Value')            
        xinit = arb_origin(1);
        yinit = arb_origin(2);
        zinit = arb_origin(3);

        % handle the case where 'microns' are selected
        if get(handles.radio_microns, 'Value')
            xinit = xinit * calib_um;
            yinit = yinit * calib_um;                
            zinit = zinit * calib_um;
        end                        
    end
 
    if get(handles.checkbox_neutoffsets, 'Value') && ~isempty(k)
        xk1 = x(k(1));
        yk1 = y(k(1));
        zk1 = z(k(1));        
    else
        xk1 = 0;
        yk1 = 0;
        zk1 = 0;
    end
    handles.xyzk1 = [xk1, yk1, zk1];
    
    r = magnitude(x(k) - xinit, y(k) - yinit, z(k) - zinit);
    
    %
    % Velocity computations by tracker
    %
    velx = zeros(size(beadID));
    vely = zeros(size(beadID));    
    beadlist = unique(beadID);
    for b = 1:length(beadlist)        
        thisbead = find(beadID == beadlist(b));
        velx(thisbead,1) = CreateGaussScaleSpace(x(thisbead), 1, 1)/dt;
        vely(thisbead,1) = CreateGaussScaleSpace(y(thisbead), 1, 1)/dt;
    end
    

    
   %
   % Mapping the logged-velocities to colors for scatter-point color-mapping
   %   
   % Obvious first steps:
   % 1. Get the magnitude of the velocity vectors 
   % 2. Set any NaN to zero.
   % 3. Take the log. We need to keep the original non-shifted logvr
   %    separate from the shifted/color-mapped one
   vr = magnitude(velx, vely);    
   vr(isnan(vr)) = 0;
   logvr = log10(vr);
   
   
   % Set any number that is set to -inf to the *non-infinite* minimum value.
   % We are just setting colors in the colormap. Anything with zero 
   % (or "less") velocity will just be black anyway. We need to keep the
   % original (non-infinite) non-shifted logvr separate from the 
   % shifted/color-mapped one.
   logvr(~isfinite(logvr)) = min(logvr(isfinite(logvr)));
   lvr = logvr;
   
   % We want to normalize the velocities to the colormap, where 1 is the
   % highest colormap value and 0 the lowest. To do that we add the minimum
   % value. If that minimum value is negative, we'll subtract is out
   % anyway. Once this operation is over the minimum value should be zero
   % and the maximum value should be one.   
   lvr = lvr + min(abs(lvr));
   lvr = lvr - min(lvr);   
   normvr = lvr ./ max(lvr);
   
   vals = floor(normvr * 254);
   heatmap = colormap(hot(256));
   velclr = heatmap(vals+1,:);
   
   handles.logvr = logvr;
   handles.velclr = velclr;
   guidata(hObject, handles);
   
    NGridX = 45;
    NGridY = 45;
    videoStruct.xDim = imx;
    videoStruct.yDim = imy;
    videoStruct.pixelsPerMicron = 1 / calib_um;
    videoStruct.fps = frame_rate;
    xgrid = (1:NGridX)*(videoStruct.xDim/NGridX/videoStruct.pixelsPerMicron);
    ygrid = (1:NGridY)*(videoStruct.yDim/NGridY/videoStruct.pixelsPerMicron);
    VelField = vel_field(trajdata, NGridX, NGridY, videoStruct);
    Xvel = reshape(VelField.sectorX, NGridX, NGridY);
    Yvel = reshape(VelField.sectorY, NGridX, NGridY);
    Vmag = sqrt(Xvel.^2 + Yvel.^2);
 
    % 
    % Setting up MSD computations
    %    
    if strcmp(AUXtype, 'MSD')  || ...
       strcmp(AUXtype, 'GSER') || ...
       strcmp(AUXtype, 'sensitivity (SNR)') || ...
       strcmp(AUXtype, 'center intensity') || ...
       strcmp(AUXtype, 'alpha vs tau') || ...
       strcmp(AUXtype, 'alpha histogram') || ...
       strcmp(AUXtype, 'Diffusivity vs. tau') || ...
       strcmp(AUXtype, 'MSD histogram') || ...
       strcmp(AUXtype, 'RMS displacement') || ...
       strcmp(AUXtype, 'Bayesian Model Histogram') || ...
       strcmp(AUXtype, 'Bayesian Model MSD')
        if handles.recomputeMSD % && get(handles.checkbox_msdmean, 'Value')
            if calib_um ~= 1
                trajdata(:,[X Y Z]) = trajdata(:,[X Y Z]) * calib_um * 1e-6;
            end
            mymsd = video_msd(trajdata, numtaus, frame_rate, calib_um, 'no');            
            myve = ve(mymsd, bead_diameter_um*1e-6/2, 'f', 'n');
            myD = mymsd.msd ./ (4 .* mymsd.tau);
            handles.mymsd = mymsd;
            handles.myve  = myve;
            handles.myD   = myD;
            handles.recomputeMSD = 0;
            if isfield(handles, 'bayes')
                handles = rmfield(handles, 'bayes');
            end
            guidata(hObject, handles);
        end

        msdID   = unique(trajdata(:,ID))';    
        mymsd   = handles.mymsd;
        myve    = handles.myve;
        myD     = handles.myD;
        tau = mymsd.tau;
        msd = mymsd.msd;
        
        q  = find(msdID  == currentBead);

    end  
    
   return


function compute_viscosity_stds(hObject, eventdata, handles) 
    video_tracking_constants;
    kB = 1.3806e-23; % [m^2 kg s^-2 K^-1];
    temp_K = 296; % [K]
    
    trajdata = handles.trajdata;
    numtaus = str2double(get(handles.edit_chosentau, 'String'));
    framemax = max(trajdata(:,FRAME));
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
    
    handles.rheo = rheo;
    guidata(hObject, handles);
    
    return
    

function plot_XYfig(hObject, eventdata, handles)

    imagesc([0 imx] * calib_um, [0 imy] * calib_um, im);
    colormap(gray);
    if get(handles.checkbox_overlayxy, 'Value')
        hold on;
            plot(x(nk) * calib_um, y(nk) * calib_um, '.', ...
                 x(k)  * calib_um, y(k)  * calib_um, 'r.');
        hold off;
    end
    
    if isfield(handles, 'poleloc')
        polex = handles.poleloc(1);
        poley = handles.poleloc(2);
        circradius = 50;
        
        if get(handles.radio_microns, 'Value')
            polex = polex * calib_um;
            poley = poley * calib_um;
            circradius = circradius * calib_um;
        end
        
        hold on;
            plot(polex, poley, 'r+', 'MarkerSize', 36);
            circle(polex, poley, circradius, 'r');
        hold off;
    end
    
    xlabel(['displacement [' ylabel_unit ']']);
    ylabel(['displacement [' ylabel_unit ']']);    
    axis([0 imx 0 imy] .* calib_um);
    set(handles.XYfig, 'Units', 'Normalized');
    set(handles.XYfig, 'Position', [0.1 0.05 0.4 0.4]);
    set(handles.XYfig, 'DoubleBuffer', 'on');
    set(handles.XYfig, 'BackingStore', 'off');
    drawnow;

return


function plot_XTfig(hObject, eventdata, handles)     

function calculate_radial_vector(hObject, eventdata, handles)


function plot_radial_vector(hObject, eventdata, handles)
    video_tracking_constants;
    
    idx = (handles.trajdata(:,ID) == handles.currentBead);
    t = handles.trajdata(idx, TIME);
    r = handles.trajdata(idx, X);
    mintime = handles.mintime;
    figure;
    plot(t - mintime, r, '.-');
    xlabel('time (s)');
    ylabel(['radial dispacement [' ylabel_unit ']']);
    drawnow;
 return

function plot_sensitivity(hObject, eventdata, handles)

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

    
function plot_data(hObject, eventdata, handles)
    disp(['CurrentBead=' num2str(handles.currentBead)]);
    
    
function old_plot_data(hObject, eventdata, handles)    
    video_tracking_constants;
    COMPUTED = 0;

    
    if get(handles.radio_pixels, 'Value')
        calib_um = 1;
        ylabel_unit = 'pixels';
    elseif get(handles.radio_microns, 'Value')
        calib_um = str2double(get(handles.edit_calib_um, 'String')); 
        ylabel_unit = '\mum';
    end
    
    trajdata   = handles.trajdata;
    im     = handles.im;
    beadID = trajdata(:,ID);
    frame  = trajdata(:,FRAME);
    x      = trajdata(:,X) * calib_um;
    y      = trajdata(:,Y) * calib_um;
    z      = trajdata(:,Z);
    t      = trajdata(:,TIME);
    sens   = trajdata(:,SENS);
    cent   = trajdata(:,CENTINTS);
    mintime = handles.mintime;
    
    if size(im,1) > 1
        [imy, imx, imc] = size(im);
    else
        imy = ceil(max(y));% * 1.1;
        imx = ceil(max(x));% * 1.1;
    end
    
    % Pull stuff off the UI
    AUXfig = handles.AUXfig;         
    AUXtype = handles.AUXtype;
    currentBead = round(get(handles.slider_BeadID, 'Value'));
    arb_origin = str2double(get(handles.edit_arb_origin, 'String'));      
    frame_rate = str2double(get(handles.edit_frame_rate, 'String'));
    calib_um   = str2double(get(handles.edit_calib_um, 'String'));
    bead_diameter_um = str2double(get(handles.edit_bead_diameter_um, 'String'));
    numtaus = round(str2double(get(handles.edit_numtaus, 'String')));


    
    % separate the currently selected bead vs not the selected bead
	k  = find(beadID == (currentBead));
	nk = find(beadID ~= (currentBead));
    
    dt = 1 ./ frame_rate;    

    %
    % Handle origins, scalings, and offsets
    %
    if get(handles.radio_relative, 'Value')
        xinit = x(k); 
        if ~isempty(xinit)
            xinit = xinit(1); 
        end
        
        yinit = y(k); 
        if ~isempty(yinit)
            yinit = yinit(1); 
        end
        
        zinit = z(k); 
        if ~isempty(zinit)
            zinit = zinit(1); 
        end
    elseif get(handles.radio_arb_origin, 'Value')            
        xinit = arb_origin(1);
        yinit = arb_origin(2);
        zinit = arb_origin(3);

        % handle the case where 'microns' are selected
        if get(handles.radio_microns, 'Value')
            xinit = xinit * calib_um;
            yinit = yinit * calib_um;                
            zinit = zinit * calib_um;
        end                        
    end
 
    if get(handles.checkbox_neutoffsets, 'Value') && ~isempty(k)
        xk1 = x(k(1));
        yk1 = y(k(1));
        zk1 = z(k(1));        
    else
        xk1 = 0;
        yk1 = 0;
        zk1 = 0;
    end
    handles.xyzk1 = [xk1, yk1, zk1];
    
    r = magnitude(x(k) - xinit, y(k) - yinit, z(k) - zinit);
    
    %
    % Velocity computations by tracker
    %
    velx = zeros(size(beadID));
    vely = zeros(size(beadID));    
    beadlist = unique(beadID);
    for b = 1:length(beadlist)        
        thisbead = find(beadID == beadlist(b));
        velx(thisbead,1) = CreateGaussScaleSpace(x(thisbead), 1, 1)/dt;
        vely(thisbead,1) = CreateGaussScaleSpace(y(thisbead), 1, 1)/dt;
    end
    
        
%     for b = 1:length(beadlist)        
%         foo = find(beadID == beadlist(b));        
%         beadID(foo(1)) = [];
%         x(foo(1)) = [];
%         y(foo(1)) = [];
%         velx(foo(1)) = [];
%         vely(foo(1)) = [];
%     end    
 

   %
   % Mapping the logged-velocities to colors for scatter-point color-mapping
   %   
   % Obvious first steps:
   % 1. Get the magnitude of the velocity vectors 
   % 2. Set any NaN to zero.
   % 3. Take the log. We need to keep the original non-shifted logvr
   %    separate from the shifted/color-mapped one
   vr = magnitude(velx, vely);    
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
%    lvr(lvr <= 0) = 0;
   lvr = lvr - min(lvr);   
   normvr = lvr ./ max(lvr);
   
   vals = floor(normvr * 255);
   heatmap = hot(256);
   velclr = heatmap(vals+1,:);
   
%    handles.logvr = logvr;
%    handles.velclr = velclr;
%    guidata(hObject, handles);
    
   NGridX = 50;
   NGridY = 50;
   videoStruct.xDim = imx;
   videoStruct.yDim = imy;
   videoStruct.pixelsPerMicron = 1 / calib_um;
   videoStruct.fps = frame_rate;
   xgrid = (1:NGridX)*(videoStruct.xDim/NGridX/videoStruct.pixelsPerMicron);
   ygrid = (1:NGridY)*(videoStruct.yDim/NGridY/videoStruct.pixelsPerMicron);
   VelField = vel_field(trajdata, NGridX, NGridY, videoStruct);
   Xvel = reshape(VelField.sectorX, NGridX, NGridY);
   Yvel = reshape(VelField.sectorY, NGridX, NGridY);
   Vmag = sqrt(Xvel.^2 + Yvel.^2);
 
   Vmag(Vmag<0.001) = NaN;
   Vmag(isnan(Vmag)) = min(Vmag(~isnan(Vmag)));
   
    % 
    % Setting up MSD computations
    %    
    if strcmp(AUXtype, 'MSD')  || ...
       strcmp(AUXtype, 'GSER') || ...
       strcmp(AUXtype, 'sensitivity (SNR)') || ...
       strcmp(AUXtype, 'center intensity') || ...
       strcmp(AUXtype, 'alpha vs tau') || ...
       strcmp(AUXtype, 'alpha histogram') || ...
       strcmp(AUXtype, 'Diffusivity vs. tau') || ...
       strcmp(AUXtype, 'MSD histogram') || ...
       strcmp(AUXtype, 'RMS displacement') || ...
       strcmp(AUXtype, 'Bayesian Model Histogram') || ...
       strcmp(AUXtype, 'Bayesian Model MSD')
        if handles.recomputeMSD % && get(handles.checkbox_msdmean, 'Value')
            if calib_um ~= 1
                trajdata(:,[X Y Z]) = trajdata(:,[X Y Z]) * calib_um * 1e-6;
            end
            mymsd = video_msd(trajdata, numtaus, frame_rate, calib_um, 'no');            
            myve = ve(mymsd, bead_diameter_um*1e-6/2, 'f', 'n');
            myD = mymsd.msd ./ (4 .* mymsd.tau);
            handles.mymsd = mymsd;
            handles.myve  = myve;
            handles.myD   = myD;
            handles.recomputeMSD = 0;
            if isfield(handles, 'bayes')
                handles = rmfield(handles, 'bayes');
            end
            guidata(hObject, handles);
        end

        msdID   = unique(trajdata(:,ID))';    
        mymsd   = handles.mymsd;
        myve    = handles.myve;
        myD     = handles.myD;
        tau = mymsd.tau;
        msd = mymsd.msd;
        
        q  = find(msdID  == currentBead);

    end    
    
%     % computing PSD
%     [p, f, id] = mypsd([x(k) y(k)]*1e-6, frame_rate, frame_rate/100, 'rectangle');
    
    %
    % PLOTTING THE XY figure
    %
    figure(handles.XYfig);   
    imagesc([0 imx] * calib_um, [0 imy] * calib_um, im);
    colormap(gray);
    if get(handles.checkbox_overlayxy, 'Value')
        hold on;
            plot(x(nk) * calib_um, y(nk) * calib_um, '.', ...
                 x(k)  * calib_um, y(k)  * calib_um, 'r.');
        hold off;
    end
    
    if isfield(handles, 'poleloc')
        polex = handles.poleloc(1);
        poley = handles.poleloc(2);
        circradius = 50;
        
        if get(handles.radio_microns, 'Value')
            polex = polex * calib_um;
            poley = poley * calib_um;
            circradius = circradius * calib_um;
        end
        
        hold on;
            plot(polex, poley, 'r+', 'MarkerSize', 36);
            circle(polex, poley, circradius, 'r');
        hold off;
    end
    
    xlabel(['displacement [' ylabel_unit ']']);
    ylabel(['displacement [' ylabel_unit ']']);    
    axis([0 imx 0 imy] .* calib_um);
    set(handles.XYfig, 'Units', 'Normalized');
    set(handles.XYfig, 'Position', [0.4039 0.7495 0.1474 0.1755]);
%     set(handles.XYfig, 'Position', [0.1 0.05 0.4 0.4]);
    set(handles.XYfig, 'DoubleBuffer', 'on');
    set(handles.XYfig, 'BackingStore', 'off');
    drawnow;
   
    
    % 
    % PLOTTING XY&Z vs T
    %
    figure(handles.XTfig);
    plot(t(k) - mintime, [x(k)-xk1 y(k)-yk1 z(k)-zk1], '.-');
    xlabel('time [s]');
    ylabel(['displacement [' ylabel_unit ']']);
    legend('x', 'y', 'z', 'Location', 'northwest');    
    set(handles.XTfig, 'Units', 'Normalized');
    set(handles.XTfig, 'Position', [0.4039 0.5025 0.1474 0.1755]);
%     set(handles.XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    set(handles.XTfig, 'DoubleBuffer', 'on');
    set(handles.XTfig, 'BackingStore', 'off');    
    drawnow;
    

    
    if strcmp(AUXfig,'OFF')
        set(AUXfig, 'Visible', 'off');
        clf(AUXfig);
    else
        set(AUXfig, 'Visible', 'on');            
%        clf(AUXfig);
    end
    
    figure(AUXfig);       
    set(handles.AUXfig, 'Units', 'Normalized');
%     set(handles.AUXfig, 'Position', [0.5617 0.5157 0.4000 0.4000]);
%     set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
    set(handles.AUXfig, 'DoubleBuffer', 'on');
    set(handles.AUXfig, 'BackingStore', 'off');    

    switch AUXtype
        case 'OFF'            
            
        case 'radial vector'
            plot(t(k) - mintime, r, '.-');
            xlabel('time (s)');
            ylabel(['radial dispacement [' ylabel_unit ']']);
                        
        case 'sensitivity (SNR)'            
            plot(t(k) - mintime, sens(k), '.-');
            xlabel('time (s)');
            ylabel('Tracking Sensitivity');
            
        case 'center intensity'            
            plot(t(k) - mintime, cent(k)./max(cent(k)), '.-');
            xlabel('time (s)');
            ylabel('Center Intensity (frac of max)');            
            
        case 'velocity'            
            plot(t(k) - mintime, [velx(k,1) vely(k,1)], '.-');
            xlabel('time (s)');
            ylabel(['velocity [' ylabel_unit '/s]']);
            legend('x', 'y');    
            
        case 'velocity magnitude'
            
            plot(t(k) - mintime, vr(k), '.-');
            xlabel('time (s)');
            ylabel(['velocity [' ylabel_unit '/s]']);
            legend('r');    
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
            
        case 'velocity scatter (all)'

            if get(handles.radio_microns, 'Value') 
              imx = imx * calib_um;
              imy = imy * calib_um;
            end
            
                vsbd= [];            
                vsx = [];
                vsy = [];           
                vsr = [];
                vsclr = zeros(0,3);
                
                bIDlist = unique(beadID); 
                imagesc([0 imx], [0 imy], im);
                colormap(gray(256));
                
            % Trim off the first and last positions and velocities to
            % remove edge effects of calculating the derivative.
            for bl = 1:length(bIDlist)
                cb = find(beadID == bIDlist(bl));
                cb = cb(2:end-1);

                vsbd= [vsbd; beadID(cb)];                    
                vsx = [vsx; x(cb)];
                vsy = [vsy; y(cb)];
                vsr = [vsr; vr(cb)];
                vsclr = [vsclr; velclr(cb,:)];                    
            end
            
            % Construct the plot
            hold on;
                % Plot the line for each path
                for bl = 1:length(bIDlist)                                       
                  cb = find(vsbd == bIDlist(bl));  
                  plot(vsx(cb), vsy(cb), 'w-');                               
                end
                % Plot the scatter points, colored according to velocity
                % magnitude
                scatter(vsx, vsy, 10, vsclr, 'filled');
                axis([0 imx 0 imy]);
            hold off;
            
            set(gca, 'YDir', 'reverse');            
            manual_colorbar(log10([min(vsr) max(vsr)]));
            disp(['Minimum Velocity = ' num2str(min(vsr)) ' ' ylabel_unit '/s.']);
            disp(['Maximum Velocity = ' num2str(max(vsr)) ' ' ylabel_unit '/s.']);
            
            drawnow;
            
        case 'velocity scatter (active)'            

            imagesc([0 imx], [0 imy], im);
            colormap(gray);
    
            hold on;
                plot(x(nk), y(nk), 'b.');
                scatter(x(k), y(k), [], velclr(k,:), 'filled');
                set(gca, 'YDir', 'reverse');
            hold off;
            
            xlabel(['displacement [' ylabel_unit ']']);
            ylabel(['displacement [' ylabel_unit ']']);    
            
        case 'velocity vectorfield'            
            
            plot_vel_field(VelField, videoStruct, AUXfig);
            colormap(hot);
            xlabel('\mum')
            ylabel('\mum')
            title('Vel. [\mum/s]');
            colorbar;
            pretty_plot;

        case 'vel. mag. scalarfield'
            
            imagesc(xgrid, ygrid, log10(Vmag')); 
            colormap(hot);
            xlabel('\mum')
            ylabel('\mum')
            title('Vel. [\mum/s]');
            colorbar;
            pretty_plot;
            
        case 'PSD'
            
            loglog(f, p);
            xlabel('frequency [Hz]');
			ylabel('power [m^2/Hz]');
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    

        case 'Integrated Disp'
            
            [p, f, id] = mypsd([x(k) y(k)], frame_rate, 10/frame_rate, 'blackman');

            plot(f, id, '.');            
%         case 'displacement hist'
%             figure(handles.AUXfig);
%             set(AUXfig, 'Visible', 'on');
%             clf(AUXfig);
%             
%             [tau, bins, dist] = diffdist(t(k), [x(k) y(k)], []);
%             plot(dist(1,:,1), bins(1,:,1), '.');
            
        case 'MSD'

            plot_all = get(handles.checkbox_msdall, 'Value');
            plot_mean = get(handles.checkbox_msdmean, 'Value');            
            
            if plot_all && plot_mean
                plot_msd(mymsd, AUXfig, 'ame');
                
                figure(AUXfig);
                hold on;
                    plot(log10(tau(:,q)), log10(msd(:,q)), 'r.-');
                hold off;
            elseif plot_all
                plot_msd(mymsd, AUXfig, 'a');
                
                hold on;
                    plot(log10(tau(:,q)), log10(msd(:,q)), 'r.-');
                    [rows,cols] = size(tau);
                    legend({num2str(transpose(0:cols-1))});
                    legend off
                hold off;
            elseif plot_mean
                plot_msd(mymsd, AUXfig, 'me');                
            end
            

            rheo = handles.rheo;

            hold on;
            if get(handles.checkbox_watermsd, 'Value')               
                    plot(log10(tau(:,q)), log10(rheo.stdMSD.water), 'b--', 'DisplayName', 'water');
            end
            if get(handles.checkbox_2Mmsd, 'Value')               
                    plot(log10(tau(:,q)), log10(rheo.stdMSD.sucrose_2M), 'r--', 'DisplayName', '2M sucrose');
            end
            if get(handles.checkbox_2p5Mmsd, 'Value')               
                    plot(log10(tau(:,q)), log10(rheo.stdMSD.sucrose_2p5M), 'k--', 'DisplayName', '2p5M sucrose');
            end           
            hold off;            
            grid on;
            
        case 'RMS displacement'
            plot_rmsdisp(mymsd, AUXfig, 'm');
            
        case 'alpha vs tau'
            plot_alphavstau(myve, AUXfig);
            
        case 'alpha histogram'
            mytauidx = str2double(get(handles.edit_chosentau, 'String'));
            
            A = mymsd.tau(1:end-1,:);
            B = mymsd.tau(2:end,:);
            C = mymsd.msd(1:end-1,:);
            D = mymsd.msd(2:end,:);

            alpha = log10(D./C)./log10(B./A);
            
            myalpha = alpha(mytauidx, :);
            set(handles.text_chosentau_value, 'String', num2str(mean(mymsd.tau(mytauidx,:))));
            plot_alphadist(myalpha, AUXfig);
            
        case 'MSD histogram'
            mytauidx = str2double(get(handles.edit_chosentau, 'String'));
            numbins = 51;
            
            mymsd_at_mytau = mymsd.msd(mytauidx, :);
            
            set(handles.text_chosentau_value, 'String', num2str(mean(mymsd.tau(mytauidx,:))));
            
            plot_msdhist_at_tau(mymsd_at_mytau, AUXfig);
            
        case 'Diffusivity @ a tau'
            
        case 'Diffusivity vs. tau'            
            plot(     log10(mymsd.tau),       log10(myD) , 'b', ...
                 mean(log10(mymsd.tau),2), mean(log10(myD),2), 'k');
            xlabel('\tau [s]');
            ylabel('Diffusivity [m^2/s]');
            grid on;
            pretty_plot;
            
        case 'temporal MSD'            
            [tau, m, time] = msdt(t(k), [x(k) y(k)], [], []);            
            surf(m);
            
        case 'Bayesian Model Histogram'            
            if ~isfield(handles, 'bayes')
                bayes = run_bayes_model_selection(hObject, eventdata, handles);
%                 bayes = run_bayes_model_selection_general(hObject, eventdata, handles);
            else
                bayes = handles.bayes;
            end
            
            bayes_plot_bar_model_freq(bayes.results, handles.AUXfig);
            
        case 'Bayesian Model MSD'
            
            if ~isfield(handles, 'bayes')
                bayes = run_bayes_model_selection(hObject, eventdata, handles);
%                 bayes = run_bayes_model_selection_general(hObject, eventdata, handles);
            else
                bayes = handles.bayes;
            end
            
            bayes_plot_msd_by_color_jac(bayes, handles.AUXfig);
            
        case 'GSER'
            plot_GSER(hObject, eventdata, handles);
            
        case 'pole locator'
            handles.poleloc = pole_locator(trajdata, handles.im, 'y', AUXfig);
            guidata(hObject, handles);
            poleloctxt = [num2str(handles.poleloc(1)) ', ' num2str(handles.poleloc(2))];
            set(handles.edit_arb_origin, 'String', poleloctxt);
            fprintf('Pole location [pixels]: X = %5.2f, Y = %5.2f\n', handles.poleloc(1), handles.poleloc(2)); 
            
        case 'tracker avail'
            plot_tracker_avail(frame, beadID, handles.AUXfig);
            
        case '2pt MSD'
            
            if COMPUTED == 0
                MICRONS = get(handles.radio_microns, 'Value');
                if MICRONS == 0
                    calib = get(handles.edit_calib_um, 'String');
                    calib = str2double(calib);
                    x = x*calib;
                    y = y*calib;
                end
                homefolder = 'D:\3dfmAnalysis\external\twopoint\';
                filename = get(handles.edit_outfile, 'String');
                slash = strfind(filename,'\');
                basepath = filename(1:slash(end));
                fps = get(handles.edit_frame_rate, 'String');
                fps = str2double(fps);
                timestep = 1/fps;
                beaddiam = get(handles.edit_bead_diameter_um, 'String');
                beaddiam = str2double(beaddiam);
                beadradius = beaddiam/2;
                imagediag = 90;
                temp = get(handles.edit_temp, 'String');
                temp = str2double(temp);
                [omega,Gp,Gpp,MSD] = evt_run_microrheology2P(homefolder,basepath,beadID,frame,x,y,timestep,beadradius,imagediag,temp);
                COMPUTED = 1;
            end
            
            plot_msd_2pt(MSD,AUXfig,'m');
            
        case '2pt GSER'
            
            if COMPUTED == 0
                MICRONS = get(handles.radio_microns, 'Value');
                if MICRONS == 0
                    calib = get(handles.edit_calib_um, 'String');
                    calib = str2double(calib);
                    x = x*calib;
                    y = y*calib;
                end
                homefolder = 'D:\3dfmAnalysis\GUIs\evt_GUI\microrheology\';
                filename = get(handles.edit_outfile, 'String');
                slash = strfind(filename,'\');
                basepath = filename(1:slash(end));
                fps = get(handles.edit_frame_rate, 'String');
                fps = str2double(fps);
                timestep = 1/fps;
                beaddiam = str2double(get(handles.edit_bead_diameter_um, 'String'));
                beadradius = beaddiam/2;
                imagediag = 90;
                temp = str2double(get(handles.edit_temp, 'String'));
                [omega,Gp,Gpp,MSD] = evt_run_microrheology2P(homefolder,basepath,beadID,frame,x,y,timestep,beadradius,imagediag,temp);
                COMPUTED = 1;
            end
            
            f = omega/(2*pi);
            np = Gpp./omega;
            npp = Gp./omega;
            tau = MSD(:,1,1);
            
            myve.w      = omega;
            myve.f      = f;
            myve.np     = np;
            myve.npp    = npp;
            myve.tau    = tau;
            myve.gp     = Gp;
            myve.gpp    = Gpp;
            
            plotG = 1;
            ploteta = 1;
            if (plotG && ploteta)
                plot_ve_2pt(myve, 'f', AUXfig, 'GgNn');
            elseif plotG
                plot_ve_2pt(myve, 'f', AUXfig, 'Gg');
            elseif ploteta %#ok<UNRCH>
                plot_ve_2pt(myve, 'f', AUXfig, 'Nn');
            else
                error('Unknown plotting condition for 2 pt.');
            end
    end
    
     drawnow;
 
 if COMPUTED ~= 1
    refresh(handles.XYfig);
    refresh(handles.XTfig);
    refresh(handles.AUXfig);
 end
     

function bayes = run_bayes_model_selection(hObject, eventdata, handles)
    video_tracking_constants;

    vidtable = handles.trajdata;

    calibum = str2double(get(handles.edit_calib_um, 'String'));

    % Set up filter settings for trajectory data
    
    filt.min_frames = 300; % DEFAULT
    filt.xyzunits   = 'm';
    filt.calib_um   = calibum;

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
    
    vidtable = handles.trajdata;

    % max_tau_s is the maximum time scale the user wants the bayesian
    % modeling code to consider when binning MSD curves.
    max_tau_s = 1;
        
    % fraction_for_subtrajectories provides the shortest total trajectory
    % length we can get away with for the number of subtrajectories we
    % want.
    fraction_for_subtraj = 0.75;

    fps = str2double(get(handles.edit_frame_rate, 'String'));
    bead_radius = str2double(get(handles.edit_bead_diameter_um, 'String'))*1e-6/2;
    calibum = str2double(get(handles.edit_calib_um, 'String'));
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
    filt.calib_um   = calibum;

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


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'evt_gui: '];
     
     fprintf('%s%s\n', headertext, txt);
 


% --- Executes when user attempts to close evt_GUI.
function evt_GUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to evt_GUI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
    FileMenuQuit_Callback(hObject, eventdata, handles)
