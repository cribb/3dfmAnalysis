rootdir = 'K:\data\material\HA_crosslinked_hydrogels\2018.02.09__HA_hydrogels';
cd(rootdir);

rsl_file_list = importdata([rootdir '\rsl_file_list.txt']);

for k = 1:length(rsl_file_list)
    cd(rootdir);
    
    %[pathstr filename ext vrsn] = fileparts(rsl_file_list{k});
    
    %File parts doesn't output a vrsn number so I got an error. vrsn is not
    %used so i dropped it. RJ 2015.02.25
    [pathstr filename ext] = fileparts(rsl_file_list{k});
    cd(pathstr);
    
    cap = tareport([filename ' exp.txt'], 'HA hydrogels');
    
end


