 function varargout = evt_GUI(varargin)
% EVT_GUI creates a new evt_GUI or raises the existing singleton
%
% 3DFM function
% GUIs/evt_GUI
% last modified 08/26/10
%
% evt_GUI M-file for evt_GUI.fig
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

% Last Modified by GUIDE v2.5 19-Jul-2013 13:51:48

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
    

function evt_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

    
	% Choose default command line output for evt_GUI
	handles.output = hObject;
	
	% Update handles structure
	guidata(hObject, handles);
	
	% UIWAIT makes evt_GUI wait for user response (see UIRESUME)
	% uiwait(handles.evt_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = evt_GUI_OutputFcn(hObject, eventdata, handles)
	

	% Get default command line output from handles structure
	varargout{1} = handles.output;

    
% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles) %#ok<DEFNU>
    if isfield(handles, 'XYfig');
        try
            close(handles.XYfig);
        catch
        end
    end

    if isfield(handles, 'XTfig');
        try
            close(handles.XTfig);
        catch
        end
    end

    if isfield(handles, 'AUXfig');
        try
            close(handles.AUXfig);
        catch
        end
    end

	close(evt_GUI);

    
% --- Executes on button press in radio_selected_dataset.
function radio_selected_dataset_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 1);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);
    
% --- Executes on button press in radio_insideboundingbox.
function radio_insideboundingbox_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 1);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);
    

% --- Executes on button press in radio_insideboundingbox.
function radio_outsideboundingbox_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 1);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);
    
    
% --- Executes on button press in radio_deletetimebefore.
function radio_deletetimebefore_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 1);
	set(handles.radio_deletetimeafter, 'Value', 0);

    
% --- Executes on button press in radio_deletetimebefore.
function radio_deletetimeafter_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_insideboundingbox, 'Value', 0);
    set(handles.radio_outsideboundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 1);
    
    
% --- Executes on button press in radio_XYfig.
function radio_XYfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 1);
    set(handles.radio_XTfig,  'Value', 0);    
    set(handles.radio_AUXfig, 'Value', 0);

    
% --- Executes on button press in radio_XTfig.
function radio_XTfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 0);
    set(handles.radio_XTfig,  'Value', 1);
    set(handles.radio_AUXfig, 'Value', 0);

% --- Executes on button press in radio_AUXfig.
function radio_AUXfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig,  'Value', 0);
    set(handles.radio_XTfig,  'Value', 0);
    set(handles.radio_AUXfig, 'Value', 1);    
    
% --- Executes during object creation, after setting all properties.
function edit_infile_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_infile_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_loadfile.
function pushbutton_loadfile_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    % reset the Active Bead to 0
    set(handles.edit_BeadID, 'String', '0');
    set(handles.slider_BeadID, 'Value', 0);
    
    filename = get(handles.edit_infile, 'String');
    
    if(isempty(filename))
		[fname, pname, fidx] = uigetfile({'*.mat';'*.csv';'*.*'}, ...
                        'Select File(s) to Open', ...
                        'MultiSelect', 'on');
        
        if sum(length(fname), length(pname)) <= 1
            logentry('No tracking file selected. No tracking file loaded.');
            return;
        end        
        
		filename = strcat(pname, fname);
        
        logentry(['Setting Path to: ' pname]);
        cd(pname);
        
        if iscell(filename) 
            set(handles.edit_infile,'String', 'Multiple Files loaded.');
        else
            set(handles.edit_infile,'String', filename);
        end
        
        set(handles.edit_outfile, 'String', '');
    end   

    filenameroot = strrep(filename,     '.raw', '');
    filenameroot = strrep(filenameroot, '.vrpn', '');
    filenameroot = strrep(filenameroot, '.mat', '');
    filenameroot = strrep(filenameroot, '.evt', '');

    % load the datafile
    logentry('Loading dataset... ');
    
    % assign "filter by" values if they're selected
    if get(handles.checkbox_minFrames, 'Value')
        handles.filt.min_frames = str2num(get(handles.edit_minFrames, 'String'));
    else
        handles.filt.min_frames = 0;
    end
        
    if get(handles.checkbox_minPixelRange, 'Value')
        handles.filt.min_pixels = str2num(get(handles.edit_minPixelRange, 'String'));
    else
        handles.filt.min_pixels = 0;
    end

    if get(handles.checkbox_maxpixels, 'Value')
        handles.filt.max_pixels = str2num(get(handles.edit_maxpixels, 'String'));
    else
        handles.filt.max_pixels = Inf;
    end
    
    if get(handles.checkbox_tCrop, 'Value')
        handles.filt.tcrop = str2num(get(handles.edit_tCrop, 'String'));
    else
        handles.filt.tcrop = 0;
    end
    
    if get(handles.checkbox_xyCrop, 'Value')
        handles.filt.xycrop = str2num(get(handles.edit_xyCrop, 'String'));
    else
        handles.filt.xycrop = 0;
    end
    
    handles.filt.xyzunits = 'pixels';
    handles.filt.calib_um = 1;
    
    
