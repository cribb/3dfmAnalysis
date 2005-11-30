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

% Last Modified by GUIDE v2.5 30-Nov-2005 13:15:31
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
set(handles.button_add,'UserData',pwd); %initial default path for browsing files
% Some figure numbers allocated to specific types of plots
handles.basefig = 1;
handles.psdfig = 10; % 10 = r, 11 = x, 12 = y, 13 = z;
handles.dvsffig = 20;
handles.threeDfig = 30;
handles.psdfigS = 40; % 10 = r, 11 = x, 12 = y, 13 = z;
handles.dvsffigS = 50;
handles.threeDfigS = 60;
handles.T1msfig = 70;
handles.T10msfig = 80;
%  ....add to this list as more types of plots are supported
% Some other constants
handles.srate = 10000;
handles.psdwin = 'blackman';
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
global g % using global (as oppose to 'UserData') prevents creating multiple copies
switch get(handles.menu_quants,'value')
    case 1 %bead only
        squant = 'b';        
    case 2 %bead and 
        squant = 'lb';        
    case 3
        squant = 'bs';
    case 4
        squant = 'bls';
    otherwise
        prompt_user('Error: Unrecognized input for desired quantities');
end
try        
    [f, p] = uigetfiles('*.mat','Select one or more files',get(hObject,'UserData'));
