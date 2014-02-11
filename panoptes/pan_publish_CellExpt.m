function pan = pan_publish_CellExpt(metadata, filt)
% PAN_PUBLISH_CELLEXPT  Generates an html report for the Panoptes Cell Experiment
%
% CISMM function
% Panoptes
%  
% Generates a report for tests perfomed on Panoptes using the
% "Beads diffusing on Cells" paradigm.
%
% Generates and reports the results in a root html file with figures saved 
% in several formats (.fig for matlab manipulation, .png as raster image 
% for quick insertion into reports, and .svg as vectorized image for ease 
% of making publication quality images).
% 
%  pan = panoptes_publish_CellExpt(metadata) 
%   
%  "metadata" is the matlab structure that describes a Panoptes experiment
%  design, outputted by 'pan_load_metadata'
%

nametag = metadata.instr.experiment;
outf = metadata.instr.experiment;
duration = metadata.instr.seconds;
% fps_bright = metadata.instr.fps_bright;
% fps_fluo = metadata.instr.fps_fluo;
autofocus = metadata.instr.auto_focus;
video_mode = metadata.instr.video_mode;
imaging_fps = metadata.instr.fps_imagingmode;

if autofocus
    autofocus_yn = 'Yes.';
else
    autofocus_yn = 'No.';
end

switch video_mode
    case 0
        video_mode = 'fluorescence burst, then brightfield';
    case 1
        video_mode = 'fluorescence only';
    otherwise
        error('Unknown video mode type.');
end

% % START REPORT GENERATION TO HTML PAGE

outfile = [outf '.html'];
fid = fopen(outfile, 'w');

%%%%
% compute the MSD for each WELL (for the heatmap)
spec_tau = 1;
[wellmsds wellID] = pan_combine_data(metadata, 'metadata.plate.well_map');
all_welltaus = [wellmsds.mean_logtau];
all_wellmsds = [wellmsds.mean_logmsd];
all_wellerrs = [wellmsds.msderr];
heatmap_msds = NaN(1,96);
log_spec_welltau = log10(spec_tau);
[minval, minloc] = min( sqrt((all_welltaus - log_spec_welltau).^2) );
mywelltau = 10.^all_welltaus(minloc(1),:);
mywellmsd = all_wellmsds(minloc(1),:);
heatmap_msds(1, str2num(char(wellID)) ) = mywellmsd;
heatmap_msds = reshape(heatmap_msds, 12, 8)';

visc = (2 * 1.3806e-23 * 300 * spec_tau) ./ (3 * pi * 0.25e-6 * 10.^heatmap_msds);
% Heat map
heatmapfig = figure('Visible', 'off');

