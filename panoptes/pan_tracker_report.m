function outs = pan_tracker_report(filepath, systemid, plate_type)

video_tracking_constants;

if nargin < 1 || isempty(filepath)
    filepath = '.';
end

metadata = pan_load_metadata(filepath, systemid, plate_type);

fps = metadata.instr.fps_imagingmode;
mytitle = metadata.instr.experiment;

bead_stacks_NF = pan_collect_tracker_areas(filepath, 'panoptes', 'n');

cs = combine_tracker_image_stacks(bead_stacks_NF);

scs = sort_tracker_images(cs, 'sens');
hs = plot_tracker_images(scs, 'sens', mytitle);
gen_pub_plotfiles('trackerimages_unscaled.sens.fig', hs(1), 'normal');
gen_pub_plotfiles('trackerimages_scaled.sens.fig', hs(2), 'normal');

sca = sort_tracker_images(cs, 'area');
ha = plot_tracker_images(sca, 'area', mytitle);
gen_pub_plotfiles('trackerimages_unscaled.area.fig', ha(1), 'normal');
gen_pub_plotfiles('trackerimages_scaled.area.fig', ha(2), 'normal');

% 
% scna = sort_tracker_images(cs, 'newarea');
% hna = plot_tracker_images(scna, 'newarea', mytitle);





sens = scs.sorted_vals;
area = sca.sorted_vals;
% newarea = scna.sorted_vals;

histfig = figure;

    figure(histfig);

    subplot(2, 1, 1);
    hist(log10(sens), 50);
    xlabel('log_{10}(VST sensitivity)');
    ylabel('counts');
    
    subplot(2,1,2);
    hist(area, 50);
    xlabel('VST region size (area)');
    ylabel('counts');
%     
%     subplot(3,1,3);
%     hist(newarea, 50);
%     xlabel('new_area');
%     ylabel('counts');
    gen_pub_plotfiles('tracker-report-histogram', histfig, 'normal');
    
outs = cs;
