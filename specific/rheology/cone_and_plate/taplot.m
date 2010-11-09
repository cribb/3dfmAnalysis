function figh = taplot(filename, mytitle)
% TAPLOT Plots rheology curves for TA Instruments cone and plate data 
%
% 3DFM function
% specific/rheology/cone_and_plate
% last modified 11/19/08 (krisford)
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
    
fn = fieldnames(v.experiments);

% figure out which 'experiments' have data 'tables' and plot if data exists
count = 1;
for k = 1 : length(fn)
   
    if isfield(getfield(v.experiments, fn{k}), 'table');

        % extract each table's information and plot
        st  = getfield(v.experiments, fn{k});

        exptype = lower(st.metadata.step_name);
        
        if findstr(exptype, 'stress sweep')
            stress = st.table(:,getcol(st, 'stress'));
            gp = st.table(:,getcol(st, 'G'''));
            gpp= st.table(:,getcol(st, 'G'''''));
            figh(count) = plot_cap_ssweep(stress, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'ssweep'));
        end
        
        if findstr(exptype, 'strain sweep')
            strain = st.table(:,getcol(st, 'strain'));
            gp = st.table(:,getcol(st, 'G'''));
            gpp= st.table(:,getcol(st, 'G'''''));
            figh(count) = plot_cap_nsweep(strain, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'nsweep'));
        end
        
        if findstr(exptype, 'frequency sweep')
            freq = st.table(:,getcol(st, 'freq'));
            gp = st.table(:,getcol(st, 'G'''));
            gpp= st.table(:,getcol(st, 'G'''''));
            delta = st.table(:,getcol(st, 'delta'));            
            figh(count) = plot_cap_fsweep(freq, [gp gpp], [], mytitle, 'ww');
            set(figh(count), 'Name', figname(fn{k}, 'fsweep'));
        end

        if findstr(exptype, 'flow')
            shear_rate = st.table(:,getcol(st, 'rate'));
            visc = st.table(:,getcol(st, 'visc'));            
            figh(count) = plot_cap_flow(shear_rate, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'flow'));
        end

        if findstr(exptype, 'creep')
            t = st.table(:,getcol(st, 'time'));
            strain = st.table(:,getcol(st, 'strain'));
            stress = st.table(:,getcol(st, 'stress'));
            figh(count) = plot_cap_creep(t, strain, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'creep'));
        end

        if findstr(exptype, 'temperature')
            temp = st.table(:,getcol(st, 'temp'));
            visc = st.table(:,getcol(st, 'viscosity'));
            srate = st.table(:,getcol(st, 'shear rate'));
            figh(count) = plot_cap_temp(temp, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'temp'));
        end
        
        if findstr(exptype, 'peak hold')
            time = st.table(:,getcol(st, 'time'));
            visc = st.table(:,getcol(st, 'viscosity'));            
            strain = st.table(:,getcol(st, 'strain'));            

            figh(count) = plot_cap_peakhold(strain, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'peakstrain'));

%             figh(count) = plot_cap_peakhold(time, visc, [], mytitle);
%             set(figh(count), 'Name', figname(fn{k}, 'peakhold'));
        end                        
            
        if isempty(findstr(exptype, 'stress sweep')) && ...
           isempty(findstr(exptype, 'strain sweep')) && ...
           isempty(findstr(exptype, 'frequency sweep')) && ...
           isempty(findstr(exptype, 'flow')) && ...
           isempty(findstr(exptype, 'creep')) && ...
           isempty(findstr(exptype, 'temperature')) && ...
           isempty(findstr(exptype, 'peak hold'))
           
           figh(count) = NaN;
        end

        count = count + 1;        
    end
        
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
    
function v = getcol(s, str)

    dlim = sprintf('\t'); %the 'tab' is the delimiter here.
    th = s.table_headers;

    p = regexp(th, str);
    q = regexp(th, dlim);

    if ~isempty(p)
        v = find(p(1)<q,1);
    else
        v = [];
    end

    return;
