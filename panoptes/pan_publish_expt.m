function pan = pan_publish_expt(metadata, filt, myparam)
% PAN_PUBLISH_EXPT  Generates an html report for Panoptes Experiments
%
% CISMM function
% Panoptes
%  
% Generates a report for tests perfomed on Panoptes
%
% Generates and reports the results tests and experiments perfomed on 
% Panoptes in a root html file with figures saved in several formats (.fig 
% for matlab manipulation, .png as raster image for quick insertion into 
% reports, and .svg as vectorized image for ease of making publication 
% quality images).
% 
%  pan = panoptes_publish_PMExpt(metadata) 
%   
%  "metadata" is the matlab structure that describes a Panoptes experiment
%  design, outputted by 'pan_load_metadata'
%  "filt" is the matlab structure that contains the settings for filtering
%  bead trajectories in panoptes type experiments
%  "myparam" is the preferred aggregating paramter(s) over which to combine
%  data in the experiment
%  "report_blocks" contains the tags used to define which blocks of
%  information to include in the outputted report
%

% Process the inputs adequately to ensure operability later on in this
% function
if nargin < 4 || isemtpy(report_blocks)
    report_blocks = {'msd_heatmap'};
end

if nargin < 3 || isempty(myparam)
    myparam = 'metadata.plate.well_map';
    % myparam = 'metadata.plate.cell.name';
end

if nargin < 2 || isempty(filt)
    error('No filter information found.');
end    

if nargin < 1 || isempty(metadata)
    error('No metadata information found.');
end

spec_tau = 1;

% XXX Need to wrap this in an 'if' block so that if the report blocks 
%     don't contain the need to compute the heatmaps then don't do this
%     very slow process of computing the msd for each well.
% report blocks for this include: 'visc_heatmap', 'msd_heatmap', 'rmsdisp_heatmap', ???
if find(strcmp(report_blocks, 'msd_heatmap'))       || ...
   find(strcmp(report_blocks, 'rmsdisp_heatmap'))   || ...
   find(strcmp(report_blocks, 'visc_heatmap'))      || ...
   find(strcmp(report_blocks, 'plate_msd_bar'))     || ...
   find(strcmp(report_blocks, 'plate_rmsdisp_bar')) || ...
   find(strcmp(report_blocks, 'plate_visc_bar'))    || ...
   find(strcmp(report_blocks, 'plate_summary'))

   %%%%  Calculate the MSD for different wells
   [plate_msds_by_well, heatmaps] = pan_compute_platewide_msd(metadata, spec_tau);    
end


% compute the MSD for the condition defined by 'myparam'
[msds data_for_myparam] = pan_combine_data(metadata, myparam);

% variables that contain summarized data
all_taus = [msds.mean_logtau];
all_msds = [msds.mean_logmsd];
all_errs = [msds.msderr];

% create plot with bar graph at a given tau
log_spec_tau = log10(spec_tau);
[minval, minloc] = min( sqrt((all_taus - log_spec_tau).^2) );
mytau = 10.^all_taus(minloc(1),:);
mymsd = all_msds(minloc(1),:);
myerr = all_errs(minloc(1),:);

% % % % % Hypothesis Testing (Stat Analysis)
% % % % count = 1;
% % % % for k = 1:length(msds)-1
% % % %     type_A = log10(msds(k).msd(minloc(1),:));   
% % % %     for m = (k+1):length(msds)
% % % %         type_B = log10(msds(m).msd(minloc(1),:));        
% % % %         [h(count),p(count)] = ttest2(type_A, type_B);
% % % % 
% % % %         type_A_names{count} = data_for_myparam{k};
% % % %         type_B_names{count} = data_for_myparam{m};
% % % %         
% % % %         count = count + 1;
% % % %     end
% % % % end

% generate information for the data table summary
all_ns   = [msds.n];
rms_mymsd = sqrt(10.^mymsd);
rms_mymsd_err = sqrt(10.^(mymsd+myerr)) - rms_mymsd;
msds_n = all_ns(minloc(1),:);

% One-dimensional bar chart
MSD = (10 .^ mymsd);
MSD_err = (10.^(mymsd+myerr)-10.^(mymsd));
barfig = figure('Visible', 'off');
barwitherr( MSD_err, MSD );
set(gca, 'XTick', 1:length(data_for_myparam));
set(gca,'XTickLabel',data_for_myparam)
xlabel('Well ID');
ylabel('MSD [m^2] at \tau=10 [s]');
barfile = [metadata.instr.experiment '_well_ALL' '.bar'];
gen_pub_plotfiles(barfile, barfig, 'normal');
close(barfig);
drawnow;

