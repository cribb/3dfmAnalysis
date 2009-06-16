function v = dmbr_run(input_params)
% 3DFM function   
% Rheology
% last modified 03/21/08 (jcribb)
%  
% dmbr_run provides a sample function for running the dmbr
% calibration from the command line.  It is also useful in testing dmbr
% code and developing additional analysis tools from the data.  
% dmbr_analysis_gui also runs via this function.
% 
%    v = dmbr_run(input_params);
% 
% where "input_params" is an input structure containing some or all of the
% following fields:
%
%  .metafile (*)                    - contains metadata parameters
%  .trackfile (*)                   - contains video tracking data for calib.
%  .poleloc (*)       [x y], [0,0]  - pole location at [x,y] in pixels.
%  .drift_remove       {on} off     - remove drift?
%  .num_buffer_points  int, 0       - number of points to buffer out of 
%                                     calculations due to clock jitter.
%  .error_tol          float, 0.4   - allowable error in force (in %)
%  .granularity        int, 8       - granularity (in pixels) of spatial
%  force matrix
%  .window_size        int, 1       - window size (tau) of derivative used
%                                     in the 'inst' calibration method.
%  .plot_results       {on}, off    - plot results?
%
% Note: Required fields are marked with a star (*).
%       Default values are enclosed in {braces}, or defined after the 
%        specified datatype.
% 

% attach constants describing column headers for dmbr raw datatable
% (extension of (derived from) video_tracking table)
dmbr_constants;

% handle input parameters
input_params = dmbr_check_input_params(input_params);

% Let's get started by making shorter variable names
trackfile         = input_params.trackfile;
metafile          = input_params.metafile;
calibfile         = input_params.calibfile;
poleloc           = input_params.poleloc;
force_type        = input_params.force_type;
tau               = input_params.tau;
scale             = input_params.scale;


% load drive parameters from dmbr_drive code.  Next we will add
% the analysis_parameters.
params = load(metafile);

% we want to put all of the metadata into a single "parameters" structure.
% However, because there are two places where metadata are inputted (once
% during the driveGUI and second through the analysisGUI) we have to merge
% the two structures together.
fnames = fieldnames(input_params);
for k = 1:length(fnames); 
    params = setfield(params, fnames{k}, getfield(input_params, fnames{k})); 
end;

% dmbr_init: initializes and loads experimental parameters and video
% tracked data.  May require user interaction to define breakpoint between 
% two sequences as the temporal alignment between the driving computer and
% the video acquisition computer is not very good (needs to be <8ms for 
% pulnix video).  Assigns pulse voltage and sequence ID for each tracker.
[vid_table,  params] = dmbr_init(params);

% output params with results as metadata information (very useful for 
% answering the myriad questions that Rich asks during a presentation or
% meeting).
v.params = params; 

% save new parameters back to the metafile so that when these data are
% loaded again, the sequence_break location, etc... will not need to be
% found again.
save(params.metafile, '-struct', 'params');

% need the magnitudes after all the adjustments for radial position.
vid_table(:,RADIAL) = magnitude(vid_table(:,X:Y));

% output the data in raw form.
v.raw.video_table = vid_table;

% attach the applied force for a given radial position from the poletip
cal = load(calibfile);
force_calib = cal.forcecal.results;

rheo_table = dmbr_attach_forces(force_calib, vid_table, force_type);

% handle each sequence for each bead separately

% iterate across beads and sequences
beads     = unique(rheo_table(:,ID))';
sequences = unique(rheo_table(:,SEQ))';
voltages  = unique(rheo_table(:,VOLTS))';

% seed some matrices
% offsetcols = [TIME X Y Z ROLL PITCH YAW J];
% v.offsets = zeros(length(beads), length(sequences), length(offsetcols))*NaN;
rheo_table(:,[J:SDJ]) = 0;

count = 1;
for k = 1:length(beads)
    idxB = find(rheo_table(:,ID) == beads(k));
    
    for m = 1:length(sequences)
        
        idx = find(rheo_table(:,ID) == beads(k) & rheo_table(:, SEQ) == sequences(m));

        
        % compute compliance
        rheo_table(idx,:) = dmbr_compute_compliance(rheo_table(idx,:), params);

        
        for n = 1:length(voltages)

            idx = find(rheo_table(:,ID)    == beads(k)      & ...
                       rheo_table(:,SEQ)   == sequences(m)  & ...
                       rheo_table(:,VOLTS) == voltages(n)   );
                   
%            fprintf('beadID: %g, unique_beads: %g, seqID: %g, voltage: %13.2g length(idx): %g\n', ...
%                     beads(k), length(unique(rheo_table(:,ID))), sequences(m), voltages(n), length(idx));

            v.beadID(count,:) = beads(k);
            v.seqID(count,:)  = sequences(m);   
            v.volts(count,:)  = voltages(n);

            if voltages(n) == 0
                % compute percent recovery
                v.recovery(count,:) = dmbr_percent_recovery(rheo_table(idx,:));

                % compute the relaxation times for the zero voltage regions
%                 v.taus(count,:) = dmbr_relaxation_time(rheo_table(idx,:), params);
            end

            if ~isempty(idx)
                rheo_table(idx,:) = dmbr_compute_derivative(rheo_table(idx,:), scale);
            end

            % fit the data to a model type
%             [v.G(count,:), v.eta(count,:), ct, v.Rsquare(count,:)] = dmbr_fit(rheo_table(idx,:), params.fit_type)

%             [G_, eta_, ct, Rsquare_] = dmbr_fit(rheo_table(idx,:), params.fit_type);
%             v.G(count,:) = G_;
%             v.eta(count,:) = eta_;
%             v.Rsquare(count,:) = Rsquare_;
            
            % compute maximum shear rate
            [v.vd(count,:), v.max_shear(count,:)] = dmbr_max_shear(rheo_table(idx,:), params);

            % compute Weissenburg Numbers
            v.Wi(count,:) = v.max_shear(count,:) * tau;

            count = count + 1;
        end
        
        %  at the sequence level, compute but do not remove offset position/time
        if ~isfield(v, 'offsets')
            nxt = 1;
        else
            nxt = size(v.offsets, 1) + 1;
        end
        
        if ~isempty(idx)
            v.offsets(nxt, :) = rheo_table(idx(1), :);
        end
        
    end

%     v.mean_curves = dmbr_compute_mean_curves(rheo_table, v.offsets);

end


% rheo_table = dmbr_compute_compliance(rheo_table, params);
v.raw.rheo_table = rheo_table;

return;
% % % % % extract the non zero regions.  for now, extract the entire vector.



%%%%%%%%%%%%%%%%
% SUBFUNCTIONS %
%%%%%%%%%%%%%%%%

%% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'dmbr_run: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;
     
     

