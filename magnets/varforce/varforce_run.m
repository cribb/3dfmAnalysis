function v = varforce_run(input_params);
% 3DFM function  
% Magnetics/varforce
% last modified 08/02/06 (jcribb)
%  
% varforce_run provides a sample function for running the varforce
% calibration from the command line.  It is also useful in testing varforce
% code and developing additional analysis tools from the data.  
% varforce_analysis_gui also runs via this function.
% 
%    v = varforce_run(input_params);
% 
% where "input_params" is an input structure containing some or all of the
% following fields:
%
%  .metafile (*)                    - contains metadata parameters
%  .trackfile (*)                   - contains video tracking data for calib.
%  .poleloc (*)       [x y], [0,0]  - pole location at [x,y] in pixels.
%  .compute_linefit    {on} off     - computes linefit calibration method.
%  .compute_inst       {on} off     - computes spatial calibration method.
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

% attach constants describing column headers for varforce raw datatable
% (extension of (derived from) video_tracking table)
varforce_constants;

% handle input parameters
input_params = check_input_params(input_params);

% Let's get started by making shorter variable names
trackfile         = input_params.trackfile;
metafile          = input_params.metafile;
poleloc           = input_params.poleloc;
    
% load drive parameters from varforce_cal_drive code.  Next we will add
% the analysis_parameters.
params = load(metafile);

% we want to put all of the metadata into a single "parameters" structure.
% However, because there are two places where metadata are inputted (once
% during the driveGUI and second through the analysisGUI) we have to munge
% the two structures together.
fnames = fieldnames(input_params);
for k = 1:length(fnames); 
    params = setfield(params, fnames{k}, getfield(input_params, fnames{k})); 
end;

% varforce_init: initializes and loads experimental parameters and video
% tracked data.  Requires user interaction to define breakpoint between 
% two sequences as the temporal alignment between the driving computer and
% the video acquisition computer is not very good (needs to be <8ms for 
% pulnix video).  Assigns pulse voltage and sequence ID for each tracker.
[vid_table,  params] = varforce_init(params);

% making more short variable names (not strictly necessary)
plot_results      = params.plot_results;
window_size       = params.window_size;
granularity       = params.granularity;
error_tol         = params.error_tol;
num_buffer_points = params.num_buffer_points;
drift_remove      = params.drift_remove;
compute_inst      = params.compute_inst;
compute_linefit   = params.compute_linefit;   
degauss           = params.degauss;
degauss_location  = params.deg_loc;
NRepeats          = params.NRepeats;
pulse_widths      = params.pulse_widths;
voltages          = params.voltages;
calib_um          = params.calibum;

v.raw.video_table = vid_table;

% handle degauss information.  along the way, extract information 
% from each zero volt remanence region and then remove from table and
% proceed as normal.
if findstr(degauss, 'on')
    [vid_table, rem_table]  = varforce_handle_degauss(vid_table);
    v.raw.rem_table = rem_table;    
end

% remove a given number of points that surround the shifts in voltage.
% This should reduce the crosstalk between voltages as well as preferentially 
% filter out any nonlinear shifts in the tracker position due to loose
% coils or other mechanical instability.
if num_buffer_points > 0
    logentry('Removing points in defined buffer-zone sequence and voltage changes.');
    vid_table = varforce_remove_buffer_points(vid_table, num_buffer_points);
end

% allows drift removal while keeping record of drift information for
% estimation of drift forces
if find(voltages == 0) && findstr(drift_remove, 'on')
    % referencing VID here is correct because we assume the drift removal period is 
    % the zeroth voltage in each sequence
    idx         = find(vid_table(:,VID) == 0);
    drift_table = vid_table(idx , :);
else
    logentry('no drift data.');
end

% send data to varforce_remove_drift to select regions of pulse to remove
% drift and then use drift_remove to actualy remove it.  Assumes linear drift
% during a sequence.
if findstr(drift_remove, 'on')
   [vid_table_out, v.drift.drift_vectors] = varforce_remove_drift(vid_table, params);
else
    vid_table_out        = vid_table;
end