% imagesc(1:12, 1:8, heatmap_msds); 
imagesc(1:12, 1:8, log10(visc)); 
colormap((hot));
cb = colorbar;
set(heatmapfig, 'Units', 'Pixels');
set(heatmapfig, 'Position', [300 300 800 600]);
set(gca, 'XTick', [1:12]');
set(gca, 'XTickLabel', [1:12]');
set(gca, 'XAxisLocation', 'top');
set(gca, 'YTick', [1:8]');
set(gca, 'YTickLabel', {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'});
cbticks = get(cb, 'YTick')';
cbtick_labels = cellstr([repmat('10^{', size(cbticks)) num2str(cbticks) repmat('}', size(cbticks))]);
set(cb, 'YTickLabel', cbtick_labels);
title('Viscosity (in log_{10} Pa s})');
    alpha = ones(8,12);
    alpha(isnan(heatmap_msds)) = 0.5;
    im = get(gca, 'Children');
%     set(im, 'AlphaData', alpha);
pretty_plot;
heatmapfile = [metadata.instr.experiment '_well_ALL' '.heatmap'];
gen_pub_plotfiles(heatmapfile, heatmapfig, 'normal');
close(heatmapfig);





%%%%  Calculate the MSD for different cell types

% myparam = 'metadata.plate.solution.molar_concentration';
% myparam = 'metadata.plate.well_map';
myparam = 'metadata.plate.cell.name';
% myparam = 'metadata.plate.solution.name';

% compute the MSD for each condition defined by 'myparam'
[msds molar_conc] = pan_combine_data(metadata, myparam);

% variables that contain summarized data
all_taus = 10.^[msds.mean_logtau];
all_msds = 10.^[msds.mean_logmsd];
all_logtaus = [msds.mean_logtau];
all_logmsds = [msds.mean_logmsd];
all_logerrs = [msds.msderr];
all_ns   = [msds.n];

% create plot with bar graph at a given tau
spec_tau = 1;
log_spec_tau = log10(spec_tau);
[minval, minloc] = min( sqrt((all_logtaus - log_spec_tau).^2) );
mytau    = all_taus(minloc(1),:);
mylogtau = all_logtaus(minloc(1),:);
mymsd    = all_msds(minloc(1),:);
mylogmsd = all_logmsds(minloc(1),:);
mylogerr = all_logerrs(minloc(1),:);
myerr    = 10.^(mylogmsd + mylogerr) - 10.^(mylogmsd);

% generate information for the data table summary
rms_mymsd = sqrt(mymsd);
rms_mymsd_err = sqrt(mymsd+myerr) - rms_mymsd;
msds_n = all_ns(minloc(1),:);

% create plots of distributions that correspond with bar graph
npoints_ksdensity = 100;
for k = 1:length(msds)
    my_type = msds(k).logmsd(minloc(1),:);
    if ~isnan(my_type)
        [mydensity, my_dens_locs] = ksdensity(my_type, 'npoints', npoints_ksdensity);
    else
        mydensity = NaN(npoints_ksdensity,1);
        my_dens_locs = NaN(npoints_ksdensity,1);
    end
    densities(:,k) = mydensity(:);
    dens_locs(:,k) = my_dens_locs(:);
    density_names{k} = molar_conc{k};
end

% Hypothesis Testing (Stat Analysis)
count = 1;
for k = 1:length(msds)-1
    type_A = msds(k).logmsd(minloc(1),:);   
    for m = (k+1):length(msds)
        type_B = msds(m).logmsd(minloc(1),:);        
        [h(count),p(count)] = ttest2(type_A, type_B);

        type_A_names{count} = molar_conc{k};
        type_B_names{count} = molar_conc{m};
        
        count = count + 1;
    end
end

% construct the ksdensity figure
ksfig  = figure('Visible', 'off');
plot(dens_locs, densities);
leg = legend(density_names);
set(leg, 'Interpreter', 'none');
xlabel('<r^2> [m^2]');
ylabel('pdf');
ksdensity_file = [metadata.instr.experiment '_molar_concentration_ALL' '.ksdensity'];
gen_pub_plotfiles(ksdensity_file, ksfig, 'normal');
close(ksfig);

barfig = figure('Visible', 'off');
barwitherr( (10.^(mylogmsd+mylogerr))-(10.^(mylogmsd)),  (10 .^ mylogmsd));
set(gca,'XTickLabel',molar_conc)
xlabel('cell type');
ylabel('log_{10}(<r^2> [m^2])');
barfile = [metadata.instr.experiment '_molar_concentration_ALL' '.bar'];
gen_pub_plotfiles(barfile, barfig, 'normal');
close(barfig);

% create plot with mean msd data for all values of 'myparam' across ALL taus
aggMSDfig = figure('Visible', 'off'); 
errorbar(all_logtaus, all_logmsds, all_logerrs, 'LineWidth', 2)
xlabel('time scale, \tau [s]');
ylabel('<r^2> [m^2]');
legend(molar_conc, 'Location', 'SouthEast');
aggMSDfile = [metadata.instr.experiment '_molar_concentration_ALL' '.aggmsd'];
gen_pub_plotfiles(aggMSDfile, aggMSDfig, 'normal');
close(aggMSDfig);

% create plots for each parameter value
for k = 1:length(molar_conc)    
    MSDfile{k} = [metadata.instr.experiment '_molar_concentration_' molar_conc{k} '.msd'];
    MSDfig  = figure('Visible', 'off');
    plot_msd(msds(k), MSDfig, 'ame');
    gen_pub_plotfiles(MSDfile{k}, MSDfig, 'normal'); 
    close(MSDfig);    
end

%
% HTML CODE
%
fprintf(fid, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" ');
fprintf(fid, '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> \n');
fprintf(fid, '<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">\n\n');
fprintf(fid, '<head> \n');
fprintf(fid, '<title> PanopticNerve, Cell Mechanics Experiment: %s </title>\n', nametag);
fprintf(fid, '</head>\n\n');
fprintf(fid, '<body>\n\n');

%
% Headers
%
fprintf(fid, '<h1> PanopticNerve: %s </h1> \n\n', nametag);
fprintf(fid, '<p> \n');
fprintf(fid, '   <b>Sample Name:</b>  %s <br/>\n', nametag);
fprintf(fid, '   <b>Path:</b>  %s <br/>\n', pwd);
fprintf(fid, '   <b>Filename:</b>  %s \n', outfile);
fprintf(fid, '</p> \n\n');

%
% Instrument setup
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Instrument Setup </h3> \n');
fprintf(fid, '   <b>Imagine Mode:</b>  %s <br/> \n', video_mode);
fprintf(fid, '   <b>Imaging framerate:</b> %s [fps].<br/> \n', num2str(imaging_fps));
fprintf(fid, '   <b>Video Duration:</b>  %s [s]<br/> \n', num2str(duration));
fprintf(fid, '   <b>Autofocus:</b> %s <br/> \n', autofocus_yn);
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');

%
% Data Filters setup
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Data Filters </h3> \n');
fprintf(fid, '   <b>Min. number of frames per tracker:</b> %i [frames]<br/> \n', filt.min_frames);
fprintf(fid, '   <b>Min. number of pixels per tracker:</b> %i [pixels]<br/> \n', filt.min_pixels);
fprintf(fid, '   <b>Max. number of pixels per tracker:</b> %i [pixels]<br/> \n', filt.max_pixels);
fprintf(fid, '   <b>Min. viscosity:</b> %8.3g [Pa s]<br/> \n', filt.min_visc);
fprintf(fid, '   <b>Number of first and Last frames cropped from each tracker:</b> %i [frames] <br/>\n', filt.tcrop);
fprintf(fid, '   <b>Number of pixels cropped around frame border:</b> %i [pixels] <br/> \n', filt.xycrop);
fprintf(fid, '   <b>Camera dead spots removed [X Y width height]: <br/>\n');
for k = 1:size(filt.dead_spots,1)
    fprintf(fid, '\t &nbsp;&nbsp;&nbsp; [%i %i %i %i] [pixels]<br/> \n', filt.dead_spots(k,1), ...
                                                                         filt.dead_spots(k,2), ...
                                                                         filt.dead_spots(k,3), ...
                                                                         filt.dead_spots(k,4));
end
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');

%
% Hypothesis Testing (html code)
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Hypothesis Testing </h3> \n');
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="200"> <b> A </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> B </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> p-value </b> </td> \n');
fprintf(fid, '    </tr>\n');

% Report p-values
count = 1;
for k = 1:length(msds)-1
    for m = (k+1):length(msds)
        fprintf(fid, '   <tr> \n');
        fprintf(fid, '      <td align="center" width="200"> %s </td> \n', type_A_names{count});
        fprintf(fid, '      <td align="center" width="200"> %s </td> \n', type_B_names{count});
        fprintf(fid, '      <td align="center" width="200"> %8.2e </td> \n', p(count));
        fprintf(fid, '   </tr>\n');        
        count = count + 1;
    end
end

fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');








%
% % % Report Summary table
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Summary </h3> \n');
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="200"> <b> Condition </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> MSD </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> RMS displacement </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> No. of trackers </b> </td> \n');
fprintf(fid, '    </tr>\n');

% Fill in Summary table with data
for k = 1:length(msds)
    fprintf(fid, '   <tr> \n');
    fprintf(fid, '      <td align="center" width="200"> %s </td> \n', molar_conc{k});
    fprintf(fid, '      <td align="center" width="200"> %8.2g +/- %8.2g [m^2]</td> \n', mymsd(k), myerr(k));
    fprintf(fid, '      <td align="center" width="200"> %8.0f +/- %8.1f [nm] </td> \n', rms_mymsd(k)*1e9, rms_mymsd_err(k)*1e9);
    fprintf(fid, '      <td align="center" width="200"> %8i </td> \n', msds_n(k));    
    fprintf(fid, '   </tr>\n');        
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');

%
% % % Report Summary figure.  Bar chart with error.  (Maybe ANOVA eventually?)
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Cell Types </b> <br/> \n');
fprintf(fid, '    <a href="%s">', [barfile '.fig']);
fprintf(fid, '      <img src="%s" width="400" height="300" border="0"></img> \n', [barfile '.svg']);
fprintf(fid, '    </a>');
% fprintf(fid, '   <iframe src="%s.svg" width="400" height="300" border="0"></iframe> <br/> \n', barfile);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');

%
% % % 
% 
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Cell Types, PDF </b> <br/> \n');
fprintf(fid, '    <a href="%s">', [ksdensity_file '.fig']);
fprintf(fid, '      <img src="%s" width="400" height="300" border="0"></img> \n', [ksdensity_file '.svg']);
fprintf(fid, '    </a>');
% fprintf(fid, '   <iframe src="%s.svg" width="400" height="300" border="0"></iframe> <br/> \n', ksdensity_file);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');


%
% % % Report for aggregated parameter values (this case is molar_concentration)
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Mean Squared Displacement (MSD) </b> <br/> \n');
fprintf(fid, '    <a href="%s">', [aggMSDfile '.fig']);
fprintf(fid, '      <img src="%s" width="400" height="300" border="0"></img> \n', [aggMSDfile '.svg']);
fprintf(fid, '    </a>');
% fprintf(fid, '   <iframe src="%s.svg" width="400" height="300" border="0"></iframe> <br/> \n', aggMSDfile);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');

%
% Plate-wide heat-map
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Heatmap (Viscosity at %i [s] time scale) </h3> \n', spec_tau);
% fprintf(fid, '   <iframe src="%s.png" border="0"></iframe> <br/> \n', heatmapfile);
% fprintf(fid, '   <iframe src="%s.png" width="800" height="600" border="0"></iframe> <br/> \n', heatmapfile);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');

%
% % % Produce results for each unique parameter value (this case is molar_concentration)
%

% % table header
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Mean Squared Displacement (MSD) </b> <br/> \n');
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '    <tr>\n  <td align="center" width="200">\n    <b> %s </b> <br/> \n', myparam);
fprintf(fid, '     </td>\n  <td align="center" width="425"> <b> Mean Squared Displacement (MSD) </b> <br/> \n');
fprintf(fid, '     </td>\n </tr>\n\n');

for k = 1 : length(molar_conc)   
   fprintf(fid, '    <tr>\n  <td align="left" width="200">\n     <b> %s </b> <br/> \n', molar_conc{k});
   fprintf(fid, '     </td>\n  <td align="center" width="425">\n');
   fprintf(fid, '    <a href="%s">', [MSDfile{k} '.fig']);
   fprintf(fid, '      <img src="%s" width="400" height="300" border="0"></img> \n', [MSDfile{k} '.svg']);
   fprintf(fid, '    </a>');
%    fprintf(fid, '       <iframe src="%s.svg" width="400" height="300" border="0"></iframe> \n', MSDfile{k});
   fprintf(fid, '     </td>\n </tr>\n\n');   
end

% % table base
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n\n');

% wrap up the file.
fprintf(fid, '</body> \n');
fprintf(fid, '</html> \n\n');

fclose(fid);

pan = msds;

return;


