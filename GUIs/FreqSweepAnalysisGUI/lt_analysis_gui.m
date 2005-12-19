function varargout = lt_analysis_gui(varargin)
% LT_ANALYSIS_GUI M-file for lt_analysis_gui.fig
%      LT_ANALYSIS_GUI, by itself, creates a new LT_ANALYSIS_GUI or raises the existing
%      singleton*.
%
%      H = LT_ANALYSIS_GUI returns the handle to a new LT_ANALYSIS_GUI or the handle to
%      the existing singleton*.
%
%      LT_ANALYSIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LT_ANALYSIS_GUI.M with the given input arguments.
%
%      LT_ANALYSIS_GUI('Property','Value',...) creates a new LT_ANALYSIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lt_analysis_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lt_analysis_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lt_analysis_gui

% Last Modified by GUIDE v2.5 16-Dec-2005 12:54:56
% % NOTES FOR PROGRAMMER: 
%  - add/load button adds new files into the database. Doesn't replace any files. 
%    if the requested file exists in the database already, then it skips loading that file and  warns user.
%  - Any file that is loaded in the database, is displayed with full name + tag in the file selection menu;
%  and only tag in the tag list. 
%  - Removing a file from the database removes it from the taglist and from the selection menu.
     
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lt_analysis_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @lt_analysis_gui_OutputFcn, ...
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


% --- Executes just before lt_analysis_gui is made visible.
function lt_analysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global g
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lt_analysis_gui (see VARARGIN)

% Choose default command line output for lt_analysis_gui
handles.output = hObject;
% a signature storing the names of the fields in global structure
handles.dmnptue = {'data','magnets','name','path','tag','usermetadata','experType'};
% NOTE: if change any of the strings above, also change the field name
% to reflect the initials.
% Update handles structure
handles.default_path = pwd;
set(handles.button_add,'UserData',handles.default_path); 

% Names of signals in the structure output by load_laser_tracking
handles.signames.intr = {'beadpos' ,'stageReport','qpd','laser'};
% Names of signals to be displayed on GUI control menu_signal
handles.signames.disp = {'Bead Pos','Stage Pos'  ,'QPD','Channel 8'};
% Figure numbers allocated to 'main-figures' for various signals
handles.mainfigids =      [   1,          2,          3,         4];

% Some other figure numbers allocated to specific types of plot
handles.threeDfig = 9;
handles.psdfig = 10; % psd
                % 10 = r, 11 = x, 12 = y, 13 = z;
handles.dvsffig = 20; % accumulated displacement 
handles.frespfig = 30; % frequency response (only FSweep experiments)
handles.boxresfig = 1000;
%  ....add to this list as more types of plots are supported
% Some other constants
handles.srate = 10000;
handles.psdwin = 'blackman';
handles.emptyflag_str = 'Database is empty';

% initialize the global structure
for c = 1:length(handles.dmnptue)
    g.(handles.dmnptue{c}) = {};
end

guidata(hObject, handles);
% UIWAIT makes lt_analysis_gui wait for user response (see UIRESUME)
% uiwait(handles.GUI);


% --- Outputs from this function are returned to the command line.
function varargout = lt_analysis_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%% $$$$$$$$$$$$$$$$$$$       CALLBACKS     $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% --- Executes on button press in button_add.
function button_add_Callback(hObject, eventdata, handles)
global g % using global (as oppose to 'UserData') prevents creating multiple copies
switch get(handles.menu_exper,'value')
    case 1 %Passive Diffusion   
        fieldstr = 'b';
    case 2 %Pulling + Diffusion
        fieldstr = 'lb';
    case 3 %Discrete Freqeuncy Sweep
        fieldstr = 'lb';        
    case 4 %Noise (QPD+laser)
        fieldstr = 'lq';
    case 5 %Noise (Stage only)
        fieldstr = 's';
    case 6 % All fields
        fieldstr = 'a';
    otherwise
        prompt_user('Error: Unrecognized experiment type');
end
if (get(hObject,'UserData') ~= 0)      
    [f, p] = uigetfiles('*.mat','Browse and select one or more files',get(hObject,'UserData'));
else
    [f, p] = uigetfiles('*.mat','Browse and select one or more files',handles.default_path);