% Instanteous method for estimating forces in a plane (NOT YET FULLY 
% IMPLEMENTED).  Calibrates a plane for each of the input voltages.  This 
% computes the "instantaneous" velocity via a windowed-derivative of a 
% given window-size.
if findstr(params.compute_inst, 'on')
     logentry(['Computing force using the instantaneous method.']);
     Ftable = varforce_compute_inst_force(vid_table_out, params);

     inst = varforce_construct_spatial_map(Ftable, params);

     % pull out the force cal for each voltage tested
     for k = 1 : size(inst.force_map, 3);
         inst.force_map_interp(:,:,k) = interp_forces2d(inst.x_bins, inst.y_bins, inst.force_map(:,:,k));

         if findstr(plot_results, 'on') 
            plot_forcecal2d(inst.x_bins, inst.y_bins, inst.force_map(:,:,k), inst.error_map, 'fe');
            plot_forcecal2d(inst.x_bins, inst.y_bins, inst.force_map_interp(:,:,k), [], 'sf');                 
        end
     end
     
%      v.forcecal.results.inst = inst;
end

% If your objective is to generate saturation data, then choose the
% 'linefit' method.  This will fit the displacement for each pulse in each
% sequence to a line whose slope is a single velocity.
if findstr(params.compute_linefit, 'on')

    logentry('Computing force using the line fit method.');

    forcecal = varforce_compute_linefit_force(vid_table_out, params);
    logfits  = varforce_compute_sat_data(forcecal, params);     

    v.forcecal.data     = forcecal;
    v.forcecal.results  = logfits;

    % computes same info for remanence data removed earlier
    if findstr(degauss, 'on') & findstr(degauss_location, 'middle');
        remanence = varforce_compute_linefit_force(rem_table, params);
        logfits = varforce_compute_sat_data(remanence, params);
        
        v.remanence.data    = remanence;
        v.remanence.results = logfits;
    end
    
    if find(voltages == 0) && findstr(drift_remove, 'on')
        % using custom error tolerance here effectievly negates error filter 
        % for this data set.    
        drift   = varforce_compute_linefit_force(drift_table, params, 1e12);
        logfits = varforce_compute_sat_data(drift, params);

        v.raw.drift_table = drift_table;
        v.drift.data       = drift;
        v.drift.results    = logfits;
    end

    % plots only when told to do so. maintains command line capabilities
    if findstr(plot_results, 'on') 
        varforce_plot_force_power_law(v.results.forcecal);
        varforce_plot_sat_data(v.results.forcecal);
    end

end

% Handle the case where no computation type is selected.
if  (findstr(params.compute_inst, 'off') & findstr(params.compute_linefit, 'off'))
    logentry('no analysis type selected. computing nothing. please select one or both analysis methods in the UI')
end

% output params along with results as metadata information (very useful for 
% answering the myriad questions that Rich asks during a presentation or
% meeting).
v.params = params; 




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
     headertext = [logtimetext 'varforce_run: '];
     
     fprintf('%s%s\n', headertext, txt);

     return;
     
     
% handles values inside the input parameters structure
function input_params = check_input_params(input_params)

    if ~isfield(input_params, 'metafile');    
        logentry('No metafile found.  Exiting now....');
        error('');
    end

    if ~isfield(input_params, 'trackfile');    
        logentry('No trackfile found.  Exiting now....');
        error('');
    end

    if ~isfield(input_params, 'compute_linefit');
       input_params.compute_linefit = 'on';
       logentry('''compute_linefit'' not defined.  Calibrating force via linefitting protocol by default.');
    end

    if ~isfield(input_params, 'compute_inst');
      input_params.compute_inst = 'off';
      logentry('''compute_inst'' not defined.  Not performing this analysis by default.');
    end

    if ~isfield(input_params, 'poleloc');
        logentry('No pole location found.  Exiting now....');
        error('');
    end

    if ~isfield(input_params, 'drift_remove');
        logentry('no drift removal preference entered, Assuming you want to remove drift');
        input_params.drift_remove = 'on';
    end

    if ~isfield(input_params, 'num_buffer_points');
        logentry('no buffer point number entered, Assuming you want to remove zero');
        input_params.num_buffer_points = '0';
    end

    if ~isfield(input_params, 'error_tol');
        logentry('No error tolerance entered.  Assuming you to allow 50% linear fit error');
        input_params.error_tol = .5;
    end

    if ~isfield(input_params, 'granularity');
        logentry('No granularity entered.  Assuming you want a granularity of 8');
        input_params.granularity = 8;
    end

    if ~isfield(input_params, 'window_size');
        logentry('No window size entered.  Assuming you want a window size of 1');
        input_params.window_size = 1;
    end

    if ~isfield(input_params, 'plot_results');
        logentry('No automatic plotting.  Set .plot_results ''on'' to change this.');
        input_params.plot_results = 'off';
    end

    if ~isfield(input_params, 'poletip_radius');    
        logentry('No poletip radius entered.  Assuming no offset from described monopole location.');
        input_params.poletip_radius = 0;
    end

    return;
    
