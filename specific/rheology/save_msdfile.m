function outfile = save_msdfile(filename, data, r2switch) 


    outfile = [filename(1:end-3) 'msd.mat'];

    if strcmp(r2switch, 'n')
        data = rmfield(data, 'r2out');   %#ok<NASGU>
    end
    
    save(outfile, '-STRUCT', 'data');

return;
