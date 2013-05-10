function out = dmbr_multi_file_report(excel_name, seq_array, file_array, filter_ext)
%
% Last modified 08/03/12 (stithc)
% Christian Stith <chstith@ncsu.edu> and Jeremy Cribb
% dmbr_multi_file_report.m
% Allows a user to run multiple data files through dmbr_report_cell_expt at
% once, creating one comprehensive HTML and Excel report. Can also be used
% to run a single data file. Users can select any combination of files and
% directories; the report will parse all relevant data files out of any
% folders selected. Generates Excel analysis footer and sidebar. Runs
% dmbr_adjust_report upon completion.
%
% Required Parameters:
%   excel_name: the root name of the new analysis
% Optional Parameters:
%   seq_arry: the array of selected sequences
%   file_array: the array of selected files
%   filter_ext: a filename filter (defaults to '*.vfd.mat')
% Returns:
%   the full filepath/name of the html file
%
% Command Line Syntax:
%   dmbr_multi_file_report(<Analysis_Name>)
% Example:
%   dmbr_multi_file_report('DataAnalysis')
%


    % check parameters & call uipickfiles
    if nargin<2
        filelist = full_list(uipickfiles('FilterSpec', '*.vfd.mat'));
    elseif(nargin<3)
        filter_ext = seq_array;
        filelist = full_list(uipickfiles('FilterSpec', filter_ext));
    else
        filelist = file_array;
    end
    
    % check filelist
    if (isempty(filelist))
        fprintf('No files selected. Program terminated.\n');
        return;
    elseif (~iscell(filelist))
        fprintf('Program canceled.\n');
        return;
    end

        
    
    % Give options to user via checkboxes
    % See function below: report_gui
    plot_selection = report_gui();
    if (isempty(plot_selection) || plot_selection{1} == -1)
        fprintf('Program canceled.\n');
        return;
    end
    

    
    filelist = char(filelist);
    files = cell(size(filelist, 1), 1);
    
    
    
    %remove all non-relevant files
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
    
    % check files again
    q = files;
    files = char(sortn(unique(q, 'rows')));
    if isempty(files)
        fprintf('No files selected. Program terminated.\n');
        return;
    end
    
    % parse out first directory
    [main_directory, ~, ~] = fileparts(char(files(1,:)));
    main_directory = strcat(main_directory, filesep);
    
    xlfilename = [main_directory excel_name '.xlsx'];
        
    % verify all files    
    counter = 1;
    if(plot_selection{7})
        logentry('Checking for breakpoints.');
    end
    % check all files for breakpoints data
    while counter <= size(files,1);
        [pathname, filename_root, ext, versn] = fileparts(files(counter,:));
        cd(pathname);
        filename_root = strtrim(filename_root);
        metadatafile = strcat(filename_root, '.vfd.mat');
        trackfile = dmbr_locate_trackfile(filename_root);
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
        
        % select new breakpoint (if needed)
        if(plot_selection{7})
            m = load(metadatafile);
            m.trackfile = trackfile;
            m.poleloc = 'poleloc.txt';
            if(plot_selection{5} && ~isfield(m, 'fps'))
                m.fps = plot_selection{6};
            end
            time_selected = NaN;
            if ~isfield(m, 'time_selected')
                % identify location of a break between sequences by clicking on plot
                video_tracking_constants;
                table = load_video_tracking(m.trackfile, m.fps, 'm', m.calibum, 'absolute', 'yes', 'table');
                poleloc = m.poleloc * m.calibum * 1e-6;
                table(:,X) = table(:,X) - poleloc(1);
                table(:,Y) = table(:,Y) - poleloc(2);
                table(:,TIME) = table(:,TIME) - min(table(:,TIME));
                time_selected = get_sequence_break(table);
            else
                time_selected = m.time_selected;
            end
            
            if(isnan(time_selected))
                counter = counter-1;
                files(counter,:) = [];
                logentry([filename_root ' removed from analysis.']);
            else
                m.time_selected = time_selected;
                logentry([filename_root ' contains sequence breakpoint.']);
            end            
            save(metadatafile, '-struct', 'm');
        end
    end

    % check file list again
    if(size(files, 1)==0)
        fprintf('No files selected. Program terminated.\n');
        return;
    end
 
% print out the finalized list of files
%
%    fprintf('Files to be analyzed:\n');
%    for i=1:size(files, 1)
%        [~, filename_root, ~] = fileparts(files(i,:));
%        fprintf([filename_root '\n']);
%    end

    % reset the working directory
    cd(main_directory);
    
    % prepare the excel file (overwrites)
    % see function below: write_header
    sizeheader = 1;
    if(plot_selection{4})
        if exist(xlfilename, 'file')
            delete(xlfilename);
        end
        sizeheader = write_header(files, xlfilename, main_directory);
    end
    
    % prepare the html file (overwrites)
    htmlfile = [main_directory excel_name '.html'];
    if exist(htmlfile)
        delete(htmlfile);
    end
    fid = fopen(htmlfile, 'w');
    fprintf(fid, '<html>\n');
    fprintf(fid, '<a name="Contents"><b>Contents:</b></a>\n<br/>');
    for b=1: size(files, 1);
        [~, filename_root, ~] = fileparts(files(b,:));
        fprintf(fid, '<a href="#%s">%s</a><br/>\n', filename_root, filename_root);
    end
