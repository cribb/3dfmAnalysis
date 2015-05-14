

%            in_struct.seed = seed value to give to random number generator.
%                             If this value is absent, the generator uses the 
%                             system time as the seed.
%            in_struct.numpaths = number of bead paths.  Default: 10.
%            in_struct.bead_radius = bead radius in [m].  Default: 0.5e-6. 
%            in_struct.viscosity = solution viscosity in [Pa s].  Default: 0.023 (2 M sucrose).
%            in_struct.rad_confined = the particle's radius of confinement in [m]. Default: Inf.
%            in_struct.alpha = anomalous diffusion constant. Default: 1.
%            in_struct.modulus = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
%            in_struct.frame_rate = frame rate of camera in [fps].  Default: 30.
%            in_struct.duration = duration of video in [s].  Default: 60.
%            in_struct.tempK = temperature of fluid in [K].  Default: 300.
%            in_struct.field_width = width of video frame in [px].  Default: 648.
%            in_struct.field_height = height of video frame in [px].  Default: 484.
%            in_struct.calib_um = conversion unit in [microns/pixel].  Default: 0.152.
%            in_struct.xdrift_vel = x-drift in [meters/frame].  Default: 0.
%            in_struct.ydrift_vel = y-drift in [meters/frame].  Default: 0.



in_struct.numpaths      = number of bead paths.  Default: 10.
in_struct.bead_radius   = bead radius in [m].  Default: 0.5e-6. 
in_struct.viscosity     = solution viscosity in [Pa s].  Default: 0.023 (2 M sucrose).
in_struct.rad_confined  = the particle's radius of confinement in [m]. Default: Inf.
in_struct.alpha         = anomalous diffusion constant. Default: 1.
in_struct.modulus       = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
in_struct.frame_rate    = frame rate of camera in [fps].  Default: 30.
in_struct.duration      = duration of video in [s].  Default: 60.
in_struct.tempK         = temperature of fluid in [K].  Default: 300.
in_struct.field_width   = width of video frame in [px].  Default: 648.
in_struct.field_height  = height of video frame in [px].  Default: 484.
in_struct.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.
in_struct.xdrift_vel    = x-drift in [meters/frame].  Default: 0.
in_struct.ydrift_vel    = y-drift in [meters/frame].  Default: 0.




sim_N.numpaths      = 10;
sim_N.viscosity     = 0;
sim_N.modulus       = 100;
sim_N.alpha         = 0;
sim_N.bead_radius   = 1e-6; 


sim_N.rad_confined  = the particle's radius of confinement in [m]. Default: Inf.
sim_N.alpha         = anomalous diffusion constant. Default: 1.
sim_N.frame_rate    = frame rate of camera in [fps].  Default: 30.
sim_N.duration      = duration of video in [s].  Default: 60.
sim_N.tempK         = temperature of fluid in [K].  Default: 300.
sim_N.field_width   = width of video frame in [px].  Default: 648.
sim_N.field_height  = height of video frame in [px].  Default: 484.
sim_N.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.
sim_N.xdrift_vel    = x-drift in [meters/frame].  Default: 0.
sim_N.ydrift_vel    = y-drift in [meters/frame].  Default: 0.




sim_D.numpaths      = 10;
sim_D.bead_radius   = 1e-6;
sim_D.viscosity     = 0.001;


sim_D.rad_confined  = the particle's radius of confinement in [m]. Default: Inf.
sim_D.alpha         = anomalous diffusion constant. Default: 1.
sim_D.modulus       = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
sim_D.frame_rate    = frame rate of camera in [fps].  Default: 30.
sim_D.duration      = duration of video in [s].  Default: 60.
sim_D.tempK         = temperature of fluid in [K].  Default: 300.
sim_D.field_width   = width of video frame in [px].  Default: 648.
sim_D.field_height  = height of video frame in [px].  Default: 484.
sim_D.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.
sim_D.xdrift_vel    = x-drift in [meters/frame].  Default: 0.
sim_D.ydrift_vel    = y-drift in [meters/frame].  Default: 0.



