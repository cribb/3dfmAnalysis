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
F = repmat(sim.F, rows(time), 1);
a = repmat(sim.a, rows(time), 1);

% compute graphable values
compliance = (6*pi.*a) .* pos ./ F;
viscosity = F ./ (6*pi.*a.*vel);


    %---------------
    % Plotting code
    %---------------
    h = figure;  
    
    subplot(2,2,1)
    plot(time,pos*1e6)
    title('bead. RP. acceleration.')
    xlabel('time, t [s]');
    ylabel('displacement, x [\mum]');
    
    
    subplot(2,2,2)
    plot(time,vel*1e6)
    title('bead. RP. acceleration.')
    ylabel('velocity, v [\mum/s]');
    xlabel('time, t [s]');
    
    subplot(2,2,3)
    plot(time,compliance)
    title('bead. RP. acceleration.')
    xlabel('time, t [s]');
    ylabel('compliance, J [Pa^{-1}]');
        
    subplot(2,2,4)
    plot(time,viscosity)
    title('bead. RP. acceleration.')
    xlabel('time, t [s]');
    ylabel('viscosity, \eta [Pa s]');
    
    
out = h;
