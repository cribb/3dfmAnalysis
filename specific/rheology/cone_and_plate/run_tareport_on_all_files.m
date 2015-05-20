rootdir = 'K:\data\material\mucus_HBE\2015.04.08__CAP_HBE_mucus_2pct_EBFDAC';
cd(rootdir);

rsl_file_list = importdata([rootdir '\rsl_file_list.txt']);

for k = 1:length(rsl_file_list)
    cd(rootdir);
    
    %[pathstr filename ext vrsn] = fileparts(rsl_file_list{k});
    
    %File parts doesn't output a vrsn number so I got an error. vrsn is not
    %used so i droped it. RJ 2015.02.25
    [pathstr filename ext] = fileparts(rsl_file_list{k});
    cd(pathstr);
    
    cap = tareport([filename ' exp.txt'], '2% HBE mucus Spec-EBFDAC');
    
end


