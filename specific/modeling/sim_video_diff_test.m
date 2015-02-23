function outs = sim_video_diff_test
% XXX STILL need to generate tests for the actual results for every model
% except for models D and N.
%

% testing default conditions, Model Type D (visc > 0)
logentry('Now testing for default conditions, D model type.')
D_struct.viscosity = 0.023; % (2M sucrose)
D_struct.modulus = 0;
D_struct.alpha = 1;
D_struct.xdrift_vel = 0;
D_struct.ydrift_vel = 0;
[D_traj, D_struct] = sim_video_diff_expt('D_test', D_struct);
if strcmp(D_struct.model_type,'D')
    logentry('D model type selected.');
else
    error('Test for D model type failed.');
end
D_vmsd = video_msd('D_test.evt.mat', 35, D_struct.frame_rate, D_struct.calib_um, 'n');
D_ve = ve(D_vmsd, D_struct.bead_radius, 'f', 'n');
D_err = abs(D_struct.viscosity - mean(D_ve.np)) / D_struct.viscosity;
if D_err < 0.2
    logentry(['D model test PASSED with ' num2str(D_err*100) '% error (less than 20%)']);
else
    logentry('D model test FAILED');
    error('D model test FAILED');
end

% Testing for model type: N (Elastic only, MSDs should be flat)
logentry('Now testing for N model type.');
N_struct.viscosity = 0;
N_struct.modulus = 0.5;
N_struct.xdrift_vel = 0;
N_struct.ydrift_vel = 0;
N_struct.alpha = 0;
[N_traj, N_struct] = sim_video_diff_expt('N_test', N_struct);
if strcmp(N_struct.model_type,'N')
    logentry('N model type selected.');
else
    error('Test for N model type failed.');
end
N_vmsd = video_msd('N_test.evt.mat', 35, N_struct.frame_rate, N_struct.calib_um, 'n');
N_ve = ve(N_vmsd, N_struct.bead_radius, 'f', 'n');
N_err = abs(N_struct.modulus - mean(N_ve.gp)) / N_struct.modulus;
if N_err < 0.2
    logentry(['N model test PASSED with ' num2str(N_err*100) '% error (less than 20%)']);
else
    logentry('N model test FAILED');
    error('N model test FAILED');
end

% Testing for model type: V (Elastic only, MSDs should be flat)
logentry('Now testing for V model type.');
V_struct.viscosity = 0;
V_struct.modulus = 0;
V_struct.xdrift_vel = -1e-9;
V_struct.ydrift_vel = 3e-9;
[traj, V_struct] = sim_video_diff_expt('V_test', V_struct);
V_vmsd = video_msd(V_traj, 35, V_struct.frame_rate, V_struct.calib_um, 'n');
if strcmp(V_struct.model_type,'V')
    logentry('V model type selected.');
else
    error('Test for V model type failed.');
end


% Testing for model type: DV (Diffusion with Drift)
logentry('Now testing for DV model type.');
DV_struct.viscosity = 0.023;
DV_struct.modulus = 0;
DV_struct.xdrift_vel = -1e-9;
DV_struct.ydrift_vel = 3e-9;
[traj, DV_struct] = sim_video_diff_expt('DV_test', DV_struct);
if strcmp(DV_struct.model_type,'DV')
    logentry('DV model type selected.');
else
    error('Test for DV model type failed.');
end


% Testing for model type: DA (Anomalous Diffusion)
logentry('Now testing for DA model type.');
DA_struct.viscosity = 0.023;
DA_struct.modulus = 0;
DA_struct.alpha = 0.5;
DA_struct.xdrift_vel = 0;
DA_struct.ydrift_vel = 0;
[traj, DA_struct] = sim_video_diff_expt('DA_test', DA_struct);
if strcmp(DA_struct.model_type,'DA')
    logentry('DA model type selected.');
else
    error('Test for DA model type failed.');
end


% Testing for model type: DR (Confined Diffusion)
logentry('Now testing for DR model type.');
DR_struct.viscosity = 0.023;
DR_struct.rad_confined = 50e-9;
DR_struct.xdrift_vel = 0;
DR_struct.ydrift_vel = 0;
[traj, DR_struct] = sim_video_diff_expt('DR_test', DR_struct);
if strcmp(DR_struct.model_type,'DR')
    logentry('DR model type selected.');
else
    error('Test for DR model type failed.');
end


% Testing for model type: DAV (Anomalous Diffusion with drift)
logentry('Now testing for DAV model type.');
DAV_struct.viscosity = 0.023;
DAV_struct.alpha = 0.5;
DAV_struct.xdrift_vel = -1e-9;
DAV_struct.ydrift_vel = 3e-9;
[traj, DAV_struct] = sim_video_diff_expt('DAV_test', DAV_struct);
if strcmp(DAV_struct.model_type,'DAV')
    logentry('DAV model type selected.');
else
    error('Test for DAV model type failed.');
end


% Testing for model type: DRV (Confined Diffusion with Drift)
logentry('Now testing for DRV model type.');
DRV_struct.viscosity = 0.023;
DRV_struct.modulus = 0;
DRV_struct.rad_confined = 50e-9;
DRV_struct.xdrift_vel = -1e-9;
DRV_struct.ydrift_vel = 3e-9;
[traj, DRV_struct] = sim_video_diff_expt('DRV_test', DRV_struct);
if strcmp(DRV_struct.model_type,'DRV')
    logentry('DRV model type selected.');
else
    error('Test for DRV model type failed.');
end