end
set(hObject,'UserData',p);
prompt_user('Wait...Loading selected files',handles);
flags.keepuct = 0; flags.keepoffset = 0; flags.askforinput = 0;flags.inmicrons = 1;
nloaded = 0;
for(c = 1:length(f))
    pack
    if exist('g') & ~isempty(g.(handles.dmnptue{1})) & any(strcmp(g.(handles.dmnptue{3}),f{c}) == 1)
        prompt_user(['The file ',f{c},' is already in the database.']);                
    else
        prompt_user(['...currently loading ','[',num2str(c),'of',num2str(length(f)),'] :',f{c}],handles);
        
        %put newly added dataset on the top of the list
        %shift all existing datasets down by one
        if (exist('g') & ~isempty(g.(handles.dmnptue{1})))
            for cf = 1:length(handles.dmnptue) 
                g.(handles.dmnptue{cf}) = [ {0}, g.(handles.dmnptue{cf})];
            end
        end
        %Make the cell arrays in the form of 1xN, and keep that form as the
        %standard. Nx1 standardization would work as well, but it seems my matlab
        %is creating arrays in the form of 1xN by default.
        try
            % load only bead positions and laser intensity values
            g.(handles.dmnptue{1}){1,1} = load_laser_tracking(fullfile(p,f{c}),fieldstr,flags);
            % fullfile usage is handy and protects code against platform variations
            g.(handles.dmnptue{2}){1,1} = {}; %start out with empty magnet data
            g.(handles.dmnptue{3}){1,1} = f{c}; %file name
            g.(handles.dmnptue{4}){1,1} = p; %file path
            g.(handles.dmnptue{5}){1,1} = 'NoTag'; %tag
            g.(handles.dmnptue{6}){1,1} = 'NoMetaData'; %user specified metadata 
                expTypes = get(handles.menu_exper,'String'); % experiment types
            g.(handles.dmnptue{7}){1,1} = expTypes{get(handles.menu_exper,'value')}; 
            
            prompt_user([f{c}, ' added to the database.'],handles);
            nloaded = nloaded + 1; %total files loaded
        catch
            prompt_user(lasterr);
            prompt_user([f{c}, ' could not be added to the database.'],handles);
            % shift back every field up by one
            if(exist('g') & ~isempty(g.(handles.dmnptue{1})))
                for cf = 1:length(handles.dmnptue)                    
                    g.(handles.dmnptue{cf}) = g.(handles.dmnptue{cf})(2:end); 
                end                 
            end
%             updatetaglist(handles);
            break;
        end
%         updatetaglist(handles);
    end
end
% set(hObject,'UserData', g); %use global instead
updatemenu(handles);
prompt_user(['Finished Loading. Loaded ',num2str(nloaded),' files']);

% --- Executes on button press in button_remove
function button_remove_Callback(hObject, eventdata, handles)
global g
[selec,ok] = listdlg('ListString',get(handles.menu_files,'String'),...
                    'OKstring','Remove',...
                    'Name','Select file(s) to be removed');
for c=1:length(selec)
    for cf = 1:length(handles.dmnptue) %delete all fields for that file id
        g.(handles.dmnptue{cf}){1,selec(c)} = {};
    end
end
% keyboard
% Now remove the empty cells from each field
for cf = 1:length(handles.dmnptue) 
    ifilled = ~cellfun('isempty',g.(handles.dmnptue{cf}));
    g.(handles.dmnptue{cf}) = g.(handles.dmnptue{cf})(ifilled); 
end
% updatetaglist(handles);
updatemenu(handles);
prompt_user([num2str(length(selec)),' files were removed from the database.'],handles);

% --- Executes on selection change in menu_files.
function menu_files_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns menu_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_files
updatesignalmenu(handles);% this will also refresh the main figure

% --- Executes on button press in button_tag.
function button_tag_Callback(hObject, eventdata, handles)
global g
% Note: Multiple tags of same string are acceptable for now.
% I need to fix this later. Also initiate the tags with "NoTag1", "NoTag2"
% etc, instead of just "NoTag".
id = get(handles.menu_files,'Value');
contents = get(handles.menu_files,'string');
prompt = {'Short tag (e.g. to be used as a legend entry in a plot) for this file',...
        'Metadata to be associated with this file'};
dlg_title = ['Edit metadata:',contents{id}];
num_lines= [1;2];
% plot_selected(id);
userinput = inputdlg(prompt,dlg_title,num_lines,...
    {g.(handles.dmnptue{5}){1,id}, g.(handles.dmnptue{6}){1,id}});
if (~isempty(userinput))
    g.(handles.dmnptue{5}){1,id} = userinput{1};
    g.(handles.dmnptue{6}){1,id} = userinput{2};
end
updatefilemenu(handles);

% --- Executes on button press in button_clip.
function button_clip_Callback(hObject, eventdata, handles)%XXX
global g
if ~exist('g') | isempty(g.(handles.dmnptue{1}))
    errordlg('Database is empty, first add files to it','Error');
    return;
end
% check if the main figure is plotted and in focus
if (0 == figflag(getmainfigname(handles)))
   updatemainfig(handles,'new'); 
end
hf = gcf; ha = gca;

[t(1),y] = ginput(1);
drawlines(ha,t(1));
[t(2),y] = ginput(1);
drawlines(ha,t(2));

t = sort(t);
% Clip all the fields existing in the current file
id = get(handles.menu_files,'Value');
for c = 1:length(handles.signames.intr)
    cursig = handles.signames.intr{c};
    if (isfield(g.(handles.dmnptue{1}){1,id}, cursig))
        sigold = g.(handles.dmnptue{1}){1,id}.(cursig);
        g.(handles.dmnptue{1}){1,id}.(cursig) = [];
        istart = max(find(sigold.time <= t(1)));
        iend = max(find(sigold.time <= t(2)));
        
        g.(handles.dmnptue{1}){1,id}.(cursig).time = sigold.time(istart:iend);
        switch c
            case {1,2}                
                g.(handles.dmnptue{1}){1,id}.(cursig).x = sigold.x(istart:iend)
                g.(handles.dmnptue{1}){1,id}.(cursig).y = sigold.y(istart:iend)
                g.(handles.dmnptue{1}){1,id}.(cursig).z = sigold.z(istart:iend)  
            case 3
                g.(handles.dmnptue{1}){1,id}.(cursig).q1 = sigold.q1(istart:iend)
                g.(handles.dmnptue{1}){1,id}.(cursig).q2 = sigold.q2(istart:iend)
                g.(handles.dmnptue{1}){1,id}.(cursig).q3 = sigold.q3(istart:iend)
                g.(handles.dmnptue{1}){1,id}.(cursig).q4 = sigold.q4(istart:iend)
            case 4
                g.(handles.dmnptue{1}){1,id}.(cursig).intensity = sigold.intensity(istart:iend)                
        end
    end