sim_V.numpaths      = 100;
sim_V.viscosity     = 0;
sim_V.xdrift_vel    = 3.33E-9;
sim_V.ydrift_vel    = 3.33E-9;


sim_V.bead_radius   = bead radius in [m].  Default: 0.5e-6. 
sim_V.rad_confined  = the particle's radius of confinement in [m]. Default: Inf.
sim_V.alpha         = anomalous diffusion constant. Default: 1.
sim_V.modulus       = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
sim_V.frame_rate    = frame rate of camera in [fps].  Default: 30.
sim_V.duration      = duration of video in [s].  Default: 60.
sim_V.tempK         = temperature of fluid in [K].  Default: 300.
sim_V.field_width   = width of video frame in [px].  Default: 648.
sim_V.field_height  = height of video frame in [px].  Default: 484.
sim_V.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.




sim_DA.numpaths      = 10;
sim_DA.alpha         = 0.75;
sim_DA.bead_radius   = 1e-6;
sim_DA.viscosity     = 0.023;


sim_DA.rad_confined  = the particle's radius of confinement in [m]. Default: Inf.

sim_DA.modulus       = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
sim_DA.frame_rate    = frame rate of camera in [fps].  Default: 30.
sim_DA.duration      = duration of video in [s].  Default: 60.
sim_DA.tempK         = temperature of fluid in [K].  Default: 300.
sim_DA.field_width   = width of video frame in [px].  Default: 648.
sim_DA.field_height  = height of video frame in [px].  Default: 484.
sim_DA.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.
sim_DA.xdrift_vel    = x-drift in [meters/frame].  Default: 0.
sim_DA.ydrift_vel    = y-drift in [meters/frame].  Default: 0.





DR_cell.numpaths      = 10;
DR_cell.rad_confined  = 10E-9;
DR_cell.viscosity     = 0.023;
DR_cell.bead_radius   = 1e-6;

DR.bead_radius   = bead radius in [m].  Default: 0.5e-6. 
DR.viscosity     = solution viscosity in [Pa s].  Default: 0.023 (2 M sucrose).
DR.alpha         = anomalous diffusion constant. Default: 1.
DR.modulus       = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
DR.frame_rate    = frame rate of camera in [fps].  Default: 30.
DR.duration      = duration of video in [s].  Default: 60.
DR.tempK         = temperature of fluid in [K].  Default: 300.
DR.field_width   = width of video frame in [px].  Default: 648.
DR.field_height  = height of video frame in [px].  Default: 484.
DR.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.
DR.xdrift_vel    = x-drift in [meters/frame].  Default: 0.
DR.ydrift_vel    = y-drift in [meters/frame].  Default: 0.




sim_DV.numpaths      = 100;
sim_DV.xdrift_vel    = 0.333E-9;
sim_DV.ydrift_vel    = 0.333E-9;

sim_DV.bead_radius   = bead radius in [m].  Default: 0.5e-6. 
sim_DV.viscosity     = solution viscosity in [Pa s].  Default: 0.023 (2 M sucrose).
sim_DV.rad_confined  = the particle's radius of confinement in [m]. Default: Inf.
sim_DV.alpha         = anomalous diffusion constant. Default: 1.
sim_DV.modulus       = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
sim_DV.frame_rate    = frame rate of camera in [fps].  Default: 30.
sim_DV.duration      = duration of video in [s].  Default: 60.
sim_DV.tempK         = temperature of fluid in [K].  Default: 300.
sim_DV.field_width   = width of video frame in [px].  Default: 648.
sim_DV.field_height  = height of video frame in [px].  Default: 484.
sim_DV.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.



sim_DRV.numpaths      = 100;
sim_DRV.xdrift_vel    = 3.33E-9;
sim_DRV.ydrift_vel    = 3.33E-9;
sim_DRV.rad_confined  = 100;

