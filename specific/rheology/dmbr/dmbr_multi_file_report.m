function out = dmbr_multi_file_report(excel_name, seq_array, file_array)
%
% Christian Stith <chstith@ncsu.edu> and Jeremy Cribb, 06-28-2012
% dmbr_multi_file_report.m
% Allows a user to run multiple data files through dmbr_report_cell_expt at
% once, creating one comprehensive HTML and Excel report. Can also be used
% to run a single data file. Users can select any combination of files and
% directories; the report will parse all relevant data files out of any
% folders selected. Runs dmbr_adjust_report upon completion.
%
% Required Parameters:
%   excel_name: the root name of the new analysis
% Optional Parameters:
%   seq_arry: the array of selected sequences
%   file_array: the array of selected files
% Returns:
%   the full filepath & name of the html file
%
% Command Line Syntax:
%   dmbr_multi_file_report(<Analysis_Name>)
% Example:
%   dmbr_multi_file_report('DataAnalysis')
%

    if(nargin<2)
        filelist = full_list(uipickfiles());
    else
        filelist = file_array;
    end
    
    if isempty(filelist)
        fprintf('No files selected. Program terminated.\n');
        return;
    end
    
    plot_selection = report_gui();
    if plot_selection(1) == -1
        return;
    end
    
    filelist = char(filelist);
    filelist = sortn(filelist);
    dirs = cell(size(filelist));

    for b=1:(size(filelist))
        [fpath, junk, junk] = fileparts(char((filelist(1))));
        dirs(b,:) = cellstr(fpath);
    end
    topdir = char(dirs(1,:));
    topdir = strcat(topdir, filesep);
    pathname = topdir;
    
    xlfilename = [topdir excel_name '.xlsx'];
    
    filelist = char(filelist);
    files = cell(size(filelist, 1), 1);
        
    count = 0;
    for b = 1:size(filelist,1)
        fname = filelist(b,:);
        index = strfind((fname), '.vfd.mat');
        index1 = strfind((fname), '.raw.vrpn.evt.mat');
        if ~isempty(index)
            count = count + 1;
            first = index(1);
            files(count) = cellstr(filelist(b,1:first-1));
        elseif ~isempty(index1) 
            count = count + 1;
            first = index1(1);
            files(count) = cellstr(filelist(b,1:first-1));            
        else
            files(count+1) = [];
 
        end
    end

    
    files = char(files);
    files = unique(files, 'rows');
    files = char(sortn(files));
    if isempty(files)
        fprintf('No files selected. Program terminated.\n');
        return;
    end
    
    
    counter = 1;

    while counter <= size(files,1);
        % check all files for breakpoints data
        [pathname, filename_root, ext, versn] = fileparts(files(counter,:));
        cd(pathname);
        filename_root = strtrim(filename_root);
        metadatafile = strcat(filename_root, '.vfd.mat');
        trackfile = tracking_check(filename_root);
        if ~exist(metadatafile, 'file')
            fprintf('***The file ');
            fprintf('%s', metadatafile);
            fprintf(' was not found. This file will be skipped.\n');
            % delete file from list
            files(counter,:) = [];
            continue;
        elseif strcmp(trackfile, 'NULL')
            fprintf('***The tracking file for ');
            fprintf('%s', filename_root);
            fprintf(' was not found. This file will be skipped.\n');
            % delete file from list
            files(counter,:) = [];
            continue;
        else
            counter = counter + 1;
        end
        m = load(metadatafile);
        m.trackfile = trackfile;
        m.poleloc = 'poleloc.txt';
        if ~isfield(m, 'time_selected')     
            %%%%
            % identify location of a break between sequences by clicking on plot
            %%%%
            video_tracking_constants;
            table = load_video_tracking(m.trackfile, m.fps, 'm', m.calibum, 'relative', 'yes', 'table');
            table(:,X) = table(:,X) - m.poleloc(1);
            table(:,Y) = table(:,Y) - m.poleloc(2);
            table(:,TIME) = table(:,TIME) - min(table(:,TIME));
            m.time_selected = get_sequence_break(table);
        end
        save(metadatafile, '-struct', 'm');

    end
    
    cd(topdir);
    
    sizeheader = 0;
    if(plot_selection(4, 1))
        if exist(xlfilename, 'file')
            delete(xlfilename);
        end
        sizeheader = writeheader(files, xlfilename, topdir);
    end
        
    htmlfile = [topdir excel_name '.html'];
    if exist(htmlfile)
        delete(htmlfile);
    end
    fid = fopen(htmlfile, 'w');
    fprintf(fid, '<html>\n');
    fprintf(fid, '<a name="Contents"><b>Contents:</b></a>\n<br/>');
    for b=1: size(files, 1);
        [pathname, filename_root, ext] = fileparts(files(b,:));
        fprintf(fid, '<a href="#%s">%s</a><br/>\n', filename_root, filename_root);
    end
    fclose(fid);
    xlfilename = [topdir excel_name];


    % beads in files, sequences availiable in Selector
    checkbxs = [0, 0];
    % beads actually used, max sequences used
    reportbxs = [0, 0];
    % all individual sequences 
    inseqs = [];
    
    
    adjust = cell(size(files,1), 3);
    
    for b=1:(size(files,1))
        % analyze all data
        if(nargin<2)
            temp = dmbr_report_cell_expt(strtrim(files(b,:)), [topdir excel_name], topdir, sizeheader, plot_selection);
        else
            temp = dmbr_report_cell_expt(strtrim(files(b,:)), [topdir excel_name], topdir, sizeheader, plot_selection, seq_array);
        end
        bxs = temp{1};
       
        start = length(inseqs);
        inseqs = vertcat(inseqs, temp{2});
        if(nargin>1)
            seq_array(1:(bxs(1,1)*bxs(1,2))) = [];
        end
        
        
        adjust{b, 1} = files(b,:);
        adjust{b, 2} = bxs(1,1);
        adjust{b, 3} = bxs(1,2);
        for i=1:bxs(1,1)
            adjust{b, i+3} = inseqs(start+i);
        end
        
        checkbxs(1, 1) = checkbxs(1, 1) + bxs(1, 1);
        checkbxs(1, 2) = checkbxs(1, 2) + bxs(1, 2);
        
        reportbxs(1, 1) = reportbxs(1, 1) + bxs(1, 3);
        if(bxs(1, 4) > reportbxs(1, 2))
            reportbxs(1, 2) = bxs(1, 4);
        end
    end
    
    if(plot_selection(4, 1))
        excel_analysis(inseqs, reportbxs, xlfilename, sizeheader);
    end

    fid = fopen(htmlfile, 'a+');
    
    
    fprintf(fid, '\n<br/><a href="#Contents">Back to Top</a></p>\n'); 
    fprintf(fid, '</html>\n');

    fclose(fid);
    
    outfile = [excel_name '.seqdat.txt'];
    if(exist(outfile))
        delete outfile;
    end
    fid = fopen(outfile, 'w');
