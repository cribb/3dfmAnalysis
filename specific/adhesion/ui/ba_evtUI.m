function varargout = ba_evtUI(varargin)
% ba_evtUI creates a new ba_evtUI or raises the existing singleton
%
% 3DFM function
% GUIs/ba_evtUI
% last modified 08/26/10
%
% ba_evtUI M-filemenu for ba_evtUI.fig
%      ba_evtUI, by itself, creates a new ba_evtUI or raises the existing
%      singleton*.
%
%      H = ba_evtUI returns the handle to a new ba_evtUI or the handle to
%      the existing singleton*.
%
%      ba_evtUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ba_evtUI.M with the given input arguments.
%
%      ba_evtUI('Property','Value',...) creates a new ba_evtUI or raises the
%      existing singleton*.  Starting from the left, property value pairs
%      are
%      applied to the GUI before ba_evtUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ba_evtUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ba_evtUI

% Last Modified by GUIDE v2.5 26-Aug-2019 15:27:38

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @ba_evtUI_OpeningFcn, ...
                       'gui_OutputFcn',  @ba_evtUI_OutputFcn, ...
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

function ba_evtUI_OpeningFcn(hObject, eventdata, handles, varargin)
	% Choose default command line output for ba_evtUI
	handles.output = hObject;
	
	% Update handles structure
	guidata(hObject, handles);
	
	% UIWAIT makes ba_evtUI wait for user response (see UIRESUME)
	% uiwait(handles.ba_evtUI);


% --- Outputs from this function are returned to the command line.
function varargout = ba_evtUI_OutputFcn(hObject, eventdata, handles)
	% Get default command line output from handles structure
	varargout{1} = handles.output;

    
