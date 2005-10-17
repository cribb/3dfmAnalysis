function varargout = FreqSweepAnalysis(varargin)
% FREQSWEEPANALYSIS M-file for FreqSweepAnalysis.fig
%      FREQSWEEPANALYSIS, by itself, creates a new FREQSWEEPANALYSIS or raises the existing
%      singleton*.
%
%      H = FREQSWEEPANALYSIS returns the handle to a new FREQSWEEPANALYSIS or the handle to
%      the existing singleton*.
%
%      FREQSWEEPANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FREQSWEEPANALYSIS.M with the given input arguments.
%
%      FREQSWEEPANALYSIS('Property','Value',...) creates a new FREQSWEEPANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FreqSweepAnalysis_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FreqSweepAnalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FreqSweepAnalysis

% Last Modified by GUIDE v2.5 17-Oct-2005 12:49:44
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
                   'gui_OpeningFcn', @FreqSweepAnalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @FreqSweepAnalysis_OutputFcn, ...
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


% --- Executes just before FreqSweepAnalysis is made visible.
function FreqSweepAnalysis_OpeningFcn(hObject, eventdata, handles, varargin)
global lastpath
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FreqSweepAnalysis (see VARARGIN)

% Choose default command line output for FreqSweepAnalysis
handles.output = hObject;
% a signature storing the names of the fields in global structure
handles.dmnpt = {'data','metadata','name','path','tag'};
% NOTE: if change any of the strings above, also change the field name
% 'dmnpt' such that it is the alphabetically ordered first letters of each
% field. This helps in knowing what the order is.
% Update handles structure
lastpath = pwd; %initial default path for browsing files
% Some figure numbers allocated to specific types of plots
handles.basefig = 1;
handles.psdfig = 10; % 10 = r, 11 = x, 12 = y, 13 = z;
%  ....add to this list as more types of plots are supported
% Some other constants
handles.srate = 10000;
guidata(hObject, handles);

% UIWAIT makes FreqSweepAnalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FreqSweepAnalysis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%% $$$$$$$$$$$$$$$$$$$       CALLBACKS     $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
% --- Executes on button press in button_add.
function button_add_Callback(hObject, eventdata, handles)
global g lastpath% using global (as oppose to 'UserData') prevents creating multiple copies

[f, p] = uigetfiles('*.mat','Select one or more files',lastpath);
lastpath = p;
prompt_user('Wait...Loading selected files',handles);
flags.keepuct = 0; flags.keepoffset = 0; flags.askforinput = 0;flags.inmicrons = 1;
newid = 0;
for(c = 1:length(f))
    if exist('g') & ~isempty(g) & any(strcmp(g.(handles.dmnpt{3}),f{c}) == 1)
        prompt_user(['The file ',f{c},' is already in the database.']);                
    else
        prompt_user(['...currently loading ','[',num2str(c),'of',num2str(length(f)),'] :',f{c}],handles);
        newid = newid+1;        
        %Make the cell arrays in the form of 1xN, and keep that form as the
        %standard. Nx1 standardization would work as well, but it seems my matlab
        %is creating arrays in the form of 1xN by default.
        new.(handles.dmnpt{3}){1,newid} = f{c};
        new.(handles.dmnpt{4}){1,newid} = p;
        new.(handles.dmnpt{5}){1,newid} = 'NoTag';
        new.(handles.dmnpt{2}){1,newid} = '';
        % load only bead positions and laser intensity values
        new.(handles.dmnpt{1}){1,newid} = load_laser_tracking(fullfile(p,f{c}),'bl',flags);
                % fullfile usage protects code against platform variations
    end
end
if exist('new')
    if(~exist('g') | isempty(g))
        g = new;
    else
        %put newly added on the top of the list
        for cf = 1:length(handles.dmnpt) %copy all fields
            g.(handles.dmnpt{cf}) = [new.(handles.dmnpt{cf}), g.(handles.dmnpt{cf})];
        end        
    end
    prompt_user([num2str(length((new.(handles.dmnpt{1})))),' files are added to the database.'],handles);
end
% set(hObject,'UserData', g); %use global instead
updatetaglist(handles);
updatemenu(handles);

% --- Executes on button press in button_remove
function button_remove_Callback(hObject, eventdata, handles)
global g

[sel,ok] = listdlg('ListString',get(handles.menu_files,'String'),...
                    'OKstring','Remove',...
                    'Name','Select file(s) to be removed');
