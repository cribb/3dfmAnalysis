function rheo = dmbr_report(filename, report_params)
%
%
% filename = vfd file from dmbr experiment
%
%
%
%
%
%
%
%
%
%
%

dmbr_constants;                                               


% Three phases: 1) Load the data, 2) Maybe process the data, 3) Report the results


% general
% pathname = pwd;
[pathname, filename, ext] = fileparts(filename);
close all;

% load metadata
metadatafile = [filename_root, '.vfd.mat'];
m = load(metadatafile);

a        = m.bead_radius;
pulses   = m.pulse_widths;
voltages = m.voltages;
calib_um = m.calibum;

% load tracking data
trackingfile = [filename_root, '.raw.vrpn.evt.mat'];

try 
    d = load(trackingfile);
catch
    trackingfile = [filename_root, '.raw.vrpn.mat'];
    try
        d = load(trackingfile);
    catch
        warning('Tracking file not found');
        beadmax = NaN;
    end
end

d = load_video_tracking(trackingfile, [], 'pixels', calib_um, 'absolute', 'yes', 'matrix');
beadmax = get_beadmax(d);

% load calibration 
filelist = dir('*.vfc.mat');
calibfile = filelist.name;
c = load(calibfile);

% load poleloc file
filelist2 = dir('poleloc.txt');
polelocfile = filelist2.name;

try
    p = load(polelocfile);
catch
    warning ('Poleloc file not found');
end

% obtain input parameters
input_params.metafile = metadatafile;
input_params.trackfile = trackingfile;
input_params.calibfile = calibfile;
input_params.poleloc = p;
input_params.force_type = 'disp';
input_params.tau = 6.25;
input_params.fit_type = 'Jeffrey';
input_params.scale = 0.5;

rheo = dmbr_run(input_params);

rheo_table = rheo.raw.rheo_table;


beads  = unique(rheo_table(:,ID))';
seqs   = unique(rheo_table(:,SEQ))';