% create plot with mean msd data for all values of 'myparam' across ALL taus
aggMSDfig = figure; 
set(aggMSDfig, 'Visible', 'off');
errorbar(all_taus, all_msds, all_errs, 'LineWidth', 2)
xlabel('time scale, \tau [s]');
ylabel('<r^2> [m^2]');
legend(data_for_myparam, 'Location', 'SouthEast');
aggMSDfile = [metadata.instr.experiment '_well_ALL' '.aggmsd'];
gen_pub_plotfiles(aggMSDfile, aggMSDfig, 'normal');
close(aggMSDfig);
drawnow;

% create plots for each parameter value

% find the highest and lowest mean MSD value for the entire run and plot
% all msd curves onto that grid so plots from different wells can be
% compared to one another by eye.  

% To do this, we need to pull out ALL of the MSD values and extract the
% absolute min and max of the dataset.
for k = 1:length(msds)
    temp_meanlogmsd(:,k) = msds(k).mean_logmsd;
end
YLim_low = floor(nanmin(temp_meanlogmsd(:)));
YLim_high = ceil(nanmax(temp_meanlogmsd(:)));

if isnan(YLim_low )
    YLim_low = -18;
end

if isnan(YLim_high)
    YLim_high = -12;
end

for k = 1:length(data_for_myparam)    
    my_data_for_myparam = strrep(data_for_myparam{k}, ' ', '');
    MSDfile{k} = [metadata.instr.experiment '_well_' my_data_for_myparam '.msd'];
    MSDfig  = figure('Visible', 'off');
    plot_msd(msds(k), MSDfig, 'ame');
    set(gca, 'YLim', [YLim_low YLim_high]);

    gen_pub_plotfiles(MSDfile{k}, MSDfig, 'normal'); 
    close(MSDfig);    
end




% % START REPORT GENERATION TO HTML PAGE

% Pull out info into shorter variable names
nametag     = metadata.instr.experiment;
duration    = metadata.instr.seconds;
autofocus   = metadata.instr.auto_focus;
video_mode  = metadata.instr.video_mode;
imaging_fps = metadata.instr.fps_imagingmode;

% Did this experiment use autofocus? (This looks stupid at first glance)
if autofocus
    autofocus_yn = 'Yes.';
else
    autofocus_yn = 'No.';
end

% which video mode did we use?
switch video_mode
    case 0
        video_mode = 'fluorescence burst, then brightfield';
    case 1
        video_mode = 'fluorescence only';
    otherwise
        error('Unknown video mode type.');
end

outfile = [nametag '.html'];
fid = fopen(outfile, 'w');

%
% HTML CODE HEADER
%
fprintf(fid, '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" ');
fprintf(fid, '"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> \n');
fprintf(fid, '<html lang="en-US" xml:lang="en-US" xmlns="http://www.w3.org/1999/xhtml">\n\n');
fprintf(fid, '<head> \n');
fprintf(fid, '<title> PanopticNerve Experiment: %s </title>\n', nametag);
fprintf(fid, '</head>\n\n');
fprintf(fid, '<body>\n\n');

%
% Report Headers
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
fprintf(fid, '   <b>Number of first and Last frames cropped from each tracker:</b> %i [frames] <br/>\n', filt.tcrop);
fprintf(fid, '   <b>Number of pixels cropped around frame border:</b> %i [pixels] <br/> \n', filt.xycrop);
fprintf(fid, '   <b>Camera dead spots removed [X Y width height]: <br/>\n');
for k = 1:size(filt.dead_spots,1)
    fprintf(fid, '\t &nbsp;&nbsp;&nbsp; [%i %i %i %i] [pixels]<br/> \n', filt.dead_spots(k,1), ...
                                                                         filt.dead_spots(k,2), ...
                                                                         filt.dead_spots(k,3), ...
                                                                         filt.dead_spots(k,4));
end
fprintf(fid, '   <b>Drift subtraction method:</b> %s <br/> \n', filt.drift_method);
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');


%
% Plate-wide RMS displacement heat-map
%
if find(strcmp(report_blocks, 'rmsdisp_heatmap'))
    [heatmaps.rmsdisp, heatmaps.rmsdisp_err] = pan_compute_rmsdisp_heatmap(heatmaps.msd, heatmaps.msd_err);

    % RMS displacement heatmap
    heatmaps.rmsdisp = sqrt(10.^heatmaps.msd);
    rmsmapfig = pan_plot_heatmap(heatmaps.rmsdisp, 'rms displacement');
    rmsmapfile = [metadata.instr.experiment '_well_ALL' '.RMSheatmap'];
    gen_pub_plotfiles(rmsmapfile, rmsmapfig, 'normal');
    close(rmsmapfig);
    drawnow;
    
    fprintf(fid, '<p> \n');
    fprintf(fid, '   <h3> Heatmap (RMS displacement at %i [s] time scale) </h3> \n', spec_tau);
    % fprintf(fid, '   <iframe src="%s.png" border="0"></iframe> <br/> \n', MSD_heatmapfile);
    fprintf(fid, '   <img src="%s.png" width=50%% border="0"></img> <br/> \n', rmsmapfile);
    fprintf(fid, '   <br/> \n\n');
    fprintf(fid, '</p> \n\n');