for c=1:length(sel)
    for cf = 1:length(handles.dmnpt) %delete all fields for that file id
        g.(handles.dmnpt{cf}){1,c} = [];
    end
end
% Now remove the cells which have been emptied out
cgood = 0; newg = [];
for c=1:length(g.(handles.dmnpt{1}))
    if ~isempty(g.(handles.dmnpt{1}){1,c})
        cgood = cgood+1;
        for cf = 1:length(handles.dmnpt) %copy all fields for that file id
            newg.(handles.dmnpt{cf}){1,cgood} = g.(handles.dmnpt{cf}){1,c};
        end
    end
end
g = newg;
updatetaglist(handles);
updatemenu(handles);
prompt_user([num2str(length(sel)),' files were removed from the database.'],handles);

% --- Executes on selection change in list_tags.
function list_tags_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns list_tags contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_tags

% --- Executes on selection change in menu_files.
function menu_files_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns menu_files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_files
global g
id = get(handles.menu_files,'Value');
bp = g.(handles.dmnpt{1}){1,id}.beadpos;
% laser = g.(handles.dmnpt{1}){1,id}.laser;
dt = diff(bp.time);
flag = min(min([bp.x,bp.y,bp.z])) +  dt*0.2*range([bp.x, bp.y, bp.z])/range(dt);
figure(handles.basefig); clf; hf = gcf;
set (hf,'name','EditData','NumberTitle','Off');
plot(bp.time, [bp.x,bp.y,bp.z]); 
hold on;
plot(bp.time(1:end-1), dt,'.k');
hold off;
legend('X','Y','Z','Interval');
ylabel('Microns (no units for black line)');
xlabel('Seconds');
title('Bring the zone with even interval in focus, then clip');
% --- Executes on button press in button_tag.
function button_tag_Callback(hObject, eventdata, handles)
global g
id = get(handles.menu_files,'Value');
contents = get(handles.menu_files,'string');
prompt = {'Short tag to be used as the plot-legend entry for this file',...
        'Metadata to be associated with this file'};
dlg_title = ['Edit info:',contents{id}];
num_lines= [1;2];
% plot_selected(id);
userinput = inputdlg(prompt,dlg_title,num_lines,...
    {g.(handles.dmnpt{5}){1,id}, g.(handles.dmnpt{2}){1,id}});
if (~isempty(userinput))
    g.(handles.dmnpt{5}){1,id} = userinput{1};
    g.(handles.dmnpt{2}){1,id} = userinput{2};
end
updatetaglist(handles);
updatemenu(handles);
% Note: Multiple tags of same string are acceptable

% --- Executes on button press in button_clip.
function button_clip_Callback(hObject, eventdata, handles)
global g
figure(handles.basefig); ha = gca;
[t(1),y] = ginput(1);
drawlines(ha, t(1));
[t(2),y] = ginput(1);
drawlines(ha, t(2));
id = get(handles.menu_files,'Value');
t = sort(t);

% Clip the beadposition field
bp = g.(handles.dmnpt{1}){1,id}.beadpos;
ist = max(find(bp.time <= t(1)));
iend = max(find(bp.time <= t(2)));
g.(handles.dmnpt{1}){1,id}.beadpos = [];
g.(handles.dmnpt{1}){1,id}.beadpos.time = bp.time(ist:iend);
g.(handles.dmnpt{1}){1,id}.beadpos.x = bp.x(ist:iend);
g.(handles.dmnpt{1}){1,id}.beadpos.y = bp.y(ist:iend);
g.(handles.dmnpt{1}){1,id}.beadpos.z = bp.z(ist:iend);

% Clip the laser intensity field
laser = g.(handles.dmnpt{1}){1,id}.laser;
ist = max(find(laser.time <= t(1)));
iend = max(find(laser.time <= t(2)));
g.(handles.dmnpt{1}){1,id}.laser = [];
g.(handles.dmnpt{1}){1,id}.laser.time = laser.time(ist:iend);
g.(handles.dmnpt{1}){1,id}.laser.intensity = laser.intensity(ist:iend);

% --- Executes on button press in button_plot.
function button_plot_Callback(hObject, eventdata, handles)
global g
alltags = get(handles.list_tags,'String');
ids = get(handles.list_tags,'Value');
dims = get(handles.list_plotRxyz,'value');
strdim = get(handles.list_plotRxyz,'String');    
colrs = 'bgrkym';

