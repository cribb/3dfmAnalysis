function varargout = lt_analysis_gui(varargin)
% LT_ANALYSIS_ltaGUI M-file for lt_analysis_ltagui.fig
%      LT_ANALYSIS_ltaGUI, by itself, creates a new LT_ANALYSIS_ltaGUI or raises the existing
%      singleton*.
%
%      H = LT_ANALYSIS_ltaGUI returns the handle to a new LT_ANALYSIS_ltaGUI or the handle to
%      the existing singleton*.
%
%      LT_ANALYSIS_ltaGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LT_ANALYSIS_ltaGUI.M with the given input arguments.
%
%      LT_ANALYSIS_ltaGUI('Property','Value',...) creates a new LT_ANALYSIS_ltaGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the ltaGUI before lt_analysis_ltagui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lt_analysis_ltagui_OpeningFcn via varargin.
%
%      *See ltaGUI Options on GUIDE's Tools menu.  Choose "ltaGUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lt_analysis_ltagui

% Last Modified by GUIDE v2.5 15-Jun-2006 19:12:04
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


% --- Executes just before lt_analysis_ltagui is made visible.
function lt_analysis_gui_OpeningFcn(hObject, eventdata, handles, varargin)
global g
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lt_analysis_ltagui (see VARARGIN)

% Choose default command line output for lt_analysis_ltagui
handles.output = hObject;

% a list of fields in the global dataset, useful when an operation is to be
% performed in all the existing fields.
handles.gfields = {'data','magdata','fname','path','tag','metadata','drift','exptype'};
% NOTE: if change any of the strings above, also change the field name of
% g in the whole file, and vice versa.

handles.default_path = pwd;
set(handles.button_add,'UserData',handles.default_path); 

