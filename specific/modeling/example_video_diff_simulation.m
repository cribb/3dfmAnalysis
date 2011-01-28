clear sim;

numsims = 1;

% viscosities for several standards used in the Superfine lab
water       = 0.001;
sucrose2M   = 0.023;
sucrose2p5M = 0.121;
karo        = 3.4;

% setup the simulation
sim.numpaths      =     20;
sim.viscosity     =  water;     % [Pa s]
sim.bead_radius   = 0.5e-6;     % [m]
sim.frame_rate    =     30;     % [frames/sec]
sim.duration      =     30;     % [sec]
sim.tempK         =    300;     % [K]
sim.field_width   =    648;     % [pixels]
sim.field_height  =    484;     % [pixels]
sim.calib_um      =  0.164;     % [um/pixel]
sim.xdrift_vel    =   0e-9;     % [m/frame]
sim.ydrift_vel    =   0e-9;     % [m/frame]

for k=1:numsims
    tic
        sim_video_diff_expt(['my_sim-' num2str(k, '%03.0f')], sim);
    toc
end

% 
% win = [1:10 20:10:100 200:100:1000 2000:500:10000];
% tic
% for k=1:10
%     vmsd = video_msd(['simulation-' num2str(k) '.vrpn.evt.mat'], win, sim.frame_rate, sim.calib_um, 'n');
%     msdpool(:,k) = vmsd.msd;
%     taupool(:,k) = vmsd.tau;
% end
% toc