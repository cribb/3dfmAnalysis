function varargout = elt_GUI(varargin)
% elt_GUI M-file for elt_GUI.fig
%      elt_GUI, by itself, creates a new elt_GUI or raises the existing
%      singleton*.
%
%      H = elt_GUI returns the handle to a new elt_GUI or the handle to
%      the existing singleton*.
%
%      elt_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in elt_GUI.M with the given input arguments.
%
%      elt_GUI('Property','Value',...) creates a new elt_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before elt_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to elt_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help elt_GUI

% Last Modified by GUIDE v2.5 14-Aug-2005 22:40:27

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @elt_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @elt_GUI_OutputFcn, ...
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
    global TIME X Y Z R;    
    TIME = 1; X = 2; Y = 3; Z = 4;  R = 5;

% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to elt_GUI (see VARARGIN)

function elt_GUI_OpeningFcn(hObject, eventdata, handles, varargin)

	% Choose default command line output for elt_GUI
	handles.output = hObject;
	
	% Update handles structure
	guidata(hObject, handles);
	
	% UIWAIT makes elt_GUI wait for user response (see UIRESUME)
	% uiwait(handles.elt_GUI);

% --- Outputs from this function are returned to the command line.
function varargout = elt_GUI_OutputFcn(hObject, eventdata, handles)
	
	% Get default command line output from handles structure
	varargout{1} = handles.output;


% --- Executes on button press in radio_boundingbox.
function radio_boundingbox_Callback(hObject, eventdata, handles)
	set(handles.radio_boundingbox, 'Value', 1);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 0);
        
% --- Executes on button press in radio_deletetimebefore.
function radio_deletetimebefore_Callback(hObject, eventdata, handles)
	set(handles.radio_boundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 1);
	set(handles.radio_deletetimeafter, 'Value', 0);

% --- Executes on button press in radio_deletetimebefore.
function radio_deletetimeafter_Callback(hObject, eventdata, handles)
	set(handles.radio_boundingbox, 'Value', 0);
	set(handles.radio_deletetimebefore, 'Value', 0);
	set(handles.radio_deletetimeafter, 'Value', 1);
    
% --- Executes on button press in check_XYZfig.
function check_XYZfig_Callback(hObject, eventdata, handles)
    global TIME X Y Z R;    
    
    txyz = handles.txyz;
    
    if get(handles.check_XYZfig, 'Value')
        figure(handles.XYZfig);   
        plot3(txyz(:,X), txyz(:,Y), txyz(:,Z), '.'); 
        xlabel('X [m]');        
        ylabel('Y [m]');
        zlabel('Z [m]');
        grid on;
        set(handles.XYZfig, 'Units', 'Normalized');
        set(handles.XYZfig, 'Position', [0.1 0.075 0.4 0.4]);
        set(handles.XYZfig, 'DoubleBuffer', 'on');
        set(handles.XYZfig, 'BackingStore', 'off');
        drawnow;
    else
        figure(handles.XYZfig);
        set(handles.XYZfig, 'Visible', 'off');
    end

% --- Executes on button press in radio_Tfig.
function radio_XTfig_Callback(hObject, eventdata, handles)
    global TIME X Y Z R;    

    set(handles.radio_XTfig, 'Value', 1);
    set(handles.radio_YTfig, 'Value', 0);
    set(handles.radio_ZTfig, 'Value', 0);
    set(handles.radio_RTfig, 'Value', 0);
    
    handles.active_time_fig = X;
	guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);

% --- Executes on button press in radio_YTfig.
function radio_YTfig_Callback(hObject, eventdata, handles)
    global TIME X Y Z R;    

    set(handles.radio_XTfig, 'Value', 0);
    set(handles.radio_YTfig, 'Value', 1);
    set(handles.radio_ZTfig, 'Value', 0);
    set(handles.radio_RTfig, 'Value', 0);

    handles.active_time_fig = Y;
	guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);

% --- Executes on button press in radio_ZTfig.
function radio_ZTfig_Callback(hObject, eventdata, handles)
    global TIME X Y Z R;    

    set(handles.radio_XTfig, 'Value', 0);
    set(handles.radio_YTfig, 'Value', 0);
    set(handles.radio_ZTfig, 'Value', 1);
    set(handles.radio_RTfig, 'Value', 0);

    handles.active_time_fig = Z;
	guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);

