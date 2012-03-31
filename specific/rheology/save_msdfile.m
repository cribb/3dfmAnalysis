function outfile = save_msdfile(filename, data, r2switch) 

if nargin < 3 || isempty(r2switch)
    r2switch = 'n';
end
    
    outfile = [filename(1:end-3) 'msd.mat'];

    q = size(data);
    
    if strcmp(r2switch, 'n')
        for k = 1:q
            if isfield(data(q), 'r2out');
                newdata(q) = rmfield(data(q), 'r2out');   %#ok<NASGU>
            else
                newdata(q) = data(q);
            end
        end
    end
    
    save(outfile, '-STRUCT', 'data');

return;