end
updatemainfig(handles,'clip');
%-------------------------------------------------------------------------
% --- Executes on button press in check_psd.
function check_psd_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
    set(handles.check_cumdisp,'Value',0);
end
%-------------------------------------------------------------------------
% --- Executes on button press in check_cumdisp.
function check_cumdisp_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.check_psd,'Value',1);
end
%-------------------------------------------------------------------------
% --- Executes on button press in button_drawbox.
% Put the main figure in the focus and let user (re) draw a box by 
% dragging mouse.
function button_drawbox_Callback(hObject, eventdata, handles)
if (0 == figflag(getmainfigname(handles)))
   updatemainfig(handles,'new');
end
if get(handles.toggle_dragbox,'value')
    set(handles.toggle_dragbox,'value',0);
    set(handles.toggle_dragbox,'String','Drag Box');
end
hmf = get(handles.button_drawbox,'UserData');
% find the handle of the axes of the main figure
hma = findobj(hmf,'Type','axes','Tag','');%legend is the other axes with tag 'legend'

% delete the box that already exists
delete(findobj(hma,'Tag','Box'));
% axes(hma); % Make sure  main axes is in focus: NO DON'T DO THAT
% DOING THIS PUTS THE AXES ON THE FRONT, MAKSING THE LEGEND
%Now let the user draw the box.
waitforbuttonpress; 
point1 = get(hma,'CurrentPoint');    % button down detected
b.figbox = rbbox;                      % return figure units
point2 = get(hma,'CurrentPoint');    % button up detected

point1 = point1(1);              % extract x 
point2 = point2(1);
x1 = min(point1,point2);             % calculate locations
width = abs(point1-point2);         % and dimensions
ylims = get(hma,'Ylim');
b.dbox = [x1, ylims(1), width, ylims(2)-ylims(1)];
set(handles.toggle_dragbox,'UserData',b);
updatebox(handles,hma,0);
%-------------------------------------------------------------------------
% --- Executes on button press in toggle_dragbox.
function toggle_dragbox_Callback(hObject, eventdata, handles)

if get(hObject,'value')
    if (0 == figflag(getmainfigname(handles)))
        updatemainfig(handles,'new');
    end    
    hmf = get(handles.button_drawbox,'UserData');
    % find the handle of the axes of the main figure
    hma = findobj(hmf,'Type','axes','Tag','');%legend is the other axes with tag 'legend' 
    
    hbox = findobj(hma,'Tag','Box');
    if isempty(hbox)
        errordlg('First draw a box to be able to drag it.','Error');
        set(hObject,'value',0);
        return
    end
    set(hObject,'String','Stop dragging');
    b = get(hObject,'UserData'); %contains info about the box
    waitforbuttonpress; 
    while get(hObject,'value')        
        point1 = get(hma,'CurrentPoint');    % button down detected
        b.figbox = dragrect(b.figbox);              % return figure units
        point2 = get(hma,'CurrentPoint');    % button up detected
        point1 = point1(1);              % extract x 
        point2 = point2(1);       
        displace = point2-point1;
        updatebox(handles,hma,displace);
        waitforbuttonpress; 
    end
else
    set(hObject,'String','Drag Box');
end
%------------------------
function updatebox(handles,hma,displace);
b = get(handles.toggle_dragbox,'UserData');
if ~isempty(b)
    hbox = findobj(hma,'Tag','Box'); delete(hbox);
    ylims = get(hma,'Ylim');
    b.dbox(1) = b.dbox(1) + displace;
    b.dbox([2,4]) = [ylims(1) ,ylims(2) - ylims(1)];
    b.xlims = [b.dbox(1), b.dbox(1) + b.dbox(3)];
    hold on;
    hbox = rectangle('Position',b.dbox);
    set(hbox,'EdgeColor','r','Tag','Box','Linewidth',2,'LineStyle','-.');
    hold off;
    set(handles.toggle_dragbox,'UserData',b);
    updateboxresults(handles);