catch
    [f, p] = uigetfiles('*.mat','Select one or more files','D:\');
end
set(hObject,'UserData',p);
prompt_user('Wait...Loading selected files',handles);
flags.keepuct = 0; flags.keepoffset = 0; flags.askforinput = 0;flags.inmicrons = 1;
nloaded = 0;
for(c = 1:length(f))
    pack
    if exist('g') & ~isempty(g) & any(strcmp(g.(handles.dmnpt{3}),f{c}) == 1)
        prompt_user(['The file ',f{c},' is already in the database.']);                
    else
        prompt_user(['...currently loading ','[',num2str(c),'of',num2str(length(f)),'] :',f{c}],handles);
        
        %put newly added on the top of the list
        if (exist('g') & ~isempty(g))
            for cf = 1:length(handles.dmnpt) %shift all fields down by one
                g.(handles.dmnpt{cf}) = [ {0}, g.(handles.dmnpt{cf})];
            end
        end
        %Make the cell arrays in the form of 1xN, and keep that form as the
        %standard. Nx1 standardization would work as well, but it seems my matlab
        %is creating arrays in the form of 1xN by default.
        try
            % load only bead positions and laser intensity values
            g.(handles.dmnpt{1}){1,1} = load_laser_tracking(fullfile(p,f{c}),squant,flags);
            % fullfile usage protects code against platform variations
            g.(handles.dmnpt{3}){1,1} = f{c};
            g.(handles.dmnpt{4}){1,1} = p;
            g.(handles.dmnpt{5}){1,1} = 'NoTag';
            g.(handles.dmnpt{2}){1,1} = 'NoMetaData';            
            prompt_user([f{c}, ' added to the database.'],handles);
            nloaded = nloaded + 1;
        catch
            prompt_user(lasterr);
            prompt_user([f{c}, ' could not be added to the database.'],handles);
            % shift back every field up by one
            if(exist('g') & ~isempty(g))
                for cf = 1:length(handles.dmnpt)                    
                    g.(handles.dmnpt{cf}) = g.(handles.dmnpt{cf})(2:end); 
                end                 
            end
            updatetaglist(handles);
            break;
        end
        updatetaglist(handles);
    end
end
% set(hObject,'UserData', g); %use global instead
updatemenu(handles);
prompt_user(['Finished Loading. Loaded ',num2str(nloaded),' files']);

% --- Executes on button press in button_remove
function button_remove_Callback(hObject, eventdata, handles)
global g
[sel,ok] = listdlg('ListString',get(handles.menu_files,'String'),...
                    'OKstring','Remove',...
                    'Name','Select file(s) to be removed');
for c=1:length(sel)
    for cf = 1:length(handles.dmnpt) %delete all fields for that file id
        g.(handles.dmnpt{cf}){1,sel(c)} = {};
    end
end
% keyboard
% Now remove the empty cells from each field
for cf = 1:length(handles.dmnpt) 
    ifilled = ~cellfun('isempty',g.(handles.dmnpt{cf}));
    g.(handles.dmnpt{cf}) = g.(handles.dmnpt{cf})(ifilled); 
end
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
%--------------makes the name string for edit figure ----------
function str = getfocusfigname(handles);
global g
id = get(handles.menu_files,'Value');
str = [num2str(id),':',g.(handles.dmnpt{5}){1,id}];

% --- Executes on button press in button_clip.
function button_clip_Callback(hObject, eventdata, handles)
global g
if ~exist('g') | isempty(g)
    prompt_user('No file exists in the database');
    return;
end
id = get(handles.menu_files,'Value');
bp = g.(handles.dmnpt{1}){1,id}.beadpos;
% check if the current file is plotted on the base figure
if (0 == figflag(getfocusfigname(handles)))
   button_preview(handles.button_preview,[],handles);
end
hf = gcf; ha = gca;

[t,y] = ginput(2);
drawlines(ha, t);
t = sort(t);
% Clip the beadposition field
ist = max(find(bp.time <= t(1)));
iend = max(find(bp.time <= t(2)));
g.(handles.dmnpt{1}){1,id}.beadpos = [];
g.(handles.dmnpt{1}){1,id}.beadpos.time = bp.time(ist:iend);
g.(handles.dmnpt{1}){1,id}.beadpos.x = bp.x(ist:iend);
g.(handles.dmnpt{1}){1,id}.beadpos.y = bp.y(ist:iend);
g.(handles.dmnpt{1}){1,id}.beadpos.z = bp.z(ist:iend);

% Clip the laser intensity field
if (isfield(g.(handles.dmnpt{1}){1,id},'laser'))
    laser = g.(handles.dmnpt{1}){1,id}.laser;
    ist = max(find(laser.time <= t(1)));
    iend = max(find(laser.time <= t(2)));
    g.(handles.dmnpt{1}){1,id}.laser = [];
    g.(handles.dmnpt{1}){1,id}.laser.time = laser.time(ist:iend);
    g.(handles.dmnpt{1}){1,id}.laser.intensity = laser.intensity(ist:iend);
end

% --- Executes on button press in button_preview.
function button_preview_Callback(hObject, eventdata, handles)
global g
if ~exist('g') | isempty(g)
    prompt_user('No file exists in the database');
    return;
end
id = get(handles.menu_files,'Value');
bp = g.(handles.dmnpt{1}){1,id}.beadpos;
figure(handles.basefig); clf; ha = gca; hf = gcf;
set(hf,'name',getfocusfigname(handles),'NumberTitle','Off');
plot(bp.time, [bp.x,bp.y,bp.z]); 
hold on;
lims = get(ha,'Ylim');
[scale, imax] = max(abs(lims)); scale = scale*scale/lims(imax(1));
% laser = g.(handles.dmnpt{1}){1,id}.laser;
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

% --- Executes on button press in button_plot.
function button_plot_Callback(hObject, eventdata, handles)
global g
dbstop if error
alltags = get(handles.list_tags,'String');
ids = get(handles.list_tags,'Value');
dims = get(handles.list_plotRxyz,'value');
strdim = get(handles.list_plotRxyz,'String');    
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
            bp = g.(handles.dmnpt{1}){1,ids(c)}.beadpos;
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
            bp = g.(handles.dmnpt{1}){1,ids(c)}.beadpos;
            bp.x = bp.x - bp.x(1,1);
            bp.y = bp.y - bp.y(1,1);
            bp.z = bp.z - bp.z(1,1);
            bp = interpXYZpos(bp,1/100);
            plot3(bp.x,bp.y,bp.z,colrs(mod(c-1,length(colrs))+1));
            xlabel('X');
            ylabel('Y');
            zlabel('Z');
            title(g.(handles.dmnpt{5}){1,ids(c)});
            pretty_plot;
        end
    end
    %% ==================   PLOT TIME-DOMAIN XYZ TRACES   =====================
    if get(handles.check_T1ms,'value')
        figure(handles.T1msfig);    
        for c = 1:1 %plot this for the first tag only        
            bp = g.(handles.dmnpt{1}){1,ids(c)}.beadpos;
            bp = interpXYZpos(bp,1/1000);
            plot(bp.time,[bp.x,bp.y,bp.z]);
            xlabel('Seconds');
            ylabel('Microns');
            title(g.(handles.dmnpt{5}){1,ids(c)});
            legend('X','Y','Z');
            pretty_plot;
        end        
    end
    if get(handles.check_T10ms,'value')
        figure(handles.T10msfig);    
        for c = 1:1 %plot this for the first tag only     
            bp = g.(handles.dmnpt{1}){1,ids(c)}.beadpos;
            bp = interpXYZpos(bp,1/100);
            plot(bp.time,[bp.x,bp.y,bp.z]);
            xlabel('Seconds');
            ylabel('Microns');
            title(g.(handles.dmnpt{5}){1,ids(c)});
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
            sp = g.(handles.dmnpt{1}){1,ids(c)}.stageReport;
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
            sp = g.(handles.dmnpt{1}){1,ids(c)}.stageReport;
            sp.x = sp.x - sp.x(1,1);
            sp.y = sp.y - sp.y(1,1);
            sp.z = sp.z - sp.z(1,1);        
            plot3(sp.x,sp.y,sp.z,colrs(mod(c-1,length(colrs))+1));
        end
    end
end
% keyboard
dbclear if error

function posout = interpXYZpos(posin,rate)
posout.time = [posin.time(1):rate:posin.time(end)]';
posout.x = interp1(posin.time,posin.x,posout.time);
posout.y = interp1(posin.time,posin.y,posout.time);
posout.z = interp1(posin.time,posin.z,posout.time);

% --- Executes on button press in check_psd.
function check_psd_Callback(hObject, eventdata, handles)
if ~get(hObject,'Value')
    set(handles.check_cumdisp,'Value',0);
end
% --- Executes on button press in check_cumdisp.
function check_cumdisp_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    set(handles.check_psd,'Value',1);
end
% --- Executes on button press in check_3d.
function check_3d_Callback(hObject, eventdata, handles)
% --- Executes on button press in button_test.
function button_test_Callback(hObject, eventdata, handles)
global g
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
val = get(handles.menu_files,'value');
if val > length(get(handles.menu_files,'String'))
    set(handles.menu_files,'value',length(handles.menu_files));
end
%-----------------------------------------------------------------------
function updatetaglist(handles)
global g
if exist('g') & ~isempty(g);
    set(handles.list_tags,'String',g.(handles.dmnpt{5}));
else
    set(handles.list_tags,'String','');
end
val = get(handles.list_tags,'value');
if any(val > length(get(handles.list_tags,'String')))
    set(handles.list_tags,'value',length(handles.list_tags));
end

%%%********************************************************************
%%%**********      ALL BELOW IS POSSIBLY JUNK     *********************
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


% --- Executes on button press in check_bead.
function check_bead_Callback(hObject, eventdata, handles)
% hObject    handle to check_bead (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_bead


% --- Executes on button press in check_stage.
function check_stage_Callback(hObject, eventdata, handles)
% hObject    handle to check_stage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_stage


% --- Executes during object creation, after setting all properties.
function menu_quants_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_quants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in menu_quants.
function menu_quants_Callback(hObject, eventdata, handles)
% hObject    handle to menu_quants (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menu_quants contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_quants


% --- Executes on button press in check_T1ms.
function check_T1ms_Callback(hObject, eventdata, handles)
% hObject    handle to check_T1ms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_T1ms


% --- Executes on button press in check_T10ms.
function check_T10ms_Callback(hObject, eventdata, handles)
% hObject    handle to check_T10ms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_T10ms