sim_DRV.bead_radius   = bead radius in [m].  Default: 0.5e-6. 
sim_DRV.viscosity     = solution viscosity in [Pa s].  Default: 0.023 (2 M sucrose).
sim_DRV.rad_confined  = the particle's radius of confinement in [m]. Default: Inf.
sim_DRV.alpha         = anomalous diffusion constant. Default: 1.
sim_DRV.modulus       = modulus of the fluid [Pa]. Default: 2.2e9 (bulk modulus of water).
sim_DRV.frame_rate    = frame rate of camera in [fps].  Default: 30.
sim_DRV.duration      = duration of video in [s].  Default: 60.
sim_DRV.tempK         = temperature of fluid in [K].  Default: 300.
sim_DRV.field_width   = width of video frame in [px].  Default: 648.
sim_DRV.field_height  = height of video frame in [px].  Default: 484.
sim_DRV.calib_um      = conversion unit in [microns/pixel].  Default: 0.152.



sim_DR_100 = sim_video_diff_expt('sim_DR_100.vrpn.mat', DR_100)




% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Simulation 1
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

s1_V.numpaths      = 10;
s1_V.viscosity     = 0;
s1_V.xdrift_vel    = 0.333E-9;
s1_V.ydrift_vel    = 0.333E-9;
s1_V = sim_video_diff_expt('s1_V.vrpn.mat', s1_V);


s1_D.numpaths      = 10;
s1_D.bead_radius   = 1e-6;    % 2um bead
s1_D.viscosity     = 0.001;   % water
s1_D = sim_video_diff_expt('s1_D.vrpn.mat', s1_D);


s1_DA.numpaths      = 10;
s1_DA.alpha         = 0.5;
s1_DA.viscosity     = 0.6;  % 2.5M sucrose
s1_DA.bead_radius   = 1e-6;
s1_DA = sim_video_diff_expt('s1_DA.vrpn.mat', s1_DA);


s1_DR.numpaths      = 10;
s1_DR.rad_confined  = 20E-9;
s1_DR.viscosity     = 0.02;  % 20 times less visc than 2 M sucrose
s1_DR.bead_radius   = 1e-6;
s1_DR = sim_video_diff_expt('s1_DR.vrpn.mat', s1_DR);


s1_N.numpaths      = 10;
s1_N.viscosity     = 0;
s1_N.modulus       = 70;    % 70 Pa solid
s1_N.alpha         = 0;
s1_N.bead_radius   = 1e-6; 
s1_N = sim_video_diff_expt('s1_N.vrpn.mat', s1_N);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Simulation 2
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

s2_V.numpaths      = 10;
s2_V.viscosity     = 0;
s2_V.xdrift_vel    = 0.333E-9;
s2_V.ydrift_vel    = 0.333E-9;
s2_V = sim_video_diff_expt('s2_V.vrpn.mat', s2_V);


s2_D.numpaths      = 10;
s2_D.bead_radius   = 1e-6;
s2_D.viscosity     = 0.001;   % water
s2_D = sim_video_diff_expt('s2_D.vrpn.mat', s2_D);


s2_DA.numpaths      = 10;
s2_DA.alpha         = 0.75;
s2_DA.viscosity     = 0.2;  % 2.5M sucrose
s2_DA.bead_radius   = 1e-6;
s2_DA = sim_video_diff_expt('s2_DA.vrpn.mat', s2_DA);


s2_DR.numpaths      = 10;
s2_DR.rad_confined  = 40E-9;
s2_DR.viscosity     = 0.01;  % 20 times less visc than 2 M sucrose
s2_DR.bead_radius   = 1e-6;
s2_DR = sim_video_diff_expt('s2_DR.vrpn.mat', s2_DR);


s2_N.numpaths      = 10;
s2_N.viscosity     = 0;
s2_N.modulus       = 70;       % 70 Pa solid
s2_N.alpha         = 0;
s2_N.bead_radius   = 1e-6; 
s2_N = sim_video_diff_expt('s2_N.vrpn.mat', s2_N);






% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % For workflow purposes
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %

s1_DR.numpaths      = 10;
s1_DR.rad_confined  = 20E-9;
s1_DR.viscosity     = 0.02;  % 20 times less visc than 2 M sucrose
s1_DR.bead_radius   = 1e-6;
s1_DR = sim_video_diff_expt('s1_DR.vrpn.mat', s1_DR);