%    fprintf(fid, '%d\n', checkbxs(1, 2));
    for w=1:size(adjust, 1)
        str = '';
        str = repmat(' %d', 1, adjust{w,2}+2);
        str = strcat('%s\n', str, '\n');
        fprintf(fid, str, adjust{w,1:adjust{w,2}+3});
    end
    fclose('all');
    
    out = htmlfile;
    dmbr_adjust_report(excel_name, topdir);
    
    return
end


function excel_analysis(inseqs, bxs, xlfilename, header)
% Creates and writes the excel analysis footer/sidebar, including averages,
% counts, SEMs, std devs, and G ratios.

    numcols = 4;
    % G ratio sidebar
    sidebar = cell(bxs(1,1)+1, bxs(1,2)-1);
    for b=1:(bxs(1,2)-1)
        sidebar(1,b) = cellstr(strcat('G', num2str(b+1), '/G1'));
    end
    first = excel_column(numcols+1);
    for b=1:bxs(1,1)
        for c=2:(inseqs(b))
            column = excel_column(numcols+4*(c-1)+1);
            sidebar(b+1,c-1) = cellstr(strcat('=', column, num2str(header+(b)+1), '/', first, num2str(header+(b)+1)));
        end
    end
    
    % Footer
    footer = cell(4, numcols+5*bxs(1,2));
    footer(1, 1) = cellstr('average:');
    footer(2, 1) = cellstr('count:');
    footer(3, 1) = cellstr('deviation:');
    footer(4, 1) = cellstr('SEM:');
    for b=(numcols+1):length(footer)
        if(b==(numcols+1)+4*bxs(1,2))
            continue;
        end
        column = excel_column(b);
        footer(1, b) = cellstr(strcat('=AVERAGE(', column, num2str(header+2), ':', column, num2str(bxs(1, 1)+header+1), ')'));        
        footer(2, b) = cellstr(strcat('=COUNT(', column, num2str(header+2), ':', column, num2str(bxs(1, 1)+header+1), ')'));        
        footer(3, b) = cellstr(strcat('=STDEV(', column, num2str(header+2), ':', column, num2str(bxs(1, 1)+header+1), ')'));        
        footer(4, b) = cellstr(strcat('=', column, num2str(bxs(1, 1)+header+5), '/SQRT(', column, num2str(bxs(1, 1)+header+4), ')'));
    end
    
    column = excel_column(4*(bxs(1,2))+2+numcols);
    
    
    % Write results
    xlfilename = strcat(xlfilename, '.xlsx');
    range = strcat(column, num2str(header+1));
    if(~isempty(sidebar))
        xlswrite(xlfilename, sidebar, 1, range);
    end
    range = strcat('A', num2str(bxs(1,1)+header+3));
    xlswrite(xlfilename, footer, 1, range);
    
