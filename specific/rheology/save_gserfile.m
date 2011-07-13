function outfile = save_gserfile(filename, data) %#ok<INUSD>
    
    outfile = [filename(1:end-3) 'gser.mat'];

    save(outfile, '-STRUCT', 'data');

return;