% --- Executes on button press in pushbutton_close.
function pushbutton_close_Callback(hObject, eventdata, handles) 
    if isfield(handles, 'XYfig')
        try
            close(handles.XYfig);
        catch
        end
    end

    if isfield(handles, 'XTfig')
        try
            close(handles.XTfig);
        catch
        end
    end

    if isfield(handles, 'AUXfig')
        try
            close(handles.AUXfig);
        catch
        end
    end

	close(ba_evtUI);

    
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
		[fname, pname, fidx] = uigetfile({'*_uint16.csv;*.evt.mat';'*.mat;*.csv';'*.mat';'*.csv';'*.*'}, ...
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
    filenameroot = strrep(filenameroot, '.csv', '');
    filenameroot = strrep(filenameroot, '.vrpn', '');
    filenameroot = strrep(filenameroot, '.mat', '');
    filenameroot = strrep(filenameroot, '.evt', '');

    % load the datafile
    logentry('Loading dataset... ');
    
    % assign "filter by" values if they're selected
    if get(handles.checkbox_minFrames, 'Value')
        handles.filt.min_frames = str2double(get(handles.edit_minFrames, 'String'));
    else
        handles.filt.min_frames = 0;
    end
        
    if get(handles.checkbox_minPixelRange, 'Value')
        handles.filt.min_pixels = str2double(get(handles.edit_minPixelRange, 'String'));
    else
        handles.filt.min_pixels = 0;
    end

    if get(handles.checkbox_maxpixels, 'Value')
        handles.filt.max_pixels = str2double(get(handles.edit_maxpixels, 'String'));
    else
        handles.filt.max_pixels = Inf;
    end
    
    if get(handles.checkbox_tCrop, 'Value')
        handles.filt.tcrop = str2double(get(handles.edit_tCrop, 'String'));
    else
        handles.filt.tcrop = 0;
    end
    
    if get(handles.checkbox_xyCrop, 'Value')
        handles.filt.xycrop = str2double(get(handles.edit_xyCrop, 'String'));
    else
        handles.filt.xycrop = 0;
    end
            
    if get(handles.checkbox_min_sens, 'Value')
        handles.filt.min_sens = str2double(get(handles.edit_min_sens, 'String'));
    else
        handles.filt.min_sens = 0;
    end
    
    handles.filt.xyzunits = 'pixels';
    handles.filt.calib_um = 1;
    
    
    [d, calout] = load_video_tracking(filename, [], [], [], 'absolute', 'yes', 'table');
     d = filter_video_tracking(d, handles.filt);

    
    if ~isempty(calout)
        if ~get(handles.checkbox_lockum, 'Value') && length(unique(calout)) == 1
            set(handles.edit_calib_um, 'String', num2str(calout(1)));
        elseif get(handles.checkbox_lockum, 'Value')
            logentry('Calib Lock set when loading new files. Overriding calibum set in file.');            
        else
            msgbox('ba_evtUI cannot load multiple files with multiple calibration factors at this time.', 'Error.', 'error');
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
    
    % try loading the MIP filemenu
try
    if ~contains(filenameroot, '.png', 'IgnoreCase', true)
        MIPfile = [filenameroot, '.png'];
    else
        MIPfile = filenameroot;
    end
    
        MIPfile = strrep(MIPfile, '_TRACKED', '');
        MIPfile = strrep(MIPfile, 'video', 'FLburst');
        im = imread(MIPfile, 'PNG');
        logentry('Successfully loaded FLburst image from a Panoptes run...');
%         MIPexists = 1;
catch
    try 
        MIPfile = [filenameroot, '.MIP.bmp'];
        im = imread(MIPfile, 'BMP');
        logentry('Successfully loaded MIP image...');
%         MIPexists = 1;
    catch
        try 
            MIPfile = [filenameroot, '.vrpn.composite.tif'];
            im = imread(MIPfile, 'tif');
            logentry('Successfully loaded MIP image...');
%             MIPexists = 1;
        catch        
            logentry('MIP file was not found.  Trying to load first frame...');

            % or, try loading the first frame        
            try
                fimfile = [filenameroot, '.00001.pgm'];
                imf = imread(fimfile, 'PGM');
                
                flmfile = [filenameroot, '.07625.pgm'];
                iml = imread(flmfile, 'PGM');
                
                im = zeros([size(imf),3]);
                im(:,:,1) = imf;
                im(:,:,2) = iml;
                im(:,:,3) = 0;
                im = uint16(im);
                
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
                end
            end        
        end
    end
end
    % if the background MIP image exists, attach it to handles structure
    if exist('im', 'var')
        handles.im = im;
    else
        handles.im = 0.5 * ones(ceil(max(d(:,Y))),ceil(max(d(:,X))));
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
    if get(handles.checkbox_lockfps, 'Value')
        logentry('FPS Lock set when loading new files. Overriding FPS set in file.');
        tsfps = str2double(get(handles.edit_frame_rate, 'String'));
    else
        idx = (beadID == 0);
        tsfps = round(1/mean(diff(table(idx,TIME))));
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
    handles.table = table;
    handles.mintime = mintime;
    handles.maxtime = maxtime;
    handles.tstamp_times = table(:,TIME);
    
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
    set(handles.radio_pixels                        , 'Enable', 'on');
    set(handles.radio_microns                       , 'Enable', 'on');
    set(handles.edit_calib_um                       , 'Enable', 'on');
    set(handles.text_calib_um                       , 'Enable', 'on');
    set(handles.checkbox_lockum                     , 'Enable', 'on');
    set(handles.pushbutton_export_all_beads         , 'Enable', 'on');
    set(handles.pushbutton_export_bead              , 'Enable', 'on');
    set(handles.pushbutton_measure_distance         , 'Enable', 'on');
    
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
    
%     tracking.spot3DSecUsecIndexFramenumXYZRPY = handles.table;
    calib_um = str2double(get(handles.edit_calib_um, 'String'));
    fps = str2double(get(handles.edit_frame_rate, 'String'));
    save_evtfile(outfile, handles.table, 'pixels', calib_um, fps, 'mat');
%     save(outfile, 'tracking');
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
        set(handles.edit_BeadID, 'String', num2str(round(bead_to_select)));
    end
    
    if get(handles.radio_AUXfig, 'Value')
        
        AUXplottypes = get(handles.popup_AUXplot, 'String');
        AUXplotvalue = get(handles.popup_AUXplot, 'Value');
        
        myAUXplottype = AUXplottypes{AUXplotvalue};
        
        logentry('Select closest dataset not yet written for AUXplot type you chose');                
        return;
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
    if isfield(bead, 'yaw')
        bead.yaw    = handles.table(idx,YAW);
    end
    
    assignin('base', ['bead' num2str(currentBead)], bead);
    
    
% --- Executes on button press in pushbutton_export_all_beads.
function pushbutton_export_all_beads_Callback(hObject, eventdata, handles)
    video_tracking_constants;
    
    bead = convert_vidtable_to_beadstruct(handles.table);
    
    assignin('base', 'beads', bead);
    
    
% --- Executes on button press in radio_pixels.
function radio_pixels_Callback(hObject, eventdata, handles)
    set(handles.radio_pixels, 'Value', 1);
    set(handles.radio_microns, 'Value', 0);

    diststr = get(handles.text_distance, 'String');
    
    if contains(diststr, 'um')
    elseif contains(diststr, 'pixels')
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

    if get(handles.checkbox_frame_rate, 'Value')
        table(:,TIME) = table(:,FRAME) / str2double(get(hObject, 'String'));
        mintime = min(table(:,TIME));
        maxtime = max(table(:,TIME));
	
        handles.table = table;
        handles.maxtime = maxtime;
        handles.mintime = mintime;
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
    arb_origin = str2double(get(hObject, 'String'));

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
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
        case 'radial vector'
            set(handles.radio_relative    ,  'Visible', 'on', 'Enable', 'on');
            set(handles.radio_arb_origin  ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_arb_origin   ,  'Visible', 'on', 'Enable', 'on');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
        case 'tracker avail'
            set(handles.radio_relative    ,  'Visible', 'off', 'Enable', 'off');
            set(handles.radio_arb_origin  ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_arb_origin   ,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_bead_diameter_um,  'Visible', 'off', 'Enable', 'off');
            set(handles.text_bead_diameter,  'Visible', 'off', 'Enable', 'off');
            set(handles.edit_temp           , 'Visible', 'off', 'Enable', 'off');
            set(handles.text_temp           , 'Visible', 'off', 'Enable', 'off');
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

    
% =========================================================================
% Everything below this point are functions related to computation and data
% handling/display, and not the gui (though the handles structure is used).
% =========================================================================

function plot_data(hObject, eventdata, handles)
    video_tracking_constants;
    COMPUTED = 0;

    if get(handles.radio_pixels, 'Value')
        calib_um = 1;
        ylabel_unit = 'pixels';
    elseif get(handles.radio_microns, 'Value')
        calib_um = str2double(get(handles.edit_calib_um, 'String')); 
        ylabel_unit = '\mum';
    end
    
    im     = handles.im;
    beadID = handles.table(:,ID);
    frame  = handles.table(:,FRAME);
    x      = handles.table(:,X) * calib_um;
    y      = handles.table(:,Y) * calib_um;
    z      = handles.table(:,Z);
    t      = handles.table(:,TIME);
    sens   = handles.table(:,SENS);
    cent   = handles.table(:,CENTINTS);
    if size(im,1) > 1
        [imy, imx, imc] = size(im);
    else
        imy = ceil(max(y));% * 1.1;
        imx = ceil(max(x));% * 1.1;
    end
    
    currentBead = round(get(handles.slider_BeadID, 'Value'));
    
    mintime = handles.mintime;
    
	k  = find(beadID == (currentBead));
	nk = find(beadID ~= (currentBead));

    figure(handles.XYfig);   
    imagesc([0 imx] * calib_um, [0 imy] * calib_um, im);
    colormap(gray);
    
    if get(handles.checkbox_overlayxy, 'Value')
        hold on;
            plot(x(nk), y(nk), '.', x(k), y(k), 'w.');  % , 'r.');   , 'c.');
        hold off;
    end
    
    xlabel(['displacement [' ylabel_unit ']']);
    ylabel(['displacement [' ylabel_unit ']']);    
    xlim([0 imx] .* calib_um);
    ylim([0 imy] .* calib_um);
    set(handles.XYfig, 'Units', 'Normalized');