%     try
        [d, calout] = load_video_tracking(filename, [], [], [], 'absolute', 'yes', 'table');
        d = filter_video_tracking(d, handles.filt);
%     catch
%         msgbox('File Not Loaded! Problem with load_video_tracking.', 'Error.');
%         return;
%     end
    
    if ~isempty(calout)
        if length(unique(calout)) == 1
            set(handles.edit_calib_um, 'String', num2str(calout(1)));
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
        set(handles.edit_infile, 'TooltipString', 'Multiple files loaded.');
    else
        set(handles.edit_infile, 'TooltipString', filename);
    end
    
    set(handles.edit_infile, 'String', '');
    
    if iscell(filename)
        logentry('Multiple datasets successfully loaded...');
    else
        logentry(['Dataset, ' filename ', successfully loaded...']);
    end
    
    % try loading the MIP file
    try 
        MIPfile = [filenameroot, '.MIP.bmp'];
        im = imread(MIPfile, 'BMP');
        logentry('Successfully loaded MIP image...');
        MIPexists = 1;
    catch
        try 
            MIPfile = [filenameroot, '.vrpn.composite.tif'];
            im = imread(MIPfile, 'tif');
            logentry('Successfully loaded MIP image...');
            MIPexists = 1;
        catch        
            logentry('MIP file was not found.  Trying to load first frame...');

            % or, try loading the first frame        
            try
                fimfile = [filenameroot, '.0001.bmp'];
                im = imread(fimfile, 'BMP');
                logentry('Successfully loaded first frame image...');            
            catch
                logentry('first frame image was not found. Trying to extract first frame...');

                % last chance.... try extracting first frame
                try
                    rawfile = [filenameroot '.RAW'];
                    im = raw2img(rawfile, 'BMP', 1, 1);
                    logentry('Successfully extracted first frame image...');
                catch
                    logentry('Could not extract image; RAW file not found.  Giving up...');
                    im = 0;
                end
            end        
        end
    end
    
    % if the background MIP image exists, attach it to handles structure
    if exist('im', 'var')
        handles.im = im;
    else
        handles.im = [];
    end
    
%     if exist('MIPexists', 'var') && get(handles.checkbox_lumicrop, 'Value')
%         desired_lum = str2num(get(handles.edit_maxpixels, 'String'));
%         threshmult = 1.0;
%         
%         [d,dummyvar1,dummyvar2] = filter_bead_aggregates(d, im, desired_lum, threshmult);
%     elseif get(handles.checkbox_lumicrop, 'Value')
%         logentry('Cannot filter based on luminance because there no MIP exists');
%     end

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
    
    if iscell(filename)
        set(handles.edit_outfile, 'TooltipString', 'Multiple files loaded.');
    else
        set(handles.edit_outfile, 'TooltipString', outfile);
    end
    
    % assign data variables
    table = d;
    mintime = min(table(:,TIME));
    maxtime = max(table(:,TIME));
    beadID = table(:,ID);

    % update fps editbox so there is an indicator of real timesteps
    idx = find(beadID == 0);
    tsfps = round(1/mean(diff(table(idx,TIME))));
    logentry(['Setting frame rate to ' num2str(tsfps) ' fps.']);
    set(handles.edit_frame_rate, 'String', num2str(tsfps));
    
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
    handles.table = table;
    handles.mintime = mintime;
    handles.maxtime = maxtime;
    handles.tstamp_times = table(:,TIME);
    handles.recomputeMSD = 1;
    
    % Enable all of the controls now that data is loaded
    set(handles.checkbox_frame_rate                 , 'Enable', 'on');
    set(handles.text_frame_rate                     , 'Enable', 'on');
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
    set(handles.radio_linearmean                    , 'Enable', 'on');
    set(handles.pushbutton_select_drift_region      , 'Enable', 'on');
    set(handles.pushbutton_remove_drift             , 'Enable', 'on');
    set(handles.radio_pixels                        , 'Enable', 'on');
    set(handles.radio_microns                       , 'Enable', 'on');
    set(handles.edit_calib_um                       , 'Enable', 'on');
    set(handles.text_calib_um                       , 'Enable', 'on');
    set(handles.pushbutton_export_all_beads         , 'Enable', 'on');
    set(handles.pushbutton_export_bead              , 'Enable', 'on');
    set(handles.pushbutton_measure_distance         , 'Enable', 'on');
    
    set(handles.checkbox_msdmean, 'Value', 1);
    
    plot_data(hObject, eventdata, handles);
    guidata(hObject, handles);

    
