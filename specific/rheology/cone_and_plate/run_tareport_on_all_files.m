rootdir = 'K:\data\material\mucus_HBE\2013.11.12__CAP_HBE_mucus_5pct';

rsl_file_list = 
for k = 1:length(rsl_file_list)
    cd(rootdir);
    
    [pathstr filename ext vrsn] = fileparts(rsl_file_list{k});
    
    cd(pathstr);
    
    cap = tareport([filename ' exp.txt'], '5% HBE mucus');
    
end


