function v = enhance_contrast(rawfilein, rawfileout)
tic;

% get input file information
file = dir(rawfilein);

% setup the input file
fid = fopen(rawfilein);
fod = fopen(rawfileout,'w');

% setup the output file
% fod = fopen()

% frame properties
rows = 484;
cols = 648;
color_depth = 1; % bytes
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

for k=1:number_of_frames
  im = fread(fid, [648,484],'uint8');   % read in the next frame
  m(k) = max(max(im));
  n(k) = min(min(im));
end 
fclose(fid);

%v.max = m;
%v.min = n;

m = max(m);
n = min(n);

gain = 255/m;

fid = fopen(rawfilein);

for k=1:number_of_frames    
    im = fread(fid, [648,484],'uint8');   % read in the next frame    
    im = im*gain;
    fwrite(fod, im, 'uint8');
end

fclose('all');

v = 0;

toc;

beep;beep;beep;beep;