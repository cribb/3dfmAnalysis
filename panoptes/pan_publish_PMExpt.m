function pan = pan_publish_PMExpt(metadata)
% PAN_PUBLISH_CELLEXPT  Generates an html report for the Panoptes Cell Experiment
%
% CISMM function
% Panoptes
% last modified 2011.08.10
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
fps_bright = metadata.instr.fps_bright;
autofocus = metadata.instr.auto_focus;

filt.min_frames = 30;
filt.min_pixels = 1;
filt.max_pixels = Inf;
filt.tcrop      = 0;
filt.xycrop     = 0;
filt.xyzunits   = 'pixels';
% filt.calib_um   = 1;
    
if autofocus
    autofocus_yn = 'Yes.';
else
    autofocus_yn = 'No.';
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
heatmat_msds = reshape(heatmap_msds, 12, 8)';

% Heat map
heatmapfig = figure; 
imagesc(1:12, 1:8, log10(sqrt(10.^heatmat_msds)*1e6)); 
colormap(hot);
colorbar;
set(gca, 'XTick', [1:12]');
set(gca, 'XTickLabel', [1:12]');
set(gca, 'XAxisLocation', 'top');
set(gca, 'YTick', [1:8]');
set(gca, 'YTickLabel', {'A'; 'B'; 'C'; 'D'; 'E'; 'F'; 'G'; 'H'});
title('RMS displacement (in log_{10} \mum)');
pretty_plot;
heatmapfile = [metadata.instr.experiment '_molar_concentration_ALL' '.heatmap'];
gen_pub_plotfiles(heatmapfile, heatmapfig, 'normal');
close(heatmapfig);

%%%%  Calculate the MSD for different cell types
% myparam = 'metadata.plate.solution.molar_concentration';
% myparam = 'metadata.plate.solution.mass_concentration';
myparam = 'metadata.plate.well_map';
% myparam = 'metadata.plate.cell.name';

% compute the MSD for each condition defined by 'myparam'
[msds molar_conc] = pan_combine_data(metadata, myparam);

% variablest that contain summarized data
all_taus = [msds.mean_logtau];
all_msds = [msds.mean_logmsd];
all_errs = [msds.msderr];

% create plot with bar graph at a given tau
spec_tau = 1;
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
% % % %         type_A_names{count} = molar_conc{k};
% % % %         type_B_names{count} = molar_conc{m};
% % % %         
% % % %         count = count + 1;
% % % %     end
% % % % end



% One-dimensional bar chart
RMS_disp = sqrt(10 .^ mymsd)*1e6;
RMS_disp_err = sqrt(10.^(mymsd+myerr)-10.^(mymsd)) *1e6;
barfig = figure;
barwitherr( RMS_disp_err, RMS_disp );
set(gca,'XTickLabel',molar_conc)
xlabel('cell type');
ylabel('RMS displacment [\mum]');
barfile = [metadata.instr.experiment '_molar_concentration_ALL' '.bar'];
gen_pub_plotfiles(barfile, barfig, 'normal');
close(barfig);

% create plot with mean msd data for all values of 'myparam' across ALL taus
aggMSDfig = figure; 
errorbar(all_taus, all_msds, all_errs, 'LineWidth', 2)
xlabel('time scale, \tau [s]');
ylabel('<r^2> [m^2]');
legend(molar_conc, 'Location', 'SouthEast');
aggMSDfile = [metadata.instr.experiment '_molar_concentration_ALL' '.aggmsd'];
gen_pub_plotfiles(aggMSDfile, aggMSDfig, 'normal');
close(aggMSDfig);

% create plots for each parameter value
for k = 1:length(molar_conc)    
    MSDfile{k} = [metadata.instr.experiment '_molar_concentration_' molar_conc{k} '.msd'];
    MSDfig  = plot_msd(msds(k), [], 'ame');
    figure(MSDfig);
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
fprintf(fid, '   <b>Video Duration:</b>  %s [s]<br/> \n', num2str(duration));
fprintf(fid, '   <b>Video framerate, brightfield:</b> %s [fps].<br/> \n', num2str(fps_bright));
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
fprintf(fid, '</p> \n');
fprintf(fid, '<hr/> \n\n');

%
% Plate-wide heat-map
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <h3> Heatmap (RMS displacement) </h3> \n');
fprintf(fid, '   <iframe src="%s.png" width="400" height="300" border="0"></iframe> <br/> \n', heatmapfile);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');

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
fprintf(fid, '   <b> Summary: Cell Types </b> <br/> \n');
fprintf(fid, '   <iframe src="%s.svg" width="400" height="300" border="0"></iframe> <br/> \n', barfile);
fprintf(fid, '   <br/> \n\n');
fprintf(fid, '</p> \n\n');

%
% % % Report for aggregated parameter values (this case is molar_concentration)
%
fprintf(fid, '<p> \n');
fprintf(fid, '   <b> Summary: Mean Squared Displacement (MSD) </b> <br/> \n');
fprintf(fid, '   <iframe src="%s.svg" width="400" height="300" border="0"></iframe> <br/> \n', aggMSDfile);
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
   fprintf(fid, '    <tr>\n  <td align="left" width="200">\n    <b> %s </b> <br/> \n', molar_conc{k});
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

return;