% --- Executes on button press in radio_RTfig.
function radio_RTfig_Callback(hObject, eventdata, handles)
    global TIME X Y Z R;    

    set(handles.radio_XTfig, 'Value', 0);
    set(handles.radio_YTfig, 'Value', 0);
    set(handles.radio_ZTfig, 'Value', 0);
    set(handles.radio_RTfig, 'Value', 1);

    handles.active_time_fig = R;
	guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
    
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
    global TIME X Y Z R;
    
    filename = get(handles.edit_infile, 'String');
    
    if(length(filename) == 0)

		[fname, pname] = uigetfile('*.mat');
        if strcmp(fname, '0') 
            logentry('No File selected ...');
            return;
        end
        
		filename = strcat(pname, fname);
        logentry(['Setting Path to: ' pname]);
        cd(pname);
		set(handles.edit_infile,'String', filename);
        set(handles.edit_outfile, 'String', '');
    end   

    filenameroot = strrep(filename, '.vrpn', '');
    filenameroot = strrep(filenameroot, '.mat', '');
    filenameroot = strrep(filenameroot, '.elt', '');

    % load the datafile
    logentry('Loading dataset... ');
    try
        d = load_vrpn_tracking(filename, 'm');
    catch
        msgbox('File Not Found!', 'Error.');
        return;
    end
    set(handles.edit_infile, 'TooltipString', filename);
    set(handles.edit_infile, 'String', '');
    logentry(['Dataset, ' filename ', successfully loaded...']);
    
    % set the default output filename
    outfile = get(handles.edit_outfile, 'String');
    if length(outfile) == 0
        outfile = [pname fname(1:end-3) 'elt.mat'];
        set(handles.edit_outfile, 'String', outfile);
    end
    set(handles.edit_outfile, 'TooltipString', outfile);

    % assign data variables
    r = magnitude(d.beadpos.x, d.beadpos.y, d.beadpos.z);
    d.beadpos.time = d.beadpos.time - d.beadpos.time(1);
    
    txyz = [d.beadpos.time d.beadpos.x d.beadpos.y d.beadpos.z r];

    XYZfig = figure;
    set(XYZfig, 'Visible', 'off');
    
    Tfig = figure;

    handles.XYZfig = XYZfig;
    handles.Tfig = Tfig;
    handles.txyz = txyz;

    guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
    drawnow;
    
    
% --- Executes on button press in pushbutton_savefile.
function pushbutton_savefile_Callback(hObject, eventdata, handles)
    global TIME X Y Z R;

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

	set(handles.radio_boundingbox, 'Enable', 'Off');
    set(handles.radio_deletetimebefore, 'Enable', 'Off');
    set(handles.radio_deletetimeafter, 'Enable', 'Off');
	
    if (get(handles.radio_boundingbox, 'Value'))
        delete_inside_boundingbox(hObject, eventdata, handles);
    elseif (get(handles.radio_deletetimebefore, 'Value'))
        set(handles.radio_Tfig, 'Value', 1, 'Enable', 'off');
        set(handles.check_XYZfig, 'Value', 0, 'Enable', 'off');

        delete_data_before_time(hObject, eventdata, handles);
        
        set(handles.radio_Tfig, 'Enable', 'on');
        set(handles.check_XYZfig, 'Enable', 'on');
    elseif (get(handles.radio_deletetimeafter, 'Value'))
        set(handles.radio_Tfig, 'Value', 1, 'Enable', 'off');
        set(handles.check_XYZfig, 'Value', 0, 'Enable', 'off');

        delete_data_after_time(hObject, eventdata, handles);
        
        set(handles.radio_Tfig, 'Enable', 'on');
        set(handles.check_XYZfig, 'Enable', 'on');
        
	else
        msgbox('One of the data handling methods must be selected.', ...
               'Error.');
	end
	
	set(handles.radio_boundingbox, 'Enable', 'On');
    set(handles.radio_deletetimebefore, 'Enable', 'On');
    set(handles.radio_deletetimeafter, 'Enable', 'Off');
    
    plot_data(hObject, eventdata, handles);
    drawnow;
    
    
function plot_data(hObject, eventdata, handles)
    global TIME X Y Z R;
    
    txyz   = handles.txyz;

	try
        active_time_fig = handles.active_time_fig;
    catch
        active_time_fig = R;
    end
    
    figure(handles.Tfig);
    plot(txyz(:,TIME), txyz(:,active_time_fig), '.');
    xlabel('time (s)');
    ylabel('displacement [m]');
    set(handles.Tfig, 'Units', 'Normalized');
    set(handles.Tfig, 'Position', [0.51 0.075 0.4 0.4]);
    set(handles.Tfig, 'DoubleBuffer', 'on');
    set(handles.Tfig, 'BackingStore', 'off');    
    drawnow;
    
    refresh(handles.XYZfig);
    refresh(handles.Tfig);
    drawnow;
    
function delete_inside_boundingbox(hObject, eventdata, handles)
    global TIME X Y Z R;

    if(get(handles.check_XYZfig, 'Value'))
        active_fig = handles.XYZfig;
    elseif(get(handles.radio_Tfig, 'Value'))
        active_fig = handles.Tfig;
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
    
    if get(handles.check_XYZfig, 'Value')
        k = find(~(x > xlo & x < xhi & y > ylo & y < yhi & beadID == currentbead));
    elseif get(handles.radio_Tfig, 'Value')
        k = find(~( ( (x > ylo & x < yhi) | (y > ylo & y < yhi) ) & ...
                      (t > xlo & t < xhi) & (beadID == currentbead)));        
    end
    handles.table = table(k,:);
    guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
	drawnow;

    
function delete_data_before_time(hObject, eventdata, handles);    
    global TIME X Y Z R;

    if(get(handles.check_XYZfig, 'Value'))
        active_fig = handles.Tfig;        
    elseif(get(handles.radio_Tfig, 'Value'))
        active_fig = handles.Tfig;
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
   
    
function delete_data_after_time(hObject, eventdata, handles);    
    global TIME X Y Z R;

    if(get(handles.check_XYZfig, 'Value'))
        active_fig = handles.Tfig;        
    elseif(get(handles.radio_Tfig, 'Value'))
        active_fig = handles.Tfig;
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
    
    % remove any points in the table that are now negative
    idx = find(table(:,TIME) <= closest_time);
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
     headertext = [logtimetext 'elt_gui: '];
     
     fprintf('%s%s\n', headertext, txt);

