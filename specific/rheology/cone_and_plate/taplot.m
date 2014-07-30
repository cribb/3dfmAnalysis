function figh = taplot(filename, mytitle)
% TAPLOT Plots rheology curves for TA Instruments cone and plate data 
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 3/20/2013 (cribb)
%  
% Plots rheology curves for TA Instruments cone and plate data.  Uses
% "plot_" functions for difference rheometry tests.
%  
%  figh = taplot(filename, mytitle)  
%   
% where "figh" is the output figure handle
% "filename" can be an input ta2mat structure or the name of a text file 
%            outputted from TA software package % (*.rsl.txt).
%  "mytitle" is a string with title for figure.
%


% check if the input is a filename or ta2mat data structure
if isstruct(filename)
    v = filename;
else
    v = ta2mat(filename);
end
    
if isfield(v, 'results')
    fn = fieldnames(v.results);
else
    logentry('No results in this file');
    figh = NaN;
    return;
end

% figure out which 'experiments' have data 'units' and plot if data exists
count = 1;
for k = 1 : length(fn)
   
%     if isfield(getfield(v.experiments, fn{k}), 'units');

        % extract each experiments's information and plot
        protocol = getfield(v.protocols, fn{k});
        result  = getfield(v.results, fn{k});

        exptype = lower(protocol.step_name);
        
        % had to hack through a 'zero' if string not found by using the sum
        % on the empty return of strfind
        if sum(strfind(exptype, 'equilibration step')) || sum(strfind(exptype, 'dissipation step'))
            t = result.data.time;
            displacement = result.data.displacement - result.data.displacement(1);
            figh(count) = plot_cap_dissipation(t, displacement, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'equilibration'));
        end            
        
        if sum(strfind(exptype, 'pre-stress')) || sum(strfind(exptype, 'prestress'))
            t = result.data.time;
            displacement = result.data.displacement - result.data.displacement(1);
            figh(count) = plot_cap_dissipation(t, displacement, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'prestress'));
        end
        
        if sum(strfind(exptype, 'stress sweep'))
            stress = result.data.osc_stress;
            gp = result.data.G_prime;
            gpp= result.data.G_double_prime;
            figh(count) = plot_cap_ssweep(stress, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'ssweep'));
        end
        
        if sum(strfind(exptype, 'strain sweep'))
            strain = result.data.strain;
            gp = result.data.G_prime;
            gpp= result.data.G_double_prime;
            figh(count) = plot_cap_nsweep(strain, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'nsweep'));
        end
        
        if sum(strfind(exptype, 'frequency sweep')) || sum(strfind(exptype, 'tts'))
            if isfield(result.data, 'frequency')
                freq = result.data.frequency;
            elseif isfield(result.data, 'ang_frequency');
                freq = result.data.ang_frequency ./ (2*pi);
            else
                error('Cannot plot frequency.  No frequencies found.');
            end
            gp = result.data.G_prime;
            gpp= result.data.G_double_prime;
            delta = result.data.delta;            
            figh(count) = plot_cap_fsweep(freq, [gp gpp], [], mytitle, 'ff');
            set(figh(count), 'Name', figname(fn{k}, 'fsweep'));
        end

        if sum(strfind(exptype, 'flow'))
            shear_rate = result.data.shear_rate;
            visc = result.data.viscosity;            
            figh(count) = plot_cap_flow(shear_rate, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'flow'));
        end

        if sum(strfind(exptype, 'creep'))
            t = result.data.time;
%             strain = result.data.strain;
%             stress = result.data.shear_stress;
            compliance_Jt = result.data.compliance_Jt;
            ending_Jt = compliance_Jt(end) - compliance_Jt(1);
            figh(count) = plot_cap_creep(t, compliance_Jt-compliance_Jt(1), [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'creep'));
        end
        
        if sum(strfind(exptype, 'recovery'))
            t = result.data.time;

            if exist('ending_Jt', 'var') && ~isempty(ending_Jt)
                compliance_Jt = ending_Jt - result.data.compliance_Jt;
                clear ending_Jt;
            else
                compliance_Jt = -result.data.compliance_Jt;
            end
%             stress = result.data.shear_stress;
            figh(count) = plot_cap_creep(t, compliance_Jt, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'recov'));
        end
        
        if sum(strfind(exptype, 'temperature'))
            temp = result.data.temperature;
            visc = result.data.viscosity;
            srate = result.data.shear_rate;
            figh(count) = plot_cap_temp(temp, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'temp'));
        end
        
        if sum(strfind(exptype, 'peak hold'))
            time = result.data.time;
            visc = result.data.viscosity;            
%             strain = result.data.strain;            
            strainrate = strrep(protocol.controlled_variable, 'shear rate ', '');
            figh(count) = plot_cap_peakhold(time, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'peakstrain'));
            ser = get(gca, 'Children');
            set(ser, 'DisplayName', strainrate);
        end           
            
        if sum(strfind(exptype, 'stress relaxation'))
            time = result.data.time;
            Gt = result.data.modulus_Gt;            
            strain = result.data.strain;            
            figh(count) = plot_cap_relax(time, Gt, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'relax'));
            ser = get(gca, 'Children');
%             set(ser, 'DisplayName', strain);
        end
        
        if isempty(strfind(exptype, 'equilibration step')) && ...
           isempty(strfind(exptype, 'dissipation step')) && ...
           isempty(strfind(exptype, 'pre-stress')) && ...
           isempty(strfind(exptype, 'prestress')) && ...
           isempty(strfind(exptype, 'stress sweep')) && ...                
           isempty(strfind(exptype, 'strain sweep')) && ...
           isempty(strfind(exptype, 'frequency sweep')) && ...
           isempty(strfind(exptype, 'flow')) && ...
           isempty(strfind(exptype, 'creep')) && ...
           isempty(strfind(exptype, 'recov')) && ...
           isempty(strfind(exptype, 'temperature')) && ...
           isempty(strfind(exptype, 'peak hold')) && ... 
           isempty(strfind(exptype, 'relax')) && ...
           isempty(strfind(exptype, 'TTS'))
       
            figh(count) = NaN;
        end

        count = count + 1;        
%     end
        
end

if ~exist('exptype')
   figh(count) = NaN;
end

return;


function name = figname(fn, oldname)

    numidx = regexp(fn, '[0-9]');
    testnum = fn(numidx);
    
    if isempty(testnum)
        testnum='1'; 
    end;
    
    name = [oldname testnum];

    return;
        
