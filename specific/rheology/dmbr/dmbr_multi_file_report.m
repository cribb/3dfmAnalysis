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
    if length(files)==0
        fprintf('No files selected. Program terminated.\n');
        return;
    end
    

    counter = 1;
    while counter <= size(files,1);
        % check all files for breakpoints data
        [pathname, filename_root, ext, versn] = fileparts(files(counter,:));
        cd(pathname);
        metadatafile = strcat(filename_root, '.vfd.mat')
        videofile = strcat(filename_root, '.raw.vrpn.evt.mat');
        videofile2 = strcat(filename_root, '.vrpn.evt.mat');
        if ~exist(metadatafile, 'file')
            fprintf('***The file ');
            fprintf('%s', metadatafile);
            fprintf(' was not found. This file will be skipped.\n');
            % delete file from list
            files(counter,:) = [];
            continue;
        elseif ~exist(videofile, 'file') && ~exist(videofile2, 'file')
            fprintf('***The file ');
            fprintf('%s', videofile2);
            fprintf(' was not found. This file will be skipped.\n');
            % delete file from list
            files(counter,:) = [];
            continue;
        else
            counter = counter + 1;
        end
        m = load(metadatafile);
        if ~isfield(m, 'time_selected')
            [dummy, m] = dmbr_init(m);
            save(m.metafile, '-struct', 'm');
        end
    end
    
    cd(topdir);
    if exist(xlfilename, 'file')
        delete(xlfilename);
    end

    sizeheader = writeheader(files, xlfilename, topdir);
        
    htmlfile = [topdir excel_name '.html'];
    if exist(htmlfile)
        delete(htmlfile);
    end
    fid = fopen(htmlfile, 'w');
    fprintf(fid, '<html>\n')    
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
            temp = dmbr_report_cell_expt(strtrim(files(b,:)), [topdir excel_name], topdir, sizeheader);
        else
            temp = dmbr_report_cell_expt(strtrim(files(b,:)), [topdir excel_name], topdir, sizeheader, seq_array);
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
    
    excel_analysis(inseqs, reportbxs, xlfilename, sizeheader);
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
    filelist = char(filegetter);
    files = cell(size(filelist, 1), 1);
    for b = 1:size(filelist,1)
        files(b) = cellstr(filelist(b,:));
        filelist(b,:);
    end
    
    for b = 1:size(files)
        if isdir(char(files(b)))
            temp = files(b);
            files(b) = [];
            files = vertcat(files, dir_parse(temp));
        end
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
    
    for b=1:size(d)
        d(b) = strcat(folder, filesep, char(d(b)))
        
        if isdir(char(d(b)))
            temp = d(b);
            d(b) = [];
            d = vertcat(d, dir_parse(temp));
        end
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
