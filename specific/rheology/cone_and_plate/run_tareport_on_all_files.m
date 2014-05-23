rootdir = 'K:\data\material\mucus_HBE\2014.03.06__CAP_HBE_mucus_3p6pct';
cd(rootdir);

rsl_file_list = importdata([rootdir '\rsl_file_list.txt']);

for k = 1:length(rsl_file_list)
    cd(rootdir);
    
    [pathstr filename ext vrsn] = fileparts(rsl_file_list{k});
    
    cd(pathstr);
    
    cap = tareport([filename ' exp.txt'], '3.6% HBE mucus');
    
end