end


%
% Plate-wide MSD heat-map
%
if find(strcmp(report_blocks, 'msd_heatmap'))
    % MSD heatmap
    msdmapfig = pan_plot_heatmap(heatmaps.msd, 'msd');
    msdmapfile = [metadata.instr.experiment '_well_ALL' '.msdheatmap'];
    gen_pub_plotfiles(msdmapfile, msdmapfig, 'normal');
    close(msdmapfig);
    drawnow;

    fprintf(fid, '<p> \n');
    fprintf(fid, '   <h3> Heatmap (MSD at 10 [s] time scale) </h3> \n');
    % fprintf(fid, '   <iframe src="%s.png" border="0"></iframe> <br/> \n', MSD_heatmapfile);
    fprintf(fid, '   <iframe src="%s.png" width="800" height="600" border="0"></iframe> <br/> \n', msdmapfile);
    fprintf(fid, '   <br/> \n\n');
    fprintf(fid, '</p> \n\n');
end


%
% Plate-wide Viscosity heat-map
%
if find(strcmp(report_blocks, 'visc_heatmap'))
    [heatmaps.visc, heatmaps.visc_err] = pan_compute_viscosity_heatmap(metadata, spec_tau, heatmaps.msd, heatmaps.msd_err);    

    % Viscosity heatmap
    viscmapfig = pan_plot_heatmap(heatmaps.visc, 'viscosity');
    viscmapfile = [metadata.instr.experiment '_well_ALL' '.heatmap'];
    gen_pub_plotfiles(viscmapfile, viscmapfig, 'normal');
    close(viscmapfig);
    drawnow;
    
    fprintf(fid, '<p> \n');
    fprintf(fid, '   <h3> Heatmap (Viscosity at %i [s] time scale) </h3> \n', spec_tau);
    % fprintf(fid, '   <iframe src="%s.png" border="0"></iframe> <br/> \n', heatmapfile);
    fprintf(fid, '   <img src="%s.png" width=50%% border="0"></img> <br/> \n', viscmapfile);
    fprintf(fid, '   <br/> \n\n');
    fprintf(fid, '</p> \n\n');
end


%
% Plate-wide MCU heat-map
%
if find(strcmp(report_blocks, 'MCU_heatmap'))
    % MCU parameter heatmap
    mcumap = NaN(1,96);
    for wellIDX = 1:96
        mywell = find(metadata.mcuparams.well == wellIDX);
        if ~isempty(mywell)
            mcumap(wellIDX) = mean( metadata.mcuparams.mcu(mywell) );
        else
            mcumap(wellIDX) = NaN;
        end
    end
    heatmaps.mcu = pan_array2plate(mcumap);
    mcumapfig = pan_plot_heatmap(heatmaps.mcu, 'MCU parameter');
    mcumapfile = [metadata.instr.experiment '_well_ALL' '.MCUheatmap'];
    gen_pub_plotfiles(mcumapfile, mcumapfig, 'normal');
    close(mcumapfig);
    drawnow;

    fprintf(fid, '<p> \n');
    fprintf(fid, '   <h3> Heatmap (MCU parameter) </h3> \n', spec_tau);
    % fprintf(fid, '   <iframe src="%s.png" border="0"></iframe> <br/> \n', heatmapfile);
    fprintf(fid, '   <img src="%s.png" width=50%% border="0"></img> <br/> \n', mcumapfile);
    fprintf(fid, '   <br/> \n\n');
    fprintf(fid, '</p> \n\n');
end


%
% Plate-wide Number of Trackers heat-map
%
if find(strcmp(report_blocks, 'NumTr_heatmap'))
    % Number of trackers heatmap
    trkrmapfig = pan_plot_heatmap(heatmaps.beadcount, 'num trackers');
    trkrmapfile = [metadata.instr.experiment '_well_ALL' '.trkrheatmap'];
    gen_pub_plotfiles(trkrmapfile, trkrmapfig, 'normal');
    close(trkrmapfig);
    drawnow;

    fprintf(fid, '<p> \n');
    fprintf(fid, '   <h3> Heatmap (Number of Trackers) </h3> \n', spec_tau);
    % fprintf(fid, '   <iframe src="%s.png" border="0"></iframe> <br/> \n', heatmapfile);
    fprintf(fid, '   <img src="%s.png" width=50%% border="0"></img> <br/> \n', trkrmapfile);
    fprintf(fid, '   <br/> \n\n');
    fprintf(fid, '</p> \n\n');
