function v = dmbr_files_summary(files)

fp = dir(files);

for k = 1 : length(fp)
    
    q = load(fp(k).name);
    
    
end
