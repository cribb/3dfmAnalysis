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

firstframe = 'frame00001.pgm';
fullfirstframe = fullfile(stackdir, firstframe);


if isempty(dir(fullfirstframe))
    error('First frame file not found.');
else
    copyfile(fullfirstframe, outfile);    
end

return