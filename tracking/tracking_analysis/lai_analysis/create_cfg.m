function [cfg_struct] = create_cfg(param_struct,projectname)
% param_struct is a structure containing several values for each parameter
%   that you want to change
% cfg will be the config file to be output/saved

% Eventually want this to be able to take any parameters as inputs:
% Identify which parameters are being varied from param_struct and pull out
% the values for each one
% params_to_vary = fieldnames(param_struct);
% num_params_to_vary = length(params_to_vary);
% for p = 1:num_params_to_vary
%     param = params_to_vary{p};
%     assignin('caller',param,param_struct.(param));
% end


%How to deal with the fact that we don't know how many parameters will be
%varied - how do we know how many for loops we will need to set each
%parameter? Another way to do this?

if nargin < 1
    error('No non-default parameters selected.');
end

if nargin < 2 || isempty(projectname)
    projectname = [];
end

if strcmp(projectname,'lai')
    param_struct.intensity_lost_tracking_sensitivity = 0.05;
    param_struct.dead_zone_around_border = 5;
    param_struct.dead_zone_around_trackers = 5;
    param_struct.radius = 10;
    param_struct.maintain_fluorescent_beads = 400;
    param_struct.lost_behavior = 1;
    param_struct.optimize = 1;
    param_struct.check_bead_count_interval = 1;
end


thresh_values = param_struct.fluorescent_spot_threshold;
num_thresh = length(thresh_values);
logentry([num2str(num_thresh) ' fluorescent_spot_threshold values.']);
sens_values = param_struct.intensity_lost_tracking_sensitivity;
num_sens = length(sens_values);
logentry([num2str(num_sens) ' intensity_lost_tracking_sensitivity values.']);
combos = num_thresh*num_sens;

%cfg_struct = param_struct;
defaults_struct = default_vst_params(param_struct);
cfg_struct = numericparams_to_string(defaults_struct);

for t = 1:length(thresh_values);
    thresh = thresh_values(t);
    cfg_struct.fluorescent_spot_threshold = ['set fluorescent_spot_threshold ' num2str(thresh)];
    for s = 1:length(sens_values);
        sens = sens_values(s);
        cfg_struct.intensity_lost_tracking_sensitivity = ['set intensity_lost_tracking_sensitivity ' num2str(sens)];
        filename = ['thresh=' num2str(thresh) '_sens=' num2str(sens) '.cfg'];
        cfg_cell = struct2cell(cfg_struct);
        fID = fopen(filename,'a+');
        for l = 1:length(cfg_cell);
            fprintf(fID,'%s\n',cfg_cell{l});
        end
        fclose(fID);
    end
end
logentry([num2str(combos) ' configuration files created.']);
end



function [param_struct] = numericparams_to_string(param_struct)
if isnumeric(param_struct.radius)
    param_struct.radius = ['set radius ' num2str(param_struct.radius)];
end

if isnumeric(param_struct.exposure_millisecs)
    param_struct.exposure_millisecs = ['set exposure_millisecs ' num2str(param_struct.exposure_millisecs)];
end

if isnumeric(param_struct.red_green_blue)
    param_struct.red_green_blue = ['set red_green_blue ' num2str(param_struct.red_green_blue)];
end

if isnumeric(param_struct.brighten)
    param_struct.brighten = ['set brighten ' num2str(param_struct.brighten)];
end

if isnumeric(param_struct.precision)
    param_struct.precision = ['set precision ' num2str(param_struct.precision)];
end

if isnumeric(param_struct.sample_spacing)
    param_struct.sample_spacing = ['set sample_spacing ' num2str(param_struct.sample_spacing)];
end

if isnumeric(param_struct.blur_lost_and_found)
    param_struct.blur_lost_and_found = ['set blur_lost_and_found ' num2str(param_struct.blur_lost_and_found)];
end

if isnumeric(param_struct.center_surround)
    param_struct.center_surround = ['set center_surround ' num2str(param_struct.center_surround)];
end

if isnumeric(param_struct.kernel_lost_tracking_sensitivity)
    param_struct.kernel_lost_tracking_sensitivity = ['set kernel_lost_tracking_sensitivity ' num2str(param_struct.kernel_lost_tracking_sensitivity)];
end

