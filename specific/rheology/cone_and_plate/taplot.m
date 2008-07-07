function v = taplot(filename, mytitle)

v = ta2mat(filename);


fn = fieldnames(v.experiments);

% figure out which 'experiments' have data 'tables'
count = 1;
for k = 1 : length(fn)
   
    if isfield(getfield(v.experiments, fn{k}), 'table');

        % extract each table's information and plot
        st  = getfield(v.experiments, fn{k});

        exptype = lower(st.metadata.step_name);
        blah{k} = exptype;
        
        if findstr(exptype, 'stress sweep');
            [stress, gp, gpp] = setup_plottype_ssweep(st);
            plot_cap_ssweep(stress, [gp gpp], [], mytitle);
        end
        
        if findstr(exptype, 'strain sweep');
            [strain, gp, gpp] = setup_plottype_nsweep(st);
            plot_cap_nsweep(strain, [gp gpp], [], mytitle);
        end
        
        if findstr(exptype, 'frequency sweep');
            [freq, gp, gpp, delta] = setup_plottype_fsweep(st);
            plot_cap_fsweep(freq, [gp gpp], [], mytitle, 'ww');
        end

        if findstr(exptype, 'creep');
            [t,strain] = setup_plottype_creep(st);
            plot_cap_flow(t, strain, [], mytitle);
        end

        if findstr(exptype, 'flow');
            [shear_rate visc] = setup_plottype_flow(st);
            plot_cap_flow(shear_rate, visc, [], mytitle);
        end

        if findstr(exptype, '');
        end
    end
        
end

blah'

return;


function [stress, gp, gpp] = setup_plottype_ssweep(st)
    
    ANGFREQ = 1;
    TEMPERATURE = 2;
    TIME = 3;
    OSCSTRESS = 4;
    STRAIN = 5;
    DELTA = 6;
    GP = 7;
    GPP = 8;

    stress = st.table(:,OSCSTRESS);
    gp = st.table(:,GP);
    gpp= st.table(:,GPP);

return;

function [strain, gp, gpp] = setup_plottype_nsweep(st)
    ANGFREQ = 1;
    TEMPERATURE = 2;
    TIME = 3;
    OSCSTRESS = 4;
    STRAIN = 5;
    DELTA = 6;
    GP = 7;
    GPP = 8;

    strain = st.table(:,STRAIN);
    gp = st.table(:,GP);
    gpp= st.table(:,GPP);
return;

function [freq, gp, gpp, delta] = setup_plottype_fsweep(st)
    
    ANGFREQ = 1;
    TEMPERATURE = 2;
    TIME = 3;
    OSCSTRESS = 4;
    STRAIN = 5;
    DELTA = 6;
    GP = 7;
    GPP = 8;

    freq = st.table(:,ANGFREQ);
    gp = st.table(:,GP);
    gpp= st.table(:,GPP);
    delta = st.table(:,DELTA);
    
return

function [t,strain] = setup_plottype_creep(st)
    
    STRAIN = 1;
    TIME = 2;
    TEMPERATURE = 3;

    t = st.table(:,TIME);
    strain = st.table(:,STRAIN);

return;

function [shear_rate, visc] = setup_plottype_flow(st)

    STRESS = 1;
    SRATE = 2;
    VISC = 3;
    TIME = 4;
    TEMPERATURE = 5;
    NSTRES = 6;
    
    shear_rate = st.table(:,SRATE);
    visc = st.table(:,VISC);
    
return
    