for b = 1 : length(beads)    
    for s = 1 : length(seqs)
        clear filtx_on;
        
        ftable = dmbr_filter_table(rheo_table, beads(b), seqs(s), []);
        
        if size(ftable,1) <= 0
            break;
        end
        
        t = ftable(:,TIME);
        t = t - t(1);
        
        x = ftable(:,X);
        x = x - x(1);
        
        Jr = ftable(:,J);

        
        % filtering displacement via moving average kernel of width, wn
        idx = find(ftable(:,VOLTS) > 0);
        t_on = ftable(idx,TIME);
        x_on = ftable(idx,X);
        Jr_on = ftable(idx,J);   

        
        filtx_on = conv(x_on(:,1), ones(wn,1).*1/wn);
        filtJx_on = conv(Jx_on(:,1), ones(wn,1).*1/wn);
        
        % computing the velocity as the windowed-derivative of displacement
        [dxdt, newt, newx] = windiff(filtx_on(wn:end-(wn-1),:), t_on(wn/2:end-(wn/2)), window_size);
        
        % computing the instantaneous viscosity as a function of compliance
        [dJxdt, newt, newc] = windiff(filtJx_on(wn:end-(wn-1),:), t_on(wn/2:end-(wn/2)), window_size);
        visc = 1 ./ dJxdt;

        if ~exist('txFig');    txFig   = figure; end
        if ~exist('txFig2');   txFig2  = figure; end
        if ~exist('tJxFig');   tJxFig  = figure; end
        if ~exist('tJxFig2');  tJxFig2 = figure; end
        if ~exist('xetaFig');  xetaFig = figure; end
        if ~exist('xetaFig2'); xetaFig2 = figure; end

        % displacement vs. time plot
        figure(txFig);
        hold on;
        plot(t,x*1e6, 'Color', [0 s/(length(seqs)+1) 0]);
        title(['bead displacement vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('displacement [\mum]');
        pretty_plot;
        hold off;
        drawnow;
        
        figure(txFig2); 
        hold on;
        plot(t,x*1e6, 'Color', [0 s/(length(seqs)+1) 0]);
        title(['bead displacement vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('displacement [\mum]');
        pretty_plot;
        hold off;
        drawnow;
        
        % compliance vs. time plot
        figure(tJxFig); 
        hold on;
        plot(t,Jx, 'Color', [s/(length(seqs)+1) 0 0]);
        title(['Compliance vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('compliance [Pa^{-1}]');
        pretty_plot;
        hold off;
        drawnow;

        figure(tJxFig2); 
        hold on;
        plot(t,Jx, 'Color', [s/(length(seqs)+1) 0 0]);
        title(['Compliance vs. time, bead ' num2str(beads(b))]);
        xlabel('time [s]');
        ylabel('compliance [Pa^{-1}]');
        pretty_plot;
        hold off;
        drawnow;

        % strain thickening (viscosity vs. displacement) plot
        figure(xetaFig);
        hold on;
        plot((newx-newx(1))*1e6,visc, '.', 'Color', [s/(length(seqs)+1) 0 s/(length(seqs)+1)]);
        title(['Strain Thickening, bead ' num2str(beads(b))]);
        xlabel('displacement [\mum]');
        ylabel('viscosity, \eta [Pa s]');
        pretty_plot;
        hold off;
        drawnow; 
        
        figure(xetaFig2);
        hold on;
        plot((newx-newx(1))*1e6,visc, '.', 'Color', [s/(length(seqs)+1) 0 s/(length(seqs)+1)]);
        title(['Strain Thickening, bead ' num2str(beads(b))]);
        xlabel('displacement [\mum]');
        ylabel('viscosity, \eta [Pa s]');
        pretty_plot;
        hold off;
        drawnow;
    end
    
        txFigfilename   = [filename_root '.txFig.bead'  num2str(beads(b)) '.png'];
        txFigfilename2  = [filename_root '.txFig.bead'  num2str(beads(b)) '.fig'];
        tJxFigfilename  = [filename_root '.tJxFig.bead' num2str(beads(b)) '.png'];
        tJxFigfilename2  = [filename_root '.tJxFig.bead' num2str(beads(b)) '.fig'];
        xetaFigfilename = [filename_root '.xetaFig.bead'  num2str(beads(b)) '.png'];
        xetaFigfilename2 = [filename_root '.xetaFig.bead'  num2str(beads(b)) '.fig'];

        saveas(  txFig,  txFigfilename, 'png');
        saveas( tJxFig, tJxFigfilename, 'png');
        saveas(xetaFig,xetaFigfilename, 'png');
        
        saveas(  txFig2,  txFigfilename2, 'fig');
        saveas( tJxFig2, tJxFigfilename2, 'fig');
        saveas(xetaFig2, xetaFigfilename2, 'fig');
                
        close(txFig);
        close(tJxFig);
        close(xetaFig);

        close(txFig2);
        close(tJxFig2);
        close(xetaFig2);
end


% calculating moving average and window size in frames and seconds
wn_seconds = wn/120;
window_size_seconds = window_size/120;

% report
outfile = [filename_root '.html'];

fid = fopen(outfile, 'w');

% html code
fprintf(fid, '<html>\n');
fprintf(fid, ' <p><b>Sample Name:</b>  %s <br/>\n', nametag);
fprintf(fid, ' <b>Path:</b>  %s </p>\n', pathname);

fprintf(fid, '<br/>');

% Table 1: Identifying information
fprintf(fid, '<b>General Parameters</b><br/>\n');
fprintf(fid, '<table border="2" cellpadding="6"> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, ' <td align="left"><b>File:</b>	%s </td> \n', filename_root);
fprintf(fid, ' <td align="left"><b>Pulse Voltages (V):</b>	[%s] </td> \n', num2str(voltages));
fprintf(fid, '</tr> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, ' <td align="left" width=250><b>Bead Diameter (um):</b>	%g </td> \n', a*2);
fprintf(fid, ' <td align="left"><b>Pulse Widths (s):</b>	[%s]</td> \n', num2str(pulses));
fprintf(fid, '</tr> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, ' <td align="left"><b>Number of Trackers:</b>	%i </td> \n', beadmax+1);
fprintf(fid, ' <td></td> \n');
fprintf(fid, '</tr> \n');
fprintf(fid, '</table> \n'); 

fprintf(fid, '<br/>');

% Table 2: Moving average and Window size in frames and seconds
fprintf(fid, '<b>Smoothing Parameters</b><br/>\n');
fprintf(fid, '<table border="2" cellpadding="6"> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, '   <td> </td> \n');
fprintf(fid, '   <td align="center"><b>Frames</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Seconds</b> </td> \n');
fprintf(fid, '</tr> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, '   <td align="left"><b>Moving Average</b> </td> \n');
fprintf(fid, '   <td align="center"> %i \n', wn);
fprintf(fid, '   <td align="center"> %12.3g \n', wn_seconds); 
fprintf(fid, '</tr> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, '   <td align="left"><b>Window Size</b> </td> \n');
fprintf(fid, '   <td align="center"> %i \n', window_size);
fprintf(fid, '   <td align="center"> %12.3g \n', window_size_seconds);
fprintf(fid, '</tr> \n');
fprintf(fid, '</table> \n\n'); 

fprintf(fid, '<br/>');

% Table 3: Shear rates and Weissenburg numbers for each bead/sequence pair
fprintf(fid, '<b>Summary of Results</b><br/>\n');
fprintf(fid, '<table border="2" cellpadding="6"> \n');
fprintf(fid, '<tr> \n');
fprintf(fid, '   <td align="center"><b>Tracker ID</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Sequence #</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Shear Rate (1/s)</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Weissenburg #</b> </td> \n');
fprintf(fid, '   <td align="center"><b>Eta_ss (Pa s)</b> </td> \n');
fprintf(fid, '   <td align="center"><b>R^2</b> </td> \n');
fprintf(fid, '</tr> \n\n');

for b = 1 : length(beads)    
    for s = 1 : length(seqs)
        idx = find(rheo.beadID == beads(b) & rheo.seqID == seqs(s));
        fprintf(fid, '<tr> \n');
        fprintf(fid, '<td align="center"> %i </td> \n', beads(b));  
        fprintf(fid, '<td align="center"> %i </td> \n', seqs(s));          
        % shear_rate for this bead/sequence
        fprintf(fid, '<td align="center"> %12.2f </td> \n', rheo.max_shear(idx));
        % Weissenberg_number for this bead/sequence
        fprintf(fid, '<td align="center"> %12.2f </td> \n', rheo.Wi(idx));
        % steady state viscosity for Jeffey model
        fprintf(fid, '<td align="center"> %12.2f </td> \n', rheo.eta(idx,end));
        % R^2
        fprintf(fid, '<td align="center"> %0.4f </td> \n', rheo.Rsquare(idx));
        fprintf(fid, '</tr> \n');
    end
end
fprintf(fid, '</table> \n\n');
        
fprintf(fid, '<br/> \n\n');

% Plots
for b = 1:length(beads)
    txFigfilename   = [filename_root '.txFig.bead'  num2str(beads(b)) '.png'];
    tJxFigfilename  = [filename_root '.tJxFig.bead' num2str(beads(b)) '.png'];
    xetaFigfilename = [filename_root '.xetaFig.bead'  num2str(beads(b)) '.png'];

    fprintf(fid, '<img src= %s width=520 height=400 border=2 > \n', txFigfilename);
    fprintf(fid, '<br/> \n');
    fprintf(fid, '<img src= %s width=520 height=400 border=2 > \n', tJxFigfilename);
    fprintf(fid, '<br/> \n');
    fprintf(fid, '<img src= %s width=520 height=400 border=2 > \n', xetaFigfilename);
    fprintf(fid, '<br/> \n');
end

fprintf(fid, '<br/> \n\n');

% Image of pole tip
fprintf(fid, ' <p><b>Pole tip image</b><br/>\n');
poleimage = [filename_root, '.MIP.bmp'];
fprintf(fid, '<img src= %s width=520 height=400 border=2> \n', poleimage);


fclose(fid);

return;


function logentry(txt)

    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_report: '];
     
     fprintf('%s%s\n', headertext, txt);

 return;