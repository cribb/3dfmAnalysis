% run ROLIE-POLY (RP) simulation on the UNC-CH BASS (supercomputer)
% PGM 4%

clear sim;

taskidstr = getenv('SGE_TASK_ID');
taskidnum = str2num(taskidstr);
taskidstr = num2str(taskidnum, '%03i');

F        = [1 5 10 30 36.5 40 50 75 100 500]*1e-12;

sim.a        = 0.5e-6;
sim.rho      = 1300;
sim.Ge       = 0.1;
sim.tr       = 1; % guess at this time
sim.td       = 132;
sim.eta_bg   = 0.01;
sim.F        = F(taskidnum);
sim.duration = 1.2;


tic; 
    sim = RP_multisim(sim, 'n');
toc;

save(['~/rpoly/results/RP_pgm4pct_task_' taskidstr '.mat'], '-struct', 'sim');

