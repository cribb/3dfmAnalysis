fl = dir('*.rsl');

fprintf('handling %i file(s).\n', length(fl));

for k = 1:length(fl)    
    myname = strrep(fl(k).name, '.rsl', '');
    mkdir(myname);
    movefile([myname '.rsl'], [myname '/' myname '.rsl']);
    movefile([myname ' exp.txt'], [myname '/' myname ' exp.txt']);
end
