
function dmbr_adjust_breakpoint(filename, topdir, analysis)
    % admin function. runs setup & teardown.
    replace_breakpoint(filename);
    plot_select = {1, 1, 1, 0, 0, 0, 0, {'Jeffrey'}, 1};
    [~, name, ext] = fileparts(filename);
    html = ['adjust_breakpoint_' name '.html']
    cd(topdir);    
    dmbr_report_cell_expt(filename, [pwd filesep 'adjust_breakpoint_' name], [pwd filesep], 0, plot_select);    
    web(html, '-browser');
    dmbr_adjust_report(analysis, topdir, 0);
    
end



function replace_breakpoint (filename)

    % replaces a currently existing breakpoint with a user's selection.

    filename = [filename '.vfd.mat'];
    fname = load(filename);
    if isfield(fname, 'time_selected')
        params = rmfield(fname, 'time_selected');
        save(filename, '-struct', 'params');
    end
    

    [pathname, filename_root, ext, versn] = fileparts(filename);
    cd(pathname);
    filename_root = strtrim(filename_root);
    metadatafile = strcat(filename_root, '.mat');
    trackfile = dmbr_locate_trackfile('vid10_Panc_Control_LDO');
    
    if ~exist(metadatafile, 'file')
        fprintf('***The file ');
        fprintf('%s', metadatafile);
        fprintf(' was not found. This file will be skipped.\n');
        return;
    elseif strcmp(trackfile, 'NULL')
        fprintf('***The tracking file for ');
        fprintf('%s', filename_root);
        fprintf(' was not found. This file will be skipped.\n');
        return;
    end

    m = load(metadatafile);
    m.trackfile = trackfile;
    m.poleloc = 'poleloc.txt';

    time_selected = NaN;
    %%%%
    % identify location of a break between sequences by clicking on plot
    %%%%
    video_tracking_constants;
    table = load_video_tracking(m.trackfile, m.fps, 'm', m.calibum, 'absolute', 'yes', 'table');
    poleloc = m.poleloc * m.calibum * 1e-6;
    table(:,X) = table(:,X) - poleloc(1);
    table(:,Y) = table(:,Y) - poleloc(2);
    table(:,TIME) = table(:,TIME) - min(table(:,TIME));
    time_selected = get_sequence_break(table);
    if ~isnan(time_selected)
        m.time_selected = time_selected;
    end            
    save(metadatafile, '-struct', 'm');
    
end


function time_selected = get_sequence_break(table)
% returns the closest time to a mouseclick on a figure of video tracking

    varforce_constants;
    h = figure(4);
    
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


function fname = tracking_check(filename_root)
% looks for tracking files with an array of extensions, keeping
% the first one it finds
    fname_array = [...
        cellstr('.raw.vrpn.evt.mat')...
        cellstr('.raw.vrpn.mat'),...
        cellstr('.avi.vrpn.evt.mat'),...
        cellstr('.avi.vrpn.mat'),...
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