%     set(handles.XYfig, 'Position', [0.1 0.05 0.4 0.4]);
    set(handles.XYfig, 'DoubleBuffer', 'on');
    set(handles.XYfig, 'BackingStore', 'off');
    drawnow;
    
    figure(handles.XTfig);
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
    
    plot(t(k) - mintime, [x(k)-xk1 y(k)-yk1 z(k)-zk1], '.-');
    xlabel('time [s]');
    ylabel(['displacement [' ylabel_unit ']']);
    legend('x', 'y', 'z', 'Location', 'northwest');    
    set(handles.XTfig, 'Units', 'Normalized');
%     set(handles.XTfig, 'Position', [0.51 0.05 0.4 0.4]);
    set(handles.XTfig, 'DoubleBuffer', 'on');
    set(handles.XTfig, 'BackingStore', 'off');    
    drawnow;
    
    arb_origin = str2double(get(handles.edit_arb_origin, 'String'));
%     calib_um = str2double(get(handles.edit_calib_um, 'String'));     
    
    AUXfig = handles.AUXfig;         
    AUXtype = handles.AUXtype;
    
    data = handles.table;
    frame_rate = str2double(get(handles.edit_frame_rate, 'String'));
    calib_um   = str2double(get(handles.edit_calib_um, 'String'));
    bead_diameter_um = str2double(get(handles.edit_bead_diameter_um, 'String'));
    numtaus = round(str2double(get(handles.edit_numtaus, 'String')));
    dt = 1 ./ frame_rate;
    

    win = numtaus;

    velx = zeros(size(beadID));
    vely = zeros(size(beadID));
    
    beadlist = unique(beadID);
    for b = 1:length(beadlist)        
        foo = find(beadID == beadlist(b));
        velx(foo,1) = CreateGaussScaleSpace(x(foo), 1, 1)/dt;
        vely(foo,1) = CreateGaussScaleSpace(y(foo), 1, 1)/dt;
    end
    
    vr = magnitude(velx, vely);
    normvr = vr ./ max(vr);
    vals = floor(normvr * 255);
    heatmap = colormap(hot(256));
    velclr = heatmap(vals+1,:);
    
    
    switch AUXtype
        case 'OFF'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'off');
            
        case 'radial vector'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            if get(handles.radio_relative, 'Value')
                xinit = x(k); if ~isempty(xinit); xinit = xinit(1); end
                yinit = y(k); if ~isempty(yinit); yinit = yinit(1); end
                zinit = z(k); if ~isempty(zinit); zinit = zinit(1); end
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

            r = magnitude(x(k) - xinit, y(k) - yinit, z(k) - zinit);

            plot(t(k) - mintime, r, '.-');
            xlabel('time (s)');
            ylabel(['radial dispacement [' ylabel_unit ']']);
            set(handles.AUXfig, 'Units', 'Normalized');