end

function column = excel_column(b)
% Calculates the corresponding letter or letter pair of a number. Ranges from
% 1 = A to 676 = ZZ.
    b2 = mod(b, 26) + 64;
    b1 = (b-(b2-64))/26 + 64;
    c = char(b2);
    if(b1~=64) c = strcat(char(b1), c); end
    column = c;
end


function f = full_list(filegetter)
% Primes the dir_parse function by taking a mixed list of files and
% folders, and calling the dir_parse function on all folders.


    files = filegetter';
    b = 1;
    while(b <= length(files))
        if isdir(char(files(b)))
            temp = files(b);
            files(b) = [];
            files = vertcat(files, dir_parse(temp));
            b = b-1;
        end
        b = b+1;
    end
    f = files;
end

function r = dir_parse(folder)
% Recursively accesses directories in a given directory, returning a
% comprehensive list of all the files contained in the given directory.

    d = dir(char(folder));
    d = struct2cell(d);
    d = d(1,3:end);
    d = d';
    
    b = 1;
    while(b <= length(d))
        d(b) = strcat(folder, filesep, char(d(b)));
        
        if isdir(char(d(b)))
            temp = d(b);
            d(b) = [];
            height = length(d);
            d = vertcat(dir_parse(temp), d);
            b = b + (length(d) - height) - 1;
        end
        b = b+1;
    end
    r = d;
    
end

function num = writeheader(files, filepath, topdir)
% Writes the Excel top header, using data from any
% 'expdata.txt' files found. Data must fit specified
% formatting.
    
    numcols = 8;
    topheader(1) = cellstr('Date of experiment');
    topheader(3) = cellstr('Description');
    topheader(5) = cellstr('Substrate');
    topheader(7) = cellstr('Sub coating');
    topheader(9) = cellstr('Bead diameter');
    topheader(11) = cellstr('Bead coat');
    topheader(13) = cellstr('Microscope');
    topheader(15) = cellstr('Magnification');
    
    files = cellstr(files);
    for b=1:size(files,1)
        files(b)
        [fpath, fname, dext] = fileparts(char(files(b)));
        fpath = strcat(fpath, filesep, 'expdata.txt');
        files(b) = cellstr(fpath);
    end
    files = char(files);
    files = unique(files, 'rows');
    files = char(sortn(files));
    
    counter = 1;
    while counter <= size(files,1);
        if exist(files(counter,:), 'file')
            counter = counter + 1;
        else
            files(counter,:) = [];
        end
    end
    
    for b=1:size(files)
        fid = fopen(files(b,:), 'r');
        str = repmat('%s ', 1, numcols);
        headrow = textscan(fid, str, 'delimiter', ':');
        top = headrow{2}';
        blank = cell(1,numcols);
        top = reshape([top;blank],1,[]);
        top(2*numcols) = [];
        topheader = vertcat(topheader, top);
        fclose(fid);
    end
    cd(topdir);
    topheader = vertcat(topheader, cell(3, 2*numcols-1));
    topheader(end-2:end,:) = cellstr(' ');
    xlswrite(filepath, topheader);
    num = size(topheader,1);
