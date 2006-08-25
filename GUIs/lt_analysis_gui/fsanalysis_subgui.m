function varargout = fsanalysis_subgui(varargin)
% FSANALYSIS_SUBGUI
% 3DFM UTILITY
% Written by: Kalpit Desai, May 1, 2006.
%
% FSANALYSIS_SUBGUI M-file for fsanalysis_subgui.fig
%      FSANALYSIS_SUBGUI, by itself, creates a new FSANALYSIS_SUBGUI or
%      raises the existing singleton*.
%
%      H = FSANALYSIS_SUBGUI returns the handle to a new FSANALYSIS_SUBGUI
%      or the handle to the existing singleton*.
%
%      FSANALYSIS_SUBGUI('CALLBACK',hObject,eventData,handles,...) calls
%      the local function named CALLBACK in FSANALYSIS_SUBGUI.M with the
%      given input arguments.
%
%      FSANALYSIS_SUBGUI('Property','Value',...) creates a new
%      FSANALYSIS_SUBGUI or raises the existing singleton*.  Starting from
%      the left, property value pairs are applied to the GUI before
%      fsanalysis_subgui_OpeningFunction gets called.  An unrecognized
%      property name or invalid value makes property application stop.  All
%      inputs are passed to fsanalysis_subgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help fsanalysis_subgui

% Last Modified by GUIDE v2.5 24-Aug-2006 13:54:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fsanalysis_subgui_OpeningFcn, ...
                   'gui_OutputFcn',  @fsanalysis_subgui_OutputFcn, ...
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


% --- Executes just before fsanalysis_subgui is made visible.
function fsanalysis_subgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fsanalysis_subgui (see VARARGIN)

% Choose default command line output for fsanalysis_subgui
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

