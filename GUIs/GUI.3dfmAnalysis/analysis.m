function varargout = analysis(varargin)
% Analysis Application M-file for analysis.fig
%    FIG = ANALYSIS launch analysis GUI.
%    ANALYSIS('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.0 15-Oct-2003 00:34:08

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

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
function varargout = button_brTracking_Callback(h, eventdata, handles, varargin)
global dorig
warning off
[path, file] = uigetfile('*.mat');
fullName = strcat(file,path);
set(handles.edit_trackingFileName,'string',fullName);
% set(handles.button_plotVis,'Enable','off');
tracking_string = get(handles.edit_trackingFileName,'string');
if isempty(tracking_string)
    disp('No tracking file selected');
    warning on
    return;
end

temp = load(tracking_string);
if(isfield(temp,'tracking'))    
    dorig = load_vrpn_tracking(tracking_string,'um','uct','no','no');
elseif(isfield(temp,'dj'))
    dorig = temp.dj;
else
    disp('Unrecognized data format: valid fields - tracking | dj');
end
dorig.info.orig.time_offset = dorig.stage.time(1,1);
% dorig.stage.time_offset = dorig.stage.time(1,1);
dorig.stage.time = dorig.stage.time - dorig.stage.time(1,1);
set(h,'UserData',dorig);
tim = dorig.stage.time - dorig.stage.time(1,1);
dorig.tstart = min(tim);
dorig.tend = max(tim);
set(handles.edit_trackingStart,'string',num2str(dorig.tstart));
set(handles.edit_trackingEnd,'string',num2str(dorig.tend));
set(handles.edit_driftStart,'string',num2str(0.0));
set(handles.edit_driftEnd,'string',num2str(0.0));
set(handles.text_driftData,'UserData',[]);

warning on

% --------------------------------------------------------------------
function varargout = button_brMagnets_Callback(h, eventdata, handles, varargin)
warning off
[path, file] = uigetfile('*.mat');
fullName = strcat(file,path);
set(handles.edit_magnetsFileName,'string',fullName);
if(isempty(fullName))
    disp('No magnet file selected');
    warning on
    return;
end
set(handles.check_mags,'Enable','On');
set(handles.check_plotMagTrack,'Enable','On');
magnets = load(fullName);
if(isfield(magnets,'magnets'))
    magnets = magnets.magnets;
    if(~isfield(magnets,'sectime'))
        magnets.sectime = magnets.time(:,1) + magnets.time(:,2)*1e-6;
    end
else
    magnets = magnets.output;
    magnets.analogs = magnets.mags;
    magnets.sectime = magnets.time;
end
set(h, 'UserData', magnets);
warning on

% % --------------------------------------------------------------------
% function varargout = button_selectData_Callback(h, eventdata, handles, varargin)
% tr_start = str2double(get(handles.edit_trackingStart,'string'));
% tr_end = str2double(get(handles.edit_trackingEnd,'string'));
% d = get(handles.button_brTracking,'UserData');
% % d = d.dorig;
% if(get(handles.check_drift,'value'))
% 	dr_start = str2double(get(handles.edit_driftStart,'string'));
% 	dr_end = str2double(get(handles.edit_driftEnd,'string'));
% end
% 	
% if (tr_start > tr_end) % not out of bounds
%     errordlg('Starting Time is greater than ending time for tracking! Wake up!','Bad Input','modal')
% elseif (get(handles.check_drift,'value') & (dr_start > dr_end))
% 	errordlg('Starting Time is greater than ending time for drift! Wake up!','Bad Input','modal')
% else
% 	
% 
% 	tra_istart = min(find(d.stage.time >= tr_start));
% 	tra_iend = max(find(d.stage.time <= tr_end));
% 	dclip.stage.time = d.stage.time(tra_istart:tra_iend);
% 	dclip.stage.x = d.stage.x(tra_istart:tra_iend);
% 	dclip.stage.y = d.stage.y(tra_istart:tra_iend);
% 	dclip.stage.z = d.stage.z(tra_istart:tra_iend);
%     dclip.stage.time_offset = d.stage.time_offset;
%     dclip.const = d.const;
% 	set(handles.text_TrackingData,'UserData',dclip);
% 	
% 	if(get(handles.check_drift,'value'))
% 		dr_istart = min(find(d.stage.time >= dr_start));
% 		dr_iend = max(find(d.stage.time <= dr_end));
% 		ddrift.stage.time = d.stage.time(dr_istart:dr_iend);
% 		ddrift.stage.x = d.stage.x(dr_istart:dr_iend);
% 		ddrift.stage.y = d.stage.y(dr_istart:dr_iend);
% 		ddrift.stage.z = d.stage.z(dr_istart:dr_iend);
% 		
% 		temp_t = ddrift.stage.time;
% 		x = ddrift.stage.x;
% 		y = ddrift.stage.y;
% 		z = ddrift.stage.z;	
% 
% 		ddrift.back_vx = polyfit(temp_t, x, 1);
% 		ddrift.back_vy = polyfit(temp_t, y, 1);
% 		ddrift.back_vz = polyfit(temp_t, z, 1);
% 		set(handles.check_drift,'UserData',ddrift);
% 	end
%    	set(handles.button_plotVis,'Enable','On');
% end
% 

% --------------------------------------------------------------------
function varargout = button_plotVis_Callback(h, eventdata, handles, varargin)
global dorig

vis_velocities = 1;

do_hairs = get(handles.check_hairs,'value');
do_colors = get(handles.check_colors,'value');
subtract_drift = get(handles.radio_plotDrift,'value');
if(do_hairs & do_colors)
	vis_mode = 'both';
elseif(do_hairs)
	vis_mode = 'hairs';
elseif(do_colors)
	vis_mode = 'colors';
else
	vis_velocities = 0;
end

if(get(handles.check_mags,'value'))
	dmag = load(get(handles.edit_magetsFileName,'string'));
	mags = dmag.magnets.analogs;
	plot3(mags(:,1), mags(:,2), mags(:,3));
end
if(vis_velocities)
    if(isempty(get(handles.button_computeVelocity,'UserData')))
        button_computeVelocity_Callback(handles.button_computeVelocity,[],handles,[]);
    end
    vel = get(handles.button_computeVelocity,'UserData');
    visVelocities(vel,vis_mode);
end


% --------------------------------------------------------------------
function varargout = edit_trackingFileName_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = edit_magnetsFileName_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = check_drift_Callback(h, eventdata, handles, varargin)

if(get(h,'value'))
	set(handles.edit_driftStart,'Enable','on'); 
	set(handles.edit_driftEnd,'Enable','on');
	set(handles.radio_plotDrift,'Enable','on');
else
	set(handles.edit_driftStart,'Enable','off'); 
	set(handles.edit_driftEnd,'Enable','off');
 	set(handles.radio_plotDrift,'Enable','off');
	set(handles.radio_plotDrift,'Value',0);
end


% --------------------------------------------------------------------
function varargout = check_colors_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = check_hairs_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = check_mags_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
function varargout = edit_trackingStart_Callback(h, eventdata, handles, varargin)
global dorig
checkVal(h, handles, dorig.tstart, dorig.tend);

% --------------------------------------------------------------------
function varargout = edit_trackingEnd_Callback(h, eventdata, handles, varargin)
global dorig
checkVal(h, handles, dorig.tstart, dorig.tend);
tr_start = str2double(get(handles.edit_trackingStart,'string'));
tr_end = str2double(get(handles.edit_trackingEnd,'string'));
if (tr_start > tr_end) % not out of bounds
    errordlg('Warning: Starting Time is greater than ending time for tracking!','Bad Input','modal')
end

% --------------------------------------------------------------------
function varargout = edit_driftStart_Callback(h, eventdata, handles, varargin)
global dorig
checkVal(h, handles, dorig.tstart, dorig.tend);
dr_start = str2double(get(handles.edit_driftStart,'string'));
dr_end = str2double(get(handles.edit_driftEnd,'string'));
if (dr_start < dr_end)
    setDriftData(handles.text_driftData,dorig,dr_start,dr_end);
elseif (dr_start == dr_end)
    set(handles.text_driftData,'UserData',[]);
end


% --------------------------------------------------------------------
function varargout = edit_driftEnd_Callback(h, eventdata, handles, varargin)
global dorig
checkVal(h, handles, dorig.tstart, dorig.tend);
dr_start = str2double(get(handles.edit_driftStart,'string'));
dr_end = str2double(get(handles.edit_driftEnd,'string'));
if (dr_start > dr_end)
	errordlg('Warning: Starting Time is greater than ending time for drift!','Bad Input','modal')
elseif (dr_start == dr_end)
    set(handles.text_driftData,'UserData',[]);
else
    setDriftData(handles.text_driftData,dorig,dr_start,dr_end);
end 




% --------------------------------------------------------------------
function varargout = slider_dt_Callback(h, eventdata, handles, varargin)
inval = get(h,'value');
set(handles.edit_dt,'string',num2str(inval));
% --------------------------------------------------------------------
function varargout = edit_dt_Callback(h, eventdata, handles, varargin)
check_editval(h, handles.slider_dt);
% --------------------------------------------------------------------
function varargout = edit_plotVrpn_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function varargout = button_plotVrpn_Callback(h, eventdata, handles, varargin)
str = get(handles.edit_plotVrpn,'string');
d = get(handles.button_brTracking,'UserData');
if(get(handles.radio_plotClipped,'value'))
	data = giveClipped(handles,d);
else
	data = d;
end

if(get(handles.radio_plotDrift,'value'))
    data = subtractDrift(handles,data);
end

plot_vrpn_tracking(data,str);

if(get(handles.check_plotMagTrack,'value'))
    i = 1;
    if(findstr('x',str))
        cstr(1,i) = 'x';
        i = i+1;
    end
    if(findstr('y',str))
        cstr(1,i) = 'y';
        i = i+1;
    end
    if(findstr('z',str))
        cstr(1,i) = 'z';
        i = i+1;
    end
    if(i == 1)
        cstr = 'xyz';
    end    
    plot_MagnetsOnTracking(data,cstr,handles);
end

% --------------------------------------------------------------------
function varargout = radio_plotDrift_Callback(h, eventdata, handles, varargin)
% --------------------------------------------------------------------
function varargout = radio_plotClipped_Callback(h, eventdata, handles, varargin)
% --- Executes on button press in check_plotMagTrack.
function check_plotMagTrack_Callback(h, eventdata, handles)

% --------------------------------------------------------------------
function varargout = radio_descrete_Callback(h, eventdata, handles, varargin)

if(get(h,'value'))
    if(isempty(get(handles.button_brMagnets,'userdata')))
        disp('Error: Load manget data first for descrete mode');
        set(h,'value',0);
        return
    end        
    set(handles.radio_continuous,'value', 0);
    set(handles.edit_dt,'Enable','off');
    set(handles.slider_dt,'Enable','off');
    set(handles.radio_filter,'Enable','off');    
else
    set(handles.radio_continuous,'value', 1);
    set(handles.edit_dt,'Enable','on');
    set(handles.slider_dt,'Enable','on');
    set(handles.radio_filter,'Enable','on');    
end
% --------------------------------------------------------------------
function varargout = radio_continuous_Callback(h, eventdata, handles, varargin)

if(~get(h,'value'))
    if(isempty(get(handles.button_brMagnets,'userdata')))
        disp('Error: Load manget data first for descrete mode');
        set(h,'value',1);
        return
    end        
    set(handles.radio_descrete,'value', 1);
    set(handles.edit_dt,'Enable','off');
    set(handles.slider_dt,'Enable','off');
    set(handles.radio_filter,'Enable','off');    
else
    set(handles.radio_descrete,'value', 0);
    set(handles.edit_dt,'Enable','on');
    set(handles.slider_dt,'Enable','on');
    set(handles.radio_filter,'Enable','on');    
end


% --------------------------------------------------------------------
function varargout = menu_mode_Callback(h, eventdata, handles, varargin)
% 
% mag_fig = openfig('velocities.fig');
% 
% % Generate a structure of handles to pass to callbacks, and store it. 
% 	handles.mag_handles = guihandles(mag_fig);
%     guidata(mag_fig, handles);
% --------------------------------------------------------------------
function varargout = radio_filter_Callback(h, eventdata, handles, varargin) 


% --------------------------------------------------------------------
function varargout = button_saveVelocity_Callback(h, eventdata, handles, varargin)

velocities = get(handles.button_computeVelocity,'UserData');
data = velocities;
if(isempty(data))
    prompt(handles,'Velocity data structure is empty: nothing saved','r');
    return;
end
name = data.info.orig.name;
name = ['Vel_',name];
fullname = get(handles.edit_trackingFileName,'string');
id_end = max(find(fullname(:) == '\'));
fpath = strcat(fullname(1:id_end),name);
save(fpath,'velocities');
prompt(handles,['Velocity data saved at: ',fpath],'r');
return;
% --------------------------------------------------------------------
function varargout = edit_instruction_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
function varargout = menu_geometry_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
function velocity = button_computeVelocity_Callback(h, eventdata, handles, varargin)

    d = get(handles.button_brTracking,'UserData');
    
	if(get(handles.radio_plotDrift,'value'))
		ddrift = subtractDrift(handles,d);
    else
        ddrift = d;
    end
	
	if(get(handles.radio_plotClipped,'value'))
		dtrack = giveClipped(handles,ddrift);
    else
		dtrack = ddrift;   
    end
    
    time_step = get(handles.slider_dt,'value');
    filter = get(handles.radio_filter,'value');
    
    if(get(handles.radio_descrete,'value'))
        calc_mode = 'descrete';
        dmag = get(handles.button_brMagnets,'UserData');
    else
        calc_mode = 'continuous';
        dmag = [];
    end
    
    velocity = computeVelocity(dtrack,dmag,calc_mode,time_step,filter);
    
    if(get(handles.menu_mode,'value') == 2)
        i =get(handles.menu_geometry,'value');
        switch(i)
        case 1
            geometry = 'Tetrapole';
        case 2
            geometry  = 'Hexapole';
        otherwise 
            geometry = 'Unknown';
        end    
        velocity = avgVelForPoles(velocity,geometry);
    end
    
    set(h,'Userdata',velocity);
    
    return;

%**********************************************************************    
%***************************NON-CALLBACK FUNCTIONS*********************
%**********************************************************************
% --------------------------------------------------------------------

function avg = avgVelForPoles(velocity,geometry);

avg = velocity;
switch geometry
case 'Tetrapole'
    n = 4;
case 'Hexapole'
    n = 6;
otherwise
    disp('Pole geometry is unknown, so can not assign velocities to poles and average them.');
    return;
end

for i=1:n
    avg.avgVec(i,1:3) = [mean(velocity.velx(i:n:end)), mean(velocity.vely(i:n:end)), mean(velocity.velz(i:n:end))];
    avg.avgMag(i) = sqrt(avg.avgVec(i,:)*avg.avgVec(i,:)');
end

return
    
% --------------------------------------------------------------------


function plot_MagnetsOnTracking(dtrack,str,handles)
dmag = get(handles.button_brMagnets,'UserData');

% dmag.base = dmag.sectime - dmag.sectime(1,1);
track_st = dtrack.stage.time_offset; 
track_end = dtrack.stage.time_offset + max(dtrack.stage.time);
mag_st = dmag.sectime(1,1);
mag_end =max(dmag.sectime);

if(track_st <= mag_st)
    low_limit = track_st;
else
    low_limit = mag_st;
end

if(track_end >= mag_end)
    up_limit = track_end;
else
    up_limit = mag_end;
end

limits = [0, up_limit - low_limit];
dmag.base = dmag.sectime - low_limit;
dtrack.base = dtrack.stage.time_offset + dtrack.stage.time - low_limit;
 
    if(findstr('x',str))
        figure(101)
        set(gca,'Xlim',limits);
        stairs(dmag.base,dmag.analogs);
        hold on;
        plot(dtrack.base,dtrack.stage.x,'--');
        title('Coils and X tracking');
        legend('C1','C2','C3','C4','X tracking',0);
        grid on;
        hold off
    end
    
    if(findstr('y',str))
        figure(102)
        set(gca,'Xlim',limits);
        stairs(dmag.base,dmag.analogs);
        hold on;
        plot(dtrack.base,dtrack.stage.y,'--');
        title('Coils and Y tracking');
        legend('C1','C2','C3','C4','Y tracking',0);
        grid on;
        hold off
    end
    
    if(findstr('z',str))
        figure(103)
        set(gca,'Xlim',limits);
        stairs(dmag.base,dmag.analogs);
        hold on;
        plot(dtrack.base,dtrack.stage.z,'--');
        title('Coils and Z tracking');
        legend('C1','C2','C3','C4','Z tracking',0); 
        grid on;
        hold off
    end
return;
% --------------------------------------------------------------------
%<<< function plot_lissajous(dtrack,ddrift,dmag,vis_mode,calc_mode,tstep,filter)
%This function is used to compute velocity vectors from given data
%Tracking data should be already clipped and drift should have been taken care of.
%dmag/magnet data will only be used in case of calc_mode = 'descrete'
%tstep and filter will only be used in case of calc_mode = 'continuous'
function data = computeVelocity(dtrack,dmag,calc_mode,tstep,filter)
block = tstep;
mstage = dtrack.stage;

%------------compute velocity vectors for descrete mode if we should
if(strcmpi(calc_mode,'descrete'))
    %--------check if  both of the datasets are clipped precisely enough

    track_st = dtrack.info.orig.time_offset; %+ dtrack.info.clip.tstart; 
    track_end = track_st + max(dtrack.stage.time);
    mag_st = dmag.sectime(1,1);
    mag_end = max(dmag.sectime);
       
    if(abs(track_st - mag_st)>1 | abs(track_end - mag_end)>1)
        disp('Tracking and magnets data are not clipped precisely. More than 0.5 secs of jitter');
        disp('Clip them again precisely at both ends and try again.');
        return
    else
        %both datasets are clipped and joined precisely enough! proceed now.
        dmag.time = dmag.sectime - dmag.sectime(1,1);
    end    
    last_edge_imag = 1;
    last_edge_itrack = 1;
    cur_index = 0;
    last_edge_time = 0;
    vel_ind = 1;
    while(1)
        edge_found = 0;
        %detect next edge in magnets excitation
        %magnitude threshold = 0.01
        %temporal threshold  = 1 sec
        while(~edge_found & cur_index < length(dmag.analogs))
            cur_index = cur_index + 1;
            temp = abs(dmag.analogs(cur_index,:) - dmag.analogs(last_edge_imag,:));
            if(max(temp)>0.01)
                if(dmag.time(cur_index,1) - last_edge_time > 1)
                    new_edge_time = dmag.time(cur_index,1);
                    new_edge_imag = cur_index;
                    edge_found = 1;
                end
            end
        end
        %Exit if we have gone thorough the whole dataset
        if(cur_index >= length(dmag.analogs))
            break;
        end
        %new edge found! compute velocity between last edge and this edge
        new_edge_itrack = max(find(mstage.time <= new_edge_time));
        window.x = -mstage.x(last_edge_itrack : new_edge_itrack);
        window.y = -mstage.y(last_edge_itrack : new_edge_itrack);
        window.z = -mstage.z(last_edge_itrack : new_edge_itrack);
        window.time = mstage.time(last_edge_itrack : new_edge_itrack) - mstage.time(last_edge_itrack);
        
        velx = polyfit(window.time, window.x,1);
        vely = polyfit(window.time, window.y,1);
        velz = polyfit(window.time, window.z,1);
        
        data.time(vel_ind,1) = 0.5*(window.time(1) + window.time(end));
        data.velx(vel_ind,1) = velx(1,1);
        data.vely(vel_ind,1) = vely(1,1);            
        data.velz(vel_ind,1) = velz(1,1);
        vel_ind = vel_ind + 1;
        last_edge_imag = new_edge_imag;
        last_edge_itrack = new_edge_itrack;
        last_edge_time = new_edge_time;        
    end
%----velocity computation for continuous mode    
elseif(strcmpi(calc_mode,'continuous'))
    if(filter)
        %form  a filter according to time_step selected
        sampPsec = length(mstage.time)/(mstage.time(end)-mstage.time(1));
        winlen = round(sampPsec*block);
        myfilter = 1/winlen*ones(winlen,1); 
        dt = diff(mstage.time);
        dx = -diff(mstage.x);
        dy = -diff(mstage.y);
        dz = -diff(mstage.z);
        %remove un-valid data points from the dataset before proceeding
        indt = isnan(dt)| (dt == 0);
        id = 1;
        ndx = dx; ndt = dt; ndy = dy; ndz = dz;
        
        for k= 1:length(dt)
            if(indt(k,1) == 0)
                ndt(id,1) = dt(k,1);
                ndx(id,1) = dx(k,1);
                ndy(id,1) = dy(k,1);
                ndz(id,1) = dz(k,1);
                id = id+1;			
            end
        end
        %un-valid data points removed - process the data now
        data.velx = resample(conv((ndx./ndt),myfilter),1,200);
        data.vely = resample(conv((ndy./ndt),myfilter),1,200);
        data.velz = resample(conv((ndz./ndt),myfilter),1,200);
    else % d0 not filter the data
        t_old = 0;
        zer = 1;
        t_end = mstage.time(end,1);
        j = 1;
        
        while t_old + block < t_end            
            i = find(mstage.time >= t_old + block);
            i = min(i);
            
            temp.time = mstage.time(zer:1:i,1)- mstage.time(zer);        
            temp.posx = -mstage.x(zer:1:i,1); %conversion from stage space to bead space.
            temp.posy = -mstage.y(zer:1:i,1);
            temp.posz = -mstage.z(zer:1:i,1);
            
            velx = polyfit(temp.time, temp.posx,1);
            vely = polyfit(temp.time, temp.posy,1);
            velz = polyfit(temp.time, temp.posz,1);
            
            data.time(j,1) = temp.time(round((i-zer+1)/2),1);
            data.velx(j,1) = velx(1,1);
            data.vely(j,1) = vely(1,1);            
            data.velz(j,1) = velz(1,1);
            j = j+1;
            zer = i;
            t_old = mstage.time(i,1);
        end
    end
else
    disp('Unvalid calculation mode: Usage - ''discrete''|''continous''');
    return;
end    
data.info = dtrack.info;
data.info.vel.calc_mode = calc_mode;
data.info.vel.filter = filter;
data.info.vel.time_step = tstep;
return;
% --------------------------------------------------------------------
function setDriftData(h,d,dr_start,dr_end)

dr_istart = min(find(d.stage.time >= dr_start));
dr_iend = max(find(d.stage.time <= dr_end));

ddrift.info.orig = d.info.orig;
ddrift.info.drift.dr_tstart = dr_start;
ddrift.info.drift.dr_tend = dr_end;
ddrift.info.drift.dr_istart = dr_istart;
ddrift.info.drift.dr_iend = dr_iend;

temp_t = d.stage.time(dr_istart:dr_iend);
temp_t = temp_t - temp_t(1,1);
x = d.stage.x(dr_istart:dr_iend);
y = d.stage.y(dr_istart:dr_iend);
z = d.stage.z(dr_istart:dr_iend);	

ddrift.back_vx = polyfit(temp_t, x, 1);
ddrift.back_vx(1,2) = 0; %store just the slope and not intercept
ddrift.back_vy = polyfit(temp_t, y, 1);
ddrift.back_vy(1,2) = 0; 
ddrift.back_vz = polyfit(temp_t, z, 1);
ddrift.back_vz(1,2) = 0;
set(h,'UserData',ddrift);

return;
 
% --------------------------------------------------------------------
function nodrift = subtractDrift(handles,d)
ddrift = get(handles.text_driftData,'Userdata');
if(isempty(ddrift))
    prompt(handles,'No drift subtracted: check limits for drift data.','r');
    nodrift = d;
    return;
end
nodrift.info.orig = d.info.orig;
nodrift.info.drift = ddrift.info.drift;
if(isfield(d.info,'clip'));
    nodrift.info.clip = d.info.clip;
end
d.stage.time = d.stage.time - d.stage.time(1,1);
px = polyval(ddrift.back_vx,d.stage.time);
py = polyval(ddrift.back_vy,d.stage.time);
pz = polyval(ddrift.back_vz,d.stage.time);

nodrift.stage.time = d.stage.time;
nodrift.stage.x = d.stage.x - px;
nodrift.stage.y = d.stage.y - py;
nodrift.stage.z = d.stage.z - pz;

return;

% --------------------------------------------------------------------
function clipped = giveClipped(handles,d)

clipped.info.orig = d.info.orig;
tstart = str2double(get(handles.edit_trackingStart,'string'));
tend = str2double(get(handles.edit_trackingEnd,'string'));
istart = max(find(d.stage.time <= tstart));
iend = max(find(d.stage.time <= tend));
if(istart >= iend)
    prompt(handles,'No clipping performed: check tracking limits','r');
    clipped = d;
    return;
end

if(isfield(d.info,'drift'));
    clipped.info.drift = d.info.drift;
end

clipped.info.clip.tstart = tstart;
clipped.info.clip.tend = tend;
clipped.info.clip.istart = istart;
clipped.info.clip.iend = iend;

clipped.stage.time = d.stage.time(istart:iend) - d.stage.time(istart);
clipped.stage.x = d.stage.x(istart:iend);
clipped.stage.y = d.stage.y(istart:iend);
clipped.stage.z = d.stage.z(istart:iend);

return;

% --------------------------------------------------------------------
function checkVal(h, handles, min, max)
user_entry = get(h,'string');
value = str2double(user_entry);
if isnan(value)
    errordlg('You must enter a numeric value','Bad Input','modal')
end
if (value <= max & value >= min) % not out of bounds
    set(h,'string',num2str(value));
else
    errordlg(['You must enter a numeric value between ',num2str(min),' and ',num2str(max)],'Bad Input','modal')
end


% --------------------------------------------------------------------
function check_editval(h,h_slider)
% Checks whether the value entered in "edit" object (h)is compatible to the
% corresponding slider object (h_slider) settings
user_entry = get(h,'string');
value = str2double(user_entry);
if isnan(value)
    errordlg('You must enter a numeric value','Bad Input','modal')
end
max = get(h_slider,'Max');
min = get(h_slider,'Min');
if (value > max | value < min) % out of bounds
    value = get(h_slider,'value');  % set the last value
    set(h,'string',num2str(value));
    errordlg(['You must enter a numeric value between ',num2str(min),' and ',num2str(max)],'Bad Input','modal')
else
    set(h_slider,'Value', value);
end

% --------------------------------------------------------------------
function prompt(handles, message, color)
disp(message);