if isnumeric(param_struct.intensity_lost_tracking_sensitivity)
    param_struct.intensity_lost_tracking_sensitivity = ['set intensity_lost_tracking_sensitivity ' num2str(param_struct.intensity_lost_tracking_sensitivity)];
end

if isnumeric(param_struct.dead_zone_around_border)
    param_struct.dead_zone_around_border = ['set dead_zone_around_border ' num2str(param_struct.dead_zone_around_border)];
end

if isnumeric(param_struct.dead_zone_around_trackers)
    param_struct.dead_zone_around_trackers = ['set dead_zone_around_trackers ' num2str(param_struct.dead_zone_around_trackers)];
end

if isnumeric(param_struct.maintain_fluorescent_beads)
    param_struct.maintain_fluorescent_beads = ['set maintain_fluorescent_beads ' num2str(param_struct.maintain_fluorescent_beads)];
end

if isnumeric(param_struct.fluorescent_max_regions)
    param_struct.fluorescent_max_regions = ['set fluorescent_max_regions ' num2str(param_struct.fluorescent_max_regions)];
end

if isnumeric(param_struct.fluorescent_max_region_size)
    param_struct.fluorescent_max_region_size = ['set fluorescent_max_region_size ' num2str(param_struct.fluorescent_max_region_size)];
end

if isnumeric(param_struct.fluorescent_spot_threshold)
    param_struct.fluorescent_spot_threshold = ['set fluorescent_spot_threshold ' num2str(param_struct.fluorescent_spot_threshold)];
end

if isnumeric(param_struct.maintain_this_many_beads)
    param_struct.maintain_this_many_beads = ['set maintain_this_many_beads ' num2str(param_struct.maintain_this_many_beads)];
end

if isnumeric(param_struct.candidate_spot_threshold)
    param_struct.candidate_spot_threshold = ['set candidate_spot_threshold ' num2str(param_struct.candidate_spot_threshold)];
end

if isnumeric(param_struct.sliding_window_radius)
    param_struct.sliding_window_radius = ['set sliding_window_radius ' num2str(param_struct.sliding_window_radius)];
end

if isnumeric(param_struct.lost_behavior)
    param_struct.lost_behavior = ['set lost_behavior ' num2str(param_struct.lost_behavior)];
end

if isnumeric(param_struct.kerneltype)
    param_struct.kerneltype = ['set kerneltype ' num2str(param_struct.kerneltype)];
end

if isnumeric(param_struct.dark_spot)
    param_struct.dark_spot = ['set dark_spot ' num2str(param_struct.dark_spot)];
end

if isnumeric(param_struct.interpolate)
    param_struct.interpolate = ['set interpolate ' num2str(param_struct.interpolate)];
end

if isnumeric(param_struct.parabolafit)
    param_struct.parabolafit = ['set parabolafit ' num2str(param_struct.parabolafit)];
end

if isnumeric(param_struct.predict)
    param_struct.predict = ['set predict ' num2str(param_struct.predict)];
end

if isnumeric(param_struct.follow_jumps)
    param_struct.follow_jumps = ['set follow_jumps ' num2str(param_struct.follow_jumps)];
end

if isnumeric(param_struct.search_radius)
    param_struct.search_radius = ['set search_radius ' num2str(param_struct.search_radius)];
end

if isnumeric(param_struct.predict)
    param_struct.predict = ['set predict ' num2str(param_struct.predict)];
end

if isnumeric(param_struct.rod3)
    param_struct.rod3 = ['set rod3 ' num2str(param_struct.rod3)];
end

if isnumeric(param_struct.length)
    param_struct.length = ['set length ' num2str(param_struct.length)];
end

if isnumeric(param_struct.rod_orient)
    param_struct.rod_orient = ['set rod_orient ' num2str(param_struct.rod_orient)];
end

if isnumeric(param_struct.image_orient)
    param_struct.image_orient = ['set image_orient ' num2str(param_struct.image_orient)];
end

if isnumeric(param_struct.frames_to_average_or)
    param_struct.frames_to_average_or = ['set frames_to_average_or ' num2str(param_struct.frames_to_average_or)];
end

if isnumeric(param_struct.frames_to_average)
    param_struct.frames_to_average = ['set frames_to_average ' num2str(param_struct.frames_to_average)];
end

if isnumeric(param_struct.round_cursor)
    param_struct.round_cursor = ['set round_cursor ' num2str(param_struct.round_cursor)];