% --- Executes on button press in pushbutton_savefile.
function pushbutton_savefile_Callback(hObject, eventdata, handles)
    video_tracking_constants;

	outfile = get(handles.edit_outfile, 'String');
    
    if (isempty(outfile))
        msgbox('No filename specified for output.', 'Error.');
        return;
    end
    
    tracking.spot3DSecUsecIndexFramenumXYZRPY = handles.table;
    save(outfile, 'tracking');
    logentry(['New tracking file, ' outfile ', saved...']);
    
    set(handles.edit_infile, 'String', '');
    set(handles.edit_outfile, 'String', '');    

       
% --- Executes during object creation, after setting all properties.
function edit_outfile_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_outfile_Callback(hObject, eventdata, handles)


% --- Executes on button press in pushbutton_Edit_Data.
function pushbutton_Edit_Data_Callback(hObject, eventdata, handles)

    if get(handles.radio_AUXfig, 'Value')
        logentry('AUXfigs are not allowed to delete data');
        return;
    end
    
    global hand;
    
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

    handles = hand;
    
	set(handles.radio_selected_dataset,   'Enable', 'On');
	set(handles.radio_insideboundingbox,  'Enable', 'On');
	set(handles.radio_outsideboundingbox, 'Enable', 'On');
    set(handles.radio_deletetimebefore,   'Enable', 'On');
    set(handles.radio_deletetimeafter,    'Enable', 'On');
    
    handles.recomputeMSD = 1;
    
    plot_data(hObject, eventdata, handles);
    
    guidata(hObject, handles);
    
    
% --- Executes during object creation, after setting all properties.
function slider_BeadID_CreateFcn(hObject, eventdata, handles)
	usewhitebg = 1;
	if usewhitebg
        set(hObject,'BackgroundColor',[.9 .9 .9]);
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


% --- Executes on slider movement.
function slider_BeadID_Callback(hObject, eventdata, handles)
	currentBead = round(get(handles.slider_BeadID, 'Value'));
	set(handles.edit_BeadID, 'String', num2str(currentBead));
    
    plot_data(hObject, eventdata, handles);
    drawnow;
    

% --- Executes during object creation, after setting all properties.
function edit_BeadID_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_BeadID_Callback(hObject, eventdata, handles)
	set(handles.slider_BeadID, 'Value', round(str2double(get(handles.edit_BeadID, 'String'))));

    
% --- Executes on button press in pushbutton_Select_Closest_xydataset.
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

        beadID = handles.table(:,ID);    
        x = handles.table(:,X);
        y = handles.table(:,Y);

        xval = repmat(xm, length(x), 1);
        yval = repmat(ym, length(y), 1);

        dist = sqrt((x - xval).^2 + (y - yval).^2);

        bead_to_select = beadID(find(dist == min(dist)));

        set(handles.slider_BeadID, 'Value', round(bead_to_select));
        set(handles.edit_BeadID, 'String', round(num2str(bead_to_select)));
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
        
                beadID = handles.table(:,ID);    
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
    

% --- Executes on button press in pushbutton_measure_distance.
function pushbutton_measure_distance_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    figure(handles.XYfig);
	[xm, ym] = ginput(2);
    li = line(xm,ym);
    set(li, 'Color', 'k');
    set(li, 'Marker', 'o');
    set(li, 'MarkerSize', 8);
    
    if get(handles.radio_microns, 'Value')
        calib_um = str2double(get(handles.edit_calib_um, 'String'));
%         xm = xm / calib_um;
%         ym = ym / calib_um;
        units = 'um';
    else
        units = 'pixels';
    end        
        
    dist = sqrt((xm(2) - xm(1)).^2 + (ym(2) - ym(1)).^2);
    
    diststr = [num2str(round(dist)) ' ' units];
    set(handles.text_distance, 'String', diststr);


    
% --- Executes on button press in pushbutton_select_drift_region.
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

    
% --- Executes on button press in radio_com.
function radio_com_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 1);
	set(handles.radio_linear, 'Value', 0);
    set(handles.radio_linearmean, 'Value', 0);

% --- Executes on button press in radio_linear.
function radio_linear_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 0);
	set(handles.radio_linear, 'Value', 1);
    set(handles.radio_linearmean, 'Value', 0);

    % --- Executes on button press in radio_linearmean.
function radio_linearmean_Callback(hObject, eventdata, handles)
	set(handles.radio_com, 'Value', 0);
	set(handles.radio_linear, 'Value', 0);
    set(handles.radio_linearmean, 'Value', 1);



