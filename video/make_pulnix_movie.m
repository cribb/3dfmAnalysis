function v = make_pulnix_movie(rawfilein, movieout,frame_rate)

% get input file information
file = dir(rawfilein);

% setup the input file
fid = fopen(rawfilein);

% setup the output file
mov = avifile(movieout,'compression','none','fps',frame_rate);

% frame properties
rows = 484;
cols = 648;
color_depth = 1; % bytes
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

% initialize figure and set initial properties
fig = figure('visible','off');
set(fig,'Position', [1 1 cols rows]);
set(fig,'DoubleBuffer','on');
set(fig,'Renderer','zbuffer',...
        'Resize',  'on');

% set axes properties
ax = axes;
set(ax, 'Units', 'Pixels');
set(ax, 'Position',[1 1 cols rows]);
axis square;

number_of_frames = 2000;

for k=1:number_of_frames
  im = fread(fid, [648,484],'uint8');   % read in the next frame
  imagesc(im','parent',ax);             % puts image in invisible axes  
  colormap(gray(256));
  axis off;
  mov=addframe(mov,ax);               % adds frames to the AVI file 
  status = fseek(fid, frame_size*k, 'bof');  % advance to next frame
end 

mov=close(mov); %closes the AVI file  
close(fig); % closes the handle to invisible figure

v=im;
beep;beep;beep;beep;