end

if isnumeric(param_struct.show_tracker)
    param_struct.show_tracker = ['set show_tracker ' num2str(param_struct.show_tracker)];
end

if isnumeric(param_struct.show_video)
    param_struct.show_video = ['set show_video ' num2str(param_struct.show_video)];
end

if isnumeric(param_struct.background_subtract)
    param_struct.background_subtract = ['set background_subtract ' num2str(param_struct.background_subtract)];
end

if isnumeric(param_struct.logging_video)
    param_struct.logging_video = ['set logging_video ' num2str(param_struct.logging_video)];
end 

if isnumeric(param_struct.video_full_frame_every)
    param_struct.video_full_frame_every = ['set video_full_frame_every ' num2str(param_struct.video_full_frame_every)];
end

if isnumeric(param_struct.optimize)
    param_struct.optimize = ['set optimize ' num2str(param_struct.optimize)];
end

if isnumeric(param_struct.check_bead_count_interval)
    param_struct.check_bead_count_interval = ['set check_bead_count_interval ' num2str(param_struct.check_bead_count_interval)];
end

logentry('Set all specified paremeters.');

end

function [param_struct] = default_vst_params(param_struct)
%Make so that you can give it a string and it will give you default values
%for that project default

%Set parameters to default values - these are panoptes defaults
if ~isfield(param_struct,'radius') || isempty(param_struct.radius)
    param_struct.radius = 'set radius 5';
end

if ~isfield(param_struct,'exposure_millisecs') || isempty(param_struct.exposure_millisecs)
    param_struct.exposure_millisecs = 'set exposure_millisecs 10';
end

if ~isfield(param_struct,'red_green_blue') || isempty(param_struct.red_green_blue)
    param_struct.red_green_blue = 'set red_green_blue 0';
end

if ~isfield(param_struct,'brighten') || isempty(param_struct.brighten)
    param_struct.brighten = 'set brighten 0';
end

if ~isfield(param_struct,'precision') || isempty(param_struct.precision)
    param_struct.precision = 'set precision 0.05';
end

if ~isfield(param_struct,'sample_spacing') || isempty(param_struct.sample_spacing)
    param_struct.sample_spacing = 'set sample_spacing 1';
end

if ~isfield(param_struct,'blur_lost_and_found') || isempty(param_struct.blur_lost_and_found)
    param_struct.blur_lost_and_found = 'set blur_lost_and_found 0';
end

if ~isfield(param_struct,'center_surround') || isempty(param_struct.center_surround)
    param_struct.center_surround = 'set center_surround 3';
end

if ~isfield(param_struct,'kernel_lost_tracking_sensitivity') || isempty(param_struct.kernel_lost_tracking_sensitivity)
    param_struct.kernel_lost_tracking_sensitivity = 'set kernel_lost_tracking_sensitivity 0';
end

if ~isfield(param_struct,'intensity_lost_tracking_sensitivity') || isempty(param_struct.intensity_lost_tracking_sensitivity)
    param_struct.intensity_lost_tracking_sensitivity = 'set intensity_lost_tracking_sensitivity 0.05';
end

if ~isfield(param_struct,'dead_zone_around_border') || isempty(param_struct.dead_zone_around_border)
    param_struct.dead_zone_around_border = 'set dead_zone_around_border 0';
end

if ~isfield(param_struct,'dead_zone_around_trackers') || isempty(param_struct.dead_zone_around_trackers)
    param_struct.dead_zone_around_trackers = 'set dead_zone_around_trackers 0';
end

if ~isfield(param_struct,'maintain_fluorescent_beads') || isempty(param_struct.maintain_fluorescent_beads)
    param_struct.maintain_fluorescent_beads = 'set maintain_fluorescent_beads 0';
end

if ~isfield(param_struct,'fluorescent_max_regions') || isempty(param_struct.fluorescent_max_regions)
    param_struct.fluorescent_max_regions = 'set fluorescent_max_regions 1000';
end

if ~isfield(param_struct,'fluorescent_max_region_size') || isempty(param_struct.fluorescent_max_region_size)
    param_struct.fluorescent_max_region_size = 'set fluorescent_max_region_size 60000';
end