% --- Executes on button press in pushbutton_export_bead.
function pushbutton_export_bead_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    currentBead = round(get(handles.slider_BeadID, 'Value'));
    beadID = handles.table(:,ID);

    k = find(beadID == currentBead);

    bead.t      = handles.table(k,TIME);
    bead.t      = bead.t - min(handles.table(:,TIME));
    bead.x      = handles.table(k,X);
    bead.y      = handles.table(k,Y);
    if isfield(bead, 'yaw');
        bead.yaw    = handles.table(idx,YAW);
    end
    
    assignin('base', ['bead' num2str(currentBead)], bead);
    
    
% --- Executes on button press in pushbutton_export_all_beads.
function pushbutton_export_all_beads_Callback(hObject, eventdata, handles)
    video_tracking_constants;
    
%     beadID = handles.table(:,ID);
% 
%     for k = 0:max(beadID)
%     
%         idx = find(beadID == k);
% 
%         bead(k+1).t      = handles.table(idx,TIME) - min(handles.table(:,TIME));
%         bead(k+1).x      = handles.table(idx,X);
%         bead(k+1).y      = handles.table(idx,Y);
%         bead(k+1).yaw    = handles.table(idx,YAW);
%         
%     end
    
    bead = convert_vidtable_to_beadstruct(handles.table);
    
    assignin('base', 'beads', bead);
    
    
