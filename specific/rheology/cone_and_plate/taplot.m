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
            stress = st.table(:,get_TA_col(st, 'stress', 'Pa'));
            gp = st.table(:,get_TA_col(st, 'G''', 'Pa'));
            gpp= st.table(:,get_TA_col(st, 'G''''', 'Pa'));
            figh(count) = plot_cap_ssweep(stress, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'ssweep'));
        end
        
        if findstr(exptype, 'strain sweep')
            strain = st.table(:,get_TA_col(st, 'strain', ''));
            gp = st.table(:,get_TA_col(st, 'G''', 'Pa'));
            gpp= st.table(:,get_TA_col(st, 'G''''', 'Pa'));
            figh(count) = plot_cap_nsweep(strain, [gp gpp], [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'nsweep'));
        end
        
        if findstr(exptype, 'frequency sweep')
            freq = st.table(:,get_TA_col(st, 'frequency', 'Hz'));
            gp = st.table(:,get_TA_col(st, 'G''', 'Pa'));
            gpp= st.table(:,get_TA_col(st, 'G''''', 'Pa'));
            delta = st.table(:,get_TA_col(st, 'delta', ''));            
            figh(count) = plot_cap_fsweep(freq, [gp gpp], [], mytitle, 'ff');
            set(figh(count), 'Name', figname(fn{k}, 'fsweep'));
        end

        if findstr(exptype, 'flow')
            shear_rate = st.table(:,get_TA_col(st, 'rate', '1/s'));
            visc = st.table(:,get_TA_col(st, 'visc', 'Pa.s'));            
            figh(count) = plot_cap_flow(shear_rate, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'flow'));
        end

        if findstr(exptype, 'creep')
            t = st.table(:,get_TA_col(st, 'time', 's'));
            strain = st.table(:,get_TA_col(st, 'strain', ''));
            stress = st.table(:,get_TA_col(st, 'stress', 'Pa'));
            figh(count) = plot_cap_creep(t, strain, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'creep'));
        end

        if findstr(exptype, 'temperature')
            temp = st.table(:,get_TA_col(st, 'temp', '°C'));
            visc = st.table(:,get_TA_col(st, 'viscosity', 'Pa.s'));
            srate = st.table(:,get_TA_col(st, 'shear rate', '1/s'));
            figh(count) = plot_cap_temp(temp, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'temp'));
        end
        
        if findstr(exptype, 'peak hold')
            time = st.table(:,get_TA_col(st, 'time', 's'));
            visc = st.table(:,get_TA_col(st, 'viscosity', 'Pa.s'));            
            strain = st.table(:,get_TA_col(st, 'strain', ''));            
            strainrate = strrep(st.metadata.controlled_variable, 'shear rate ', '');
            figh(count) = plot_cap_peakhold(time, visc, [], mytitle);
            set(figh(count), 'Name', figname(fn{k}, 'peakstrain'));
            ser = get(gca, 'Children');
            set(ser, 'DisplayName', strainrate);
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

% if ~exist('exptype')
%    figh(count) = NaN;
% end

return;


function name = figname(fn, oldname)

    numidx = regexp(fn, '[0-9]');
    testnum = fn(numidx);
    
    if isempty(testnum)
        testnum='1'; 
    end;
    
    name = [oldname testnum];

    return;
        
