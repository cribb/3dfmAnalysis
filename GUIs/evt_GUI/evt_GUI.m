function varargout = evt_GUI(varargin)
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
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before evt_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evt_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evt_GUI

% Last Modified by GUIDE v2.5 29-Jan-2005 16:37:57

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @evt_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @evt_GUI_OutputFcn, ...
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

    % set up global constants for data columns
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;
    
    TIME = 1; ID = 2; FRAME = 3; X = 4; Y = 5; Z = 6;
    ROLL = 7; PITCH = 8; YAW = 9; RADIAL = 10;
    

% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to evt_GUI (see VARARGIN)

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


% --- Executes on button press in radio_selected_dataset.
function radio_selected_dataset_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 1);
	set(handles.radio_boundingbox, 'Value', 0);
	set(handles.radio_deletetime, 'Value', 0);

    
% --- Executes on button press in radio_boundingbox.
function radio_boundingbox_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_boundingbox, 'Value', 1);
	set(handles.radio_deletetime, 'Value', 0);
    
    
% --- Executes on button press in radio_deletetime.
function radio_deletetime_Callback(hObject, eventdata, handles)
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_boundingbox, 'Value', 0);
	set(handles.radio_deletetime, 'Value', 1);

    
% --- Executes on button press in radio_XYfig.
function radio_XYfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig, 'Value', 1);
    set(handles.radio_XTfig, 'Value', 0);    

    
% --- Executes on button press in radio_XTfig.
function radio_XTfig_Callback(hObject, eventdata, handles)
    set(handles.radio_XYfig, 'Value', 0);
    set(handles.radio_XTfig, 'Value', 1);

    
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
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;

    filename = get(handles.edit_infile, 'String');
    
    if(length(filename) == 0)
		[fname, pname] = uigetfile('*.mat');
		filename = strcat(pname, fname);
		set(handles.edit_infile,'String', filename);
        set(handles.edit_outfile, 'String', '');
    end   

    % load the datafile
    logentry('Loading dataset... ');
    try
        d = load_video_tracking2(filename, [], [], [], 'absolute', 'yes');
    catch
        msgbox('File Not Found!', 'Error.');
        return;
    end
    set(handles.edit_infile, 'TooltipString', filename);
    logentry(['Dataset, ' filename ', successfully loaded...']);
    
    % try loading the MIP file
    try 
        MIPfile = [filename(1:end-12) 'MIP.bmp'];
        im = imread(MIPfile, 'BMP');
        logentry('Successfully loaded MIP image...');
    catch
        logentry('MIP file was not found.  Trying to load first frame...');

        % or, try loading the first frame        
        try
            fimfile = [filename(1:end-12) '0001.bmp'];
            im = imread(fimfile, 'BMP');
            logentry('Successfully loaded first frame image...');            
        catch
            logentry('first frame image was not found. Trying to extract first frame...');
            
            % last chance.... try extracting first frame
            try
                rawfile = [filename(1:end-3) 'RAW'];
                im = raw2img(rawfile, 'BMP', 1, 1);
                logentry('Successfully extracted first frame image...');
            catch
                logentry('Could not extract image; RAW file not found.  Giving up...');
                im = 0;
            end
        end        
    end
    
    % if the background image exists, attach it to handles structure
    if exist('im')
        handles.im = im;
    end
    
    % set the default output filename
    outfile = get(handles.edit_outfile, 'String');
    if length(outfile) == 0
        outfile = [pname fname(1:end-3) 'evt.mat'];
        set(handles.edit_outfile, 'String', outfile);
    end
    set(handles.edit_outfile, 'TooltipString', outfile);

    % assign data variables
    table = d;
    % table = attach_time(table);
    beadID = table(:,ID);
    x = table(:,X);
    y = table(:,Y);
    XYfig = figure;
    XTfig = figure;
    currentBead = 0;
    
	slider_max = max(beadID);
	slider_min = 0;
    if slider_min == slider_max
        slider_max = slider_min + 1;
    end
	slider_step = 1/(slider_max - slider_min);
    	
	set(handles.slider_BeadID, 'Min', slider_min);
	set(handles.slider_BeadID, 'Max', slider_max);
	set(handles.slider_BeadID, 'SliderStep', [slider_step slider_step]);

    handles.XYfig = XYfig;
    handles.XTfig = XTfig;
    handles.table = table;
    guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
    drawnow;
    
    
% --- Executes on button press in pushbutton_savefile.
function pushbutton_savefile_Callback(hObject, eventdata, handles)
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;

	outfile = get(handles.edit_outfile, 'String');
    
    if (length(outfile) == 0)
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

	set(handles.radio_selected_dataset, 'Enable', 'Off');
	set(handles.radio_boundingbox, 'Enable', 'Off');
    set(handles.radio_deletetime, 'Enable', 'Off');
	
	if (get(handles.radio_selected_dataset, 'Value'))
        delete_selected_dataset(hObject, eventdata, handles);
	elseif (get(handles.radio_boundingbox, 'Value'))
        delete_inside_boundingbox(hObject, eventdata, handles);
    elseif (get(handles.radio_deletetime, 'Value'))
        set(handles.radio_XTfig, 'Value', 1, 'Enable', 'off');
        set(handles.radio_XYfig, 'Value', 0, 'Enable', 'off');

        delete_data_before_time(hObject, eventdata, handles);
        
        set(handles.radio_XTfig, 'Enable', 'on');
        set(handles.radio_XYfig, 'Enable', 'on');

	else
        msgbox('One of the data handling methods must be selected.', ...
               'Error.');
	end
	
	set(handles.radio_selected_dataset, 'Enable', 'On');
	set(handles.radio_boundingbox, 'Enable', 'On');
    set(handles.radio_deletetime, 'Enable', 'On');
    
    plot_data(hObject, eventdata, handles);
    drawnow;
    
    
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
	currentBead = get(handles.slider_BeadID, 'Value');
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
	set(handles.slider_BeadID, 'Value', str2num(get(handles.edit_BeadID, 'String')));

    
