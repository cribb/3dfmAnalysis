function outs = ba_unpack_tiff(tif_filename, stack_path)

if nargin < 1 || isempty(tif_filename) || ~contains(tif_filename, '.tif')
    error('No file defined or file does not end with a ".tif" extension.');
end

if nargin < 2 || isempty(stack_path)
    stack_path = strrep(tif_filename, '.tif', '');
end
    
nfo = imfinfo(tif_filename);

if isempty(nfo)
    error('No info in file input.');
end

rootdir = pwd;

mkdir(stack_path);


for k =  1:length(nfo)
    im = imread(tif_filename, k); 
    basename = ['frame' num2str(k,'%04u') '.pgm'];
    myfile = fullfile(rootdir, stack_path, basename);
    disp(['Saving ' myfile]);
    imwrite(im, myfile, 'pgm'); 
end