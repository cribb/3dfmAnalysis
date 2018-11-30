function ba_minivideo(stack_folder, destination_folder, outfile)

if nargin < 1 || isempty(stack_folder)
    error('No Stack folder defined.');
end

sftmp = dir(stack_folder);
slashpos = regexp(stack_folder, filesep);

if ~isempty(sftmp)
    stack_folder = sftmp.folder;
else
    error('Stack not found. Incorrect filename?');
end

if nargin < 2 || isempty(destination_folder)
    destination_folder = stack_folder(1:slashpos(end)-1);
end

if nargin < 3 || isempty(outfile)
    outfile = [destination_folder, stack_folder(slashpos(end):end), '.mp4'];
end

rootdir = pwd;

filelist = dir([stack_folder filesep 'frame*.pgm']);

if isempty(filelist)
    error('No images found. Bad directory name?');
end

v = VideoWriter(outfile, 'MPEG-4');
v.FrameRate = 60;

open(v);
for k = 1:4:length(filelist)
    myfile = fullfile(filelist(k).folder, (filelist(k).name));
    im = imread(myfile);
%     im = imresize(im, [640 NaN]);
    im = imresize(im, 0.5);
    imrgb = insertText(im, [5 5], k, 'AnchorPoint', 'LeftTop', ...
                                     'BoxColor', 'black', ...
                                     'BoxOpacity', 0.4, ...
                                     'TextColor', 'white', ...
                                     'FontSize', 14);
    im = im2uint8(imrgb);
    writeVideo(v, im); 
end
close(v);

