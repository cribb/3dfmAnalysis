% script for testing dmbr_run

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

dmbr_constants;

ins.metafile = 'dna_1v_3.vfd.mat';
ins.trackfile = 'dna_1v_3.raw.vrpn.evt.mat';
ins.calibfile = '2.5M_tip_saturation_1.raw.vrpn.evt.evt.vfc.mat';
ins.poleloc  = [322 56];
ins.num_buffer_points = 0;
ins.poletip_radius = 0;
ins.drift_remove    = 'off';
ins.plot_results    = 'off';
ins.degauss         = 'off';

v = dmbr_run(ins);

