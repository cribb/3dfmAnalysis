%extract CAP data--results are saved in the variables 'creep' and
%'recovery'

files = dir;
files = {files.name};
load(files{4})

%get applied stress information from variable 'protocols'
names = fieldnames(protocols);
index = strfind(names, 'creep_step');
index = find(cell2num(index) > 0);
creep_fields = names(index);
    
index = strfind(names, 'recovery_step');
index = find(cell2num(index) > 0);
recovery_fields = names(index);
    
stresses = cell(length(creep_fields), 1);

for j = 1:length(creep_fields)
    stress_string = protocols.(creep_fields{j}).applied_value;
    stress_string = strsplit(stress_string, ' ');
    stress_string = stress_string{3};
        
    old_stresses(j) = str2double(stress_string);
end
old_stresses = sort(old_stresses);
old_unique_stresses = unique(old_stresses);
unique_stresses = cell(length(unique(old_stresses)), 1);
    
for w = 1:length(old_stresses)
    stresses{w} = num2str(old_stresses(w));
end
for v = 1:length(old_unique_stresses)
    unique_stresses{v} = num2str(old_unique_stresses(v));
end

clear old_stresses old_unique_stresses names index


%record time and compliance information for each stress level
for j = 1:length(unique_stresses)
    stress_bool = strcmp(unique_stresses{j}, stresses);
    current_creep_fields = creep_fields(stress_bool);
        
    results_recovery_fields = fieldnames(results);
    index = strfind(results_recovery_fields, 'recovery_step');
    index = find(cell2num(index) > 0);
    results_recovery_fields = results_recovery_fields(index);
    current_results_recovery_fields = results_recovery_fields(stress_bool);
        
    stress_name = strrep(unique_stresses{j}, ' ', '');
    stress_name = ['s_', strrep(stress_name, '.', 'p')];
        
    for k = 1:length(current_creep_fields)
        creep_time_length(k) = length(results.(current_creep_fields{k}).data.time);
    end
    for k = 1:length(current_results_recovery_fields)
        recovery_time_length(k) = length(results.(current_results_recovery_fields{k}).data.time);
    end
    creep_max_length = max(creep_time_length);
    creep.(stress_name).time = zeros(creep_max_length, length(current_creep_fields));
    creep.(stress_name).compliance = zeros(creep_max_length, length(current_creep_fields));
        
    recovery_max_length = max(recovery_time_length);
    recovery.(stress_name).time = zeros(recovery_max_length, length(current_results_recovery_fields));
    recovery.(stress_name).compliance = zeros(recovery_max_length, length(current_results_recovery_fields));
        
    for k = 1:length(current_creep_fields)
        creep.(stress_name).time(1:creep_time_length(k),k) = results.(current_creep_fields{k}).data.time;
        creep.(stress_name).compliance(1:creep_time_length(k),k) = results.(current_creep_fields{k}).data.compliance_Jt;
    end
        
    for k = 1:length(current_results_recovery_fields)
        recovery.(stress_name).time(1:recovery_time_length(k),k) = results.(current_results_recovery_fields{k}).data.time;
        %compliance calculation
        strain = results.(current_results_recovery_fields{k}).data.strain;
        stress = repmat(str2double(unique_stresses{j}), length(strain), 1);
        recovery.(stress_name).compliance(1:recovery_time_length(k),k) = strain./stress;
    end
end

save('creep.mat', 'creep')
save('recovery.mat', 'recovery')

clear all

load('creep.mat')
load('recovery.mat')



%plot
stresses = fieldnames(creep);
runs_names = {'run 1', 'run 2', 'run 3'};
for j = 1:length(stresses)
        runs = size(creep.(stresses{j}).time, 2);
        
        colors = varycolor(runs);
       
        for k = 1:runs
            %format creep times
            creep_time = creep.(stresses{j}).time(:,k);
            last_creep_time_index = find(max(creep_time) == creep_time);
            creep_time = creep_time(1:last_creep_time_index);
            last_creep_time = creep_time(last_creep_time_index);
            creep_compliance = creep.(stresses{j}).compliance(1:last_creep_time_index,k);
            if k == 1
                figure
                hold on
            end
            plot(creep_time, creep_compliance, 'color', colors(k,:), 'linewidth', 3)
        end
        current_runs = runs_names(1:k);
        h_legend = legend(current_runs, 'location', 'northeastoutside');
        set(h_legend, 'fontsize', 13)
            for k = 1:runs
                creep_time = creep.(stresses{j}).time(:,k);
                last_creep_time_index = find(max(creep_time) == creep_time);
                creep_time = creep_time(1:last_creep_time_index);
                last_creep_time = creep_time(last_creep_time_index);
                %format recovery times
                recovery_time = recovery.(stresses{j}).time(:,k);
                last_recovery_time_index = find(max(recovery_time) == recovery_time);
                time_vector = repmat(last_creep_time, last_recovery_time_index, 1);
                recovery_time = recovery_time(1:last_recovery_time_index) + time_vector;
                recovery_compliance = recovery.(stresses{j}).compliance(1:last_recovery_time_index,k);
            
                plot(recovery_time, recovery_compliance, 'color', colors(k,:), 'linewidth', 3)
            end
        set(h_legend, 'fontsize', 13)
        xlabel('time (s)', 'fontsize', 15)
        ylabel('J(t) (1/Pa)', 'fontsize', 15)
        stressname = strrep(stresses{j}, 's_', []);
        title([stressname, ' Pa'], 'fontsize', 20)
end
