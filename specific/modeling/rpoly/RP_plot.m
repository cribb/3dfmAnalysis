function out = RP_plot(sim)
%RP_PLOT generates common plots from ROLIE-POLY modeling data 
%
% 3DFM function  
% specific/modeling/rpoly 
% last modified 28-Sep-2009 
%
% RP_PLOT generates common plots from ROLIE-POLY modeling data.
%
% [out] = RP_plot(sim)
%
% where   "out" is the vector of handles to the generated figures.
%         "sim" is the RP data structure (see RP_force_on_a_bead_surface) 
%

% extract vectors from sim structure
time = sim.time;
pos = sim.pos;
vel = sim.vel;

len = [length(time), length(pos), length(vel)];
minlen = min(len);

time = time(1:minlen,:);
pos = pos(1:minlen,:);
vel = vel(1:minlen,:);

F = repmat(sim.F, rows(time), 1);
a = repmat(sim.a, rows(time), 1);

% compute graphable values
srate = (3./sqrt(2)).* vel ./ a;
compliance = (6*pi.*a) .* pos ./ F;
viscosity = F ./ (6*pi.*a.*vel);
termsrate = srate(end,:);
termvisc = viscosity(end,:);



    %---------------
    % Plotting code
    %---------------
    h(1) = figure;  
    
    subplot(2,2,1)
    loglog(time,pos*1e6)
%     title('bead. RP. acceleration.')
    title('RP bead');
    xlabel('time, t [s]');
    ylabel('displacement, x [\mum]');
    
    
    subplot(2,2,2)
    loglog(time,vel*1e6)
%     title('bead. RP. acceleration.')
    title('RP bead');
    ylabel('velocity, v [\mum/s]');
    xlabel('time, t [s]');
    
    subplot(2,2,3)
    loglog(time,compliance)
%    title('bead. RP. acceleration.')
    title('RP bead');
    xlabel('time, t [s]');
    ylabel('compliance, J [Pa^{-1}]');
        
    subplot(2,2,4)
    loglog(time,viscosity)
%    title('bead. RP. acceleration.')
    title('RP bead');
    xlabel('time, t [s]');
    ylabel('viscosity, \eta [Pa s]');
    
    h(2) = figure;
    loglog(termsrate, termvisc, '.-');
    xlabel('max shear rate on bead [1/s]');
    ylabel('apparent viscosity [Pa s]');
    
out = h;
