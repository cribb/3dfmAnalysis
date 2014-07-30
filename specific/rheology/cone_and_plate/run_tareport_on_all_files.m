rootdir = 'C:\Users\cribb\Desktop\2014.07.23__CAP_mucus_3pct_notfrozen';
cd(rootdir);

rsl_file_list = importdata([rootdir '\rsl_file_list.txt']);

for k = 1:length(rsl_file_list)
    cd(rootdir);
    
    [pathstr filename ext vrsn] = fileparts(rsl_file_list{k});
    
    cd(pathstr);
    
    cap = tareport([filename ' exp.txt'], '3% HBE mucus');
    
end