%%=========== COMPUTE AND PLOT PSD ===============
if get(handles.check_psd,'Value')
    % set up all figures
    for c = 1:dims
        figure(handles.psdfig + c - 1); clf;
        title(['PSD: ',strdim{dims(c)}]);
        ylabel('Micron^2/Hz');
        hold on;
    end        
    for c = 1:length(ids)        
        bp = g.(handles.dmnpt{1}){1,ids(c)}.beadpos;
        srate = handles.srate; %reset sample rate if changed by previous file
        if (range(diff(bp.time)) > 1e-6)            
            fnames = get(handles.menu_files,'String');            
            prompt_user(['UnEven TimeStamps: ',fnames{ids(c)}]);
            srate = srate*2;
            prompt_user(['I will resample this file at ',num2str(srate),' Hz']);            
            t = [bp.time(1):1/srate:bp.time(end)]';
            x = interp1(bp.time,bp.x,t);
            y = interp1(bp.time,bp.y,t);
            z = interp1(bp.time,bp.z,t);
            bp = [];            
            [bp.time bp.x bp.y bp.z] = deal(t, x, y, z);
        end
        psdres = 1/floor(range(bp.time)*10);
        for cd = 1:length(dims)
            switch strdim{dims(cd)}
                case strdim{1}
                    bp.r = sqrt(bp.x.^2 + bp.y.^2 + bp.z.^2);
                    [p f] = mypsd(bp.r,srate,psdres);
                    figure(handles.psdfigs + 1 -1);           
                    loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                    if (c == length(ids))% if this is last file
                        legend(gca,alltags{ids});
                        hold off;
                    end
                case strdim{2}
                    [p f] = mypsd(bp.x,srate,psdres);
                    figure(handles.psdfigs + 2 -1);           
                    loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                    if (c == length(ids))% if this is last file
                        legend(gca,alltags{ids});
                        hold off;
                    end
                case strdim{3}
                    [p f] = mypsd(bp.y,srate,psdres);
                    figure(handles.psdfigs + 3 -1);           
                    loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                    if (c == length(ids))% if this is last file
                        legend(gca,alltags{ids});
                        hold off;
                    end
                case strdim{4}
                    [p f] = mypsd(bp.z,srate,psdres);
                    figure(handles.psdfigs + 4 -1);           
                    loglog(f,p,['.-',colrs(mod(c-1,length(colrs))+1)]);
                    if (c == length(ids))% if this is last file
                        legend(gca,alltags{ids});
                        hold off;
                    end
                otherwise
                    prompt_user('Unrecognized type (not among r,x,y,z) for psd calculation');
            end
        end
    end    
end

% --- Executes on button press in check_psd.
function check_psd_Callback(hObject, eventdata, handles)

% --- Executes on button press in button_test.
function button_test_Callback(hObject, eventdata, handles)
dbstop if error
contents = get(handles.list_tags,'String');% returns list_tags contents as cell array
selected = contents{get(handles.list_tags,'Value')};% returns selected item from list_tags
disp(selected)
whos selected
dbclear if error
keyboard
%%%$$$$$$$$$$$$$$$$  NON-CALLBACK ROUTINES     $$$$$$$$$$$$$$$$$$$$$$$$
%-----------------------------------------------------------------------
function prompt_user(str,handles)
% set(handles.text_message,'String',str);
disp(str);
%-----------------------------------------------------------------------
function updatemenu(handles)
global g
menustr{1,1}='No file is loaded';
if exist('g') & ~isempty(g);
    for c=1:length(g.(handles.dmnpt{3}))
        menustr{1,c} = ['[',g.(handles.dmnpt{5}){1,c},']  ',g.(handles.dmnpt{3}){1,c}];
    end
end
set(handles.menu_files,'String',menustr);
%-----------------------------------------------------------------------
function updatetaglist(handles)
global g
if exist('g') & ~isempty(g);
    set(handles.list_tags,'String',g.(handles.dmnpt{5}));
else
    set(handles.list_tags,'String','');
end
%%%********************************************************************
%%%********** ALL BELOW IS POSSIBLY JUNK     **************************
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
function list_plotRxyz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list_plotRxyz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes on selection change in list_plotRxyz.
function list_plotRxyz_Callback(hObject, eventdata, handles)
% hObject    handle to list_plotRxyz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns list_plotRxyz contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list_plotRxyz

%%%####################################################################






