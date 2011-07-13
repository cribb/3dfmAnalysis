function outfile = save_msdfile(filename, data) %#ok<INUSD>
    
    outfile = [filename(1:end-3) 'msd.mat'];

    save(outfile, '-STRUCT', 'data');

return;