end


function selection = report_gui()
%
% Displays a checkbox GUI that allows the user to select analysis
% parameters, including displacement, compliance, compliance fit, Excel
% generation, and FPS addition. Easily expandable. Returns an ordered array
% of the user's choices.
%

selection = [];

% Create GUI figure
h.f = figure('units','pixels','position',[400,400,350,200], 'toolbar','none','menu','none', 'Name', 'Plot Selector');

% Divider line
h.panel=uipanel(h.f, 'Units', 'pixels', 'Position',[0 105 1260 1]);

% Checkboxes
h.c(6) = uicontrol('style', 'edit', 'units','pixels', 'position', [85, 47, 50, 20]);
h.c(5) = uicontrol('Value', 0, 'style','checkbox','units','pixels', 'position', [15, 50, 65, 15], 'string', 'Set FPS:');
h.c(4) = uicontrol('Value', 1, 'style','checkbox','units','pixels', 'position', [15, 75, 200, 15], 'string', 'Generate Excel Spreadsheet');
h.c(3) = uicontrol('Value', 1, 'style','checkbox','units','pixels', 'position', [15, 120, 150, 15], 'string', 'Plot Compliance Fit');
h.c(2) = uicontrol('Value', 1, 'style','checkbox','units','pixels', 'position', [15, 145, 150, 15], 'string', 'Plot Compliance');
h.c(1) = uicontrol('Value', 1, 'style','checkbox','units','pixels', 'position', [15, 170, 150, 15], 'string', 'Plot Displacement');

% Create Compute and Cancel pushbuttons 
h.submit = uicontrol('style','pushbutton','units','pixels', 'position',[15,15,70,20],'string','Compute','callback',@p_call);
h.cancel = uicontrol('style','pushbutton','units','pixels', 'position',[100,15,70,20],'string','Cancel','callback',@p_cancel);

uiwait(h.f);

    % Compute callback
    function p_call(varargin)
        checked = get(h.c,'Value');
        checked{6} = str2num(get(h.c(6), 'String'));
        close(h.f);
        selection = cell2mat(checked);
    end

    % Cancel callback
    function p_cancel(varargin)
        checked = get(h.c,'Value');
        selection = cell2mat(checked);
        close(h.f);
        selection(1) = -1;
    end
end


function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_init: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
end


% returns the closest time to a mouseclick on a figure of video tracking
function time_selected = get_sequence_break(table)

    varforce_constants;

        h = figure;
        set(h, 'Units', 'Normalized');
        hpos = get(h, 'Position');
        set(h, 'Position', [0.4 0.55 hpos(3:4)]);        
        plot(table(:,TIME), magnitude(table(:,X:Y)), '.');
        title('Use figure toolbox, press key, and click mouse on break-point.');
        drawnow;
        pause;

    logentry('Click once on the figure to identify a break between pulse sequences.');
    [tm,xm] = ginput(1);

        close(h);
        drawnow;

    t = table(:,TIME);
    x = table(:,X);

    tval = repmat(tm, length(t), 1);
    xval = repmat(xm, length(x), 1);

    dist = sqrt((t - tval).^2 + (x - xval).^2);

    time_selected = t(find(dist == min(dist)));

    return;

end

% finds a matching tracking file in the current directory

function fname = tracking_check(filename_root)
    fname_array = [...
        cellstr('.raw.vrpn.evt.mat')...
        cellstr('.raw.vrpn.mat'),...
        cellstr('.avi.vrpn.evt.mat'),...
        cellstr('.avt.vrpn.mat'),...
        cellstr('.vrpn.evt.mat'),...
        cellstr('.vrpn.mat')...
    ];
        
    for i=1:length(fname_array)
        filen = strcat(filename_root, fname_array{i});
        if exist(filen, 'file')
            fname = filen;
            return;
        end
    end
    warning('Tracking file not found');
    fname = 'NULL';
    return;
end