% Names of signals in the structure given by load_laser_tracking
% If we want to add a signal later, just change all the fields below (e.g
% siganmes.intr, signmaes.disp, posid, and all figids accordingly. Rest of
% the program *should* still work unchanged.
handles.signames.intr = {'beadpos' ,'stageReport','qpd','laser', 'posError'};
% Names of signals to be displayed on ltaGUI control menu_signal
handles.signames.disp = {'Probe Pos','Stage Pos' ,'QPD','Channel 8', 'Pos Error'};
handles.posid = [1, 2, 5]; %index of the signals which are position measurements
% Figure numbers allocated to 'main-figures' for various signals
handles.mainfigids =      [   1,          2,          3,         4,     5];
handles.psdfigids =       [  10,         20,         30,        40,     50];
handles.dvsffigids =  handles.psdfigids + 5;      % accumulated displacement 
handles.msdfigids = 60;
%  ....add to this list as more types of plots are supported

% Some other figure numbers allocated to specific types of plot
handles.threeDfig = 9;
handles.boxresfig = 99;
handles.specgramfigid = [110,   120,    130,    140,    150];
handles.tstackfigid = 160;
handles.stackfigidoff = 200;
%  ....add to this list as more types of plots are supported

% Some other constants
handles.srate = 10000;
handles.psdwin = 'blackman';
handles.emptyflag_str = 'Database is empty';

% initialize the global structure and placeholders
for c = 1:length(handles.gfields)
    g.(handles.gfields{c}) = {};
    if isequal(handles.gfields{c},'drift')
    % 'drift' field must be treated differenty because when initializing, we will assign 
    % values to individual field of drift structure (unlike the whole structure as in 'data')
    % . This causes a warning on matlab 7.04 R14SP2. "allowed structure assignment
    % to a non-empty non-structure to overwrite the previous value".
        for c = 1:length(handles.signames.intr)
            handles.ph.drift.(handles.signames.intr{c}) = 0;
        end
        handles.ph.drift = {handles.ph.drift};
    else
        handles.ph.(handles.gfields{c}) = {0};
    end
end

guidata(hObject, handles);
% UIWAIT makes lt_analysis_ltagui wait for user response (see UIRESUME)
% uiwait(handles.ltaGUI);

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
global g % using global (as oppose to 'UserData') prevents creating multiple copies and conserves memory
dbstop if error
allexptype = get(handles.menu_exper,'String');
curexptype = allexptype{get(handles.menu_exper,'value')};
% load only those fields which are pertinent to the selected experiment 
switch curexptype
    case allexptype{1} %Passive Diffusion   
        fieldstr = 'b';
    case allexptype{2} %Pulling + Diffusion
        fieldstr = 'lb';
    case allexptype{3} %Discrete Frequency Sweep
        fieldstr = 'lb';
    case allexptype{4} %Load (BeadPos & PosError)
        fieldstr = 'be';
    case allexptype{5} %Load (QPD & Channel 8)
        fieldstr = 'lq';
    case allexptype{6} %Load (Stage only)
        fieldstr = 's';
    case allexptype{7} %Load All fields
        fieldstr = 'a';
    otherwise
        prompt_user('Error: Unrecognized experiment type',handles);
end
% A cheap hacky fix to the bug where ltaGUI sometimes forgets the last path
if (get(hObject,'UserData') == 0),  set(hObject,'UserData',handles.default_path); end    

[f, p] = uigetfiles('*.mat','Browse and select one or more files',get(hObject,'UserData'));

set(hObject,'UserData',p); %memorize the last browsing path
prompt_user('Wait...Loading selected files',handles);
amibusy(1,handles);
flags.keepuct = 0; flags.keepoffset = 0; flags.askforinput = 0;flags.inmicrons = 1;
flags.filterstage = get(handles.check_filterMCL,'value'); % Lowpass Filter stage-sensed values with 600Hz cutoff?
flags.matoutput = 1; %request output fields in the [time vals] matrix form.
nloaded = 0;
for(c = 1:length(f))
    pack
    doload = 1;
    if exist('g') & ~isempty(g.data) & any(strcmp(g.fname,f{c}) == 1)
        isame = find(strcmp(g.fname,f{c}) == 1);
        if isequal(g.exptype{isame}, curexptype)
            button = questdlg(['The file ',f{c},' is already in the database. ',...
                'Reloading it will discard any modifications made to it ',...
                '(e.g. cut, drift selection, metadata etc). ','Continue?'],...
                'File already loaded','Yes','No','No');            
            if strcmpi(button,'no')
                doload = 0;
            else % Remove the old file from the data base
                remove_file(isame,handles);
            end
        else
            button = questdlg(['The file ',f{c},' already loaded with ',g.exptype{isame}, ' experiment type. ' ...
                'Should I re-load it with ', curexptype,' experiment type?'],...
                'File loaded with different experiment type','Yes','No','No');            
            if strcmpi(button,'no')
                doload = 0;
            else % remove the old file  from the database
                remove_file(isame,handles);
            end
        end
    end
    if doload
        prompt_user(['Currently loading ','[',num2str(c),'of',num2str(length(f)),'] :',f{c}],handles);
        
        %put newly added dataset on the top of the list
        %shift all existing datasets down by one
        if (exist('g') & ~isempty(g.data))
            for cf = 1:length(handles.gfields) 
                g.(handles.gfields{cf}) = [handles.ph.(handles.gfields{cf}), g.(handles.gfields{cf})];
            end
        end
        % First try to load the file. Loading can fail if there is not
        % enough memory, or if the file is of wrong format. If the loading
        % fails, print what the error was.
        try
            if findstr(f{c},'.vrpn.mat')
                % load only those fields which are pertinent to the selected experiment type
                %POLICY: Make the cell arrays in the form of 1xN, and keep that form as the
                %standard. Nx1 standardization would work as well, but it seems my matlab
                %is creating arrays in the form of 1xN by default.
                load_laser_tracking(fullfile(p,f{c}),fieldstr,flags);
                g.data{1,1} = ans.data;
                % fullfile usage is handy and protects code against platform variations
                g.magdata{1,1} = handles.ph.magdata; %start out with placeholder magnet data
                g.fname{1,1} = f{c}; %file name
                g.path{1,1} = p; %file path
                % Now add the default tag
                NoTagInd = get(handles.button_tag,'UserData');
                if(isempty(NoTagInd) | NoTagInd < 1), NoTagInd = 1; end
                g.tag{1,1} = ['NoTag',num2str(NoTagInd)]; %tag
                set(handles.button_tag,'UserData',NoTagInd+1);
                if ~isfield(ans,'metadata')
                    g.metadata{1,1} = 'NoMetaData'; %user specified metadata                
                else
                    g.metadata = ans.metadata;
                end
                for k = 1:length(handles.signames.intr)
                    if isfield(g.data{1},handles.signames.intr{k})
                        % calculate # of columns in the current signal
                        M = size(g.data{1}.(handles.signames.intr{k}),2);                    
                        % enter zero as the place-holder in the drift fields to start with.
                        % do not allocate space for drift for the first column which is time
                        g.drift{1,1}.(handles.signames.intr{k}) = zeros(2,M-1);
                        % First Row = Slope, Second Row = Offset
                    end
                end
                g.exptype{1,1} = curexptype;
            elseif findstr(f{c},'.edited.mat')
                load_laser_tracking(fullfile(p,f{c}),fieldstr,flags);
                g.data{1,1} = ans.data;
                g.metadata{1,1} = ans.metadata;
                g.tag{1,1} = ans.tag;
                g.fname{1,1} = ans.fname;
                g.path{1,1} = ans.path;
                g.magdata{1,1} = ans.magdata;
                g.drift{1,1} = ans.drift;
                g.exptype{1,1} = ans.exptype;                    
            else
                error('Unrecognied file format, only know about .vrpn.mat and .edited.mat formats');
            end
            
            prompt_user(['  ',f{c}, ' added to the database.'],handles);
            nloaded = nloaded + 1; %total files loaded
        catch
            prompt_user(lasterr,handles);
            prompt_user(['  ',f{c}, ' could not be added to the database.'],handles);
            % shift back every field up by one
            if(exist('g') & ~isempty(g.data))
                for cf = 1:length(handles.gfields)                    
                    g.(handles.gfields{cf}) = g.(handles.gfields{cf})(2:end); 
                end                 
            end
            break;
        end
    end
end
% set(hObject,'UserData', g); %use global instead

prompt_user(['Finished Loading. Loaded ',num2str(nloaded),' files'],handles);
amibusy(0,handles);
if nloaded 
    updatemenu(handles);
end

% --- Executes on button press in button_remove
function button_remove_Callback(hObject, eventdata, handles)
global g
if cellfun('isempty',g.data)
    errordlg('Database is empty, nothing to be removed.','Alert');
    return;
end
[selec,ok] = listdlg('ListString',get(handles.menu_files,'String'),...
    'OKstring','Remove',...
    'Name','Select file(s) to be removed');
remove_file(selec, handles);
updatemenu(handles);
prompt_user([num2str(length(selec)),' files were removed from the database.'],handles);

% --- Executes on selection change in menu_files.
function menu_files_Callback(hObject, eventdata, handles)
global g
% Hints: contents = get(hObject,'String') returns menu_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_files
updatesignalmenu(handles);
% updatemainfig(handles);

% --- Executes on button press in button_tag.
function button_tag_Callback(hObject, eventdata, handles)
global g
% Note: Multiple tags of same string are discouraged.
fileid = get(handles.menu_files,'Value');
contents = get(handles.menu_files,'string');
prompt = {'Short tag (e.g. to be used as a legend entry in a plot) for this file',...
        'Metadata to be associated with this file'};
dlg_title = ['Edit metadata:',contents{fileid}];
num_lines= [1;2];
while 1    
    userinput = inputdlg(prompt,dlg_title,num_lines,...
        {g.tag{1,fileid}, g.metadata{1,fileid}});  
    if ~isempty(userinput) 
        sameid = find(strcmp(g.tag,userinput{1}) == 1);
    else   %if user pressed cancel
        sameid = [];
        userinput{1} = g.tag{1,fileid};
        userinput{2} = g.metadata{1,fileid};
    end
    if isempty(sameid) | isequal(sameid, fileid) % if there is no another tag of same string
        break;        
    else
        button = questdlg(['Some other file has already been assigned the tag ',userinput{1},...
            '. Press CONTINUE to continue or BACK to go back to change the tag'],...
            'Tag already exists','Continue','Back','Back');
        if strcmpi(button,'continue')
            break;
        end
    end
end
g.tag{1,fileid} = userinput{1};
g.metadata{1,fileid} = userinput{2};
updatefilemenu(handles); % do not replot the main figure, just change menu entries.

% --- Executes on button press in button_cut.
function button_cut_Callback(hObject, eventdata, handles)
global g
dbstop if error
if ~exist('g') | isempty(g.data)
    errordlg('Database is empty, first add files to it','Alert');
    return;
end
% check if the main figure is plotted and in focus
if (0 == figflag(getmainfigname(handles)))
   updatemainfig(handles,'new'); 
end
% set the buttonDownFcn to DoNothing.
% % manageboxradiogroup(handles,3,1);

[t,y] = ginput(2);

t = sort(t);
% Cut all the fields existing in the current file
id = get(handles.menu_files,'Value');
for c = 1:length(handles.signames.intr)
    cursig = handles.signames.intr{c};
    if (isfield(g.data{1,id}, cursig))
        sigold = g.data{1,id}.(cursig);  
        sigold(:,1) = sigold(:,1) - sigold(1,1); % remove offset in time
%         find indices outside the selected box
        linds = sort(find(sigold(:,1) < t(1))); %indices before box
        uinds = sort(find(sigold(:,1) > t(2))); %indices after box
        %adjust the data after box such that there is no step visible after
        %cutting the box
        if ~isempty(uinds) & ~isempty(linds)
            steps = sigold(uinds(1),:) - sigold(linds(end)+1,:);
            sigold(uinds,:) = sigold(uinds,:) - repmat(steps,size(uinds,1),1);
        end
        g.data{1,id}.(cursig) = [];
        g.data{1,id}.(cursig) = sigold(union(linds, uinds),:);
        clear sigold;
    end
end
updatemainfig(handles,'cut');
dbclear if error
%-------------------------------------------------------------------------
% --- Executes on button press in button_selectdrift.
% This function lets user select a box that is to be considered as
% 'drift calculation section'. Then the routine calcualtes drift
% over the selected section for the currently selected signal and
% updates the drift parameters in the global master database.
function button_selectdrift_Callback(hObject, eventdata, handles)
global g
if ~exist('g') | isempty(g.data)
    errordlg('Database is empty, first add files to it','Alert');
    return;
end
% check if the main figure is plotted and in focus
if (0 == figflag(getmainfigname(handles)))
   updatemainfig(handles,'new'); 
end
% set the buttonDownFcn to DoNothing.
% % manageboxradiogroup(handles,3,1);

[t,y] = ginput(2);

t = sort(t);
% calculate drift for currently selected signal
sigid = get(handles.menu_signal,'UserData');
signame = handles.signames.intr{sigid};
fileid = get(handles.menu_files,'Value');
sig = g.data{fileid}.(signame);
sig(:,1) = sig(:,1) - sig(1,1); %Remove offset in time.
M = size(sig,2);
[selec(:,1),selec(:,2:M)] = clipper(sig(:,1),sig(:,2:M),t(1),t(2));
for c = 2:M % repeat for all columns
    fit = polyfit(selec(:,1),selec(:,c),1);
    % First Row = Slope, 2nd Row = offset;
 % since we need only the slope and not offset, we can set the offset to zero.
 % If we don't set the offset to zero, the code that uses this drift
 % (polyval) will have to add the offset manually after subtracting
 % drift.
    g.drift{fileid}.(signame)(:,c-1) = [fit(1), 0];
end
set(handles.check_subdrift,'Enable','On');
%-------------------------------------------------------------------------
% --- Executes on button press in check_subdrift.
function check_subdrift_Callback(hObject, eventdata, handles)
% updatemainfig(handles);

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
% --- Executes on button press in radio_drawbox.
function radio_drawbox_Callback(hObject, eventdata, handles)
manageboxradiogroup(handles,1,get(hObject,'value'));
%-------------------------------------------------------------------------
% --- Executes on button press in radio_dragbox.
function radio_dragbox_Callback(hObject, eventdata, handles)
manageboxradiogroup(handles,2,get(hObject,'value'));
%--------------------DELETED THIS RADIO ON JUNE 08, 2006------------------
% --- Executes on button press in radio_nothing.
function radio_nothing_Callback(hObject, eventdata, handles)
manageboxradiogroup(handles,3,get(hObject,'value'));

%-----------------------------------------------------------------------
function manageboxradiogroup(handles,radind,radstat)
hmf = get(handles.radio_drawbox,'UserData');
if isempty(hmf) | hmf == 0
    sigid = get(handles.menu_signal,'UserData');
    hmf = handles.mainfigids(sigid);
    set(handles.radio_drawbox,'UserData',hmf);
end
if ~ishandle(hmf) % If user wants to do anything with box, figure must exist
    updatemainfig(handles,'new');
end
hma = findobj(hmf,'Type','Axes','Tag','');
% some constants
hrad(1) = handles.radio_drawbox;
hrad(2) = handles.radio_dragbox;
% hrad(3) = handles.radio_nothing;

for c = 1:2 % reset all radios first
    set(hrad(c),'Value',0);
end
if radstat == 0
    set(hrad(1), 'Value', 1);
    set(hma,'ButtonDownFcn',{@DrawNewBoxFcn,handles});
else
    switch radind
        case 1                               
            % delete the old box
            delete(findobj(hma,'Tag','Box'));
            set(hrad(1), 'Value', 1);
            set(hma,'ButtonDownFcn',{@DrawNewBoxFcn,handles}); 
        case 2
            if isempty(findobj(hma,'Tag','Box'))
                errordlg('First draw a box to enable this mode.','Alert');                
                set(hrad(1), 'Value', 1);
                set(hma,'ButtonDownFcn',{@DrawNewBoxFcn,handles});
                return
            else                
                set(hrad(2), 'Value', 1);
                set(hma,'ButtonDownFcn',{@DragBoxFcn,handles});
            end
        case 3 %DELETED THIS RADIO ON JUNE 08, 2006
            set(hrad(3), 'Value', 1);
            set(hma,'ButtonDownFcn',{@DoNothingFcn,handles});
        otherwise
            prompt_user('Error:Unrecognized radio index',handles);
    end
end
%-------------------------------------------------------------------------
function DrawNewBoxFcn(hcaller,eventdata,handles)
% ----Executes when mouse is pressed inside the main axes and the box radio 
% is set to 'Draw New Box'. Because this function is called by the figure,
% we are sure that gcf gives the handle of the main figure and gca gives 
% handle of the axis of the main figure
dbstop if error

% NO NEED hmf = get(handles.radio_drawbox,'UserData');   
% % find the handle of the axes of the main figure
% hma = findobj(hmf,'Type','axes','Tag','');%legend is the other axes with tag 'legend'
hma = gca;

point1 = get(hma,'CurrentPoint');    % button down detected
b.figbox = rbbox;                      % return figure units
point2 = get(hma,'CurrentPoint');    % button up detected

point1 = point1(1);              % extract x 
point2 = point2(1);
x1 = min(point1,point2);             % calculate locations
width = abs(point1-point2);         % and dimensions
ylims = get(hma,'Ylim');
b.xlims = [x1, x1+width];
b.dbox = [x1, ylims(1), width, ylims(2)-ylims(1)];
updatebox(handles,hma,0,b);

%Now switch to 'drag box' mode automatically.
manageboxradiogroup(handles,2,1)
dbclear if error
%-------------------------------------------------------------------------
% Executes when mouse is pressed inside the main axes and the box mode
% is set to 'Drag Box'. Because this function is called by the figure,
% we are sure that gcf gives the handle of the main figure and gca gives 
% handle of the axis of the main figure
function DragBoxFcn(hcaller,eventdata,handles)
dbstop if error
hmf = gcf; hma = gca;
% NO NEED hmf = get(handles.radio_drawbox,'UserData');
% % find the handle of the axes of the main figure
% hma = findobj(hmf,'Type','axes','Tag','');%legend is the other axes with tag 'legend'
hbox = findobj(hma,'Tag','Box');
if isempty(hbox)
    errordlg('Box not found, redraw it. Switching to ''draw new box'' mode...');
    %Now switch to 'draw new box' mode automatically.
    manageboxradiogroup(handles,1,1);
    return;
end
b = get(hbox,'UserData'); %b must not be empty, if everything is working.
% The box is drawn in figure units which are usually 'pixels' but the 
% axis units are 'normalized' by default. Moreover, we have the coordinates
% of the box in data units, and to be able to show the shadow while
% dragging, we need to convert them into the figure units i.e. 'pixels'.
% So, idea is to first set the axis units to same as figure units, then
% take two points: bottom-left corner and top-righ corner. 
% Asking 'position' property gives info about coordinates of
% this points in axes units (and thus figure units), and asking 'Xlim' and 'Ylim'
% property gives info about coordinates of this points in data units.
% Figure out the transfer function from data to figure units and apply it
% to the box.
figunits = get(hmf,'Units');
axunits = get(hma,'Units'); % remember so we can restore it before leaving

set(hma,'Units',figunits); % make axes units same as figure units
posf = get(hma,'Position'); % axis position in figure units
set(hma,'Units',axunits); %restore original units of axes

xlims = get(hma,'Xlim'); ylims = get(hma,'Ylim');
% Now change the ylimits of box so that shadow is always lock-lock on Yaxis
b.dbox(2) = ylims(1); b.dbox(4) = ylims(2)-ylims(1);
% Now check if the old box is outside current X axis limits, in which case put it
% inside in the center of the axis but do not do any boxresults calculations
if b.xlims < xlims(1) | b.xlims > xlims(2) % both limits of the box should be out of view
    prompt_user('Warning: Old box was outside view, resetting the box. Happens after zoom.',handles);
    b.dbox(1) = mean(xlims); 
end
if b.dbox(3) > xlims(2) - xlims(1) % too wide?
    prompt_user('Warning: Old box was too wide, resetting the width. Happens after zoom.',handles);
    b.dbox(3) = 0.25*range(xlims);
end

% Now figure out the transfer function from data units to figure units
scale.x = posf(3)/(xlims(2) - xlims(1));
scale.y = posf(4)/(ylims(2) - ylims(1));
offset.x = posf(1) - xlims(1)*scale.x;
offset.y = posf(2) - ylims(1)*scale.y;

% calculate position of the old box in figure units
b.figbox = [b.dbox(1)*scale.x + offset.x, b.dbox(2)*scale.y + offset.y, ...
        b.dbox(3)*scale.x, b.dbox(4)*scale.y];
point1 = get(hma,'CurrentPoint');    % button down detected
b.figbox = dragrect(b.figbox);
point2 = get(hma,'CurrentPoint');    % button up detected
point1 = point1(1);              % extract x 
point2 = point2(1);       
displace = point2-point1;
updatebox(handles,hma,displace,b);
% keyboard
dbclear if error
%-------------------------------------------------------------------------
% ----Executes when mouse is pressed inside the main axes and the box mode
% is set to 'Do Nothing'
function DoNothingFcn(hcaller,eventdata,handles)
return
%------------------------
%---This routine updates the existing box or draws a new box.
function updatebox(handles,hma,displace,b);
amibusy(1,handles);
hbox = findobj(hma,'Tag','Box');
% look for the box-parameters in the UserData of the box itself, ONLY IF
% box-parameters are not supplied exlicitely
if (nargin < 4 | isempty(b)) 
    if isempty(hbox)
        b = [];
    else
        b = get(hbox,'UserData');
    end
end
if isempty(b) 
    prompt_user('Error in updatebox. Box params can not be found',handles);
    return;
end
if (nargin < 3 | isempty(displace))
    displace = 0;
end
delete(hbox); %delete old box
ylims = get(hma,'Ylim');
b.dbox(1) = b.dbox(1) + displace;
b.dbox([2,4]) = [ylims(1) ,ylims(2) - ylims(1)];
b.xlims = [b.dbox(1), b.dbox(1) + b.dbox(3)];
hold on;
hbox = rectangle('Position',b.dbox);
set(hbox,'EdgeColor','r','Tag','Box','Linewidth',2,'LineStyle','-.');
hold off;
set(hbox,'UserData',b);

% Update the window showing basic statistics for the data within the box 
if get(handles.check_boxstat,'value')
    updateboxresults(handles,hbox);
else
    if ishandle(handles.boxresfig)
        close(handles.boxresfig);
    end
end

% Update 3D plot to show what falls inside the selected box
if isequal(lower(get(handles.check_3d,'Enable')),'on') & (get(handles.check_3d,'Value') == 1)
    plot3dfigure(handles);
end

amibusy(0,handles);
% --- Executes on selection change in menu_dispres.
function menu_dispres_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if isequal(val,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',val);%remember the last selection
% updatemainfig(handles,'dispres');


% --- Executes on selection change in menu_signal.
function menu_signal_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
strs = get(hObject,'String');
TF = strcmp(handles.signames.disp,strs{val});
sigid = find(TF == 1);
% if isequal(sigid,get(hObject,'UserData'))
%     return; % do nothing, if this was an accidental click selecting same things
% end
set(hObject,'UserData',sigid);%remember the last selection
checkdimsvalidity(handles);
checkdriftvalidity(handles);
% updatemainfig(handles,'quant');

% --- Executes on selection change in list_dims.
function list_dims_Callback(hObject, eventdata, handles)
val = get(hObject,'Value');
if isequal(val,get(hObject,'UserData'))
    return; % do nothing, if this was an accidental click selecting same things
end
set(hObject,'UserData',val);%remember the last selection
% % updatemainfig(handles,'dims');

% --- Executes on button press in button_addfsinfo.
function button_addfsinfo_Callback(hObject, eventdata, handles)
global g
% This routine interactively walks the user through the process of
% attaching the frequency sweep excitations with the laser tracking data

%First check that the field associated with channel 8 ('laser') was loaded.
fid = get(handles.menu_files,'value');
if ~isfield(g.data{fid},handles.signames.intr{4})
    prompt_user(['The magnet-synchorizer signal was not found.', ...
        'Choose ''Discrete Freq Sweep'' as the experiment type and reload the file.'],handles);
    return;
end
[f, p] = uigetfiles('*freqSweep.mat','Browse and select the appropriate *freqSweep.mat logfile',get(handles.button_add,'UserData'));
load(fullfile(p,f{1})); % outputs a structure
g.magdata{fid} = data;
prompt_user(['Frequency sweep excitation log was attached to the tracking logfile ',g.fname{fid}],handles);
% set(handles.check_fresponse,'Enable','On');

% --- Executes on button press in check_fdbox.
% should we consider box for the frequency domain analysis
function check_fdbox_Callback(hObject, eventdata, handles)
if get(hObject,'value')
    set(handles.button_many,'Enable','off');
%     set(handles.button_plotfreq,'UserData',[]);
else
    set(handles.button_many,'Enable','On');
end
% --- Executes on button press in button_many.
function button_many_Callback(hObject, eventdata, handles)
% can not consider box if selecting multiple files
set(handles.check_fdbox,'value',0); 
[selec,ok] = listdlg('ListString',get(handles.menu_files,'String'),...
                    'InitialValue',get(handles.menu_files,'value'),...
                    'OKstring','Select',...
                    'Name','Select file(s) to be analyzed');
if ok
    set(handles.button_plotfreq,'UserData',selec);
end
%-----------------------------------------------------------------------
% --- Executes on button press in button_plotfreq.
function button_plotfreq_Callback(hObject, eventdata, handles)
stack_mode = 0;
plotfreqdom(handles,stack_mode);
return;

% --- Executes on button press in button_stack.
function button_stack_Callback(hObject, eventdata, handles)
stack_mode = 1;
plotfreqdom(handles,stack_mode);
return;

% --- Executes on button press in button_clearstack.
function button_clearstack_Callback(hObject, eventdata, handles)
stack_count = 0;
set(handles.button_clearstack,'UserData',stack_count);
close(findobj('Tag','boxstack'));
return;

%-----------------------------------------------------------------------
function plotfreqdom(handles,stack_mode)
global g
dbstop if error
amibusy(1,handles);
sigid = get(handles.menu_signal,'UserData');
signame = handles.signames.intr{sigid};

xlims = [-Inf, Inf];
manyfiles = 1;
% determine the ids of the files  to be processed
if stack_mode | get(handles.check_fdbox,'value')    
    ids = get(handles.menu_files,'Value');% only 1 file
    hmf = handles.mainfigids(sigid);
    if ~(ishandle(hmf))
        set(handles.check_fdbox,'value',0);
        if (stack_mode) 
            return; 
        end        
    else
        hma = findobj(hmf,'Type','Axes','Tag','');
        hbox = findobj(hma,'Tag','Box');
        if ~isempty(hbox)
            get(hbox,'UserData');
            xlims = ans.xlims;
        end
        manyfiles = 0;
    end
end
if manyfiles
    ids = get(handles.button_plotfreq,'UserData');
    % if 'select many files' button was not used, then consider the
    % curretly active file only.
    if isempty(ids)
        ids = get(handles.menu_files,'value');
    end
end

% Now determine the columns/dimensions of the signal to be processed
if any(sigid == handles.posid)
    % which of the R X Y Z are selected?
    cols = get(handles.list_dims,'value');
    strs = get(handles.list_dims,'String');
else %non-positional sigal, so process for all columns
    cols = 1:size(g.data{ids(1)}.(signame),2)-1; 
        % first column is always timestamp
    for k = 1:length(cols) 
        strs{k} = num2str(k); 
    end
end

% First setup figures for msd and psd computations if we should. Then fill
% in the plots for each file one by one.
if stack_mode
    msdfignum = handles.msdfigids + handles.stackfigidoff;
    psdfignum = handles.psdfigids(sigid) + handles.stackfigidoff;
    dvsffignum = handles.dvsffigids(sigid) + handles.stackfigidoff;
else
    msdfignum = handles.msdfigids;
    psdfignum = handles.psdfigids(sigid);
    dvsffignum = handles.dvsffigids(sigid);
end
% $$$$$$$$ Setup MSD figures if we should
if get(handles.check_msd,'Value')
    % setup msd figure
    figure(msdfignum); 
    if ~stack_mode          
        clf;    
    end
    title([handles.signames.disp{sigid}, '-MSD']);
    % xlabel('log_{10}(\tau)      [seconds]');	                        
    % ylabel('log_{10}(MSD)       [micron^2]');
    xlabel('{\tau}     [S]');
    ylabel('MSD   [micron^2]');    
    hold on;
end

% $$$$$$$$ Setup PSD figure if we should
if get(handles.check_psd,'value')  
    for c = 1:length(cols)
        % setup psd figure
        figure(psdfignum + cols(c) - 1);
        if ~stack_mode      
            clf;    
        end
        
        title([handles.signames.disp{sigid}, '-PSD: ',strs{cols(c)}]);
        xlabel('log_{10} Frequency [Hz]');
        if any(sigid == handles.posid) % if this signal is a position measurement
            ylabel('log_{10} Micron^2/Hz');
        else 
            ylabel('log_{10} Volts^2/Hz');
        end
        hold on;
        % setup 'area under psd' figure if we should
        if get(handles.check_cumdisp,'value')
            figure(dvsffignum + cols(c) - 1);
            if ~stack_mode      
                clf;    
            end  
            if any(sigid == handles.posid) % if this signal is a position measurement
                title([handles.signames.disp{sigid}, '-Cumulative Displacement: ',strs{cols(c)}]);                
            else 
                title([handles.signames.disp{sigid}, '- sqrt[Area under PSD]: ',strs{cols(c)}]);
            end                
            ylabel('Micron');
            xlabel('log_{10} Frequency [Hz]');
            hold on;
        end            
    end
end
scolor = 'brkgmc';
smarker = '.^+';
% LOOP TO PROCESS EACH FILE ONE BY ONE (when not in stack_mode)
for fi = 1:length(ids) %repeat for all files selected
    % grab the signal to be processed
    sig = g.data{ids(fi)}.(signame); 
    sig(:,1) = sig(:,1) - sig(1,1); % Remove offset from time
    % First check if we are told to consider data inside the Box only
    if stack_mode | get(handles.check_fdbox,'value')
        if (fi > 1)
            disp('Warning: Was told to consider only ''inside box'' data, but multiple files were selected');
            disp('Will ignore the box and process all files');
            set(handles.check_fdbox,'value',0);
            stack_mode = 0;
        else % only one file to be processed, and boxlimits have been set previously
            M = size(sig,2);
            oldsig = sig; sig = [];
            [sig(:,1), sig(:,2:M)] = clipper(oldsig(:,1), oldsig(:,2:M),xlims(1),xlims(2));
            clear oldsig;
        end
    end        
    % now check if the timestamps are evenly spaced and adjust sampling rate accordingly        
    
    if stack_mode
        cbox = get(handles.button_clearstack,'UserData')+1;
        set(handles.button_clearstack,'UserData',cbox);
        scolor_now = scolor(mod(cbox-1,length(scolor))+1);
        smarker_now = smarker(ceil(cbox/length(scolor)));
    else 
        scolor_now = scolor(mod(fi-1,length(scolor))+1);
        smarker_now = smarker(ceil(fi/length(scolor)));
    end
    if (range(diff(sig(:,1))) > 1e-6)            
        fnames = get(handles.menu_files,'String');            
        prompt_user(['UnEven TimeStamps: ',fnames{ids(fi)}],handles);
        srate = handles.srate*0.1;
        prompt_user(['This file will be resampled at ',num2str(srate),' Hz'],handles);            
        oldsig = sig;
        sig = [];
        sig(:,1) = [oldsig(1,1):1/srate:oldsig(end,1)]';
        for k = 2:size(oldsig,2);
            sig(:,k) = interp1(oldsig(:,1),oldsig(:,k),sig(:,1));
        end
        clear oldsig
    else
        srate = round(1/mean(diff(sig(:,1)))); %reset sample rate if changed by previous file
    end
    % now Subtract out the drift if we are told to do so
    if get(handles.check_subdrift,'value')
        drift = g.drift{ids(fi)}.(signame);
        for j = 2:size(sig,2)
            sig(:,j) = sig(:,j) - polyval(drift(:,j-1),sig(:,1)) + drift(2,j-1);
        end
    end
    % Now the columns in the data loaded for a positional signal are
    % x,y,z but the columns in the listbox displayed on UI are
    % r,x,y,z. So push down x,y and z by one column. Then calculate R  
    if any(sigid == handles.posid) % is this a position signal?
        if size(sig,2) <= 4 % if there are only 4 columns then R has not been calculated
            temp = sig; sig = [];
            sig(:,1) = temp(:,1); % timestamps
            sig(:,2) = sqrt((temp(:,2) - temp(1,2)).^2 + ...
                (temp(:,3) - temp(1,3)).^2 + ...
                (temp(:,4) - temp(1,4)).^2); % R
            sig(:,3:5) = temp(:,2:4); % xyz
            clear temp            
        end
    end
    % now remove mean from the original signal
    sig(:,2:end) = sig(:,2:end) - repmat(mean(sig(:,2:end),1),size(sig,1),1);
    
    
    %%=========== COMPUTE AND PLOT PSD + CUMULATIVE DISTANCE ===============
    if get(handles.check_psd,'Value')        
        % set the psd-resolution such that we have about 10 cycles of the lowest frequency.
        psdres = 10/range(sig(:,1));        
        % Now, ready to compute psd and, if we are told to, area under psd
        for c = 1:length(cols)
            [p f] = mypsd(sig(:,cols(c)+1),srate,psdres,handles.psdwin);
            figure(psdfignum + cols(c) -1);
            warning off % No better way in matlab 6.5 to turn off 'log of zero' warning 
            plot(log10(f),log10(p),[smarker_now,'-',scolor_now]);                        
            if get(handles.check_cumdisp,'value')
                dc = sqrt(cumsum(p)*mean(diff(f)));% sqrt of area under psd
                figure(dvsffignum + cols(c)-1);
                plot(log10(f),dc,[smarker_now,'-',scolor_now]);
            end
            warning on
            if stack_mode % if we just stacked results of this box position, annotate
                figure(psdfignum + cols(c) -1);
                % first get the old legend strings
                [lh oh ph strs] = legend(gca);
                legstr = sprintf('t: %.1f to %.1f',xlims(1),xlims(2));
%                 legstr = ['t:',num2str(xlims(1)),'-',num2str(xlims(2))];
                legend([strs,legstr],'Location','Best');
                %                 set(gca,'Xscale','Log','Yscale','Log');
                pretty_plot;
                hold off;
                set(gcf,'Tag','boxstack');
                if get(handles.check_cumdisp,'value')
                    figure(dvsffignum + cols(c) -1);
                    % first get the old legend strings
                    [lh oh ph strs] = legend(gca);
                    legstr = sprintf('t: %.1f to %.1f',xlims(1),xlims(2));
                    legend([strs,legstr],'Location','Best');
                    %              set(gca,'Xscale','Log','Yscale','Linear');
                    pretty_plot;
                    hold off;
                    set(gcf,'Tag','boxstack');
                end                
            elseif (fi == length(ids))% if this is last file, annotate
                alltags = g.tag;                
                figure(psdfignum + cols(c) -1);
                legend(gca,alltags{ids});
                %                 set(gca,'Xscale','Log','Yscale','Log');
                hold off;
                if get(handles.check_cumdisp,'value')
                    figure(dvsffignum + cols(c) -1);
                    legend(gca,alltags{ids});
                    %              set(gca,'Xscale','Log','Yscale','Linear');
                    hold off;
                end
            end   
        end       
    end   
    %%=========== COMPLETED PLOTTING PSD + CUMULATIVE DISTANCE ===============
    
    %%********      MEAN-SQUARE-DISPLACEMENT (MSD) COMPUTATION      **********
    if get(handles.check_msd,'value')
        % Allow msd for position-signal only. So this signal has 5 columns
        % (trxyz) guaranteed. 
        [msd, tau] = msdbase([sig(:,1), sig(:,3:5)],[]);% use default msd TAUs
        figure(msdfignum);
        warning off % No better way in matlab 6.5 to turn off 'log of zero' warning 
        % plot(log10(tau),log10(msd),[smarker_now,'-',scolor_now]);
        loglog(tau, msd,[smarker_now,'-',scolor_now]);
        warning on
        alld.msd{fi} = msd;
        alld.tau{fi} = tau;
        alld.fname{fi} = g.fname{ids(fi)};
        if stack_mode % if we just stacked results of this box position, annotate
            % first get the old legend strings
            [lh oh ph strs] = legend(gca);
            legstr = sprintf('t: %.1f to %.1f',xlims(1),xlims(2));
            legend([strs,legstr],'Location','Best');
            pretty_plot;
            hold off;
            set(gcf,'Tag','boxstack');
        elseif (fi == length(ids))% if this is last file, annotate
            alltags = g.tag;                
            legend(gca,alltags{ids});
            pretty_plot;
            %                 set(gca,'Xscale','Log','Yscale','Log');            
            hold off;
            assignin('base','alld');            
        end       
    end    
    %%=====  COMPLETED MEAN-SQUARE-DISPLACEMENT (MSD) COMPUTATION   =======    

    if stack_mode % then update the time domain figure that shows each box color coded
        if ~ishandle(handles.tstackfigid);
            % because the previous code only parses that data within the
            % box, we have to recollect the data across the whole duration.
            sigid = get(handles.menu_signal,'UserData');            
            signame = handles.signames.intr{1,sigid};            
            fileid = get(handles.menu_files,'value');
            allvals = g.data{1,fileid}.(signame);
            allvals(:,1) = allvals(:,1) - allvals(1,1); %remove offset  from time
            % Now down sample for faster display
            downvals = allvals(1:100:end,:); clear allvals;
            figure(handles.tstackfigid); set(gcf,'Tag','boxstack');
            if any(sigid == handles.posid) % If this is position then compute and insert R                
                ov = downvals; downvals = [];
                downvals(:,1) = ov(:,1);
                downvals(:,2) = sqrt(ov(:,2).^2 + ov(:,3).^2 + ov(:,4).^2);
                downvals(:,3:5) = ov(:,2:4);
                clear ov
                ylstr = 'Microns';
            else
                ylstr = 'Volts';
            end
            plot(downvals(:,1), downvals(:,1+cols(1)), ':k', 'tag', 'stack');
            xlabel('Time [s]'); ylabel(ylstr);
            % Now overlay magnets if user has told us to do so
            overlaymag(handles,gcf,1);
        end
        figure(handles.tstackfigid); hold on;
        hstack = findobj(gcf,'type','Line','tag','stack'); %Handle to the data line
        x = get(hstack,'Xdata'); y = get(hstack,'Ydata');
        ist = min(find(x >= xlims(1))); iend = max(find(x <= xlims(2)));
        plot(x(ist:iend),y(ist:iend),[smarker_now,'-',scolor_now]);
    end
    
    %%=========== COMPUTE AND PLOT SPECTROGRAM FOR THE FIRST FILE =========
    if ~stack_mode & fi == 1 & get(handles.check_spectrogram,'Value')% Only one file
        srxyz = 'RXYZ';
        for c = 1:length(cols)
            fignum = handles.specgramfigid(sigid) + cols(c) - 1;
%             tres = []; % Use the best tradeoff between time and freq. resol
            tres = 1; % explicitly specify the time resolution
            [s f t p] = myspectrogram(sig(:,cols(c)+1),srate,tres,handles.psdwin);          
            % Now remove the zero frequency component because
            % 1. It causes problems on loglog plots
            % 2. I don't think we can ever sample zero frequency 
            igood = find(f ~= 0);
            f = f(igood);
            s = s(igood,:);
            p = p(igood,:);
            
            p = p.*repmat(f,1,size(t,2));
            figure(fignum); clf;
            logf = log10(f);
            args = {t,logf,log10(abs(p)+eps)}; 
            surf(args{:},'EdgeColor','none'); axis tight; colormap(bone); colorbar;
            hold on;           
            surfaceplot = 0;
            if surfaceplot
                % try to make the 60,600,1800 Hz line red
                i60 = max(find(f <=60));
                i600 = max(find(f <=600));
                i1800 = max(find(f <=1800));

                msync = g.data{ids(fi)}.(handles.signames.intr{4});% channel 8;
                imags = find(msync(:,2) > 0.01); % When were the magnets on?
                tmag = msync(:,1) - msync(1,1);
                % If the box is in use, then we need to translate imags in to
                % indices relative to box
                itrue = interp1(t,[1:length(t)],tmag(imags),'nearest');
                itrue = unique(itrue);

                line(t(itrue),repmat(log10(f(i60)),size(itrue)),log10(abs(p(i60,itrue))+eps),'Color',[1 0 0],'LineWidth',2);
                line(t(itrue),repmat(log10(f(i600)),size(itrue)),log10(abs(p(i600,itrue))+eps),'Color',[1 0 0],'LineWidth',2);
                line(t(itrue),repmat(log10(f(i1800)),size(itrue)),log10(abs(p(i1800,itrue))+eps),'Color',[1 0 0],'LineWidth',2);
                hold off;

                view(75,60);
            else
                % Now overlay the time domain trace on the surface;
                overt = sig(1:100:end,1)-sig(1,1);
                overy = sig(1:100:end,cols(c) + 1);
                overy = overy*range(logf)/range(overy);
                overy = (overy-min(overy)+min(logf));
                plot(overt,overy,'.-k')
                % Now overlay the magnet log if are told to do so
                overlaymag(handles,gcf,1); % This causes the figure to hold  off
                view(0,90); % Looking from top down - looks like colormap
            end
            xlabel('Time [S]'); ylabel('Log_{10} Frequency [Hz]');
            title(['Spectrogram: File ID = ', g.tag{ids(fi)}, ' --', signame, ': ', srxyz(cols(c))]);
            
%             %---- This, plotting energy vs time, may be temporaray
%             figure(fignum+5);
%             binres = 0.5;% jumping window size to compute rms on
%             nbins = floor(range(sig(:,1))/binres);
%             nperbin = floor(srate*binres);
%             tzero = sig(1,1);
%             for j = 1:nbins
%                 ibinst = (j-1)*nperbin + 1;
%                 binsig = sig(ibinst:j*nperbin, c+1)-sig(ibinst,c+1);
%                 energy(j) = rms(binsig);
%                 time(j) = sig(ibinst+floor(nperbin/2),1)-tzero;                
%             end
%             plot(time,energy,'.-r');
%             % Now overlay the time domain trace on the surface;
%             hold on;           
% 
%             overt = sig(1:100:end,1)-sig(1,1);
%             overy = sig(1:100:end,cols(c) + 1);
%             overy = overy*range(energy)/range(overy);
%             overy = (overy-min(overy)+min(energy));
%             plot(overt,overy,'.-k')
%             % Now overlay the magnet log if are told to do so
%             overlaymag(handles,gcf,1); % This causes the figure to hold off
%             hold off;           
% %             legend('Energy','Bead diplacement','Magnets');
%             xlabel('Time [S]'); ylabel('Energy');            
        end
    end
    %%=======  COMPLETED SPECTROGRAM COMPUTATION AND PLOTTING   ===========
end % Finished processing + plotting all files in frequency domain

% clear the memory of file-ids that were selected last time.
set(handles.button_plotfreq,'UserData',[]);
amibusy(0,handles);
dbclear if error
return;


% --- Executes on selection in check_3d.
function check_3d_Callback(hObject, eventdata, handles)
global g
if (get(hObject,'Value'))
    if ~isempty(g.data)
        plot3dfigure(handles);
    end
else
    if (ishandle(handles.threeDfig))
        close(handles.threeDfig);
    end
end
% --- Executes on button press in button_backdoor.
function button_backdoor_Callback(hObject, eventdata, handles)
global g
keyboard
% --- Executes on button press in button_export.
function button_export_Callback(hObject, eventdata, handles)

% --- Executes on button press in button_save.
function button_save_Callback(hObject, eventdata, handles)
global g
amibusy(1,handles);
fid = get(handles.menu_files,'value');
fname = g.fname{1,fid};
itracking = findstr(fname,'tracking.');
if isempty(itracking)
    fname = [fname,'.tracking.mat'];
    itracking = length(fname) - 4;
end
lastpwd = pwd;
tp = get(handles.button_add,'UserData');%target path
cd(tp);
[filename, pathname] = uiputfile([fname(1:itracking+7),'.edited.mat'], 'Save Currently active file as');

if isequal(filename,0)|isequal(pathname,0)
    prompt_user('User aborted saving',handles);
else
    for cf = 1:length(handles.gfields) %copy all fields for that file id
        edited.(handles.gfields{cf}) = g.(handles.gfields{cf}){1,fid};
    end
    save(fullfile(pathname,filename),'edited');
    prompt_user(['Edited file was saved at',pathname],handles);
end
cd(lastpwd);
amibusy(0,handles);
%%%$$$$$$$$$$$$$$$$  NON-CALLBACK ROUTINES     $$$$$$$$$$$$$$$$$$$$$$$$
%-----------------------------------------------------------------------
function updateboxresults(handles,hbox)
global g
b = get(hbox,'UserData'); %has the xy location of box
% hmain  = get(handles.radio_drawbox,'UserData');% current 'main' figure id
fileid = get(handles.menu_files,'Value');
sigid = get(handles.menu_signal,'UserData');% internal ID of currently selected signal.
signame = handles.signames.intr{sigid};
sigmat = g.data{1,fileid}.(signame); 
% Remove offset in time
sigmat(:,1) = sigmat(:,1) - sigmat(1,1);
% Now grab the points that fall inside the box
[tsel, selec] = clipper(sigmat(:,1),sigmat(:,2:end),b.xlims(1),b.xlims(2));

% Subtract out the background drift, if we are told to do so
if get(handles.check_subdrift,'Value')
    selec = subtract_background_drift(tsel,selec,handles,signame);
end

% Now perform computations and make the result strings
str.trend = []; str.detrms = []; str.p2p = []; str.detp2p = []; tab = '    ';
sf = '%+05.3f';
if any(sigid == handles.posid) % if this signal is a position measurement
    % calculate and prepend a column of R
    selec(:,2:4) = selec;
    selec(:,1) = sqrt(selec(:,2).^2 + selec(:,3).^2 + selec(:,4).^2);
    dims = get(handles.list_dims,'Value'); %selected dimensions
    strdims = get(handles.list_dims,'String');% all strings    
    for c = 1:length(dims)
        [p s] = polyfit(tsel,selec(:,dims(c)),1);                
        detrend = selec(:,dims(c)) - polyval(p,tsel);
        str.trend = [str.trend,' (',strdims{dims(c)},') ', num2str(p(1),sf),tab];
        str.detrms = [str.detrms,' (', strdims{dims(c)}, ') ',num2str(rms(detrend),sf),tab];
        str.detp2p = [str.detp2p,' (', strdims{dims(c)}, ') ',num2str(range(detrend),sf),tab];
        str.p2p = [str.p2p,' (',strdims{dims(c)}, ') ',num2str(range(selec(:,dims(c))),sf),tab];
    end
else % Not a position measurement, so no extra labels for dimensions
    for c = 1:size(selec,2)
        [p s] = polyfit(tsel,selec(:,c),1);                
        detrend = selec(:,c) - polyval(p,tsel);
        str.trend = [str.trend, num2str(p(1),sf),tab];
        str.detrms = [str.detrms, num2str(rms(detrend),sf),tab];
        str.detp2p = [str.detp2p, num2str(range(detrend),sf),tab];    
        str.p2p = [str.p2p,num2str(range(selec(:,c)),sf),tab];
    end
end
% Now print all this information on the separate figure
if (~ishandle(handles.boxresfig))
    initresultfig(handles.boxresfig);
end

figure(handles.boxresfig);
htext = get(handles.boxresfig,'UserData');
set(htext.trend,'String',['Avg Trend [dY/dX]: ',str.trend]);
set(htext.p2p,'String',  ['Peak-to-Peak     : ',str.p2p]);
set(htext.detrms,'String',  ['Detrended RMS  : ',str.detrms]);
set(htext.detp2p,'String',  ['Detrended Range: ',str.detp2p]);
disp(['|-------Results for: ',num2str(b.xlims(1)),' to ',num2str(b.xlims(2)), ' -------|']);
disp(get(htext.trend,'String'));
disp(get(htext.p2p,'String'));
disp(get(htext.detrms,'String'));
disp(get(htext.detp2p,'String'));
%-----------------------------------------------------------------------
function initresultfig(h)
sp = get(0,'ScreenSize');
figure(h);
fp = get(h,'Position');
set(h,'DoubleBuffer', 'off', ...
    'Position', [fp(1:2) sp(3)*0.3 sp(4)*0.2], ...
    'Resize', 'On', ...
    'MenuBar', 'none', ...
    'NumberTitle', 'off', ...
    'Name', 'BoxResults');

htext.trend = text(0.1,0.9,' ','FontSize',12);
htext.p2p = text(0.1,0.7,' ','FontSize', 12); 
htext.detrms = text(0.1,0.5,' ', 'FontSize', 12);         
htext.detp2p = text(0.1,0.3,' ', 'FontSize',12);
htext.units = text(0.1,0.1,'Units should be derived from units of X and Y axis','Fontsize',10);
axis off;
set(h, 'UserData', htext);
% disp('result figure initiated');    
%-----------------------------------------------------------------------
function checkdimsvalidity(handles)
val = get(handles.menu_signal,'Value');
if any(val == handles.posid)
    set(handles.list_dims,'Enable','On');
    set(handles.check_3d,'Enable','On');
else
    set(handles.list_dims,'Enable','Off');
    set(handles.check_3d,'Enable','Off');
end
%-----------------------------------------------------------------------
function prompt_user(str,handles)
set(handles.text_message,'String',str); drawnow;
disp(str);

%-----------------------------------------------------------------------
function amibusy(busy,handles)
cbusy = [1 0.45 0.45];
cready_frame = [0.760784 0.854902 0.843137];
cready_text = [1 1 0.501961];
if busy
    set(handles.frame_busy,'BackgroundColor',cbusy);
    set(handles.text_message,'BackgroundColor',cbusy);
else
    set(handles.frame_busy,'BackgroundColor',cready_frame);
    set(handles.text_message,'BackgroundColor',cready_text);
end
drawnow;
%--------------makes the name string for the main figure ---------------
function str = getmainfigname(handles);
sigid = get(handles.menu_signal,'Value');
sigstr = get(handles.menu_signal,'String');
figid = get(handles.radio_drawbox,'UserData');
str = [num2str(figid),':',sigstr{sigid}];
%-----------------------------------------------------------------------
% --- Executes on button press in check_overlaymag.
function check_overlaymag_Callback(hObject, eventdata, handles)
overlaymag(handles);

%-----------------------------------------------------------------------
% --- Executes on button press in button_sound.
function button_sound_Callback(hObject, eventdata, handles)
global g

xlims = [-Inf, Inf];
% adjust limits if there is a box drawn
fileid = get(handles.menu_files,'Value');
sigid = get(handles.menu_signal,'UserData');
signame = handles.signames.intr{sigid};
hmf = handles.mainfigids(sigid);
hma = findobj(hmf,'Type','Axes','Tag','');
hbox = findobj(hma,'Tag','Box');
if ~isempty(hbox)
    get(hbox,'UserData');
    xlims = ans.xlims;
end
sig = g.data{fileid}.(signame);
M = size(sig,2); % Number of colums
oldsig = sig; sig = [];
[sig(:,1), sig(:,2:M)] = clipper(oldsig(:,1), oldsig(:,2:M),xlims(1),xlims(2));
clear oldsig;
% Policy for playing sound: If this is a position signal, always play R
% (regardless what dimension is selected by user). This is to put the
% matlab sound player in alignment with particle tracker (cur ver 05.01) sound player, so
% that user experience similar sounds for similar events, regardless what 
% program they use to play it from. If features or abilities are added to the sound player
% in particle tracker, then and then only, add only those abilities to this sound player.
% Also, the particle tracker (cur ver 05.01) plays the position-error
% signals (i.e. the bead position relative to laser), while we here have
% positions relative to specimen. The closest we can get is by taking
% first-differences. 

% On the other hand, if this is not a position signal, then play first
% column of the matrix. (e.g. Q1 for QPD signals).
if any(sigid == handles.posid) % if this signal is a position measurement
    raw = sqrt(sig(:,2).^2 + sig(:,3).^2 + sig(:,4).^2);
    % scale the numbers so that -0.1 micron to 0.1 micron steps are transformed to -1 to 1
    % This means the steps larger than 100 nm will be clipped during playback
    k = 10;
else
    raw = sig(:,2);
    k = 1; % No scaling for non-positional signal
end
t = sig(:,1) - sig(1,1);
if range(diff(t)) > 1E-6
    tmax = t(end);
    clear t;
    t = [0:1/handles.srate:tmax];
    newraw = interp1(sig(:,1)-sig(1,1), raw, t);
    clear raw; raw = newraw; clear newraw;
end
playsig = k*diff(raw);
plotsig = raw(1:10:end); % plot only every 10 th point
plott = t(1:10:end);
% figure(handles.specgramfigid); 
% specgram(playsig,512,handles.srate); colormap gray;

Nbits = 16; % Number of bits that P'tracker sound player seems to be using
    
N_sec = floor(t(end)); % Number to 1sec slots
tsvec = [0:1:N_sec];
dbstop if error
figure(1235); clf;
plot(plott,plotsig); pretty_plot; hold on;
set(1235,'DoubleBuffer','On');
ylims = get(gca,'Ylim');
hline = line([tsvec(1), tsvec(1)],ylims,'LineStyle',':','Color','m');
for c = 1:length(tsvec)    
    ist(c) = max(find(t <=tsvec(c)));
    if c == length(tsvec)
        iend(c) = length(t)-1;
    else 
        iend(c) = max(find(t <= tsvec(c+1)));
    end
end
figure(1235); pause(1);
k = 1;
while k <= c    
    set(hline,'Xdata',[tsvec(k), tsvec(k)]);
%     sound(playsig(ist(k):iend(k)),handles.srate,Nbits);   
    wavplay(playsig(ist(k):iend(k)), handles.srate,'sync');
%     pause(0.001);
    k = k+1;
end
wavplay(playsig,handles.srate)
dbclear if error    
 
%-----------------------------------------------------------------------
% make the matrices of signal values to be displayed and related annotations
function [sigout, annots] = filldispsig(sigin,res,signame,handles)
% first make the time abscissa with correct resolution
if res == 0;
    tout = sigin(:,1);
else
    tout = [sigin(1,1):res:sigin(end,1)]';
end

for k = 2:size(sigin,2)
    if res == 0
        temp(:,k-1) = sigin(:,k);
    else
        temp(:,k-1) = interp1(sigin(:,1),sigin(:,k),tout,'nearest');
    end    
end
% Remove offset from time
tout = tout - tout(1);
% Subtract out the background drift, if we are told to do so
if get(handles.check_subdrift,'Value')
    temp = subtract_background_drift(tout,temp,handles,signame);
end
sigout(:,1) = tout; % first column is always the time
switch signame
    case {handles.signames.intr{1},handles.signames.intr{2},handles.signames.intr{5}} 
        %bead pos, stage pos, and pos error        
        % now pick the only dimesions that are requested
        dims = get(handles.list_dims,'value');
        for c = 1:length(dims)
            switch dims(c)
                case 1 %R
                    sigout(:,c+1) = sqrt(temp(:,1).^2 + temp(:,2).^2 + temp(:,3).^2);
                    annots.legstr{c} = 'R';
                    annots.colorOrder(c,:) = [0,0,0]; % R is always black
                case 2 %X
                    sigout(:,c+1) = temp(:,1);
                    annots.legstr{c} = 'X';
                    annots.colorOrder(c,:) = [0,0,1]; % X is always blule
                case 3 %Y
                    sigout(:,c+1) = temp(:,2);                    
                    annots.legstr{c} = 'Y';
                    annots.colorOrder(c,:) = [0,1,0]; % Y is always green          
                case 4 %Z
                    sigout(:,c+1) = temp(:,3);
                    annots.legstr{c} = 'Z';
                    annots.colorOrder(c,:) = [1,0,0]; % Z is always red             
                otherwise
                    prompt_user('Error: Unrecognized dimension (not among RXYZ)',handles);
            end
        end
        annots.y = 'Microns';
        annots.x = 'Seconds';
        switch signame
            case handles.signames.intr{1} %bead position
                annots.t = 'Probe Postion (relative to specimen)';
            case handles.signames.intr{2} % stage sensed postion
                annots.t = 'Stage Postion (sensed)';
            case handles.signames.intr{5} % position error
                annots.t = 'Position error';
            otherwise 
                promptuser('Error: Unrecognized signal type');                
        end
    case handles.signames.intr{3} % qpd signals
        sigout(:,2:5) = temp;
        annots.legstr = {'Q1','Q2','Q3','Q4'};
        annots.colorOrder = [0 0 1; 0 1 0; 1 0 0; 0 0 0];
        annots.y = 'Volts';
        annots.x = 'Seconds';
        annots.t = 'QPD Signals';        
    case handles.signames.intr{4} %channel 8 
        sigout(:,2) = temp;
        annots.legstr = {'Ch 8'};
        annots.colorOrder = [0 0 1];
        annots.y = 'Volts';
        annots.x = 'Seconds';
        annots.t = 'ADC channel 8 (laser intensity OR magnets)';
    otherwise
        prompt_user('Error: Unrecognized signalName',handles);
end
%-----------------------------------------------------------------------
function remove_file(ids, handles)
global g
% ids is a list of the file-indexes that needs to be removed
allid = 1:1:length(g.(handles.gfields{1}));
keepid = setdiff(allid,ids); % indexes of the files that would be kept

for cf = 1:length(handles.gfields) 
    g.(handles.gfields{cf}) = g.(handles.gfields{cf})(keepid); 
end

% --- Executes on button press in check_spectrogram.
function check_spectrogram_Callback(hObject, eventdata, handles)

%-----------------------------------------------------------------------
% This function removes the pre-calculated background drift from selected
% section of the dataset. This is different than 'trend' or 'detrending' 
% which is displayed in the result-figure. 'Trend' referes to the slope of 
% the selected dataset itself, while 'drift' refers to the slope of the
% dataset previously designated as 'drift-section'.
function dout = subtract_background_drift(t,vals,handles,signame);
global g
fileid = get(handles.menu_files,'Value');
drift = g.drift{fileid}.(signame);
for c = 1:size(vals,2)% repeat for all columns
    dout(:,c) = vals(:,c) - polyval(drift(:,c),t) + drift(2,c);
end   

%-----------------------------------------------------------------------
function updatemainfig(handles,modestr)
global g
amibusy(1,handles);
dbstop if error
if ~exist('g') | isempty(g.data)
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
set(handles.radio_drawbox,'UserData',figid);% share with others

if ishandle(figid) % if the figure is open,   
    % delete old data lines
    dlinesh = findobj(figid,'Type','Line','Tag','data');    
    delete(dlinesh);     
end

fileid = get(handles.menu_files,'value');
sigvals = g.data{1,fileid}.(signame);
switch get(handles.menu_dispres,'value')
    case 1 % full or raw resolution
        [dispmat annots] = filldispsig(sigvals,0,signame,handles);
    case 2 % 1 ms resolution       
        [dispmat annots] = filldispsig(sigvals,1e-3,signame,handles);        
    case 3 % 10 ms resolution
        [dispmat annots] = filldispsig(sigvals,1e-2,signame,handles);
    otherwise
        prompt_user('Error: Unrecognized time resolution',handles);
end
%now ready to plot the data
 figure(figid); hold on;
% I prefer not to use gca and gcf, so that user accidentally clicking
% somewhere doesn't mess me up.
hma = findobj(figid,'Type','Axes','Tag','');
if isempty(hma) % if this is the very first time figure is plotted then axes won't exist
    % a cheap hacky work-around: make a fake axes and hold-off
    plot([0:10;0:10]);
    hma = findobj(figid,'Type','Axes','Tag','');
    hold off
end
b = []; hbox = findobj(hma,'Tag','Box'); replot_box = 0;
if ~isempty(hbox)
    b = get(hbox,'UserData');
    replot_box = 1;
end
set(hma,'colorOrder',annots.colorOrder,'NextPlot','replacechildren');
% set colororder so that each dimension has same color each time it is plotted.
% Not settig 'nextplot' replaces the parent ie axes itself.
plot(dispmat(:,1),dispmat(:,2:end),'Tag','data'); % all lines will be tagged as 'data' lines
title(annots.t);
xlabel(annots.x);
ylabel(annots.y);
set(figid,'name',getmainfigname(handles),'NumberTitle','Off');
legend(hma,annots.legstr,0);

% Now remove the old box and redraw it according to new axis limits
axis(hma,'tight'); set(hma,'Box','On');
if replot_box
    updatebox(handles,hma,0,b);
else
    % If not reploting the box, it means that box didn't exist. 
    % If box didn't exist then automatically switch to 'Draw New Box' mode.
    manageboxradiogroup(handles,1,1);
end
    

% Now update the overlaid magnets/channel 8 trace if we are told to
if isequal(lower(get(handles.check_overlaymag,'Enable')),'on')
    overlaymag(handles,figid,1);
end
% Now overlay the bad-time-interval flag if we are told to
% if isequal(lower(get(handles.check_overlaydt,'Enable')),'on')
overlaydt(handles,figid);
% end
% pretty_plot;

% Now plot the 3D trace if we are told to
if isequal(lower(get(handles.check_3d,'Enable')),'on') & (get(handles.check_3d,'Value') == 1)
    plot3dfigure(handles);
end
amibusy(0,handles);
dbclear if error
%-----------------------------------------------------------------------
function overlaydt(handles,figid)
% Called by mainfigure update routine and spectrogram plotting routine.
global g
sigid = get(handles.menu_signal,'UserData');
if nargin < 2  | isempty(figid)     
    figid = handles.mainfigids(sigid);    
end

% Proceed only if the target figure is open, otherwise return
if ~ishandle(figid)
    return;
end

olddt = findobj(figid,'Type','Line','Tag','difft');
delete(olddt);
axis tight;
% if get(handles.check_overlaydt,'value')
    fileid = get(handles.menu_files,'value');
    t = g.data{fileid}.(handles.signames.intr{sigid})(:,1);
    t = t - t(1);
    dt = diff(t);
    if range(dt) > 0.01*mean(dt)
        ibad = find(dt > 1.1*min(dt));
        % Find points that have uneven time intervals.
        overt = t(ibad);
        overy = ones(size(overt));
        % Now adjust the level so that Dt trace is visible at the top of axis
        hma = findobj(figid,'Type','Axes','Tag','');
        ylims = get(hma,'Ylim');
        overy = overy*0.99*ylims(2);
        figure(figid); hold on;
        plot(overt,overy,'.r','Tag','difft');%magenta color
        hold off;
    end
% end

%-----------------------------------------------------------------------
function overlaymag(handles,figid,remtoff)
% Called by mainfigure update routine and spectrogram plotting routine.
global g
if nargin < 3  | isempty(remtoff)    
    remtoff = 0; % Do not remove offset in time
end
if nargin < 2  | isempty(figid) 
    sigid = get(handles.menu_signal,'UserData');
    figid = handles.mainfigids(sigid);    
end

% Proceed only if the target figure is open, otherwise return
if ~ishandle(figid)
    return;
end
% Find the handle to the old magnet trace and delete it
oldmag = findobj(figid,'Type','Line','Tag','Mag');
delete(oldmag);
axis tight; % Resize axes after deleting old magnet trace
% replot the magnets only if the box is checked
if get(handles.check_overlaymag,'value')
    fileid = get(handles.menu_files,'value');
    mags = g.data{fileid}.(handles.signames.intr{4});
    overt = mags(1:100:end,1);    
    if (remtoff) overt = overt - overt(1); end
    % Now adjust the range so that mags are visible in the current axis
    hma = findobj(figid,'Type','Axes','Tag','');
    ylims = get(hma,'Ylim');   
    overy = mags(1:100:end,2)*0.25*range(ylims)/range(mags(:,2));
    % Now shift the magnet trace so that LOW state is always at bottom of
    % the plot
    overy = (overy + ylims(1) - min(overy));    
    
    figure(figid); hold on;
    plot(overt,overy,'.m','Tag','Mag');%magenta color
    hold off;
end

%-----------------------------------------------------------------------
function plot3dfigure(varargin)
global g
handles = varargin{1};
get(handles.menu_signal,'String');
dispname = ans{get(handles.menu_signal,'val')};
if nargin < 2    
    sigid = get(handles.menu_signal,'UserData');
    signame = handles.signames.intr{1,sigid};
    
    fileid = get(handles.menu_files,'value');
    sigvals = g.data{1,fileid}.(signame);
else
    sigvals = varargin{2};
end
% remove offset in position and in time
sigvals = sigvals - repmat(sigvals(1,:),size(sigvals,1),1);
% decimate to 100 Hz so that the 3D trace loads faster
t = [sigvals(1,1):0.01:sigvals(end,1)]';
for c = 1:3
    p(:,c) =  interp1(sigvals(:,1),sigvals(:,c+1),t,'nearest');   
end

% get the id of the main figure
hmf = get(handles.radio_drawbox,'UserData');
if isempty(hmf) | hmf == 0
    sigid = get(handles.menu_signal,'UserData');
    hmf = handles.mainfigids(sigid);
    set(handles.radio_drawbox,'UserData',hmf);
end

inbox = []; prebox = []; postbox = [];
% if the main figure does not exist, consider everything outside the box
if ~ishandle(hmf)
    prebox = 1:size(p,1);
else
    hbox = findobj(hmf,'Tag','Box');
    if ~isempty(hbox)
        b = get(hbox,'UserData');
        prebox = find(t <= b.xlims(1));
        inbox = find(t < b.xlims(2) & t > b.xlims(1));
        postbox = find(t >= b.xlims(2));
    else % if there is no box
        prebox = 1:size(p,1);
    end
end
if ishandle(handles.threeDfig)
    figure(handles.threeDfig);
    [az el] = view;
else
    az = 45; el = 45;
end
figure(handles.threeDfig);
plot3(p(prebox,1),p(prebox,2),p(prebox,3),'k'); hold on;
plot3(p(inbox,1),p(inbox,2),p(inbox,3),'m'); 
plot3(p(postbox,1),p(postbox,2),p(postbox,3),'k'); hold off;
xlabel('X');    ylabel('Y');    zlabel('Z');
set(gca,'Xcolor','b','Ycolor',[0.25, 0.5, 0.5],'Zcolor','r');
set(handles.threeDfig,'Name',['3d ',dispname]);
pretty_plot;
view(az,el); axis equal;
%-----------------------------------------------------------------------
% This routine updates two menus: menu_files and menu_signal
% This routine is called only by 'add' and 'remove' buttons
function updatemenu(handles)
updatefilemenu(handles);
updatesignalmenu(handles);
%-----------------------------------------------------------------------
% This routine updates file menu
% This routine does not replot the main figure.
function updatefilemenu(handles)
global g
if ~exist('g') | isempty(g.data) %database is empty
    filestr = {''};        
    set(handles.menu_files,'String',filestr);
    set(handles.menu_files,'value',1);    
    return;
end
% Now fill in the tag-attached fileNames in the menu_files
% Leave the 'selected' pointer for the menu unchanged; unless
% it points to the index outside the new size of the menu, in 
% which case reset the pointer to point to one - point to first file.
for c=1:length(g.fname)
    filestr{1,c} = ['[',g.tag{1,c},']  ',g.fname{1,c}];
end
set(handles.menu_files,'String',filestr);
if get(handles.menu_files,'Value') > length(get(handles.menu_files,'String'))
    set(handles.menu_files,'Value',1);
end
%-----------------------------------------------------------------------
% This routine updates signal menu:
% 1. Checks and fills in the permitted signalNames in the signal menu
% 2. Shares the internal index (sigid) for the currently selected signal
% 3. Enables/disables 'overlay magnets' and ['3d' % 'dimension(s)'] objects
% CALLED OFF 4. Updates the main figure
function updatesignalmenu(handles)
global g
if ~exist('g') | isempty(g.data) %database is empty     
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
fileid = get(handles.menu_files,'Value');
for c=1:size(handles.signames.intr,2) %check for each possible signal name
    % if a field with the 'internal name' for this signal type is present in the 
    % currently selected file,
    % then put the associated 'display name' in the string-set for menu_signal.
    if isfield(g.data{1,fileid},handles.signames.intr{1,c})
        k = k+1;
        sigstr{1,k} = handles.signames.disp{1,c};
        if c == last_sigid %the last selected signal is also present in this file
            sigid = c; %then, the sigid remains unchanged
        end
    end
end
if k == 0% none of the recognized signals are present (shouldn't happen)
    prompt_user('Error: Selected file has none of the recognized signal types',handles);
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

% if the current file has ch 8 loaded, then enable overlay of mags
if isfield(g.data{fileid}, handles.signames.intr{4})
    set(handles.check_overlaymag,'Enable','On');
else
    set(handles.check_overlaymag,'Enable','Off');
    set(handles.check_overlaymag,'Value',0);
end
checkdimsvalidity(handles);% check if RXYZ and/or 3D is applicable
checkdriftvalidity(handles);% check if drift subtraction is allowed
% --- -------------------------------------------------------
function checkdriftvalidity(handles);
% check if current file and signal has drift parameters calculated
% and thus if drift subtraction is allowed
global g

sigid = get(handles.menu_signal,'UserData');
fileid = get(handles.menu_files,'value');

if any(any(g.drift{fileid}.(handles.signames.intr{sigid}) ~=0 )) == 1
    set(handles.check_subdrift,'Enable','On');
else
    set(handles.check_subdrift,'Enable','Off');
    set(handles.check_subdrift,'Value',0);
end
% --- Executes on button press in button_plottime.
function button_plottime_Callback(hObject, eventdata, handles)
% profile on
updatemainfig(handles);
% profile viewer
% profile off
% --- Executes on button press in check_msd.
function check_msd_Callback(hObject, eventdata, handles)
if get(hObject,'value')
    sigid = get(handles.menu_signal,'UserData');    
    if ~any(sigid == handles.posid)
        errordlg(['Signal must be of position-measurement type to compute MSD.'  ... 
                    'Please change signal type'],'Error');
        set(hObject,'value',0);    
    end
end

% --- Executes on button press in button_invokeFSgui.
function button_invokeFSgui_Callback(hObject, eventdata, handles)

setappdata(handles.ltaGUI,'ltahandles',handles);
fsanalysis_subgui;

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
set(hObject,'value',3); % Set to 10 ms resolution by default
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


% --- Executes on selection change in menu_exper.
function menu_exper_Callback(hObject, eventdata, handles)
% hObject    handle to menu_exper (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menu_exper contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_exper

% --- Executes on button press in check_filterMCL.
function check_filterMCL_Callback(hObject, eventdata, handles)
% hObject    handle to check_filterMCL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_filterMCL

% --- Executes on button press in button_advopt.
function button_advopt_Callback(hObject, eventdata, handles)
% hObject    handle to button_advopt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in check_boxstat.
function check_boxstat_Callback(hObject, eventdata, handles)
% hObject    handle to check_boxstat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_boxstat


%%%####################################################################
%%%#############    GUIDE WILL ADD NEW CALLBACKS BELOW      ###########
%%%####################################################################



