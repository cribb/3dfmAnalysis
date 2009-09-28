% run ROLIE-POLY (RP) simulation on the UNC-CH BASS (supercomputer)
% DNA 1.4 mg/mL

clear sim;

taskidstr = getenv('SGE_TASK_ID');
taskidnum = str2num(taskidstr);
taskidstr = num2str(taskidnum, '%03i');

td        = [0.1 1 3 6.5 8 10 15 20 32 63];

sim.a        = 0.5e-6;
sim.rho      = 1300;
sim.Ge       = 0.3;
sim.tr       = 6.61;
sim.td       = td(taskidnum);
sim.eta_bg   = 0.005;
sim.F        = 5e-12;
sim.duration = 0.5;


tic; 
    sim = RP_multisim(sim, 'n');
toc;

save(['~/rpoly/results/RP_dna1p4mgmL_tr_task_' taskidstr '.mat'], '-struct', 'sim');

