function ba_copyfirstframe(stackdir, destination_folder, outfile)

if nargin < 1 || isempty(stackdir)
    error('No Stack folder defined.');
end

sftmp = dir(stackdir);

if ~isempty(sftmp)
    stackdir = sftmp.folder;
else
    error('Stack not found. Incorrect filename?');
end

slashpos = regexp(stackdir, filesep);

if nargin < 2 || isempty(destination_folder)
    destination_folder = stackdir(1:slashpos(end)-1);
end

dftmp = dir(destination_folder);

if ~isempty(dftmp)
    destination_folder = dftmp.folder;
else
    error('Destination folder not found. Incorrect filename?');
end

if nargin < 3 || isempty(outfile)
    outfile = [stackdir '.00001.pgm'];
end

framelist = dir([stackdir filesep 'frame*.pgm']);
firstframe = framelist(1).name;
lastframe = framelist(end).name;

fullfirstframe = fullfile(stackdir, firstframe);
fulllastframe = fullfile(stackdir, lastframe);

if isempty(dir(fullfirstframe))
    error('First frame file not found.');
else
    copyfile(fullfirstframe, outfile);    
end

if isempty(dir(fullfirstframe))
    error('Last frame file not found.');
else
    copyfile(fulllastframe, [stackdir '.07625.pgm']);    
end

return