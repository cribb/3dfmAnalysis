function struct_out = RP_continue_sim(sim_in, new_tend)
%RP_CONTINUE_SIM generates a new structure for continuing a RP simulation. 
%
% 3DFM function  
% specific/modeling/rpoly 
% last modified 28-Sep-2009 
%
% RP_CONTINUE_SIM generates a new structure for continuing a RP simulation. 
% The new structure needs to be passed to a new instance of RP_multisim.
%
% [struct_out] = RP_continue_sim(sim_in, new_tend)
%
% where   "struct_out" is the new outputted RP structure 
%                      (see RP_force_on_a_bead_surface) 
%         "sim_in" is the inputted RP data structure from the old simulation. 
%         "new_tend" is the new endpoint for the simulation's "duration"
%

    me = sim_in;
    
    me.t0 = sim_in.time(end,:);
    me.x0 = sim_in.pos(end,:);
    me.v0 = sim_in.vel(end,:);
    me.stress0 = sim_in.stress(:,:,:,end);    
    
    me = rmfield(me, 'time');
    me = rmfield(me, 'pos');
    me = rmfield(me, 'vel');
    me = rmfield(me, 'stress');
    
    me.duration = new_tend - me.t0;

    struct_out = me;
    
    