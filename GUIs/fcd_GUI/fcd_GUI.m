function varargout = fcd_GUI(varargin)
% fcd_GUI M-file for fcd_GUI.fig
%      fcd_GUI, by itself, creates a new fcd_GUI or raises the existing
%      singleton*.
%
%      H = fcd_GUI returns the handle to a new fcd_GUI or the handle to
%      the existing singleton*.
%
%      fcd_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in fcd_GUI.M with the given input arguments.
%
%      fcd_GUI('Property','Value',...) creates a new fcd_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fcd_GUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fcd_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fcd_GUI

% Last Modified by GUIDE v2.5 17-Sep-2004 19:32:21

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @fcd_GUI_OpeningFcn, ...
                       'gui_OutputFcn',  @fcd_GUI_OutputFcn, ...
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


% --- Executes just before fcd_GUI is made visible.
function fcd_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fcd_GUI (see VARARGIN)

	% Choose default command line output for fcd_GUI
	handles.output = hObject;
	
	% Update handles structure
	guidata(hObject, handles);
	
	% UIWAIT makes fcd_GUI wait for user response (see UIRESUME)
	% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fcd_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	
	% Get default command line output from handles structure
	varargout{1} = handles.output;


% --- Executes on button press in radio_selected_dataset.
function radio_selected_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to radio_selected_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of radio_closest_dataset
	set(handles.radio_selected_dataset, 'Value', 1);
	set(handles.radio_boundingbox, 'Value', 0);

    
% --- Executes on button press in radio_boundingbox.
function radio_boundingbox_Callback(hObject, eventdata, handles)
% hObject    handle to radio_boundingbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hint: get(hObject,'Value') returns toggle state of radio_boundingbox
	set(handles.radio_selected_dataset, 'Value', 0);
	set(handles.radio_boundingbox, 'Value', 1);


% --- Executes during object creation, after setting all properties.
function edit_infile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_infile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_infile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_infile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of edit_infile as text
	%        str2double(get(hObject,'String')) returns contents of edit_infile as a double


% --- Executes on button press in pushbutton_loadfile.
function pushbutton_loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    filename = get(handles.edit_infile, 'String');
    
    if(length(filename) == 0)
		[fname, pname] = uigetfile('*.mat');
		filename = strcat(pname, fname);
		set(handles.edit_infile,'String', filename);
    end   

    try
        d = load(filename);
    catch
        msgbox('File Not Found!', 'Error.');
        return;
    end
    
    set(handles.edit_outfile, 'String', [pname 'fcd_' fname]);
    
    table = d.tracking.spot2DSecUsecIndexXYZ;
    table = attach_time(table);
    beadID = table(:,3);
    x = table(:,4);
    y = table(:,5);
    fig = figure;
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

    handles.fig = fig;
    handles.table = table;
    guidata(hObject, handles);

    plot_data(hObject, eventdata, handles);
    
    
% --- Executes on button press in pushbutton_savefile.
function pushbutton_savefile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_savefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	outfile = get(handles.edit_outfile, 'String');
    
    if (length(outfile) == 0)
        msgbox('No filename specified for output.', 'Error.');
        return;
    end
    
    tracking = handles.table;
    save(outfile, 'tracking');
    
    set(handles.edit_infile, 'String', '');
    set(handles.edit_outfile, 'String', '');
    

       
% --- Executes during object creation, after setting all properties.
function edit_outfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_outfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
	
	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_outfile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_outfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of edit_outfile as text
	%        str2double(get(hObject,'String')) returns contents of edit_outfile as a double


% --- Executes on button press in pushbutton_Edit_Data.
function pushbutton_Edit_Data_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Edit_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	set(handles.radio_selected_dataset, 'Enable', 'Off');
	set(handles.radio_boundingbox, 'Enable', 'Off');
	
	if (get(handles.radio_selected_dataset, 'Value'))
        delete_closest_dataset(hObject, eventdata, handles);
	elseif (get(handles.radio_boundingbox, 'Value'))
        delete_inside_boundingbox(hObject, eventdata, handles);
	else
        msgbox('One of the data handling methods must be selected.', ...
               'Error.');
	end
	
	set(handles.radio_selected_dataset, 'Enable', 'On');
	set(handles.radio_boundingbox, 'Enable', 'On');

    plot_data(hObject, eventdata, handles);
    
    
% --- Executes during object creation, after setting all properties.
function slider_BeadID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_BeadID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: slider controls usually have a light gray background, change
	%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
	usewhitebg = 1;
	if usewhitebg
        set(hObject,'BackgroundColor',[.9 .9 .9]);
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


