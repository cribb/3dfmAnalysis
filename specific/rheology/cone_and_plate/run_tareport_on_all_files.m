rootdir = 'K:\data\material\PEO\2016.07__PEO_Study\2016.07.18__CAP_PEO_5MD_0p91pct_dH2O';
cd(rootdir);

rsl_file_list = importdata([rootdir '\rsl_file_list.txt']);

for k = 1:length(rsl_file_list)
    cd(rootdir);
    
    %[pathstr filename ext vrsn] = fileparts(rsl_file_list{k});
    
    %File parts doesn't output a vrsn number so I got an error. vrsn is not
    %used so i dropped it. RJ 2015.02.25
    [pathstr filename ext] = fileparts(rsl_file_list{k});
    cd(pathstr);
    
    cap = tareport([filename ' exp.txt'], 'PEO 5MD 0.91%');
    
end