% UIWAIT makes fsanalysis_subgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fsanalysis_subgui_OutputFcn(hObject, eventdata, handles) 
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
    [selec,ok] = listdlg('ListString',goodstr,...
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

% --- Executes on button press in button_selectPass.
function button_selectPass_Callback(hObject, eventdata, handles)
% select file associated with passive diffusion. 
global g
allstr = get(handles.lta.menu_files,'String');
[selec,ok] = listdlg('ListString',allstr,...
    'InitialValue',1,'OKstring','Select',...
    'Name','Select fixed bead freq sweep file(s)');
if ok
    set(handles.button_selectPass,'UserData',selec);
else
    set(handles.button_selectPass,'UserData',[]);
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
    [selec,ok] = listdlg('ListString',goodstr,...
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
dbstop if error
dfs = get(handles.button_selectFS,'UserData'); 
dfx = get(handles.button_selectFixed,'UserData'); 

if get(handles.check_compnFixed,'value')
    outfix  = computefs(dfx.fid, dfx.iseg, handles);
    assignin('base','outfix',outfix);
    % Normalizing by the response to the interleaved control-frequency
    % doesn't make sense for the fixed bead case. 
    resfix = outfix.res; meanfix = outfix.meanres;    
end
out = computefs(dfs.fid, dfs.iseg, handles);
assignin('base','outfs',out);
if get(handles.check_normalize,'Value')
    resfs = out.normres; meanfs = out.meannormres;    
else
    resfs = out.res; meanfs = out.meanres;
end
allstr = get(handles.menu_yaxis,'string');
stry = allstr{get(handles.menu_yaxis,'value')};
alltags = g.tag;
figlist = [];
xyzrr = {'x','y','z','xy','r'};
dl = get(handles.lta.list_dims,'value');
for dim = 1:length(dl)
    sdim = xyzrr{dl(dim)};
    % Initialize all figures for this dimension
    if get(handles.check_FvsAllH,'Value')
        hfthis = handles.FvsAllHfigid + dl(dim); figlist = [figlist,hfthis];
        figure(hfthis); clf;          
        title(['Frequency response @ 1st to 4th harmonic: ', sdim]);        
        xlabel('Frequency [Hz]');
        ylabel(['Response [',stry,']']);
        hold on;        
    end
    if get(handles.check_FvsFs1,'Value')
        hfthis = handles.FvsFs1figid + dl(dim); figlist = [figlist,hfthis];
        figure(hfthis); clf;     
        title(['Frequency response @ Fundamental: ', sdim]);        
        xlabel('Frequency [Hz]');
        ylabel(['Response [',stry,']']);
        hold on;        
    end
    if get(handles.check_FvsFs2,'Value')
        hfthis = handles.FvsFs2figid + dl(dim); figlist = [figlist,hfthis];
        figure(hfthis); clf;    
        title(['Frequency response @ 2nd harmonic: ', sdim]);        
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
        if get(handles.check_compnDiffuse,'Value')
            dplot(fid).(sdim).power = resfs(fid).(sdim).active_power;
        elseif get(handles.check_compnFixed,'value') %DEPRICATED???
            % Compensate for the motion of whole magnet-holding stage.
            % NOTE: This approach assumes that motion of the stage seen for
            % the fixed-beads specimen is comparable to the motion of the stage seen
            % for the specimen of the real experiment. However, this
            % assumption may not be true. Unless you know what you are doing, 
            % IT IS ADVISABLE NOT TO USE THIS OPTION. Also, for most of the cases, the
            % overall motion of the stage could be avoided by not using the
            % shorted coils. 
            for j = 1:length(dplot(fid).(sdim).ftest)
                fthis = dplot(fid).(sdim).ftest(j);
                dplot(fid).(sdim).power(j,:) = resfs(fid).(sdim).power(j,:)...
                - meanfix.(sdim).power(find(meanfix.(sdim).ftest == fthis),:);
            end
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
                    error('Unrecognized option for Y axis. Tell some programmer to fix');
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
    set(gca,'Xscale','log','Yscale','log');
%     set(gca,'Xscale','linear','Yscale','log');
%     set(gca,'Xscale','log','Yscale','linear');
    legend(gca,alltags{dfs.fid});
end
assignin('base','figlist',figlist);
dbclear if error

% ------------------------------------------------------------------------
function slider_fseg_Callback(hObject, eventdata, handles)
update_fseg(handles,'slider');
pause(0.5);
button_segpsd_Callback(handles.button_segpsd, eventdata, handles);
% ------------------------------------------------------------------------
function edit_fseg_Callback(hObject, eventdata, handles)
update_fseg(handles,'edit');

% ------------------------------------------------------------------------
function update_fseg(handles,caller);
lastarray = get(handles.slider_fseg,'UserData');
if length(lastarray) > 1
    fstep = mean(diff(lastarray));
else
    fstep = 10;
end
switch caller
    case 'slider'
        if get(handles.slider_fseg,'value') >= 5
            newarray = lastarray - min(lastarray) + max(lastarray) + fstep;
        elseif get(handles.slider_fseg,'value') < 5
            newarray = lastarray + min(lastarray) - max(lastarray) - fstep;
            if any(newarray) <= 0
                newarray = lastarray;
            end
        end
        set(handles.slider_fseg,'value',5);
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

% --- Executes on button press in button_segpsd.
function button_segpsd_Callback(hObject, eventdata, handles)
% Plot psd of the segments that correspond to frequencies listed in
% edit_fseg box. Overlay each file one by one.
global g
dl = get(handles.lta.list_dims,'value'); % list of requested dimensions
xyzrr = {'x','y','z','xy','r'};
fseg = get(handles.slider_fseg,'UserData');

rexp = get(handles.button_selectFS,'UserData');
rfix = get(handles.button_selectFixed,'UserData');
clrs = handles.colors;
alltags = g.tag;
for ifreq = 1:length(fseg) % Process and plot for each frequency one by one.
    for dim = 1:length(dl) % process and plot for each requested dimension one by one        
        figure(handles.segpsdfigid +10*(ifreq-1) + dl(dim)); clf;
        xlabel('Frequency Hz');
        ylabel('PSD Power/Hz');
        title(['Segment PSD for excitation frequency: ', num2str(fseg(ifreq)), ' Hz',...
            ', Dimension: ', xyzrr{dl(dim)}]);
        hold on
        for iex = 1:length(rexp.fid) %process each file in the 'experiment' list one by one
            fileid = rexp.fid(iex);
            allf = rexp.iseg(fileid).ftest;
            if g.magdata{fileid}.info.param.docontrol == 1
                allf = allf(find(allf ~= g.magdata{fileid}.info.param.fcont));
            end
            % find index of the nearest excitation frequency. This gives pointer
            % to the segment that needs to be processed
            inearest = round(interp1(allf,[1:1:length(allf)],fseg(ifreq)));
            i_st = rexp.iseg(fileid).bpos_st(inearest);
            i_end = rexp.iseg(fileid).bpos_end(inearest);
            txyz = g.data{fileid}.beadpos(i_st:i_end,:);
            switch dl(dim)
                case {1,2,3}
                    pseg = txyz(:,dl(dim)+1);
                case 4 % XY
                    pseg = sqrt(sum(txyz(:,2:3) - repmat(txyz(1,2:3),size(txyz,1),1).^2, 2));
                case 5 % R
                    pseg = sqrt(sum(txyz(:,2:4) - repmat(txyz(1,2:4),size(txyz,1),1).^2, 2));
            end            
            [p, f] = mypsd(pseg,handles.lta.srate);
            loglog(f,p,['.-',clrs(mod(iex-1,length(clrs))+1)]);
        end
        legstr = alltags(rexp.fid);

        if ~isempty(rfix)
            % Now process each file in the 'fixed bead' list one by one
            coff = length(rexp.fid); %offset in color
            for ifx = 1:length(rfix.fid)
                fileid = rfix.fid(ifx);
                allf = rfix.iseg(fileid).ftest;
                % find index of the nearest excitation frequency. This gives pointer
                % to the segment that needs to be processed
                if g.magdata{fileid}.info.param.docontrol == 1
                    allf = allf(find(allf ~= g.magdata{fileid}.info.param.fcont));
                end
                inearest = round(interp1(allf,[1:1:length(allf)],fseg(ifreq)));
                i_st = rfix.iseg(fileid).bpos_st(inearest);
                i_end = rfix.iseg(fileid).bpos_end(inearest);
                txyz = g.data{fileid}.beadpos(i_st:i_end,:);
                if dl(dim) == 1 % THis is radial dimension
                    pseg = sqrt(txyz(:,2).^2 + txyz(:,3).^2 + txyz(:,4).^2);
                else
                    pseg = txyz(:,dl(dim)+1-1);
                end
                [p, f] = mypsd(pseg,handles.lta.srate);
                % Plot the fixed bead psd without any marker
                loglog(f,p,['-',clrs(mod(coff+ifx-1,length(clrs))+1)]);
            end
            legstr =alltags([rexp.fid,rfix.fid]);
        end
        
        hold off; set(gca,'Xscale','log','Yscale','log');
        drawlines(gca,fseg(ifreq)*[1:4]);
        legend(gca,legstr,'Location','Best');
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
    if magdata.info.param.docontrol == 1 % if the control frequency was interleaved
        allf(1,:) = magdata.info.param.fvec;
        allf(2,:) = repmat(magdata.info.param.fcont,size(magdata.info.param.fvec));
        fvecall = reshape(allf,1,[]);
    else
        fvecall = magdata.info.param.fvec;
    end
    % Now segment the data
    idx = find(diff(msync(:,2)>THRESHOLD)>0); % detect +ve edge threshold crosssings
    % Check that number of crossings detected match with number of test
    % frequencies. This is the only test verifying that our edge-detection
    % algorithm worked successfully.
    if ~isequal(length(idx),length(fvecall))
        disp(['Error: number of edge-detection crossings do not match',num2str(fids(c))]);
        goon =questdlg(['Error: number of edge-detection crossings do not match for file #', ...
            num2str(fids(c)),' What is your wish?'], 'Error in detecting segments', ...
            'Ignore and move to next file', 'Debug matlab code' , 'Ignore and move to next file');
        if isequal(goon,'Debug matlab code');
            keyboard;
        else
            for dim = 1:4
                iseg(fids(c)).bpos_st = [];
                iseg(fids(c)).bpos_end = [];
                iseg(fids(c)).icrossing = [];
                iset(fids(c)).ftest = [];
            end
            fail_count = fail_count + 1;
            continue;
        end
    else
        iseg(fids(c)).icrossing = idx;
            
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
            Nless = 0; % The bug is fixed in versions later than 2.2 by adding two extra cycles instead of one
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
            % remove the intial 2/3rd of a cycle and last 2/3rd of a cycle
            ftest = fvecall(k);
            Ncut = ceil((2/3)*tsrate/ftest);
            ilaser_st = idx(k)+ Ncut;
            ilaser_end = floor(ilaser_st + tsrate*(1/ftest)*(magdata.info.param.nCycles - Nless)); % points for nCycles - 1
            % Now find contemporary bead positions
           
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
% fids: File indices
% iseg: index-pairs of segment boundaries
% out.res(:).ibeadpos
%           .(x,y,z,xy,r).power
%           .(x,y,z,xy,r).ftest
%           .(x,y,z,xy,r).active_power (when opted to compensate for
%                                       passive diffusion)
% out.meanres.power 
%            .ftest
%            .active_power
% out.normres(:) :: When opted for normalization. 
%                   Structure is same as that of out.res, but the numbers
%                 are normalized with the response at the control frequency
% out.meannormres(:)
% 
function out = computefs(fids,iseg,handles)
global g
dbstop if error
xyzrr = {'x','y','z','xy','r'};
% Check if user has selected to account for the passive diffusion
if get(handles.check_compnDiffuse,'Value')
    fpass = get(handles.button_selectPass,'UserData');
    % consider only one file for the passive dataset. For now. Compute the
    % radial positions.
    passpos = radialpos(g.data{fpass(1)}.beadpos,[],1);
    % Compute psd for the passive dataset
    [passp, passf] = mypsd(passpos(:,2:end),handles.lta.srate,[]);
end

for c = 1:length(fids) % Process each file one by one
    magdata = g.magdata{fids(c)};
    % iseg containts segments for all excitation frequencies. First focus down
    % to the excitation frequencies that the user is interested in and then
    % loop through all associated segments. If the control frequency was
    % interleaved then consider it in the list of the frequencies even if it
    % falls out of range.
    fAll = iseg(fids(c)).ftest;
    if magdata.info.param.docontrol == 1
        fcont = magdata.info.param.fcont;
        iclean = (find(fAll ~= magdata.info.param.fcont));
    else
        iclean = 1:length(fAll);
    end
    
    frange(1) = str2double(get(handles.edit_fmin,'string'));
    frange(2) = str2double(get(handles.edit_fmax,'string'));
    iwithin = iclean(find(fAll(iclean) >= frange(1) & fAll(iclean) <= frange(2)));
    if magdata.info.param.docontrol == 1
        iwithin = sort([iwithin, iwithin+1]);
        % Assuming that all test-frequency bursts are followed by one
        % control-frequency burst.
    end    
    fwithin = fAll(iwithin);
    bpos = g.data{fids(c)}.beadpos;
    % Now process each segment
    kk = 0;
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
        seg = radialpos(seg,[],1);
        
        % Now compute PSD of this segment and process the relevant peak
        [segp, segf] = mypsd(seg(:,2:end),handles.lta.srate,[]);
        
        for dim = 1:length(xyzrr)
            sdim = xyzrr{dim};
            res(c).ibeadpos(k,:) = [ibpos_st, ibpos_end];
            for ip = 1:4% process peaks upto 4 hormonics
                peak = processpeak(segp(:,dim),segf,ftest*ip,0);
                if peak.p == 0
%                     keyboard;
                end
                
                res(c).(sdim).power(k,ip) = peak.p;
                res(c).(sdim).ftest(k) = ftest;
                
                % IF we are told to compensate for the passive diffusion,
                % then process the relevant peaks in the psd of the passive
                % motion
                if get(handles.check_compnDiffuse,'value')
                    passpeak = processpeak(passp(:,dim),passf,ftest*ip,0);
                    res(c).(sdim).active_power(k,ip) = ...
                        res(c).(sdim).power(k,ip) - passpeak.p;
                end
                % Initiate meanres structure if this is the first file
                if c == 1
                    meanres.(sdim) = res(c).(sdim); 
                else
                    meanres.(sdim).power(k,ip) = (1/c)* ...
                        (meanres.(sdim).power(k,ip)*(c-1) + res(c).(sdim).power(k,ip));
                    if get(handles.check_compnDiffuse,'value')
                        meanres.(sdim).active_power(k,ip) = (1/c)* ...
                            (meanres.(sdim).active_power(k,ip)*(c-1) + ...
                            res(c).(sdim).active_power(k,ip));                   
                    end
                    meanres.(sdim).ftest(k) = ftest;
                end
            end %looping through harmonics
        end % looping through dimensions
        % If the control-frequency bursts were interleaved, then normalize
        % the response at the test frequency by the average of the
        % responses at the control-frequency bursts immediately before and
        % after the particular test-frequency burst. Then check
        % if the current segment is a control-frequency burst and if it is
        % then normalize the response at the previous burst.
        if magdata.info.param.docontrol == 1 & isequal(ftest, fcont) & k > 1
            kk = kk + 1;            
            for dim = 1:length(xyzrr)
                sdim = xyzrr{dim};
                normres(c).(sdim).ftest(kk) = res(c).(sdim).ftest(k-1);
                if k < 3
                    normres(c).(sdim).power(kk,:) = ...
                        res(c).(sdim).power(k-1,:) ./ ...
                        res(c).(sdim).power(k,:);
                else                     
                    normres(c).(sdim).power(kk,:) = ...
                        res(c).(sdim).power(k-1,:) ./ ...
                        (0.5*(res(c).(sdim).power(k,:) + ...
                        res(c).(sdim).power(k-2,:)));
                end
                if get(handles.check_compnDiffuse,'Value')
                    if k < 3
                        normres(c).(sdim).active_power(kk,:) = ...
                            res(c).(sdim).active_power(k-1,:) ./ ...
                            res(c).(sdim).active_power(k,:);
                    else
                        normres(c).(sdim).active_power(kk,:) = ...
                            res(c).(sdim).active_power(k-1,:) ./ ...
                            (0.5*(res(c).(sdim).active_power(k,:) + ...
                            res(c).(sdim).active_power(k-2,:)));
                    end
                end
                % Initiate meannormres structure if this is the first file
                if c == 1
                    meannormres.(sdim) = normres(c).(sdim); 
                else
                    meannormres.(sdim).power(kk,ip) = (1/c)* ...
                        (meannormres.(sdim).power(kk,ip)*(c-1) + normres(c).(sdim).power(kk,ip));
                    if get(handles.check_compnDiffuse,'value')
                        meannormres.(sdim).active_power(kk,ip) = (1/c)* ...
                            (meannormres.(sdim).active_power(kk,ip)*(c-1) + ...
                            normres(c).(sdim).active_power(kk,ip));                   
                    end
                    meannormres.(sdim).ftest(kk) = ftest;
                end                
            end % looping through dimensions
        end % checking if we need normalization
    end % looping through segments (k)
end % looping through files (c)
out.res = res;
out.meanres = meanres;
if exist('normres','var')
    out.normres = normres;
    out.meannormres = meannormres;
end   
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


% --- Executes on button press in check_compnFixed.
function check_compnFixed_Callback(hObject, eventdata, handles)
% hObject    handle to check_compnFixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_compnFixed



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


% --- Executes on button press in check_normalize.
function check_normalize_Callback(hObject, eventdata, handles)
% hObject    handle to check_normalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_normalize



% --- Executes on button press in check_.
function check_compnDiffuse_Callback(hObject, eventdata, handles)
% hObject    handle to check_ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_


