% run ROLIE-POLY (RP) simulation on the UNC-CH BASS (supercomputer)
% Guar 1.5%

clear sim;

taskidstr = getenv('SGE_TASK_ID');
taskidnum = str2num(taskidstr);
taskidstr = num2str(taskidnum, '%03i');

F        = [10 25 30 36.5 40 50 75 100 200 500]*1e-12;

sim.a        = 0.5e-6;
sim.rho      = 1300;
sim.Ge       = 42;
sim.tr       = 7.91;
sim.td       = 14.27;
sim.eta_bg   = 0.032;
sim.F        = F(taskidnum);
sim.duration = 0.1;


tic; 
    sim = RP_multisim(sim, 'n');
toc;

save(['~/rpoly/results/RP_guar1p5pct_task_' taskidstr '.mat'], '-struct', 'sim');

