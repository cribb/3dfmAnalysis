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
    
fn = fieldnames(v.results);

% figure out which 'experiments' have data 'units' and plot if data exists
count = 1;
for k = 1 : length(fn)
   
%     if isfield(getfield(v.experiments, fn{k}), 'units');

        % extract each experiments's information and plot
        protocol = getfield(v.protocols, fn{k});
        result  = getfield(v.results, fn{k});

        exptype = lower(protocol.step_name);
        
        if findstr(exptype, 'stress sweep')
            stress = result.data.osc_stress;
            gp = result.data.G_prime;
            gpp= result.data.G_double_prime;
            figh(count) = plot_cap_ssweep(stress, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'ssweep'));
        end
        
        if findstr(exptype, 'strain sweep')
            strain = result.data.strain;
            gp = result.data.G_prime;
            gpp= result.data.G_double_prime;
            figh(count) = plot_cap_nsweep(strain, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'nsweep'));
        end
        
        if findstr(exptype, 'frequency sweep') | findstr(exptype, 'tts')
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

        if findstr(exptype, 'flow')
            shear_rate = result.data.shear_rate;
            visc = result.data.viscosity;            
            figh(count) = plot_cap_flow(shear_rate, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'flow'));
        end

        if findstr(exptype, 'creep')
            t = result.data.time;
            strain = result.data.strain;
%             stress = result.data.shear_stress;
            figh(count) = plot_cap_creep(t, strain, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'creep'));
        end
        
        if findstr(exptype, 'recovery')
            t = result.data.time;
            strain = result.data.strain;
            stress = result.data.shear_stress;
            figh(count) = plot_cap_creep(t, strain, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'recov'));
        end
        
        if findstr(exptype, 'temperature')
            temp = result.data.temperature;
            visc = result.data.viscosity;
            srate = result.data.shear_rate;
            figh(count) = plot_cap_temp(temp, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'temp'));
        end
        
        if findstr(exptype, 'peak hold')
            time = result.data.time;
            visc = result.data.viscosity;            
%             strain = result.data.strain;            
            strainrate = strrep(protocol.controlled_variable, 'shear rate ', '');
            figh(count) = plot_cap_peakhold(time, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'peakstrain'));
            ser = get(gca, 'Children');
            set(ser, 'DisplayName', strainrate);
        end           
            
        if findstr(exptype, 'stress relaxation')
            time = result.data.time;
            Gt = result.data.modulus_Gt;            
            strain = result.data.strain;            
            figh(count) = plot_cap_relax(time, Gt, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'relax'));
            ser = get(gca, 'Children');
%             set(ser, 'DisplayName', strain);
        end
        
        if isempty(findstr(exptype, 'stress sweep')) && ...
           isempty(findstr(exptype, 'strain sweep')) && ...
           isempty(findstr(exptype, 'frequency sweep')) && ...
           isempty(findstr(exptype, 'flow')) && ...
           isempty(findstr(exptype, 'creep')) && ...
           isempty(findstr(exptype, 'recov')) && ...
           isempty(findstr(exptype, 'temperature')) && ...
           isempty(findstr(exptype, 'peak hold')) && ... 
           isempty(findstr(exptype, 'relax')) && ...
           isempty(findstr(exptype, 'TTS'))
       
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
        