% --- Executes on button press in radio_pixels.
function radio_pixels_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 1);
    set(handles.radio_microns, 'Value', 0);

    diststr = get(handles.text_distance, 'String');
    
    if findstr(diststr, 'um')
    elseif findstr(diststr, 'pixels')
    else
    end
    
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in radio_microns.
function radio_microns_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 0);
    set(handles.radio_microns, 'Value', 1);

    plot_data(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_calib_um_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_calib_um_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(hObject, eventdata, handles);    

% --- Executes on button press in pushbutton_remove_drift.
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
        [v,q] = remove_drift(handles.table, start_time, end_time, 'linear');
    elseif get(handles.radio_com, 'Value')
        logentry('Removing Drift via center-of-mass method.');
        [v,q] = remove_drift(handles.table, start_time, end_time, 'center-of-mass');
    elseif get(handles.radio_linearmean, 'Value')
        logentry('Removing Drift via linear mean method.');
        [v,q] = remove_drift(handles.table, start_time, end_time, 'linearMean');
    end
    
    handles.table = v;
    handles.recomputeMSD = 1;
	guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
        

% --- Executes on button press in checkbox_frame_rate.
function checkbox_frame_rate_Callback(hObject, eventdata, handles)

    video_tracking_constants;
    table = handles.table;
    
    if get(hObject, 'Value')      
        set(handles.edit_frame_rate, 'Enable', 'on');

        table(:,TIME) = table(:,FRAME) / str2double(get(handles.edit_frame_rate, 'String'));
        mintime = min(table(:,TIME));
        maxtime = max(table(:,TIME));
	
        handles.table = table;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
    else
        set(handles.edit_frame_rate, 'Enable', 'off');

        handles.table(:,TIME) = handles.tstamp_times;
        handles.mintime = min(handles.table(:,TIME));
        handles.maxtime = max(handles.table(:,TIME));
    end

    handles.recomputeMSD = 1;
	guidata(hObject, handles);
    
    plot_data(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_frame_rate_CreateFcn(hObject, eventdata, handles)
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_frame_rate_Callback(hObject, eventdata, handles)
    video_tracking_constants;

    table = handles.table;

    if get(handles.checkbox_frame_rate, 'Value');
        table(:,TIME) = table(:,FRAME) / str2double(get(hObject, 'String'));
        mintime = min(table(:,TIME));
        maxtime = max(table(:,TIME));
	
        handles.table = table;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
        handles.recomputeMSD = 1;
        guidata(hObject, handles);
	
        plot_data(hObject, eventdata, handles);
        drawnow;
    end

    
% --- Executes on button press in radio_relative.
function radio_relative_Callback(hObject, eventdata, handles)
    set(handles.radio_relative, 'Value', 1);
    set(handles.radio_arb_origin, 'Value', 0);
    
    plot_data(hObject, eventdata, handles);
    drawnow;

    
% --- Executes on button press in radio_arb_origin.
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
    arb_origin = str2num(get(hObject, 'String'));

    if length(arb_origin) ~= 2
        logentry('Origin value is not valid.  Not plotting.')
        set(handles.radio_arb_origin, 'Value', 0);
    else
        plot_data(hObject, eventdata, handles);
    end
    

% --- Executes during object creation, after setting all properties.
function edit_arb_origin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_arb_origin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function radio_AUXoff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radio_AUXoff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popup_AUXplot.
function popup_AUXplot_Callback(hObject, eventdata, handles)
% hObject    handle to popup_AUXplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_AUXplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_AUXplot
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
    end
    
    plot_data(hObject, eventdata, handles);
    

% --- Executes during object creation, after setting all properties.
function popup_AUXplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_AUXplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_msdmean.
function checkbox_msdmean_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in checkbox_msdall.
function checkbox_msdall_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

    
% --- Executes on button press in checkbox_G.
function checkbox_G_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

% --- Executes on button press in checkbox_Gstar.
function checkbox_Gstar_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

% --- Executes on button press in checkbox_eta.
function checkbox_eta_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

% --- Executes on button press in checkbox_etastar.
function checkbox_etastar_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);
    
    
function edit_bead_diameter_um_Callback(hObject, eventdata, handles)
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




% =========================================================================
% Everything below this point are functions related to computation and data
% handling/display, and not the gui (though the handles structure is used).
% =========================================================================

function plot_data(hObject, eventdata, handles)
    video_tracking_constants;
    COMPUTED = 0;

    if get(handles.radio_pixels, 'Value');
        calib_um = 1;
        ylabel_string = 'displacement [pixels]';
    elseif get(handles.radio_microns, 'Value');
        calib_um = str2double(get(handles.edit_calib_um, 'String')); 
        ylabel_string = 'displacement [\mum]';
    end
    
    im     = handles.im;
    beadID = handles.table(:,ID);
    frame  = handles.table(:,FRAME);
    x      = handles.table(:,X) * calib_um;
    y      = handles.table(:,Y) * calib_um;
    t      = handles.table(:,TIME);
    
    if size(im,1) > 1
        [imy imx imc] = size(im);
    else
        imy = max(y) * 1.1;
        imx = max(x) * 1.1;
    end;
    
    currentBead = round(get(handles.slider_BeadID, 'Value'));
    
    mintime = handles.mintime;
    
	k  = find(beadID == (currentBead));
	nk = find(beadID ~= (currentBead));

    figure(handles.XYfig);   
        imagesc(0:imx * calib_um, 0:imy * calib_um, im);
    colormap(gray);
    
    
    if get(handles.checkbox_overlayxy, 'Value')
        hold on;
            plot(x(nk), y(nk), '.', x(k), y(k), 'r.'); 
        hold off;
    end
    
    if isfield(handles, 'poleloc')
        polex = handles.poleloc(1);
        poley = handles.poleloc(2);
        circradius = 50;
        
        if get(handles.radio_microns, 'Value');
            polex = polex * calib_um;
            poley = poley * calib_um;
            circradius = circradius * calib_um;
        end
        
        hold on;
            plot(polex, poley, 'r+', 'MarkerSize', 36);
            circle(polex, poley, circradius, 'r');
        hold off;
    end
    
    xlabel(ylabel_string);
    ylabel(ylabel_string);    
    axis([0 imx 0 imy] .* calib_um);
    set(handles.XYfig, 'Units', 'Normalized');
    set(handles.XYfig, 'Position', [0.1 0.05 0.4 0.4]);
    set(handles.XYfig, 'DoubleBuffer', 'on');
    set(handles.XYfig, 'BackingStore', 'off');
    drawnow;
    
    figure(handles.XTfig);
    if get(handles.checkbox_neutoffsets, 'Value')
        plot(t(k) - mintime, [x(k)-x(k(1)) y(k)-y(k(1))], '.-');        
    else
        plot(t(k) - mintime, [x(k) y(k)], '.');
    end
    xlabel('time [s]');
    ylabel(ylabel_string);
    legend('x', 'y');    
    set(handles.XTfig, 'Units', 'Normalized');
    set(handles.XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    set(handles.XTfig, 'DoubleBuffer', 'on');
    set(handles.XTfig, 'BackingStore', 'off');    
    drawnow;
    
    arb_origin = str2num(get(handles.edit_arb_origin, 'String'));
    calib_um = str2double(get(handles.edit_calib_um, 'String'));     
    
    AUXfig = handles.AUXfig;         
    AUXtype = handles.AUXtype;
    
    data = handles.table;
    frame_rate = str2num(get(handles.edit_frame_rate, 'String'));
    calib_um   = str2num(get(handles.edit_calib_um, 'String'));
    bead_diameter_um = str2num(get(handles.edit_bead_diameter_um, 'String'));
    numtaus = round(str2num(get(handles.edit_numtaus, 'String')));
    dt = 1 ./ frame_rate;
    
%     win = unique(floor(logspace(0,log10(max(frame)),numtaus)));
    win = numtaus;

    if strcmp(AUXtype, 'MSD')  || ...
       strcmp(AUXtype, 'GSER') || ...
       strcmp(AUXtype, 'alpha vs tau') || ...
       strcmp(AUXtype, 'alpha histogram') || ...
       strcmp(AUXtype, 'Diffusivity vs. tau') || ...
       strcmp(AUXtype, 'MSD histogram') || ...
       strcmp(AUXtype, 'RMS displacement')
        if handles.recomputeMSD % && get(handles.checkbox_msdmean, 'Value')
            data_in_correct_units = data;
            data_in_correct_units(:,X:Z) = data(:,X:Z) * calib_um * 1e-6;
            mymsd = video_msd(data_in_correct_units, win, frame_rate, calib_um, 'no');            
            myve = ve(mymsd, bead_diameter_um*1e-6/2, 'f', 'n');
            myD = mymsd.msd ./ (4 .* mymsd.tau);
            handles.mymsd = mymsd;
            handles.myve  = myve;
            handles.myD   = myD;
            handles.recomputeMSD = 0;
            guidata(hObject, handles);
        end

        msdID   = unique(handles.table(:,ID))';    
        mymsd   = handles.mymsd;
        myve    = handles.myve;
        myD     = handles.myD;
        tau = mymsd.tau;
        msd = mymsd.msd;
        
        q  = find(msdID  == currentBead);
    end
    
    switch AUXtype
        case 'OFF'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'off');
            
        case 'radial vector'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            if get(handles.radio_relative, 'Value')
                xinit = x(k); xinit = xinit(1);
                yinit = y(k); yinit = yinit(1);        
            elseif get(handles.radio_arb_origin, 'Value')            
                xinit = arb_origin(1);
                yinit = arb_origin(2);

                % handle the case where 'microns' are selected
                if get(handles.radio_microns, 'Value');
                    xinit = xinit * calib_um;
                    yinit = yinit * calib_um;                
                end                        
            end

            r = magnitude(x(k) - xinit, y(k) - yinit);

            plot(t(k) - mintime, r, '.-');
            xlabel('time (s)');
            ylabel(['radial ' ylabel_string]);
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
            
        case 'velocity'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
            if get(handles.radio_relative, 'Value')
                xinit = x(k); xinit = xinit(1);
                yinit = y(k); yinit = yinit(1);        
            elseif get(handles.radio_arb_origin, 'Value')            
                xinit = arb_origin(1);
                yinit = arb_origin(2);

                % handle the case where 'microns' are selected
                if get(handles.radio_microns, 'Value');
                    xinit = xinit * calib_um;
                    yinit = yinit * calib_um;                
                end                        
            end

            velx = CreateGaussScaleSpace(x(k), 1, 0.5)/dt;
            vely = CreateGaussScaleSpace(y(k), 1, 0.5)/dt;
            
            vr = magnitude(velx, vely);            
            
            plot(t(k) - mintime, vr(:), '.-');
            xlabel('time (s)');
            ylabel(['velocity ']);
            legend('x', 'y');    
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
            
        case 'velocity magnitude'
                        figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
            velx = CreateGaussScaleSpace(x(k), 1, 0.5)/dt;
            vely = CreateGaussScaleSpace(y(k), 1, 0.5)/dt;
            
            velr = magnitude
            plot(t(k) - mintime, [velx(:) vely(:)], '.-');
            xlabel('time (s)');
            ylabel(['velocity ']);
            legend('x', 'y');    
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
            
        case 'PSD'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            clf(AUXfig);
            
            [p, f, id] = mypsd([x(k) y(k)]*1e-6, frame_rate, frame_rate/100, 'rectangle');

            loglog(f, p);
            xlabel('frequency [Hz]');
			ylabel('power [m^2/Hz]');

            
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
        case 'Integrated Disp'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            clf(AUXfig);
            
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
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

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
                
                figure(AUXfig);
                hold on;
                    plot(log10(tau(:,q)), log10(msd(:,q)), 'r.-');
                    [rows,cols] = size(tau);
                    legend({num2str([0:cols-1]')});
                    legend off
                hold off;
            elseif plot_mean
                plot_msd(mymsd, AUXfig, 'me');                
            end
            
            grid on;
            
        case 'RMS displacement'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            plot_rmsdisp(mymsd, AUXfig, 'm');
            
        case 'alpha vs tau'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            plot_alphavstau(myve, AUXfig);
            
        case 'alpha histogram'
            mytauidx = str2num(get(handles.edit_chosentau, 'String'));
            
            A = mymsd.tau(1:end-1,:);
            B = mymsd.tau(2:end,:);
            C = mymsd.msd(1:end-1,:);
            D = mymsd.msd(2:end,:);

            alpha = log10(D./C)./log10(B./A);
            
            myalpha = alpha(mytauidx, :);
            set(handles.text_chosentau_value, 'String', num2str(mean(mymsd.tau(mytauidx,:))));
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            plot_alphadist(myalpha, AUXfig);
            
        case 'MSD histogram'
            mytauidx = str2num(get(handles.edit_chosentau, 'String'));
            numbins = 51;
            
            mymsd_at_mytau = mymsd.msd(mytauidx, :);
            
            set(handles.text_chosentau_value, 'String', num2str(mean(mymsd.tau(mytauidx,:))));
            
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');


            
            
% This is for plotting the surface or colormap of all r^2 for all taus, 
% allowing for a 'mean' or 'most probable' MSD to show up as a max or peak
% value. These functions should be rebased accordingly.
%             v = msdhist(mymsd, numbins);
%             plot_msdhist(v, AUXfig, 's');
                       
        case 'temporal MSD'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
            [tau, m, time] = msdt(t(k), [x(k) y(k)], [], []);
            
            surf(m);
            
        case 'Diffusivity vs. tau'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
            plot(     log10(mymsd.tau),       log10(myD) , 'b', ...
                 mean(log10(mymsd.tau),2), mean(log10(myD),2), 'k');
            xlabel('\tau [s]');
            ylabel('Diffusivity [m^2/s]');
            grid on;
            pretty_plot;
            
        case 'Diffusivity @ a tau'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
            
        case 'GSER'

            plotG       = get(handles.checkbox_G, 'Value');
            ploteta     = get(handles.checkbox_eta, 'Value');
            plotGstar   = get(handles.checkbox_Gstar, 'Value');
            plotetastar = get(handles.checkbox_etastar, 'Value');
            
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            clf;
            
            hold on;
            
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
            
            hold off;

            plot_ve(myve, 'f', AUXfig, plotstring);                
            
%             if (plotG && ploteta)
%                 plot_ve(myve, 'f', AUXfig, 'GgNn');
%             elseif plotG
%                 plot_ve(myve, 'f', AUXfig, 'Gg');
%             elseif ploteta
%                 plot_ve(myve, 'f', AUXfig, 'Nn');
%             elseif (plotGstar && plotetastar)
%                 plot_ve(myve, 'f', AUXfig, 'Ss');
%             elseif plotGstar
%                 plot_ve(myve, 'f', AUXfig, 'S');
%             elseif plotetastar
%                 plot_ve(myve, 'f', AUXfig, 's');
%             end
            
        case 'pole locator'
            set(AUXfig, 'Visible', 'on');

            handles.poleloc = pole_locator(handles.table, handles.im, 'y', AUXfig);
            guidata(hObject, handles);

            poleloctxt = [num2str(handles.poleloc(1)) ', ' num2str(handles.poleloc(2))]
            set(handles.edit_arb_origin, 'String', poleloctxt);
            
        case 'tracker avail'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            plot_tracker_avail(frame, beadID, handles.AUXfig);
            
        case '2pt MSD'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
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
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
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
                beaddiam = get(handles.edit_bead_diameter_um, 'String');
                beaddiam = str2double(beaddiam);
                beadradius = beaddiam/2;
                imagediag = 90;
                temp = get(handles.edit_temp, 'String');
                temp = str2double(temp);
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
            
%             plotG   = get(handles.checkbox_G, 'Value');
%             ploteta = get(handles.checkbox_eta, 'Value');
            plotG = 1;
            ploteta = 1;
            if (plotG && ploteta)
                plot_ve_2pt(myve, 'f', AUXfig, 'GgNn');
            elseif plotG
                plot_ve_2pt(myve, 'f', AUXfig, 'Gg');
            elseif ploteta
                plot_ve_2pt(myve, 'f', AUXfig, 'Nn');
            end
    end
 %      hihi;
 if COMPUTED ~= 1
    refresh(handles.XYfig);
    refresh(handles.XTfig);
    refresh(handles.AUXfig);
 end
    

    
function delete_selected_dataset(hObject, eventdata, handles)

global hand
    video_tracking_constants;
    
    table = handles.table;

    bead_to_remove = round(get(handles.slider_BeadID, 'Value'));
    
    bead_max = max(table(:,ID));

	k = find(table(:,ID) ~= bead_to_remove);
    
    table = table(k,:);
    
    if (bead_max ~= bead_to_remove) % otherwise I don't have to rearrange beadIDs
        for m = (bead_to_remove + 1) : bead_max
            k = find(table(:,ID) == m);
            table(k,ID) = m-1;
        end
    end
    
    if (bead_to_remove == 0)
        set(handles.slider_BeadID, 'Value', bead_to_remove+1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove+1));
    else
    	set(handles.slider_BeadID, 'Value', bead_to_remove-1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove-1));        
    end
    
    if bead_max ~= 1
        set(handles.slider_BeadID, 'Max', bead_max-1);
        set(handles.slider_BeadID, 'SliderStep', [1/(bead_max-1) 1/(bead_max-1)]);
    else
        set(handles.slider_BeadID, 'Max', bead_max);
        set(handles.slider_BeadID, 'SliderStep', [1/(bead_max) 1/(bead_max)]);
    end
    
    handles.table = table;
	guidata(hObject, handles);

    hand = handles;
    
function delete_inside_boundingbox(hObject, eventdata, handles)
    global hand;
    
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
    
    table = handles.table;
    
    beadID = table(:,ID);
    t = table(:,TIME) - handles.mintime;
    x = table(:,X);
    y = table(:,Y);
    currentbead = round(get(handles.slider_BeadID, 'Value'));
    
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
    handles.table = table(k,:);
    handles.tstamp_times = handles.tstamp_times(k);
    guidata(hObject, handles);

    hand = handles;

function delete_outside_boundingbox(hObject, eventdata, handles)
    global hand;
    
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
    
    table = handles.table;
    
    beadID = table(:,ID);
    t = table(:,TIME) - handles.mintime;
    x = table(:,X);
    y = table(:,Y);
    currentbead = get(handles.slider_BeadID, 'Value');
    
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
        k = find( (x > xlo & x < xhi & y > ylo & y < yhi ));

        handles.table = table(k,:);
        handles.tstamp_times = handles.tstamp_times(k);

    elseif get(handles.radio_XTfig, 'Value')
        k = find( ~( ( (x > ylo & x < yhi) | (y > ylo & y < yhi) ) & ...
                       (t > xlo & t < xhi) ) & beadID == currentbead );

        table(k,:) = [];
        handles.tstamp_times(k) = [];
        handles.table = table;

    elseif get(handles.radio_AUXfig, 'Value')
        logentry('Deleting data from AUX plot is not allowed.');
    end
%     handles.table = table(k,:);
%     handles.tstamp_times = handles.tstamp_times(k);
    guidata(hObject, handles);

    hand = handles;

    
function delete_data_before_time(hObject, eventdata, handles) 

    global hand;
    
    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    table = handles.table;
    % beadID = table(:,ID);

    t = table(:,TIME) - handles.mintime;
    x = table(:,X);
    y = table(:,Y);
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify time
    idx = find(dists == min(dists));
    closest_time = mean(t(idx));
    
    % remove any points in the table that have times eariler than our
    % prescribed beginning time point
    idx = find(table(:,TIME) > (closest_time + handles.mintime));
    table = table(idx,:);
    
    handles.table = table;
    handles.mintime = min(table(:,TIME));
    guidata(hObject, handles);

    hand = handles;
   
    
function delete_data_after_time(hObject, eventdata, handles)
    global hand;

    video_tracking_constants;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    elseif(get(handles.radio_AUXfig, 'Value'))
        active_fig = handles.XTfig;
    end

    figure(active_fig);

    table = handles.table;

    t = table(:,TIME) - handles.mintime;
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify index value that corresponds to this time
    idx = find(dists == min(dists));
    closest_time = t(idx);

    % remove any points in the table that are greater than the time value
    % selected by the mouse-click.
    idx = find(t <= closest_time(1));
    table = table(idx,:);
    
    handles.table = table;
    guidata(hObject, handles);

    hand = handles;

% function set_active_figure(hObject, eventdata, handles);

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
   

% --- Executes on button press in checkbox_minFrames.
function checkbox_minFrames_Callback(hObject, eventdata, handles)


function edit_minFrames_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_minFrames_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_minPixelRange.
function checkbox_minPixelRange_Callback(hObject, eventdata, handles)


function edit_minPixelRange_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_minPixelRange_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_tCrop.
function checkbox_tCrop_Callback(hObject, eventdata, handles)


function edit_tCrop_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_tCrop_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_xyCrop.
function checkbox_xyCrop_Callback(hObject, eventdata, handles)


function edit_xyCrop_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_xyCrop_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


% --- Executes on button press in checkbox_neutoffsets.
function checkbox_neutoffsets_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in checkbox_overlayxy.
function checkbox_overlayxy_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);


% --- Executes on button press in checkbox_maxpixels.
function checkbox_maxpixels_Callback(hObject, eventdata, handles)


function edit_maxpixels_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function edit_maxpixels_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function edit_numtaus_Callback(hObject, eventdata, handles)
    handles.recomputeMSD = 1;    
    plot_data(hObject, eventdata, handles);    
    guidata(hObject, handles);
    
    
% --- Executes during object creation, after setting all properties.
function edit_numtaus_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



function edit_temp_Callback(hObject, eventdata, handles)
% hObject    handle to edit_temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_temp as text
%        str2double(get(hObject,'String')) returns contents of edit_temp as a double


% --- Executes during object creation, after setting all properties.
function edit_temp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_temp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_filename as text
%        str2double(get(hObject,'String')) returns contents of edit_filename as a double


% --- Executes during object creation, after setting all properties.
function edit_filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_chosentau_Callback(hObject, eventdata, handles)
    plot_data(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function edit_chosentau_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_chosentau (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