%             set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
                        
        case 'sensitivity (SNR)'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            plot(t(k) - mintime, sens(k), '.-');
            xlabel('time (s)');
            ylabel('Tracking Sensitivity');
            
        case 'center intensity'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            plot(t(k) - mintime, cent(k)./max(cent(k)), '.-');
            xlabel('time (s)');
            ylabel('Center Intensity (frac of max)');
            
            
        case 'velocity'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
            if get(handles.radio_relative, 'Value')
                xinit = x(k); 
                xinit = xinit(1);
                
                yinit = y(k); 
                yinit = yinit(1);        
            elseif get(handles.radio_arb_origin, 'Value')            
                xinit = arb_origin(1);
                yinit = arb_origin(2);
            end
            
            % handle the case where 'microns' are selected
            if get(handles.radio_microns, 'Value')
                xinit = xinit * calib_um;
                yinit = yinit * calib_um;                
            end                        

            plot(t(k) - mintime, [velx(k,1) vely(k,1)], '.-');
            xlabel('time (s)');
            ylabel(['velocity [' ylabel_unit '/s]']);
            legend('x', 'y');    
            set(handles.AUXfig, 'Units', 'Normalized');
            set(handles.AUXfig, 'Position', [0.51 0.525 0.4 0.4]);
            set(handles.AUXfig, 'DoubleBuffer', 'on');
            set(handles.AUXfig, 'BackingStore', 'off');    
            drawnow;
            
        case 'velocity magnitude'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            
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
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            clf(AUXfig);

            hold on;
                imagesc([0 imx], [0 imy], im);
                colormap(gray);
                scatter(x, y, [], velclr, 'filled');
            hold off;
            
            set(gca, 'YDir', 'reverse');
        
        case 'velocity scatter (active)'            
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');
            clf(AUXfig);

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
            NGridX = 45;
            NGridY = 45;
            xgrid = (1:NGridX)*(video.xDim/NGridX/video.pixelsPerMicron);
            ygrid = (1:NGridY)*(video.yDim/NGridY/video.pixelsPerMicron);
            foo = vel_field(evt_filename, NGridX, NGridY, video);
            Xvel = reshape(foo.sectorX, NGridX, NGridY);
            Yvel = reshape(foo.sectorY, NGridX, NGridY);
            Vmag = sqrt(Xvel.^2 + Yvel.^2);

            figure; 
            imagesc(xgrid, ygrid, Vmag'); 
            colormap(hot);
            xlabel('\mum')
            ylabel('\mum')
            title('Vel. [\mum/s]');
            pretty_plot;
            
        case 'tracker avail'
            figure(handles.AUXfig);
            set(AUXfig, 'Visible', 'on');

            plot_tracker_avail(frame, beadID, handles.AUXfig);            
    end
 
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

	k = (table(:,ID) ~= bead_to_remove);
    
    table = table(k,:);
    
    if (bead_max ~= bead_to_remove) % otherwise I don't have to rearrange beadIDs
        for m = (bead_to_remove + 1) : bead_max
            q = (table(:,ID) == m);
            table(q,ID) = m-1;
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
    
    table = handles.table;
    
    beadID = table(:,ID);
    t = table(:,TIME) - handles.mintime;
    x = table(:,X);
    y = table(:,Y);
    z = table(:,Z);
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

        handles.table = table(k,:);
        handles.tstamp_times = handles.tstamp_times(k);

    elseif get(handles.radio_XTfig, 'Value')
        k = find( ~(t > xlo & t < xhi ) & beadID == currentbead );

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


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'ba_evtUI: '];
     
     fprintf('%s%s\n', headertext, txt);
   

