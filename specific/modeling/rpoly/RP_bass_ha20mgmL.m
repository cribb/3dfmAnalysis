% run ROLIE-POLY (RP) simulation on the UNC-CH BASS (supercomputer)
% HA 20 mg/mL (2%)

clear sim;

taskidstr = getenv('SGE_TASK_ID');
taskidnum = str2num(taskidstr);
taskidstr = num2str(taskidnum, '%03i');

F        = [100 250 300 365 400 500 750 1000 2000 5000]*1e-12;

sim.a        = 0.5e-6;
sim.rho      = 1300;
sim.Ge       = 347;
sim.tr       = 0.73;
sim.td       = 4;
sim.eta_bg   = 0.005;
sim.F        = F(taskidnum);
sim.duration = 1;


tic; 
    sim = RP_multisim(sim, 'n');
toc;

save(['~/rpoly/results/RP_HA_20mgml_task_' taskidstr '.mat'], '-struct', 'sim');