%    fprintf(fid, ['<title>' excel_name '</title>\n']);
    fclose(fid);
    xlfilename = [main_directory excel_name];

    % beads in files, sequences availiable in Selector
    checkbxs = [0, 0];
    % beads actually used, max sequences used
    reportbxs = [0, 0];
    % all individual sequences 
    inseqs = [];
    
    adjust = cell(size(files,1), 3);
    
    % analyze all data: run dmbr_report_cell_expt on each validated file
    for b=1:(size(files,1))
        if(nargin<2)
            temp = dmbr_report_cell_expt(strtrim(files(b,:)), [main_directory excel_name], main_directory, sizeheader, plot_selection);
        else
            temp = dmbr_report_cell_expt(strtrim(files(b,:)), [main_directory excel_name], main_directory, sizeheader, plot_selection, seq_array);
        end
        bxs = temp{1};
        
        % update bead/pull counts for excel
        start = length(inseqs);
        inseqs = vertcat(inseqs, temp{2});
        if(nargin>1)
            seq_array(1:(bxs(1,1)*bxs(1,2))) = [];
        end
        
        % set up dmbr_adjust_report
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
    
    % finish excel file (see function below: excel_analysis)
    if(plot_selection{4})
        pword = plot_selection{8, :};
        excel_analysis(inseqs, reportbxs, xlfilename, sizeheader, pword{:});
    end

    % finish html file
    fid = fopen(htmlfile, 'a+');
    fprintf(fid, '\n<br/><a href="#Contents">Back to Top</a></p>\n'); 
    fprintf(fid, '</html>\n');
    fclose(fid);
    
    
    outfile = [excel_name '.seqdat.txt'];
    if(exist(outfile, 'file'))
        delete outfile;
    end
    fid = fopen(outfile, 'w');
%    fprintf(fid, '%d\n', checkbxs(1, 2));
    for w=1:size(adjust, 1)
        str = repmat(' %d', 1, adjust{w,2}+2);
        str = strcat('%s\n', str, '\n');
        fprintf(fid, str, adjust{w,1:adjust{w,2}+3});
    end
    fclose('all');
    
    out = htmlfile;
    dmbr_adjust_report(excel_name, main_directory);
    
    return
end


function excel_analysis(inseqs, bxs, xlfilename, header, fit_type)
% Creates and writes the excel analysis footer/sidebar, including averages,
% counts, SEMs, std devs, and G ratios.
    numvars = 0;
    if(strcmp(fit_type, 'Jeffrey'))
        numvars = 4;
    elseif(strcmp(fit_type, 'Power Law (Fabry)'))
        numvars = 3;
    else
        return;
    end
            
    numcols = 4;
    % G ratio sidebar
    
    % THIS IS WHERE THE G INFORMATION IS WRITTEN INTO THE EXCEL FILE
    % ^ no idea why I capitalized that
    % It must have been really important
    sidebar = cell(bxs(1,1)+1, bxs(1,2)-1);
    for b=1:(bxs(1,2)-1)
        sidebar(1,b) = cellstr(strcat('G', num2str(b+1), '/G1'));
    end
    first = excel_column(numcols+1);
    for b=1:bxs(1,1)
        for c=2:bxs(1,2)
            column = excel_column(numcols+numvars*(c-1)+1);
            sidebar(b+1,c-1) = cellstr(strcat('=', column, num2str(header+(b)+1), '/', first, num2str(header+(b)+1)));
        end
    end
    
    % Footer
    footer = cell(4, numcols+(numvars+1)*bxs(1,2));
    footer(1, 1) = cellstr('average:');
    footer(2, 1) = cellstr('count:');
    footer(3, 1) = cellstr('deviation:');
    footer(4, 1) = cellstr('SEM:');
    for b=(numcols+1):length(footer)
        if(b==(numcols+1)+numvars*bxs(1,2))
            continue;
        end
        column = excel_column(b);
        footer(1, b) = cellstr(strcat('=AVERAGE(', column, num2str(header+2), ':', column, num2str(bxs(1, 1)+header+1), ')'));        
        footer(2, b) = cellstr(strcat('=COUNT(', column, num2str(header+2), ':', column, num2str(bxs(1, 1)+header+1), ')'));        
        footer(3, b) = cellstr(strcat('=STDEV(', column, num2str(header+2), ':', column, num2str(bxs(1, 1)+header+1), ')'));        
        footer(4, b) = cellstr(strcat('=', column, num2str(bxs(1, 1)+header+5), '/SQRT(', column, num2str(bxs(1, 1)+header+4), ')'));
    end
    
    column = excel_column(numvars*(bxs(1,2))+2+numcols);
    
    
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
% Calculates the corresponding letter code of a number. Infinite range.
    c = '';
    while b > 0
        m = mod((b - 1), 26);
        c = [char(m+65) c];
        b = (b - m - 1) / 26;
    end
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