% --- Executes on button press in checkbox_lockfps.
function checkbox_lockfps_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lockfps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lockfps


% --- Executes on button press in checkbox_lockum.
function checkbox_lockum_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_lockum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_lockum


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    


% --------------------------------------------------------------------
function FileMenuOpen_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenuOpen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    pushbutton_loadfile_Callback(hObject, eventdata, handles);


% --------------------------------------------------------------------
function EditMenu_Callback(hObject, eventdata, handles)
% hObject    handle to EditMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_6_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function EditMenuFilter_Callback(hObject, eventdata, handles)
% hObject    handle to EditMenuFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FileMenuAdd_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenuAdd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FileMenuClose_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenuClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function ExportMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ExportMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FileMenuQuit_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenuQuit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if isfield(handles, 'XYfig')
        try
            close(handles.XYfig);
        catch
        end
    end

    if isfield(handles, 'XTfig')
        try
            close(handles.XTfig);
        catch
        end
    end

    if isfield(handles, 'AUXfig')
        try
            close(handles.AUXfig);
        catch
        end
    end

	close(ba_evtUI);


% --------------------------------------------------------------------
function FileMenuSaveAs_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenuSaveAs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function FileMenuSave_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in checkbox_min_sens.
function checkbox_min_sens_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_min_sens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_min_sens



function edit_min_sens_Callback(hObject, eventdata, handles)
% hObject    handle to edit_min_sens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_min_sens as text
%        str2double(get(hObject,'String')) returns contents of edit_min_sens as a double


% --- Executes during object creation, after setting all properties.
function edit_min_sens_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_min_sens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on key press with focus on ba_evtUI and none of its controls.
function ba_evtUI_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ba_evtUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    keyPressed = eventdata.Key;
    % disp(keyPressed);

    switch keyPressed 
        case 's'
            if strcmp(handles.radio_selected_dataset.Enable, 'on')
                radio_selected_dataset_Callback(hObject, eventdata, handles);
            end
        case 'i'
            if strcmp(handles.radio_insideboundingbox.Enable, 'on')
                radio_insideboundingbox_Callback(hObject, eventdata, handles);            
            end
        case 'o'
            if strcmp(handles.radio_outsideboundingbox.Enable, 'on')
                radio_outsideboundingbox_Callback(hObject, eventdata, handles);
            end
        case 'b'
            if strcmp(handles.radio_deletetimebefore.Enable, 'on')
                radio_deletetimebefore_Callback(hObject, eventdata, handles);
            end
        case 'a'
            if strcmp(handles.radio_deletetimeafter.Enable, 'on')
                radio_deletetimeafter_Callback(hObject, eventdata, handles);
            end
        case 'e'
            if strcmp(handles.pushbutton_Edit_Data.Enable, 'on')
                pushbutton_Edit_Data_Callback(hObject, eventdata, handles);
            end
    end