% --- Executes on button press in pushbutton_Select_Closest_dataset.
function pushbutton_Select_Closest_dataset_Callback(hObject, eventdata, handles)
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;

    figure(handles.XYfig);
	[xm, ym] = ginput(1);
    
    beadID = handles.table(:,ID);    
    x = handles.table(:,X);
    y = handles.table(:,Y);
    
    xval = repmat(xm, length(x), 1);
    yval = repmat(ym, length(y), 1);

    dist = sqrt((x - xval).^2 + (y - yval).^2);

    bead_to_select = beadID(find(dist == min(dist)));
    
    set(handles.slider_BeadID, 'Value', bead_to_select);
    set(handles.edit_BeadID, 'String', num2str(bead_to_select));
    
    plot_data(hObject, eventdata, handles);
    drawnow;
    

function plot_data(hObject, eventdata, handles)
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;

    beadID = handles.table(:,ID);
    x      = handles.table(:,X);
    y      = handles.table(:,Y);
    t      = handles.table(:,TIME);
    
    currentBead = get(handles.slider_BeadID, 'Value');
    
	k = find(beadID == currentBead);
	nk = find(beadID ~= currentBead);
    
    im = handles.im;
    
    figure(handles.XYfig);   
    imagesc(handles.im);
    colormap(gray);
    hold on;
    plot(x(nk), y(nk), '.', x(k), y(k), 'r.'); 
    hold off;
    axis([0 648 0 484]);
    set(handles.XYfig, 'Units', 'Normalized');
    set(handles.XYfig, 'Position', [0.1 0.075 0.4 0.4]);
    set(handles.XYfig, 'DoubleBuffer', 'on');
    set(handles.XYfig, 'BackingStore', 'off');
    drawnow;
    
    figure(handles.XTfig);
    plot(t(k), [x(k) y(k)], '.');
    xlabel('time (s)');
    ylabel('displacement (pixels)');
    legend('x', 'y');    
    set(handles.XTfig, 'Units', 'Normalized');
    set(handles.XTfig, 'Position', [0.51 0.075 0.4 0.4]);
    set(handles.XTfig, 'DoubleBuffer', 'on');
    set(handles.XTfig, 'BackingStore', 'off');    
    drawnow;
    
    
function delete_selected_dataset(hObject, eventdata, handles)
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;
    
    table = handles.table;

    bead_to_remove = get(handles.slider_BeadID, 'Value');
    
    bead_max = max(table(:,ID));

	k = find(table(:,ID) ~= bead_to_remove);
    
    table = table(k,:);
    
    if (bead_max ~= bead_to_remove) % otherwise I don't have to rearrange beadIDs
        for m = (bead_to_remove + 1) : bead_max
            k = find(table(:,ID) == m);
            table(k,ID) = m-1;
        end
    end
    
    handles.table = table;
	guidata(hObject, handles);
    
    if (bead_to_remove == 0)
        set(handles.slider_BeadID, 'Value', bead_to_remove+1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove+1));
    else
    	set(handles.slider_BeadID, 'Value', bead_to_remove-1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove-1));        
    end

    set(handles.slider_BeadID, 'Max', bead_max-1);
    set(handles.slider_BeadID, 'SliderStep', [1/(bead_max-1) 1/(bead_max-1)]);
    
    plot_data(hObject, eventdata, handles);
    drawnow;
    
    
function delete_inside_boundingbox(hObject, eventdata, handles)
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XYfig;
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    end
    figure(active_fig);
    
    table = handles.table;
    beadID = table(:,ID);
    t = table(:,TIME);
    x = table(:,X);
    y = table(:,Y);
    currentbead = get(handles.slider_BeadID, 'Value');
    
    [xm, ym] = ginput(2);
    
    xlo = min(xm);
    xhi = max(xm);
    ylo = min(ym);
    yhi = max(ym);
    
    if get(handles.radio_XYfig, 'Value')
        k = find(~(x > xlo & x < xhi & y > ylo & y < yhi & beadID == currentbead));
    elseif get(handles.radio_XTfig, 'Value')
        k = find(~( ( (x > ylo & x < yhi) | (y > ylo & y < yhi) ) & ...
                      (t > xlo & t < xhi) & (beadID == currentbead)));        
    end
    handles.table = table(k,:);
    guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
	drawnow;

    
function delete_data_before_time(hObject, eventdata, handles);    
    global TIME ID FRAME X Y Z ROLL PITCH YAW RADIAL;

    if(get(handles.radio_XYfig, 'Value'))
        active_fig = handles.XTfig;        
    elseif(get(handles.radio_XTfig, 'Value'))
        active_fig = handles.XTfig;
    end
    figure(active_fig);

    table = handles.table;
    beadID = table(:,ID);

    currentbead = get(handles.slider_BeadID, 'Value');
    idx = find(beadID == currentbead);
    
    t = table(idx,TIME);
    x = table(idx,X);
    y = table(idx,Y);
    
    [tm, xm] = ginput(1);
    
    % find the closest time point to mouse click
    dists = abs(t - tm);    
    
    % identify time
    idx = find(dists == min(dists));
    closest_time = t(idx);
    
    % subtract this time from all points
    table(:,TIME) = table(:,TIME) - closest_time;
    
    % remove any points in the table that are now negative
    idx = find(table(:,TIME) > 0);
    table = table(idx,:);
    
    handles.table = table;
    guidata(hObject, handles);

    drawnow;
    
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

