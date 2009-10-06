function sim_out = RP_multisim(RP_params, plot_output)
%RP_MULTISIM runs single or multiple concurrent thread ROLIE-POLY models.
%
% 3DFM function  
% specific/modeling/rpoly 
% last modified 28-Sep-2009 
%
% RP_MULTISIM handles running the ROLIE-POLY modeling according to the
% input parameters.  If one of the parameters is a vector, RP_MULTISIM will
% attempt to execute several runs concurrently.  On multi-processor
% machines this results in faster modeling for a suite of parameters.
%
% NOTE: for multi-threading, the Parallel Computing toolbox is required.
%
% [sim_out] = RP_multisim(RP_params, plot_output)
%
% where   "sim_out" is a structure containing the parameter and resulting
%                   modeling data.
%         "RP_params" is the input parameter structure (see
%                   RP_force_on_a_bead_surface)
%         "plot_output" generates output plots if set to 'y'
%

parallelize = 'yes';

if nargin < 2 || isempty('plot_output')
    plot_output = 'no';
end

if nargin < 1 || ~exist('RP_params')
    RP_params = [];
end

RP_params = RP_checkparams(RP_params);

if nargin < 1 
    RP_params.Ge = [1 5 10 25];
end



dummy = RP_params;
if isfield(dummy, 'stress0')
    dummy = rmfield(dummy, 'stress0');
end

fields = fieldnames(dummy);

for k = 1:length(fields)
    foo = getfield(dummy, fields{k});
    sz_array(k,:) = length(foo);
end

clear dummy foo

idx = find(sz_array > 1);

if size(idx,1) > 1
    num_sims = max(sz_array(idx));
%     error('too many parameter combinations, reduce to one parameter with length >1');
elseif isempty(idx)
    idx = 0;
    num_sims = 1;
    parallelize = 'no';
else
    num_sims = max(sz_array(idx));
end


for k = 1:length(fields)
    if sz_array(k) > 1
        foo = getfield(RP_params, fields{k});
        RP_params = setfield(RP_params, fields{k}, foo(:)');
    else
        foo = getfield(RP_params, fields{k});
        RP_params = setfield(RP_params, fields{k}, repmat(foo,1,num_sims));
    end        
end

switch parallelize
    case 'no'
%         [time, stored_position, stored_vel] = ...
        [time, stored_position, stored_vel, stored_stress] = ...
                 RP_force_on_a_bead_surface(RP_params);
         time = time;
         pos  = stored_position;
         vel  = stored_vel;
         stress = stored_stress;
         
    otherwise
        
        RP_cell_params = tocell(RP_params);
        
%         [time, stored_position, stored_vel] = dfeval( ...
        [time, stored_position, stored_vel, stored_stress] = dfeval( ...
                @RP_force_on_a_bead_surface, ...
                RP_cell_params.a,...
                RP_cell_params.rho,...
                RP_cell_params.m,...
                RP_cell_params.Ge,...
                RP_cell_params.tr,...
                RP_cell_params.td,...
                RP_cell_params.eta_bg,...
                RP_cell_params.delta,...
                RP_cell_params.beta,...
                RP_cell_params.F,...
                RP_cell_params.x0,...
                RP_cell_params.v0,...
                RP_cell_params.t0,...
                RP_cell_params.stress0,...
                RP_cell_params.duration,...                
                'Configuration', 'local');
            
                time = cell2mat(time);
                pos = cell2mat(stored_position);
                vel = cell2mat(stored_vel);
                stress = cell2mat(stored_stress);
end

time = time';
pos  = pos(:,1:end-1)';
vel  = vel(:,1:end-1)';
   
sim_out = RP_params;
sim_out.time = time;
sim_out.pos = pos;
sim_out.vel = vel;
sim_out.stress = stress;

% plotting code
if strcmp(plot_output, 'y')
    try
        h = RP_plot(sim_out);
    catch
        fprintf('plotting did not work, probably mismatch in time and pos,vel sizes\n');
    end
end

return;


function out = tocell(in)

    out = in;
    
    fields = fieldnames(out);

    for k = 1:length(fields)
        foo = getfield(out, fields{k});
        out = setfield(out, fields{k}, num2cell(foo));
    end
    
return


function out = tomat(in)

    out = in;
    
    fields = fieldnames(out);

    for k = 1:length(fields)
        foo = getfield(out, fields{k});
        out = setfield(out, fields{k}, cell2mat(foo));
    end
    
return;