end
% --- Executes on selection change in menu_dispres.
function menu_dispres_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if isequal(val,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',val);%remember the last selection
updatemainfig(handles,'dispres');


% --- Executes on selection change in menu_signal.
function menu_signal_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
strs = get(hObject,'String');
TF = strcmp(handles.signames.disp,strs{val});
sigid = find(TF == 1);
if isequal(sigid,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',sigid);%remember the last selection
checkdimsvalidity(handles);
updatemainfig(handles,'quant');


% --- Executes on selection change in list_dims.
function list_dims_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if isequal(val,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',val);%remember the last selection
updatemainfig(handles,'dims');

% --- Executes on button press in button_addfsinfo.
function button_addfsinfo_Callback(hObject, eventdata, handles)

% --- Executes on button press in button_many.
function button_many_Callback(hObject, eventdata, handles)

% --- Executes on button press in check_fresponse.
function check_fresponse_Callback(hObject, eventdata, handles)
% --- Executes on button press in button_test.

function button_test_Callback(hObject, eventdata, handles)
global g
keyboard
% --- Executes on button press in button_export.
function button_export_Callback(hObject, eventdata, handles)

% --- Executes on button press in button_save.
function button_save_Callback(hObject, eventdata, handles)


%%%$$$$$$$$$$$$$$$$  NON-CALLBACK ROUTINES     $$$$$$$$$$$$$$$$$$$$$$$$
%-----------------------------------------------------------------------
function updateboxresults(handles)
global g
% keyboard
b = get(handles.toggle_dragbox,'UserData'); %has the xy location of box
% hmain  = get(handles.button_drawbox,'UserData');% current 'main' figure id
fileid = get(handles.menu_files,'Value');
sigid = get(handles.menu_signal,'UserData');% internal ID of currently selected signal.
sigval = g.(handles.dmnptue{1}){1,fileid}.(handles.signames.intr{sigid}); 

% Now grab the points that fall inside the box
istart = max(find(sigval.time <= b.xlims(1)));
iend = max(find(sigval.time <= b.xlims(2)));
tsel = sigval.time(istart:iend);
switch sigid
    case {1,2}
        selec(:,2) = sigval.x(istart:iend);
        selec(:,3) = sigval.y(istart:iend);
        selec(:,4) = sigval.z(istart:iend);
        selec(:,1) = sqrt(selec(:,1).^2 + selec(:,2).^2 + selec(:,3).^2);      
    case 3
        selec(:,1) = sigval.q1(istart:iend);
        selec(:,2) = sigval.q2(istart:iend);
        selec(:,3) = sigval.q3(istart:iend);
        selec(:,4) = sigval.q4(istart:iend);
    case 4
        selec = sigval.intensity(istart:iend);
end

% Now perform computations and make the result strings
str.trend = []; str.rms = []; str.p2p = []; tab = '    ';
sf = '%+05.3f';
if sigid == 1 | sigid ==2 %if the signal is a position measurement
    dims = get(handles.list_dims,'Value'); %selected dimensions
    strdims = get(handles.list_dims,'String');% all strings
    for c = 1:length(dims)
        [p s] = polyfit(tsel,selec(:,dims(c)),1);                
        detrend = selec(:,dims(c)) - polyval(p,tsel);
        str.trend = [str.trend,' (',strdims{dims(c)},') ', num2str(p(1),sf),tab];
        str.rms = [str.rms,' (', strdims{dims(c)}, ') ',num2str(rms(detrend),sf),tab];
        str.p2p = [str.p2p,' (', strdims{dims(c)}, ') ',num2str(range(detrend),sf),tab];                                
    end
else % Not a position measurement, so no extra labels for dimensions
    for c = 1:size(selec,2)
        [p s] = polyfit(tsel,selec(:,c),1);                
        detrend = selec(:,c) - polyval(p,tsel);
        str.trend = [str.trend, num2str(p(1),sf),tab];
        str.rms = [str.rms, num2str(rms(detrend),sf),tab];
        str.p2p = [str.p2p, num2str(range(detrend),sf),tab];    
    end
end
% Now print all this information on the separate figure
if (~ishandle(handles.boxresfig))
    initresultfig(handles.boxresfig);
end
figure(handles.boxresfig);
htext = get(handles.boxresfig,'UserData');
set(htext.trend,'String',['Avg Trend [dY/dX]: ',str.trend]);
set(htext.rms,'String',  ['Detrended RMS    : ',str.rms]);
set(htext.p2p,'String',  ['Detrended Range  : ',str.p2p]);
% disp('results updated');
%-----------------------------------------------------------------------
function initresultfig(h)
figure(h);	
% set(h,'DoubleBuffer', 'off', ...
%     'Position', [100 100 500 150], ...
%     'Resize', 'Off', ...
%     'MenuBar', 'none', ...
%     'NumberTitle', 'off', ...
%     'Name', 'BoxResults', ...
%     'Colormap', gray(256));
set(h,'DoubleBuffer', 'off');
% set(h,'Position', [100 100 500 150]);%throws out of screen
set(h,'Resize', 'On');
set(h,'MenuBar', 'none');
set(h,'NumberTitle', 'off');
set(h,'Name', 'BoxResults');

htext.trend = text(0.1,0.9,' ','FontSize',12);
htext.rms = text(0.1,0.7,' ', 'FontSize', 12);         
htext.p2p = text(0.1,0.5,' ','FontSize', 12); 
htext.units = text(0.1,0.1,'Units should be derived from units of X and Y axis','Fontsize',10);
axis off;
set(h, 'UserData', htext);
% disp('result figure initiated');    
%-----------------------------------------------------------------------
function checkdimsvalidity(handles)
val = get(handles.menu_signal,'Value');
if val == 1 | val == 2
    set(handles.list_dims,'Enable','On');
    set(handles.check_3d,'Enable','On');
else
    set(handles.list_dims,'Enable','Off');
    set(handles.check_3d,'Enable','Off');
end
%-----------------------------------------------------------------------
function prompt_user(str,handles)
% set(handles.text_message,'String',str);
disp(str);

%--------------makes the name string for edit figure -------------------
function str = getmainfigname(handles);
sigid = get(handles.menu_signal,'Value');
sigstr = get(handles.menu_signal,'String');
figid = get(handles.button_drawbox,'UserData');
str = [num2str(figid),':',sigstr{sigid}];
%-----------------------------------------------------------------------
%-----------------------------------------------------------------------
% make the matrices of signal values to be displayed
function [sigout, tout, annots] = fillsig(sigin,res,signame,handles)
if res == 0;
    tout = sigin.time;
else
    tout = [sigin.time(1):res:sigin.time(end)]';
end
switch signame
    case {handles.signames.intr{1},handles.signames.intr{2}} %bead and stage pos                   
        if res == 0
            temp(:,1) = sigin.x;
            temp(:,2) = sigin.y;
            temp(:,3) = sigin.z;
        else    % interpolate to the nearest neighbour, so no averaging artifacts
            temp(:,1) = interp1(sigin.time,sigin.x,tout,'nearest');
            temp(:,2) = interp1(sigin.time,sigin.y,tout,'nearest');
            temp(:,3) = interp1(sigin.time,sigin.z,tout,'nearest');
        end
        % now pick the only dimesions that are requested
        dims = get(handles.list_dims,'value');
        for c = 1:length(dims)
            switch dims(c)
                case 1 %R
                    sigout(:,c) = sqrt(temp(:,1).^2 + temp(:,2).^2 + temp(:,3).^2);
                    annots.legstr{c} = 'R';
                    annots.colorOrder(c,:) = [0,0,0]; % R is always black
                case 2 %X
                    sigout(:,c) = temp(:,1);
                    annots.legstr{c} = 'X';
                    annots.colorOrder(c,:) = [0,0,1]; % X is always blule
                case 3 %Y
                    sigout(:,c) = temp(:,2);                    
                    annots.legstr{c} = 'Y';
                    annots.colorOrder(c,:) = [0,1,0]; % Y is always green          
                case 4 %Z
                    sigout(:,c) = temp(:,3);
                    annots.legstr{c} = 'Z';
                    annots.colorOrder(c,:) = [1,0,0]; % Z is always red             
                otherwise
                    prompt_user('Unrecognized dimension');
            end
        end
        annots.y = 'Microns';
        annots.x = 'Seconds';
        if isequal(signame,handles.signames.intr{1}) %if this is bead position
            annots.t = 'Bead Postion (relative to specimen)';
        else
            annots.t = 'Stage Postion (sensed)';
        end
    case handles.signames.intr{3} % qpd signals
        if rate == 0
            sigout(:,1) = sigin.q1;
            sigout(:,2) = sigin.q2;
            sigout(:,3) = sigin.q3;
            sigout(:,4) = sigin.q4;
        else
            sigout(:,1) = interp1(sigin.time,sigin.q1,tout,'nearest');
            sigout(:,2) = interp1(sigin.time,sigin.q2,tout,'nearest');
            sigout(:,3) = interp1(sigin.time,sigin.q3,tout,'nearest');
            sigout(:,4) = interp1(sigin.time,sigin.q4,tout,'nearest');
        end
        annots.legstr = {'Q1','Q2','Q3','Q4'};
        annots.colorOrder = [0 0 1; 0 1 0; 1 0 0; 0 0 0];
        annots.y = 'Volts';
        annots.x = 'Seconds';
        annots.t = 'QPD Signals';        
    case handles.signames.intr{4} %channel 8 
        if rate == 0
            sigout(:,1) = sigin.intensity;            
        else
            sigout(:,1) = interp1(sigin.time,sigin.intensity,tout,'nearest');            
        end
        annots.legstr = {'Ch 8'};
        annots.colorOrder = [0 0 1];
        annots.y = 'Volts';
        annots.x = 'Seconds';
        annots.t = 'ADC channel 8 (laser intensity OR magnets)';
    otherwise
        prompt_user('Error: Unrecognized signalName');
end
%-----------------------------------------------------------------------

%-----------------------------------------------------------------------
function updatemainfig(handles,modestr)
global g
dbstop if error
if ~exist('g') | isempty(g.(handles.dmnptue{1}))
    % if dataset empty, close all main figures
    for c = 1:length(handles.mainfigids)
        if ishandle(handles.mainfigids(c))
            close(handles.mainfigids(c));
        end
    end
    return; 
end
get(handles.menu_signal,'String');
dispname = ans{get(handles.menu_signal,'val')};
sigid = get(handles.menu_signal,'UserData');
% sigid = find(strcmp(handles.signames.disp, dispname) == 1);
signame = handles.signames.intr{1,sigid};
figid = handles.mainfigids(sigid); %handle of the main figure
set(handles.button_drawbox,'UserData',figid);% share with others

if ishandle(figid) % if the figure is open,          
    dlinesh = findobj(figid,'Type','Line','Tag','data');    
    delete(dlinesh);
    figure(figid); hold on;
end

fileid = get(handles.menu_files,'value');
sigvals = g.(handles.dmnptue{1}){1,fileid}.(signame);
switch get(handles.menu_dispres,'value')
    case 1 % full or raw resolution
        [dispval tout annots] = fillsig(sigvals,0,signame,handles);
    case 2 % 1 ms resolution       
        [dispval tout annots] = fillsig(sigvals,1e-3,signame,handles);        
    case 3 % 10 ms resolution
        [dispval tout annots] = fillsig(sigvals,1e-2,signame,handles);
    otherwise
        prompt_user('Error: Unrecognized time resolution');
end
%now ready to plot the data
figure(figid);
% I prefer not to use gca and gcf, so that user accidentally clicking
% somewhere doesn't mess me up.
hma = findobj(figid,'Type','Axes','Tag','');
if isempty(hma) % if this is the very first time figure is plotted then axes won't exist
    % a cheap hacky work-around: make a fake axes and hold-off
    plot([0:10;0:10]);
    hma = findobj(figid,'Type','Axes','Tag','');
    hold off
end
set(hma,'colorOrder',annots.colorOrder,'NextPlot','replacechildren');
% so that each dimension has same color each time it is plotted.

plot(tout,dispval,'Tag','data'); % all lines will be tagged as 'data' lines
title(annots.t);
xlabel(annots.x);
ylabel(annots.y);
set(figid,'name',getmainfigname(handles),'NumberTitle','Off');
legend(hma,annots.legstr,0);

% Now remove the old box and redraw it according to new axis limits
axis(hma,'tight');
if findobj(hma,'Tag','Box')
    updatebox(handles,hma,0);
end
dbclear if error
%-----------------------------------------------------------------------
% This routine updates two menus: menu_files and menu_signal
function updatemenu(handles)
updatefilemenu(handles);
updatesignalmenu(handles);
%-----------------------------------------------------------------------
% This routine updates file menu
function updatefilemenu(handles)
global g
if ~exist('g') | isempty(g.(handles.dmnptue{1})) %database is empty
    filestr = {''};        
    set(handles.menu_files,'String',filestr);
    set(handles.menu_files,'value',1);    
    return;
end
% Now fill in the tag-attached fileNames in the menu_files
% Leave the 'selected' pointer for the menu unchanged; unless
% it points to the index outside the new size of the menu, in 
% which case reset the pointer to point to one - point to first file.
for c=1:length(g.(handles.dmnptue{3}))
    filestr{1,c} = ['[',g.(handles.dmnptue{5}){1,c},']  ',g.(handles.dmnptue{3}){1,c}];
end
set(handles.menu_files,'String',filestr);
if get(handles.menu_files,'Value') > length(get(handles.menu_files,'String'))
    set(handles.menu_files,'Value',1);
end
%-----------------------------------------------------------------------
% This routine updates signal menu
function updatesignalmenu(handles)
global g
if ~exist('g') | isempty(g.(handles.dmnptue{1})) %database is empty     
    set(handles.menu_signal,'String',{''});
    set(handles.menu_signal,'value',1);    
    return;
end
% Now fill in the permitted signal types in the menu_signal.
% Set the selected 'signal-type' to the last value, unless
% that type is not present in the newly loaded file; in
% which case select first available signal type.
last_sigid = get(handles.menu_signal,'UserData');%could be empty
sigid = -1; %impossible value;
k = 0;
val = get(handles.menu_files,'Value');
for c=1:size(handles.signames.intr,2) %check for each possible signal name
    % if a field with the 'internal name' for this signal type is present in the 
    % currently selected file,
    % then put the associated 'display name' in the string-set for menu_signal.
    if isfield(g.(handles.dmnptue{1}){1,val},handles.signames.intr{1,c})
        k = k+1;
        sigstr{1,k} = handles.signames.disp{1,c};
        if c == last_sigid %the last selected signal is also present in this file
            sigid = c; %then, the sigid remains unchanged
        end
    end
end
if k == 0% none of the recognized signals are present (shouldn't happen)
    prompt_user('Error: Selected file has none of the recognized signal types');
    keyboard
    return;
end
set(handles.menu_signal,'String',sigstr);
% Now determine if sigid needs to be changed
% Also, set the value of the menu_signal accordingly
if sigid > 0    % sigid is valid and doesn't need to be changed.
    TF = strcmp(sigstr,handles.signames.disp{sigid});
    set(handles.menu_signal,'Value',find(TF==1));   
else
    set(handles.menu_signal,'Value',1);
    TF = strcmp(handles.signames.disp,sigstr{1});
    sigid = find(TF==1);    
end
set(handles.menu_signal,'UserData',sigid);%share sigid with others
checkdimsvalidity(handles);
updatemainfig(handles,'new');

%%%********************************************************************
%%%**********     ALL BELOW IS NEEDED BUT NOT-USED     ****************
%%%********************************************************************




























% --- Executes during object creation, after setting all properties.
function menu_files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function list_tags_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_tags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function list_dims_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_dims (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function menu_exper_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_exper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function menu_signal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_signal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.
function menu_dispres_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_dispres (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in menu_exper.
function menu_exper_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menu_exper contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_exper

%888888888888888%888888888888888%888888888888888%888888888888888
%888888888888888   ALL BELOW IS DEPRECATED      %888888888888888
%888888888888888%888888888888888%888888888888888%888888888888888
% --- Executes on button press in button_plot.
function button_plot_Callback(hObject, eventdata, handles)
global g
dbstop if error
alltags = get(handles.list_tags,'String');
ids = get(handles.list_tags,'Value');
dims = get(handles.list_dims,'value');
strdim = get(handles.list_dims,'String');    
colrs = 'bgrkym';

%%=========== COMPUTE AND PLOT PSD + CUMULATIVE DISTANCE ===============
if get(handles.check_bead,'value')
    if get(handles.check_psd,'Value')
        % set up all figures
        for c = 1:length(dims)
            figure(handles.psdfig + c - 1); clf;
            title(['Bead PSD: ',strdim{dims(c)}]);
            ylabel('Micron^2/Hz');
            hold on;
            if get(handles.check_cumdisp,'value')
                figure(handles.dvsffig + c - 1); clf;
                title(['Bead Cumulative Displacement: ',strdim{dims(c)}]);
                ylabel('Micron');
                hold on;
            end
            
        end        
        for c = 1:length(ids)        
            bp = g.(handles.dmnptue{1}){1,ids(c)}.beadpos;
            srate = handles.srate; %reset sample rate if changed by previous file
            if (range(diff(bp.time)) > 1e-6)            
                fnames = get(handles.menu_files,'String');            
                prompt_user(['UnEven TimeStamps: ',fnames{ids(c)}]);
                srate = srate*0.1;
                prompt_user(['I will resample this file at ',num2str(srate),' Hz']);            
                t = [bp.time(1):1/srate:bp.time(end)]';
                x = interp1(bp.time,bp.x,t);
                y = interp1(bp.time,bp.y,t);
                z = interp1(bp.time,bp.z,t);
                bp = [];            
                [bp.time bp.x bp.y bp.z] = deal(t, x, y, z);
            end
            bp.x = bp.x - mean(bp.x);
            bp.y = bp.y - mean(bp.y);
            bp.z = bp.z - mean(bp.z);
            psdres = 10/range(bp.time);
            for cd = 1:length(dims)
                switch strdim{dims(cd)}
                    case strdim{1}
                        bp.r = sqrt(bp.x.^2 + bp.y.^2 + bp.z.^2);
                        bp.r = bp.r - mean(bp.r);
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(bp.r,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffig + 1 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(bp.r,srate,psdres);
                        end
                        figure(handles.psdfig + 1 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            set(gca,'Xscale','Log','Yscale','Log');
                            hold off;
                        end
                    case strdim{2}
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(bp.x,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffig + 2 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(bp.x,srate,psdres);
                        end
                        figure(handles.psdfig + 2 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            set(gca,'Xscale','Log','Yscale','Log');
                            hold off;
                        end
                    case strdim{3}
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(bp.y,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffig + 3 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(bp.y,srate,psdres);
                        end
                        figure(handles.psdfig + 3 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            set(gca,'Xscale','Log','Yscale','Log');
                            hold off;
                        end
                    case strdim{4}
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(bp.z,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffig + 4 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(bp.z,srate,psdres);
                        end
                        figure(handles.psdfig + 4 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            hold off;
                            set(gca,'Xscale','Log','Yscale','Log');
                        end
                    otherwise
                        prompt_user('Unrecognized type (not among r,x,y,z) for psd calculation');
                end
            end
        end    
    end
    %% ==================   PLOT 3D TRACE   =====================
    if get(handles.check_3d,'Value')
        figure(handles.threeDfig);    
        for c = 1:length(ids)        
            bp = g.(handles.dmnptue{1}){1,ids(c)}.beadpos;
            bp.x = bp.x - bp.x(1,1);
            bp.y = bp.y - bp.y(1,1);
            bp.z = bp.z - bp.z(1,1);
            bp = interpXYZpos(bp,1/100);
            plot3(bp.x,bp.y,bp.z,colrs(mod(c-1,length(colrs))+1));
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            title(g.(handles.dmnptue{5}){1,ids(c)});
            pretty_plot;
        end
    end
    %% ==================   PLOT TIME-DOMAIN XYZ TRACES   =====================
    if get(handles.check_T1ms,'value')
        figure(handles.T1msfig);    
        for c = 1:1 %plot this for the first tag only        
            bp = g.(handles.dmnptue{1}){1,ids(c)}.beadpos;
            bp = interpXYZpos(bp,1/1000);
            plot(bp.time,[bp.x,bp.y,bp.z]);
            xlabel('Seconds');
            ylabel('Microns');
            title(g.(handles.dmnptue{5}){1,ids(c)});
            legend('X','Y','Z');
            pretty_plot;
        end        
    end
    if get(handles.check_T10ms,'value')
        figure(handles.T10msfig);    
        for c = 1:1 %plot this for the first tag only     
            bp = g.(handles.dmnptue{1}){1,ids(c)}.beadpos;
            bp = interpXYZpos(bp,1/100);
            plot(bp.time,[bp.x,bp.y,bp.z]);
            xlabel('Seconds');
            ylabel('Microns');
            title(g.(handles.dmnptue{5}){1,ids(c)});
            legend('X','Y','Z');
            pretty_plot;
        end        
    end
end
%%=========== stage: COMPUTE AND PLOT PSD + CUMULATIVE DISTANCE ===============
if get(handles.check_stage,'value')
    if get(handles.check_psd,'Value')
        % set up all figures
        for c = 1:length(dims)
            figure(handles.psdfigS + c - 1); clf;
            title(['Stage PSD: ',strdim{dims(c)}]);
            ylabel('Micron^2/Hz');
            hold on;
            if get(handles.check_cumdisp,'value')
                figure(handles.dvsffigS + c - 1); clf;
                title(['Stage Cumulative Displacement: ',strdim{dims(c)}]);
                ylabel('Micron');
                hold on;
            end
            
        end        
        for c = 1:length(ids)        
            sp = g.(handles.dmnptue{1}){1,ids(c)}.stageReport;
            srate = handles.srate; %reset sample rate if changed by previous file
            if (range(diff(sp.time)) > 1e-6)            
                fnames = get(handles.menu_files,'String');            
                prompt_user(['UnEven TimeStamps: ',fnames{ids(c)}]);
                srate = srate*0.1;
                prompt_user(['I will resample this file at ',num2str(srate),' Hz']);            
                t = [sp.time(1):1/srate:sp.time(end)]';
                x = interp1(sp.time,sp.x,t);
                y = interp1(sp.time,sp.y,t);
                z = interp1(sp.time,sp.z,t);
                sp = [];            
                [sp.time sp.x sp.y sp.z] = deal(t, x, y, z);
            end
            sp.x = sp.x - mean(sp.x);
            sp.y = sp.y - mean(sp.y);
            sp.z = sp.z - mean(sp.z);
            psdres = 10/range(sp.time);
            for cd = 1:length(dims)
                switch strdim{dims(cd)}
                    case strdim{1}
                        sp.r = sqrt(sp.x.^2 + sp.y.^2 + sp.z.^2);
                        sp.r = sp.r - mean(sp.r);
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(sp.r,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffigS + 1 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(sp.r,srate,psdres);
                        end
                        figure(handles.psdfigS + 1 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            set(gca,'Xscale','Log','Yscale','Log');
                            hold off;
                        end
                    case strdim{2}
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(sp.x,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffigS + 2 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(sp.x,srate,psdres);
                        end
                        figure(handles.psdfigS + 2 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            set(gca,'Xscale','Log','Yscale','Log');
                            hold off;
                        end
                    case strdim{3}
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(sp.y,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffigS + 3 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(sp.y,srate,psdres);
                        end
                        figure(handles.psdfigS + 3 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            set(gca,'Xscale','Log','Yscale','Log');
                            hold off;
                        end
                    case strdim{4}
                        if get(handles.check_cumdisp,'Value')
                            [p f Id] = mypsd(sp.z,srate,psdres,handles.psdwin,[],'yes');
                            figure(handles.dvsffigS + 4 -1);           
                            semilogx(f,Id,['.-',colrs(mod(c-1,length(colrs))+1)]);
                            if (c == length(ids))% if this is last file
                                legend(gca,alltags{ids});
                                set(gca,'Xscale','Log','Yscale','Linear');
                                hold off;
                            end
                        else
                            [p f] = mypsd(sp.z,srate,psdres);
                        end
                        figure(handles.psdfigS + 4 -1);           
                        loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                        if (c == length(ids))% if this is last file
                            legend(gca,alltags{ids});
                            hold off;
                            set(gca,'Xscale','Log','Yscale','Log');
                        end
                    otherwise
                        prompt_user('Unrecognized type (not among r,x,y,z) for psd calculation');
                end
            end
        end    
    end
    %% ==================   PLOT 3D TRACE   =====================
    if get(handles.check_3d,'Value')
        figure(handles.threeDfigS);    
        for c = 1:length(ids)        
            sp = g.(handles.dmnptue{1}){1,ids(c)}.stageReport;
            sp.x = sp.x - sp.x(1,1);
            sp.y = sp.y - sp.y(1,1);
            sp.z = sp.z - sp.z(1,1);        
            plot3(sp.x,sp.y,sp.z,colrs(mod(c-1,length(colrs))+1));
        end
    end
end
% keyboard
dbclear if error


% --- Executes on selection change in list_tags.
function list_tags_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns list_tags contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_tags

% --- Executes on button press in button_preview.
function button_preview_Callback(hObject, eventdata, handles)
global g
if ~exist('g') | isempty(g.(handles.dmnptue{1}))
    prompt_user('No file exists in the database');
    return;
end
id = get(handles.menu_files,'Value');
bp = g.(handles.dmnptue{1}){1,id}.beadpos;
figure(handles.mainfig); clf; ha = gca; hf = gcf;
set(hf,'name',getfocusfigname(handles),'NumberTitle','Off');
plot(bp.time, [bp.x,bp.y,bp.z]); 
hold on;
lims = get(ha,'Ylim');
[scale, imax] = max(abs(lims)); scale = scale*scale/lims(imax(1));
% laser = g.(handles.dmnptue{1}){1,id}.laser;
dt = diff(bp.time);
flag = zeros(size(bp.time));
% flag all time stamps that were not within +/-0.01us allowance from 100us
flag(find(abs(dt - 1e-4) > 1e-8)) = 0.5*scale;
axes(ha);
plot(bp.time, flag,'k');
hold off;
legend('X','Y','Z','Interval');
ylabel('Microns (no units for black line)');
xlabel('Seconds');
%-----------------------------------------------------------------------
function updatetaglist(handles)
global g
if exist('g') & ~isempty(g.(handles.dmnptue{1}));
    set(handles.list_tags,'String',g.(handles.dmnptue{5}));
else
    set(handles.list_tags,'String','');
end
val = get(handles.list_tags,'value');
if any(val > length(get(handles.list_tags,'String')))
    set(handles.list_tags,'value',length(handles.list_tags));
end
%%%####################################################################
%%%#############    GUIDE WILL ADD NEW CALLBACKS BELOW      ###########
%%%####################################################################