function num = write_header(files, filepath, topdir)
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
% parameters, including plot type, displacement, compliance, compliance fit, Excel
% generation, and FPS addition. Easily expandable. Creates an ordered array
% of the user's choices.
%

selection = [];

chosen_plot = cellstr('Jeffrey');
chosen_mode = 1;

% Create GUI figure
h.f = figure('units','pixels','position',[400,400,350,200], 'toolbar','none','menu','none', 'Name', 'Analysis Options');

% Divider line
h.panel=uipanel(h.f, 'Units', 'pixels', 'Position',[0 100 1260 1]);

% Checkboxes
h.c(9) = uicontrol( 'style', 'popupmenu', 'String', {'Mode 1 (All Parameters)', 'Mode 2 (Just G Ratios)'}, 'position', [190, 140, 150, 15], 'callback', @mode);
h.c(8) = uicontrol( 'style', 'popupmenu', 'String', {'Jeffrey', 'Power Law (Fabry)'}, ... 'Newtonian', 'Maxwell', 'Kelvin-Voight', 'Stretched Exponential', 'KE model #1', 'Power Law',
                    'position', [190, 170, 150, 15], 'callback', @plot_call);
h.c(7) = uicontrol('Value', 0, 'style', 'checkbox', 'units', 'pixels', 'position', [190, 110, 150, 15], 'string', 'Check for Breakpoints');
h.c(6) = uicontrol('style', 'edit', 'units', 'pixels', 'position', [85, 47, 50, 20]);
h.c(5) = uicontrol('Value', 0, 'style', 'checkbox', 'units', 'pixels', 'position', [15, 50, 65, 15], 'string', 'Set FPS:');
h.c(4) = uicontrol('Value', 1, 'style', 'checkbox', 'units', 'pixels', 'position', [15, 75, 200, 15], 'string', 'Generate Excel Spreadsheet');
h.c(3) = uicontrol('Value', 1, 'style', 'checkbox', 'units', 'pixels', 'position', [15, 110, 150, 15], 'string', 'Plot Compliance Fit');
h.c(2) = uicontrol('Value', 1, 'style', 'checkbox', 'units', 'pixels', 'position', [15, 140, 150, 15], 'string', 'Plot Compliance');
h.c(1) = uicontrol('Value', 1, 'style', 'checkbox', 'units', 'pixels', 'position', [15, 170, 150, 15], 'string', 'Plot Displacement');



% Create Compute and Cancel pushbuttons 
h.submit = uicontrol('style','pushbutton','units','pixels', 'position',[15,15,70,20],'string','Compute','callback',@p_call);
h.cancel = uicontrol('style','pushbutton','units','pixels', 'position',[100,15,70,20],'string','Cancel','callback',@p_cancel);

uiwait(h.f);

    %%%%%
    function mode(varargin)
        index = get(h.c(9), 'Value');
        chosen_mode = index;
    %%%%%
    end    
    
    function plot_call(varargin)
        contents = get(h.c(8),'String');
        index = get(h.c(8), 'Value');
        chosen_plot = contents(index);
    %%%%%
    end
    % Compute callback
    function p_call(varargin)
        checked = get(h.c,'Value');
        checked{6} = str2num(get(h.c(6), 'String'));
        checked{8} = chosen_plot;
        selection = checked;
        close(gcf);
        pause(0.1);
        return;
    end

    % Cancel callback
    function p_cancel(varargin)
        selection{1} = -1;
        close(gcf);
        pause(0.1);
        return;
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
     headertext = [logtimetext 'dmbr_multi_file_report: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
end


function time_selected = get_sequence_break(table)
% returns the closest time to a mouseclick on a figure of video tracking
% taken from Jeremy Cribb's code elsewhere

    varforce_constants;

    h = figure;
    
    set(h, 'Units', 'Normalized');
    hpos = get(h, 'Position');
    set(h, 'Position', [0.4 0.55 hpos(3:4)]);

    x = table(:,X);
    y = table(:, Y);       
    radial = magnitude(x, y);


    plot(table(:,TIME), -radial, '.');
    set(gca,'YTick',[]);
 
    title({'Use figure toolbox, press key, and click mouse on break-point.';'Data is right-side-up. Press 0 to skip this file.'});
    
    pause;
    p = get(h, 'currentcharacter');
    if(strcmp(p, '0') || strcmp(p, 'numpad0'))
        check = questdlg('Are you sure you want to remove this file from the analysis?', 'Remove File');
        if(strcmp(check, 'Yes'))
            time_selected = NaN;
            close(h);
            return;
        end
    end
    
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