% --- Executes on slider movement.
function slider_BeadID_Callback(hObject, eventdata, handles)
% hObject    handle to slider_BeadID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
	
	currentBead = get(handles.slider_BeadID, 'Value');
	set(handles.edit_BeadID, 'String', num2str(currentBead));
    
    plot_data(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function edit_BeadID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_BeadID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

	% Hint: edit controls usually have a white background on Windows.
	%       See ISPC and COMPUTER.
	if ispc
        set(hObject,'BackgroundColor','white');
	else
        set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
	end


function edit_BeadID_Callback(hObject, eventdata, handles)
% hObject    handle to edit_BeadID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Hints: get(hObject,'String') returns contents of edit_BeadID as text
	%        str2double(get(hObject,'String')) returns contents of edit_BeadID as a double
	set(handles.slider_BeadID, 'Value', str2num(get(handles.edit_BeadID, 'String')));

    
% --- Executes on button press in pushbutton_Select_Closest_dataset.
function pushbutton_Select_Closest_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Select_Closest_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    figure(handles.fig);
	[xm, ym] = ginput(1);
    
    beadID = handles.table(:,3);    
    x = handles.table(:,4);
    y = handles.table(:,5);
    
    xval = repmat(xm, length(x), 1);
    yval = repmat(ym, length(y), 1);

    dist = sqrt((x - xval).^2 + (y - yval).^2);

    bead_to_select = beadID(find(dist == min(dist)));
    
    set(handles.slider_BeadID, 'Value', bead_to_select);
    set(handles.edit_BeadID, 'String', num2str(bead_to_select));
    
    plot_data(hObject, eventdata, handles);
    

function v = attach_time(table)

    beadIDs = table(:,3);
    times = zeros(length(beadIDs), 1);
    
    for thisbead = 0:max(beadIDs);
        k = find(beadIDs == thisbead);
        
        times(k) = [0 : 1/120 : (length(k)-1)/120]';    
    end
    
    table = [table times];
    
    v = table;

    
function plot_data(hObject, eventdata, handles)

    beadID = handles.table(:,3);
    x      = handles.table(:,4);
    y      = handles.table(:,5);
    t      = handles.table(:,7);
    
    currentBead = get(handles.slider_BeadID, 'Value');
    
	k = find(beadID == currentBead);
	nk = find(beadID ~= currentBead);
    
    figure(handles.fig);
    subplot(1,2,1);
    plot(x(nk), y(nk), '.', x(k), y(k), 'r.'); 
    axis([0 648 0 484]);
    
    figure(handles.fig);
    subplot(1,2,2);
    plot(t(k), [x(k) y(k)], '.');
    
    
    set(handles.fig, 'Units', 'Normalized');
    set(handles.fig, 'Position', [0.1 0.075 0.8 0.4]);
    
    
function delete_closest_dataset(hObject, eventdata, handles)
    
    table = handles.table;

    bead_to_remove = get(handles.slider_BeadID, 'Value');
    bead_max = max(table(:,3));
    
    bead_max = max(table(:,3));

	k = find(table(:,3) ~= bead_to_remove);
    
    table = table(k,:);
    
    if (bead_max ~= bead_to_remove) % otherwise I don't have to rearrange beadIDs
        for m = (bead_to_remove + 1) : bead_max
            k = find(table(:,3) == m);
            table(k,3) = m-1;
        end
    end
    
    handles.table = table;
	guidata(hObject, handles);
    
    if (bead_to_remove == 0)
        set(handles.slider_BeadID, 'Value', bead_to_remove);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove));
    else
    	set(handles.slider_BeadID, 'Value', bead_to_remove-1);
        set(handles.edit_BeadID, 'String', num2str(bead_to_remove-1));        
    end

    set(handles.slider_BeadID, 'Max', bead_max-1);
    set(handles.slider_BeadID, 'SliderStep', [1/(bead_max-1) 1/(bead_max-1)]);
    
    
function delete_inside_boundingbox(hObject, eventdata, handles)

    figure(handles.fig);
    
    table = handles.table;
    beadID = table(:,3);
    x = table(:,4);
    y = table(:,5);
    currentbead = get(handles.slider_BeadID, 'Value');
    
    [xm, ym] = ginput(2);

    k = find(~(x > xm(1) & x < xm(2) & y < ym(1) & y > ym(2) & beadID == currentbead));
    
    handles.table = table(k,:);
    guidata(hObject, handles);

    