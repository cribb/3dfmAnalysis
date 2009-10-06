% run ROLIE-POLY (RP) simulation on the UNC-CH BASS (supercomputer)
% validating pmoore's earlier results from strain rate controlled model

clear sim;

taskidstr = getenv('SGE_TASK_ID');
taskidnum = str2num(taskidstr);
taskidstr = num2str(taskidnum, '%03i');

F        = [0.1 0.2 0.5 1 2 2.5 2.6 2.7 2.8 2.9 3 5]*1e-12;

sim.a        = 0.5e-6;
sim.rho      = 1300;
sim.Ge       = 15;
sim.tr       = 0.3;
sim.td       = 0.3;
sim.eta_bg   = 0.001;
sim.F        = F(taskidnum);
sim.beta     = 1;
sim.delta    = -0.5;
sim.duration = 1;


tic; 
    sim = RP_multisim(sim, 'n');
toc;

save(['~/rpoly/results/RP_pmval_01_task_' taskidstr '.mat'], '-struct', 'sim');

