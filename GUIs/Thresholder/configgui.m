function varargout = ConfigGUI(varargin)
% CONFIGGUI Application M-file for ConfigGUI.fig
%    FIG = CONFIGGUI launch ConfigGUI GUI.
%    CONFIGGUI('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 20-Jul-2003 12:13:27

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = edit_particle_size_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = popupmenu_particle_size_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = edit_viscosity_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = popupmenu_viscosity_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = edit_frame_rate_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = popupmenu_frame_rate_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = edit_calib_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = popupmenu_calib_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = checkbox_x_position_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = checkbox_y_position_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = checkbox_frame_number_Callback(h, eventdata, handles, varargin)







% --------------------------------------------------------------------
function varargout = checkbox_time_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = checkbox_velocity_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = checkbox_force_Callback(h, eventdata, handles, varargin)






% --------------------------------------------------------------------
function varargout = pushbutton_calib_browse_Callback(h, eventdata, handles, varargin)

	[pname, fname] = uigetfile('*.txt');
	
	file_name = strcat(fname, pname);
	
% 	set(handles.calibSelectEdit,'String', file_name);
%     
%     
%     	cal_file = get(handles.calibSelectEdit,'String');
	
	M = CSVREAD(file_name);
	
	calib_factor = M(1);
	
	handles.calibration = calib_factor;
	guidata(h,handles);
	
	
	good_string = strcat(num2str(handles.calibration));
	
	set(handles.edit_calib,'String', good_string);
    
     


% --------------------------------------------------------------------
function varargout = pushbutton_make_calib_Callback(h, eventdata, handles, varargin)

CalibrateGUIa;



% --------------------------------------------------------------------
function varargout = edit_log_name_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = pushbutton_log_browse_Callback(h, eventdata, handles, varargin)

directory = uigetfolder_standalone;
file_name = get(handles.edit_log_name,'String');


whole_name = strcat(directory,'\', file_name);

set(handles.edit_log_name,'String', whole_name);





% --------------------------------------------------------------------
function varargout = edit_config_name_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = pushbutton_config_browse_Callback(h, eventdata, handles, varargin)

directory = uigetfolder_standalone;
file_name = get(handles.edit_config_name,'String');


whole_name = strcat(directory,'\', file_name);

set(handles.edit_config_name,'String', whole_name);




% --------------------------------------------------------------------
function varargout = pushbutton_save_Callback(h, eventdata, handles, varargin)


%Particle Size
% *****************************************************************
handles.particle_size = str2num(get(handles.edit_particle_size,'String'));
guidata(h, handles);


%Particle Size Units
% *****************************************************************
val = get(h,'Value');
switch val
case 1 
    handles.particle_size_units = 'microns';
case 2 
    handles.particle_size_units = 'meters';
case 3 
    handles.particle_size_units = 'inches';
end

guidata(h,handles)


%Viscosity
% *****************************************************************
handles.viscosity = str2num(get(handles.edit_viscosity,'String'));
guidata(h, handles);


%Viscosity Units
% *****************************************************************
val = get(h,'Value');
switch val
case 1 
    handles.viscosity_units = 'centipoise';
case 2 
    handles.viscosity_units = 'poise';
case 3 
    handles.viscosity_units = 'pas';
end

guidata(h,handles)


%Frame Rate
% *****************************************************************
handles.frame_rate = str2num(get(handles.edit_frame_rate,'String'));
guidata(h, handles);



%Frame Rate Units
% *****************************************************************
val = get(h,'Value');
switch val
case 1 
    handles.frame_rate_units = 'fps';
end
guidata(h,handles)



%Calibration
% *****************************************************************
handles.calibration = str2num(get(handles.edit_calib,'String'));
guidata(h, handles);



%Calibration Units
% *****************************************************************
val = get(h,'Value');
switch val
case 1 
    handles.calibration_units = 'pixelspermicron';
end
guidata(h,handles)

   


%X Position Checkbox
% *****************************************************************
if (get(handles.checkbox_x_position,'Value') == get(handles.checkbox_x_position,'Max'))
    % then checkbox is checked-take approriate action
    handles.x_position_log = 1;
    
else
    % checkbox is not checked-take approriate action
    handles.x_position_log = 0;
end

guidata(h,handles)



%Y Position Checkbox
% *****************************************************************
if (get(handles.checkbox_y_position,'Value') == get(handles.checkbox_y_position,'Max'))
    % then checkbox is checked-take approriate action
    handles.y_position_log = 1;
    
else
    % checkbox is not checked-take approriate action
    handles.y_position_log = 0;
end

guidata(h,handles)




%Frame Number Checkbox
% *****************************************************************
if (get(handles.checkbox_frame_number,'Value') == get(handles.checkbox_frame_number,'Max'))
    % then checkbox is checked-take approriate action
    handles.frame_number_log = 1;
    
else
    % checkbox is not checked-take approriate action
    handles.frame_number_log = 0;
end

guidata(h,handles)



%Time Checkbox
% *****************************************************************
if (get(handles.checkbox_time,'Value') == get(handles.checkbox_time,'Max'))
    % then checkbox is checked-take approriate action
    handles.time_log = 1;
    
else
    % checkbox is not checked-take approriate action
    handles.time_log = 0;
end

guidata(h,handles)






%Velocity Checkbox
% *****************************************************************
if (get(handles.checkbox_velocity,'Value') == get(handles.checkbox_velocity,'Max'))
    % then checkbox is checked-take approriate action
    handles.velocity_log = 1;
    
else
    % checkbox is not checked-take approriate action
    handles.velocity_log = 0;
end

guidata(h,handles)







%Force Checkbox
% *****************************************************************
if (get(handles.checkbox_force,'Value') == get(handles.checkbox_force,'Max'))
    % then checkbox is checked-take approriate action
    handles.force_log = 1;
    
else
    % checkbox is not checked-take approriate action
    handles.force_log = 0;
end

guidata(h,handles)
































%Write the configurate changes to a file
    save_file = get(handles.edit_config_name,'String');
    a = ('#');
    
    b = get(handles.edit_particle_size,'String');
    c = handles.particle_size_units;
    d = get(handles.edit_viscosity,'String');
    e = handles.viscosity_units;
    f = get(handles.edit_frame_rate,'String');
    g = handles.frame_rate_units;
    h = get(handles.edit_calib,'String');
    i = handles.calibration_units;
    
    j = num2str(handles.x_position_log);
    k = num2str(handles.y_position_log);
    l = num2str(handles.frame_number_log);
    m = num2str(handles.time_log);
    n = num2str(handles.velocity_log);
    o = num2str(handles.force_log);
    
    p = get(handles.edit_log_name,'String');
    q = get(handles.edit_config_name,'String');
    
    
    total_string = strcat(a,b,a,c,a,d,a,e,a,f,a,g,a,h,a,i,a,j,a,k,a,l,a,m,a,n,a,o,a,p,a,q);
    

    
    M = [total_string];


    csvwrite(save_file,M);
    

%Close the window
    delete(handles.figure1)


% --------------------------------------------------------------------
function varargout = pushbutton_cancel_Callback(h, eventdata, handles, varargin)

delete(handles.figure1)




% --------------------------------------------------------------------
function varargout = pushbutton_parse_Callback(h, eventdata, handles, varargin)

clc

	[pname, fname] = uigetfile('*.txt');
	
	file_name = strcat(fname, pname);
		
	fid = fopen(file_name);
    
    dataline = fgetl(fid);
    
    str = strrep(dataline,',','');
    
    [particle_size,str] = strtok(str,'#');
    [particle_size_units,str] = strtok(str,'#');
    [viscosity,str] = strtok(str,'#');
    [viscosity_units,str] = strtok(str,'#');
    [frame_rate,str] = strtok(str,'#');
    [frame_rate_units,str] = strtok(str,'#');
    [calibration,str] = strtok(str,'#');
    [calibration_units,str] = strtok(str,'#');
    
    [x_position,str] = strtok(str,'#');
    [y_position,str] = strtok(str,'#');
    [frame_number,str] = strtok(str,'#');
    [time,str] = strtok(str,'#');
    [velocity,str] = strtok(str,'#');
    [force,str] = strtok(str,'#');
    
    [log_file,str] = strtok(str,'#');
    [config_file,str] = strtok(str,'#');