if ~isfield(param_struct,'fluorescent_spot_threshold') || isempty(param_struct.fluorescent_spot_threshold)
    param_struct.fluorescent_spot_threshold = 'set fluorescent_spot_threshold 0.5';
end

if ~isfield(param_struct,'maintain_this_many_beads') || isempty(param_struct.maintain_this_many_beads)
    param_struct.maintain_this_many_beads = 'set maintain_this_many_beads 0';
end

if ~isfield(param_struct,'candidate_spot_threshold') || isempty(param_struct.candidate_spot_threshold)
    param_struct.candidate_spot_threshold = 'set candidate_spot_threshold 5';
end

if ~isfield(param_struct,'sliding_window_radius') || isempty(param_struct.sliding_window_radius)
    param_struct.sliding_window_radius = 'set sliding_window_radius 10';
end

if ~isfield(param_struct,'lost_behavior') || isempty(param_struct.lost_behavior)
    param_struct.lost_behavior = 'set lost_behavior 0';
end

if ~isfield(param_struct,'kerneltype') || isempty(param_struct.kerneltype)
    param_struct.kerneltype = 'set kerneltype 2';
end

if ~isfield(param_struct,'dark_spot') || isempty(param_struct.dark_spot)
    param_struct.dark_spot = 'set dark_spot 0';
end

if ~isfield(param_struct,'interpolate') || isempty(param_struct.interpolate)
    param_struct.interpolate = 'set interpolate 1';
end

if ~isfield(param_struct,'parabolafit') || isempty(param_struct.parabolafit)
    param_struct.parabolafit = 'set parabolafit 0';
end

if ~isfield(param_struct,'predict') || isempty(param_struct.predict)
    param_struct.predict = 'set predict 0';
end

if ~isfield(param_struct,'follow_jumps') || isempty(param_struct.follow_jumps)
    param_struct.follow_jumps = 'set follow_jumps 0';
end

if ~isfield(param_struct,'search_radius') || isempty(param_struct.search_radius)
    param_struct.search_radius = 'set search_radius 0';
end

if ~isfield(param_struct,'predict') || isempty(param_struct.predict)
    param_struct.predict = 'set predict 0';
end

if ~isfield(param_struct,'rod3') || isempty(param_struct.rod3)
    param_struct.rod3 = 'set rod3 0';
end

if ~isfield(param_struct,'length') || isempty(param_struct.length)
    param_struct.length = 'set length 20';
end

if ~isfield(param_struct,'rod_orient') || isempty(param_struct.rod_orient)
    param_struct.rod_orient = 'set rod_orient 0';
end

if ~isfield(param_struct,'image_orient') || isempty(param_struct.image_orient)
    param_struct.image_orient = 'set image_orient 0';
end

if ~isfield(param_struct,'frames_to_average_or') || isempty(param_struct.frames_to_average_or)
    param_struct.frames_to_average_or = 'set frames_to_average_or 0';
end

if ~isfield(param_struct,'frames_to_average') || isempty(param_struct.frames_to_average)
    param_struct.frames_to_average = 'set frames_to_average 0';
end

if ~isfield(param_struct,'round_cursor') || isempty(param_struct.round_cursor)
    param_struct.round_cursor = 'set round_cursor 1';
end

if ~isfield(param_struct,'show_tracker') || isempty(param_struct.show_tracker)
    param_struct.show_tracker = 'set show_tracker 1';
end

if ~isfield(param_struct,'show_video') || isempty(param_struct.show_video)
    param_struct.show_video = 'set show_video 1';
end

if ~isfield(param_struct,'background_subtract') || isempty(param_struct.background_subtract)
    param_struct.background_subtract = 'set background_subtract 0';
end

if ~isfield(param_struct,'logging_video') || isempty(param_struct.logging_video)
    param_struct.logging_video = 'set logging_video 0'; 
end

if ~isfield(param_struct,'video_full_frame_every') || isempty(param_struct.video_full_frame_every)
    param_struct.video_full_frame_every = 'set video_full_frame_every 400';
end

if ~isfield(param_struct,'optimize') || isempty(param_struct.optimize)
    param_struct.optimize = 'set optimize 0';
end

if ~isfield(param_struct,'check_bead_count_interval') || isempty(param_struct.check_bead_count_interval)
    param_struct.check_bead_count_interval = 'set check_bead_count_interval 5';
end

logentry('Finished filling in default VST parameters.');
end