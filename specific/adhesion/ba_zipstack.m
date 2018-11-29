function ba_zipstack(stack_folder, destination_folder, outfile)

if nargin < 1 || isempty(stack_folder)
    error('No Stack folder defined.');
end

sftmp = dir(stack_folder);

if ~isempty(sftmp)
    stack_folder = sftmp.folder;
else
    error('Stack not found. Incorrect filename?');
end

slashpos = regexp(stack_folder, filesep);

if nargin < 2 || isempty(destination_folder)
    destination_folder = stack_folder(1:slashpos(end)-1);
end

if nargin < 3 || isempty(outfile)
    outfile = [destination_folder, stack_folder(slashpos(end):end), '.zip'];
end

startdir = pwd;
cd(stack_folder);

filelist = dir('frame*.pgm');

if isempty(filelist)
    error('No images found. Bad directory name?');
end

filelistcell = {filelist.name};

zip(outfile,filelistcell);

cd(startdir);

return