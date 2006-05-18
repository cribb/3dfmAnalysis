function varargout = guidetemplate0(varargin)
% GUIDETEMPLATE0 M-file for guidetemplate0.fig
%      GUIDETEMPLATE0, by itself, creates a new GUIDETEMPLATE0 or raises the existing
%      singleton*.
%
%      H = GUIDETEMPLATE0 returns the handle to a new GUIDETEMPLATE0 or the handle to
%      the existing singleton*.
%
%      GUIDETEMPLATE0('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIDETEMPLATE0.M with the given input arguments.
%
%      GUIDETEMPLATE0('Property','Value',...) creates a new GUIDETEMPLATE0 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before guidetemplate0_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to guidetemplate0_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help guidetemplate0

% Last Modified by GUIDE v2.5 17-May-2006 22:05:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @guidetemplate0_OpeningFcn, ...
                   'gui_OutputFcn',  @guidetemplate0_OutputFcn, ...
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


% --- Executes just before guidetemplate0 is made visible.
function guidetemplate0_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to guidetemplate0 (see VARARGIN)

% Choose default command line output for guidetemplate0
handles.output = hObject;

% Now add any info that needs to be shared across all callbacks
hlta = findobj('Tag','ltaGUI');
handles.lta = getappdata(hlta,'ltahandles');
handles.figidoff = 100; %offset in figure numbers

handles.FvsFs1figid = handles.figidoff + 10;
handles.FvsFs2figid = handles.figidoff + 20;
handles.FvsAllHfigid = handles.figidoff + 40;
handles.FvsTHDfigid = handles.figidoff + 30;
handles.segpsdfigid = handles.figidoff + 100;
handles.colors = 'brkgmy';
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes guidetemplate0 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = guidetemplate0_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in button_selectFS.
function button_selectFS_Callback(hObject, eventdata, handles)
% Select files associated with frequency sweep on bead on cell
% Only display those files which have magdata associated with them
global g 
igood = findgood(g.magdata,handles.lta.ph.magdata);
if isempty(igood)
    errordlg(['There is no file for which Frequency Sweep data is attached to. ',...
        'Attach frequency sweep data and then come back']);
    set(handles.button_selectFS,'UserData',[]);
else
    allstr = get(handles.lta.menu_files,'String');
    goodstr = allstr(igood); % CURLY BRACES DOESN'T WORK HERE!!
    [selec,ok] = listdlg('ListString',get(handles.lta.menu_files,'String'),...
        'InitialValue',1,...
        'OKstring','Select',...
        'Name','Select real experiment freq sweep file(s)');
    if ok
        % Now detect segments for this files and put everything on UserData
        r.iseg = detectsegments(igood(selec),handles);
        r.fid = igood(selec);
        set(handles.button_selectFS,'UserData',r);
    end
end

% --- Executes on button press in button_selectFixed.
function button_selectFixed_Callback(hObject, eventdata, handles)
% select file associated with fixed bead frequency sweep
% Only display those files which have magdata associated with them
global g
igood = findgood(g.magdata,handles.lta.ph.magdata);
if isempty(igood)
    errordlg(['There is no file for which Frequency Sweep data is attached to. ',...
        'Attach frequency sweep data and then come back']);
    set(handles.button_selectFS,'UserData',[]);
else
    allstr = get(handles.lta.menu_files,'String');
    goodstr = allstr(igood);
    [selec,ok] = listdlg('ListString',get(handles.lta.menu_files,'String'),...
        'InitialValue',1,'OKstring','Select',...
        'Name','Select fixed bead freq sweep file(s)');
    if ok
        % Now detect segments for this files and put everything on UserData
        r.iseg = detectsegments(igood(selec),handles);
        r.fid = igood(selec);
        set(handles.button_selectFixed,'UserData',r);
    else
        set(handles.button_selectFixed,'UserData',[]);
    end
end
% -----------------------------------
function inds = findgood(carray, bad)
inds = [];
for c = 1:length(carray)
    if ~isequal(carray{c},bad)
        inds = [inds,c];
    end
end
% ----------------------------------------------------------------------
% --- Executes on button press in button_plotfs.
function button_plotfs_Callback(hObject, eventdata, handles)
global g

dfs = get(handles.button_selectFS,'UserData'); 
dfx = get(handles.button_selectFixed,'UserData'); 

if get(handles.check_compensate,'value')
    [resfix, meanfix]  = computefs(dfx.fid, dfx.iseg, handles);
    assignin('base','resfix',resfix);
end
[resfs, meanfs] = computefs(dfs.fid, dfs.iseg, handles);

dbstop if error
assignin('base','resfs',resfs);
set(hObject,'UserData',resfs);

allstr = get(handles.menu_yaxis,'string');
stry = allstr{get(handles.menu_yaxis,'value')};
alltags = g.tag;
figlist = [];
rxyz = 'rxyz';
dl = get(handles.lta.list_dims,'value');
for dim = 1:length(dl)
    sdim = rxyz(dl(dim));
    if get(handles.check_FvsAllH,'Value')
        hfthis = handles.FvsAllHfigid + dl(dim); figlist = [figlist,hfthis];
        figure(hfthis); clf;          
        title(['Freq Sweep response @ 1st to 4th harmonic: ', sdim]);        
        xlabel('Frequency [Hz]');
        ylabel(['Response [',stry,']']);
        hold on;        
    end
    if get(handles.check_FvsFs1,'Value')
        hfthis = handles.FvsFs1figid + dl(dim); figlist = [figlist,hfthis];
        figure(hfthis); clf;     
        title(['Freq Sweep response @ Fundamental: ', sdim]);        
        xlabel('Frequency [Hz]');
        ylabel(['Response [',stry,']']);
        hold on;        
    end
    if get(handles.check_FvsFs2,'Value')
        hfthis = handles.FvsFs2figid + dl(dim); figlist = [figlist,hfthis];
        figure(hfthis); clf;    
        title(['Freq Sweep response @ 2nd harmonic: ', sdim]);        
        xlabel('Frequency [Hz]');
        ylabel(['Response [',stry,']']);
        hold on;        
    end
    if get(handles.check_FvsTHD,'Value')
        hfthis = handles.FvsTHDfigid + dl(dim); figlist = [figlist,hfthis];
        figure(hfthis); clf;                
        title(['Total Harmonic Distortion: ', sdim]);        
        xlabel('Frequency [Hz]');
        ylabel(['% THD ']);
        hold on;        
    end
    
    clrs = handles.colors;    
    
    for fid = 1:length(dfs.fid) % Plot each file one by one
        dplot(fid).(sdim).ftest = resfs(fid).(sdim).ftest;
        if get(handles.check_compensate,'value')
            % Compensate for the motion of whole magnet-holding stage.            
            dplot(fid).(sdim).power = resfs(fid).(sdim).power - meanfix.(sdim).power;
        else
            dplot(fid).(sdim).power = resfs(fid).(sdim).power;
        end
            
        switch get(handles.menu_yaxis,'value')            
            case 1 % Power
                dyaxis(fid).(sdim).indH = dplot(fid).(sdim).power; %rows = frequencies, cols = harmonics
                dyaxis(fid).(sdim).allH = sum(dyaxis(fid).(sdim).indH, 2); % Sum all columns 
            case 2 % distance
                for xs = 1:size(dplot(fid).(sdim).power,1) % loop for each frequency one by one
                    dyaxis(fid).(sdim).indH(xs,:) = sqrt(dplot(fid).(sdim).power(xs,:)*2); 
                    dyaxis(fid).(sdim).allH = sqrt(sum(dyaxis(fid).(sdim).indH, 2)*2); 
                end                
            case 3 % distance*Frequency
                for xs = 1:size(dplot(fid).(sdim).power,1) % loop for each frequency one by one
                    ftest = dplot(fid).(sdim).ftest(xs);
                    dyaxis(fid).(sdim).indH(xs,:) = sqrt(dplot(fid).(sdim).power(xs,:)*2)*ftest; 
                    dyaxis(fid).(sdim).allH = sqrt(sum(dyaxis(fid).(sdim).indH, 2)*2)*ftest; 
                end
            otherwise
                    disp('Unrecognized option for Y axis. Tell some programmer to fix');
        end
        
        if get(handles.check_FvsAllH,'Value')
            figure(handles.FvsAllHfigid + dl(dim));
%             loglog(dplot(fid).(sdim).ftest,dyaxis(fid).(sdim).allH,['.-',clrs(mod(fid-1,length(clrs))+1)]);
            plot(dplot(fid).(sdim).ftest,dyaxis(fid).(sdim).allH,['.-',clrs(mod(fid-1,length(clrs))+1)]);
        end
        
        if get(handles.check_FvsFs1,'Value')
            figure(handles.FvsFs1figid + dl(dim));
%             loglog(dplot(fid).(sdim).ftest,dyaxis(fid).(sdim).indH(:,1),['.-',clrs(mod(fid-1,length(clrs))+1)]);           
            plot(dplot(fid).(sdim).ftest,dyaxis(fid).(sdim).indH(:,1),['.-',clrs(mod(fid-1,length(clrs))+1)]);
        end
        
        if get(handles.check_FvsFs2,'Value')
            figure(handles.FvsFs2figid + dl(dim));
%             loglog(dplot(fid).(sdim).ftest,dyaxis(fid).(sdim).indH(:,2),['.-',clrs(mod(fid-1,length(clrs))+1)]);            
            plot(dplot(fid).(sdim).ftest,dyaxis(fid).(sdim).indH(:,2),['.-',clrs(mod(fid-1,length(clrs))+1)]);            
        end 
        
        if get(handles.check_FvsTHD,'Value')
            figure(handles.FvsTHDfigid + dl(dim));
            thd = (sum(dplot(fid).(sdim).power,2)./dplot(fid).(sdim).power(:,1))-1;
%             loglog(dplot(fid).(sdim).ftest,thd,['.-',clrs(mod(fid-1,length(clrs))+1)]);
            plot(dplot(fid).(sdim).ftest,thd,['.-',clrs(mod(fid-1,length(clrs))+1)]);
        end         
    end % Looping through files   
end % Looping through dimensions

for fi = 1:length(figlist)
    figure(figlist(fi));
    hold off; 
%     set(gca,'Xscale','log','Yscale','log');
    set(gca,'Xscale','linear','Yscale','log');
%     set(gca,'Xscale','log','Yscale','linear');
    legend(gca,alltags{dfs.fid});
end
assignin('base','figlist',figlist);
dbclear if error

% ------------------------------------------------------------------------
function slider_fseg_Callback(hObject, eventdata, handles)
update_fseg(handles,'slider');
% ------------------------------------------------------------------------
function edit_fseg_Callback(hObject, eventdata, handles)
update_fseg(handles,'edit');
pause(0.5);
button_segpsd_Callback(handles.button_segpsd, eventdata, handles);
% ------------------------------------------------------------------------
function update_fseg(handles,caller);
lastarray = get(handles.slider_fseg,'UserData');
switch caller
    case 'slider'
        if get(handles.slider_fseg,'value') > 0
            newarray = lastarray - min(lastarray) + max(lastarray) + mean(diff(lastarray));
        elseif get(handles.slider_fseg,'value') < 0
            newarray = lastarray + min(lastarray) - max(lastarray) -  mean(diff(lastarray));
            if any(newarray) <= 0
                newarray = lastarray;
            end
        end
    case 'edit'
        newarray = parse_csv_int(get(handles.edit_fseg,'String'));
        if isempty(newarray)
            newarray = lastarray;
        end
end
if (length(newarray) > 10)
    errordlg('Too many frequencies in the segment-psd list. Reduce to less than 11.');
    newarray = lastarray;    
end
set(handles.slider_fseg,'UserData',newarray);
set(handles.edit_fseg,'string',num2str(newarray));
newarray
% --- Executes on button press in button_segpsd.
function button_segpsd_Callback(hObject, eventdata, handles)
% Plot psd of the segments that correspond to frequencies listed in
% edit_fseg box. Overlay each file one by one.
global g
dl = get(handles.lta.list_dims,'value'); % list of requested dimensions
rxyz = 'rxyz';
fseg = get(handles.slider_fseg,'UserData');

rexp = get(handles.button_selectFS,'UserData');
rfix = get(handles.button_selectFixed,'UserData');
clrs = handles.colors;
alltags = g.tag;
for ifreq = 1:length(fseg) % Process and plot for each frequency one by one.
    for dim = 1:length(dl) % process and plot for each requested dimension one by one        
        figure(handles.segpsdfigid +10*(ifreq-1) + dl(dim));
        xlabel('Frequency Hz');
        ylabel('PSD Power/Hz');
        title(['Segment PSD for excitation frequency: ', fseg(ifreq), ' Hz',...
            ', Dimension: ', rxyz(dl(dim))]);
        hold on
        for iex = 1:length(rexp.fid) %process each file in the 'experiment' list one by one
            fileid = rexp.fid(iex);
            allf = rexp.iseg(fileid).ftest;
            % find index of the nearest excitation frequency. This gives pointer
            % to the segment that needs to be processed
            inearest = round(interp1(allf,[1:1:length(allf)],fseg(ifreq)));
            i_st = rexp.iseg(fileid).bpos_st(inearest);
            i_end = rexp.iseg(fileid).bpos_end(inearest);
            pseg = g.data{fileid}.beadpos(i_st:i_end,dl(dim)+1);
            [p, f] = mypsd(pseg,handles.lta.srate);
            loglog(f,p,['.-',clrs(mod(iex-1,length(clrs))+1)]);
        end
        % Now process each file in the 'fixed bead' list one by one
        coff = length(rexp.fid);
        for ifx = 1:length(rfix.fid)
            fileid = rfix.fid(ifx);
            allf = rfix.iseg(fileid).ftest;
            % find index of the nearest excitation frequency. This gives pointer
            % to the segment that needs to be processed
            inearest = round(interp1(allf,[1:1:length(allf)],fseg(ifreq)));
            i_st = rfix.iseg(fileid).bpos_st(inearest);
            i_end = rfix.iseg(fileid).bpos_end(inearest);
            pseg = g.data{fileid}.beadpos(i_st:i_end,dl(dim)+1);
            [p, f] = mypsd(pseg,handles.lta.srate);
            % Plot the fixed bead psd withot any marker
            loglog(f,p,['-',clrs(mod(coff+ifx-1,length(clrs))+1)]);
        end
        legend(gca,alltags{[rexp.fid,rfix.fid]});       
        hold off; set(gca,'Xscale','log','Yscale','log');
    end
end

% ------------------------------------------------------------------------
function iseg = detectsegments(fids,handles);
% This routine segments out the time-pos trace so that each segment contains 
% tracking data for only one excitation frequency in the frequency sweep. 
% Here the main challenge is automatically separating out individual
% excitation frequency and associated tracking data.
% Strategy: Detect when the magnet-synchoronizer signal crosses some
% small (above noise floor) threshold with positive edge. Each crossing
% indicates start of a new excitation frequency. I choose 0.007 volts
% as the threshold because
% 1. it is above the noise floor
% 2. it falls between two steps of magnet DAC board.
% this helps against DAC+ADC noise that is present only on the
% voltage levels that correspond to the steps of DAC board.
% All files listed in fids will be segmented one
% by one and then indices of the segments will be returned.
% THIS ROUTINE ASSUMES THAT MAGSYNC CABLE WAS CONNECTED AND THAT THE
% MAGDATA IS ATTACHED.
global g
dbstop if error
THRESHOLD = 0.007;
fail_count = 0;
tsrate = handles.lta.srate;
for c = 1:length(fids)
    bpos = g.data{fids(c)}.beadpos;    
    magdata = g.magdata{fids(c)};
    msync = g.data{fids(c)}.laser;
    % Now segment the data
    idx = find(diff(msync(:,2)>THRESHOLD)>0); % detect +ve edge threshold crosssings
    % Check that number of crossings detected match with number of test
    % frequencies. This is the only test that our edge-detection
    % algorithm works
    if ~isequal(length(idx),length(magdata.info.param.fvec))
        disp(['Error: number of edge-detection crossings do not match',num2str(fids(c))]);
        goon =questdlg(['Error: number of edge-detection crossings do not match', ...
            num2str(fids(c)),'What is your wish?'], 'Ignore and move to next file', ...
            'Debug');
        if isequal(goon,'Debug');
            keyboard;
        else
            for dim = 1:4
                iseg(fids(c)).bpos_st = [];
                iseg(fids(c)).bpos_end = [];
                iseg(fids(c)).icrossing = [];
                iset(fid(c)).ftest = [];
            end
            fail_count = fail_count + 1;
            continue;
        end
    else
        iseg(fids(c)).icrossing = idx;
        fvec = magdata.info.param.fvec;        
        % Because the amplifier can go unstable for step inputs,
        % we start and stop all sinewaves exactly at zero. Because the
        % three sine waves are 120 degree apart in phase, we don't have
        % sinusoidal forces for 2/3rd of the first cycle and 2/3rd of
        % the last cycle. The excitation program
        % (threePoleFreqSweep.gui upto version 2.2 only adds one extra
        % cycle, so we have magdata.info.param.nCycles - 1 number of cycles to work
        % with.
        if str2double(magdata.info.version) <= 2.2
            Nless = 1;
        else
            Nless = 0; % The bug is fixed in later versions than 2.2 by adding two extra cycles instead of one
        end
        % Note, .laser and .beadpos MAY have some offset in time stamps.
        % Compute this offset before looping through segments.
        if bpos(1,1) >= msync(1,1); %bpos started after laser            
            noff = interp1(bpos(:,1),[1:length(bpos(:,1))],msync(1,1), 'nearest');            
        else % bpos started before laser
            noff = -interp1(msync(:,1),[1:length(msync(:,1))],bpos(1,1), 'nearest');
        end
            
        % Now process each segment
        for k = 1:length(idx)
            % remove the intial 2/3rd of cycle and last 2/3rd of cycle
            ftest = fvec(k);
            Ncut = ceil((2/3)*tsrate/ftest);
            ilaser_st = idx(k)+ Ncut;
            ilaser_end = floor(ilaser_st + tsrate*(1/ftest)*(magdata.info.param.nCycles - Nless)); % points for nCycles - 1
            % Now find contemporary bead positions
            
%             ibpos_st = max(find(bpos(:,1) <= msync(ilaser_st,1)));
%             ibpos_end = max(find(bpos(:,1) <= msync(ilaser_end,1)));            
%             ibpos_st = ceil(interp1(bpos(:,1),indvec,msync(ilaser_st,1)));
%             ibpos_end = floor(interp1(bpos(:,1),indvec,msync(ilaser_end,1)));
            ibpos_st = ilaser_st - noff;
            ibpos_end = ilaser_end - noff;
            iseg(fids(c)).bpos_st(k) = ibpos_st;
            iseg(fids(c)).bpos_end(k) = ibpos_end;
            iseg(fids(c)).ftest(k) = ftest;
        end
    end
end
%--------------------------------------------------------------------------
%%***********       FREQUENCY RESPONSE COMPUTATION       ******************
function    [res, meanres] = computefs(fids,iseg,handles)
global g
dbstop if error
rxyz = 'rxyz';
for c = 1:length(fids)
    % iseg containts segments for all excitation frequencies. First focus down
    % to the excitation frequencies that the user is interested in and then
    % loop through all associated segments
    fAll = iseg(fids(c)).ftest;
    frange(1) = str2double(get(handles.edit_fmin,'string'));
    frange(2) = str2double(get(handles.edit_fmax,'string'));
    iwithin = find(fAll <= frange(2) & fAll >= frange(1));
    fwithin = fAll(iwithin);
    bpos = g.data{fids(c)}.beadpos;
    % Now process each segment
    for k = 1:length(fwithin)
        ftest = fwithin(k);
        ibpos_st = iseg(fids(c)).bpos_st(iwithin(k));
        ibpos_end = iseg(fids(c)).bpos_end(iwithin(k));

        seg = bpos(ibpos_st:ibpos_end,:);
        if range(diff(seg(:,1))) > 1E-6 % uneven time stamps
            disp(['Uneven Time Stamps:', 'Fid: ', num2str(fids(c)), 'Ftest: ', num2str(ftest)]);
            srate = handles.lta.srate;
            oldseg = seg;
            seg = [];
            seg(:,1) = [oldseg(1,1):1/srate:oldseg(end,1)]';
            for cl = 2:size(oldseg,2);
                seg(:,cl) = interp1(oldseg(:,1),oldseg(:,cl),seg(:,1));
            end
            clear oldseg
        end
        % Now compute radial vector for bead positions in this segment
        rseg(:,1) = seg(:,1);
        rseg(:,3:5) = seg(:,2:4) - repmat(seg(1,2:4),size(seg,1),1);
        rseg(:,2) = sqrt(rseg(:,3).^2 + rseg(:,4).^2 + rseg(:,5).^2);
        clear seg; seg = rseg; clear rseg;
        % Now compute psd of the segment, using best available frequency resolution
        [segp, segf] = mypsd(seg(:,2:5),handles.lta.srate,[]);

        % process peaks upto 4 hormonics
        for dim = 1:4
            res(c).ibeadpos = [ibpos_st, ibpos_end];
            for ip = 1:4
                peak = processpeak(segp(:,dim),segf,ftest*ip,0);
                if peak.p == 0
                    keyboard;
                end
                res(c).(rxyz(dim)).power(k,ip) = peak.p;
                res(c).(rxyz(dim)).ftest(k) = ftest;
                % Initiate meanres if this is the first file
                if c == 1
                    meanres.(rxyz(dim)).power(k,ip) = peak.p;
                else
                    meanres.(rxyz(dim)).power(k,ip) = meanres.(rxyz(dim)).power(k,ip) + peak.p;
                end
                meanres.(rxyz(dim)).ftest(k) = ftest;
                % Now normalize if this is the last file
                if c == length(fids)
                    meanres.(rxyz(dim)).power(k,ip) = meanres.(rxyz(dim)).power(k,ip)/c;
                end
            end %looping through harmonics
        end % looping through dimensions
    end % looping through segments
end % looping through files

dbclear if error

%%===========   COMPLETED FREQUENCY RESPONSE COMPUTATION    ===============
% --- Executes on button press in button_exportfs.
function button_exportfs_Callback(hObject, eventdata, handles)


% --- Executes on button press in button_savefs.
function button_savefs_Callback(hObject, eventdata, handles)


function edit_fmin_Callback(hObject, eventdata, handles)


function edit_fmax_Callback(hObject, eventdata, handles)


% --- Executes on button press in button_backdoor.
function button_backdoor_Callback(hObject, eventdata, handles)
% hObject    handle to button_backdoor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g
keyboard


% --- Executes on selection change in menu_yaxis.
function menu_yaxis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_yaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns menu_yaxis contents as cell array
%        contents{get(hObject,'Value')} returns selected item from menu_yaxis


% --- Executes on button press in check_compensate.
function check_compensate_Callback(hObject, eventdata, handles)
% hObject    handle to check_compensate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_compensate



% --- Executes on button press in check_FvsAllH.
function check_FvsAllH_Callback(hObject, eventdata, handles)
% hObject    handle to check_FvsAllH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_FvsAllH


% --- Executes on button press in check_FvsFs1.
function check_FvsFs1_Callback(hObject, eventdata, handles)
% hObject    handle to check_FvsFs1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_FvsFs1


% --- Executes on button press in check_FvsFs2.
function check_FvsFs2_Callback(hObject, eventdata, handles)
% hObject    handle to check_FvsFs2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_FvsFs2


% --- Executes on button press in check_FvsTHD.
function check_FvsTHD_Callback(hObject, eventdata, handles)
% hObject    handle to check_FvsTHD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_FvsTHD













% --- Executes during object creation, after setting all properties.
function edit_fmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_fmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function menu_yaxis_CreateFcn(hObject, eventdata, handles)
% hObject    handle to menu_yaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_fseg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fseg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function slider_fseg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_fseg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