end

%
% % % Report Summary table
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Summary at %i timescale </h3> \n', num2str(spec_tau));
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '   <tr> \n');
fprintf(fid, '      <td align="center" width="200"> <b> Condition </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> MSD </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> RMS displacement </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> App. Viscosity </b> </td> \n');
fprintf(fid, '      <td align="center" width="200"> <b> No. of trackers </b> </td> \n');
fprintf(fid, '    </tr>\n');

% Fill in Summary table with data
for k = 1:length(msds)
    fprintf(fid, '   <tr> \n');
    fprintf(fid, '      <td align="center" width="200"> %s </td> \n', data_for_myparam{k});
    fprintf(fid, '      <td align="center" width="200"> %8.2g +/- %8.2g [m^2]</td> \n', MSD(k), MSD_err(k));
    fprintf(fid, '      <td align="center" width="200"> %8.0f +/- %8.1f [nm] </td> \n', rms_mymsd(k)*1e9, rms_mymsd_err(k)*1e9);
    fprintf(fid, '      <td align="center" width="200"> %8.1f +/- %8.2f [mPa s] </td> \n', visclist(k)*1e3, visc_errlist(k)*1e3);
    fprintf(fid, '      <td align="center" width="200"> %8i </td> \n', msds_n(k));    
    fprintf(fid, '   </tr>\n');        
end
fprintf(fid, '   </table>\n');
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');

% % % % % %
% % % % % % Hypothesis Testing (html code)
% % % % % %
% % % % % fprintf(fid, '<p> \n');
% % % % % fprintf(fid, '   <h3> Hypothesis Testing </h3> \n');
% % % % % fprintf(fid, '   <table border="2" cellpadding="6"> \n');
% % % % % fprintf(fid, '   <tr> \n');
% % % % % fprintf(fid, '      <td align="center" width="200"> <b> A </b> </td> \n');
% % % % % fprintf(fid, '      <td align="center" width="200"> <b> B </b> </td> \n');
% % % % % fprintf(fid, '      <td align="center" width="200"> <b> p-value </b> </td> \n');
% % % % % fprintf(fid, '    </tr>\n');
% % % % % 
% % % % % % Report p-values
% % % % % count = 1;
% % % % % for k = 1:length(msds)-1
% % % % %     for m = (k+1):length(msds)
% % % % %         fprintf(fid, '   <tr> \n');
% % % % %         fprintf(fid, '      <td align="center" width="200"> %s </td> \n', type_A_names{count});
% % % % %         fprintf(fid, '      <td align="center" width="200"> %s </td> \n', type_B_names{count});
% % % % %         fprintf(fid, '      <td align="center" width="200"> %8.2e </td> \n', p(count));
% % % % %         fprintf(fid, '   </tr>\n');        
% % % % %         count = count + 1;
% % % % %     end
% % % % % end
% % % % % 
% % % % % fprintf(fid, '   </table>\n');
% % % % % fprintf(fid, '</p> \n');
% % % % % fprintf(fid, '<hr/> \n\n');

%
% % % Report Summary figure.  Bar chart with error.  (Maybe ANOVA eventually?)
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Mean Squared Displacements at %i [s] timescale </b> <br/> \n', spec_tau);
fprintf(fid, '   <iframe src="%s.svg" width="400" height="300" border="0"></iframe> <br/> \n', barfile);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');

%
% % % Report for aggregated parameter values (this case is data_for_myparam)
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Mean Squared Displacement (MSD) </b> <br/> \n');
fprintf(fid, '   <iframe src="%s.svg" width="400" height="300" border="0"></iframe> <br/> \n', aggMSDfile);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');

%
% % % Produce results for each unique parameter value (this case is data_for_myparam)
%

% % table header
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Mean Squared Displacement (MSD) </b> <br/> \n');
fprintf(fid, '   <table border="2" cellpadding="6"> \n');
fprintf(fid, '    <tr>\n  <td align="center" width="200">\n    <b> %s </b> <br/> \n', myparam);
fprintf(fid, '     </td>\n  <td align="center" width="425"> <b> Mean Squared Displacement (MSD) </b> <br/> \n');
fprintf(fid, '     </td>\n </tr>\n\n');

for k = 1 : length(data_for_myparam)   
   fprintf(fid, '    <tr>\n  <td align="left" width="200">\n    <b> %s </b> <br/> \n', data_for_myparam{k});
   fprintf(fid, '     </td>\n  <td align="center" width="425">\n');
   fprintf(fid, '       <iframe src="%s.svg" width="400" height="300" border="0"></iframe> \n', MSDfile{k});
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

save(nametag);

return;


