function v = make_pulnix_movie(rawfilein, movieout, frame_rate)
% 3DFM function  
% Video 
% last modified 09/07/2004 
%  
% This function converts RAW files from the Pulnix camera
% (via take, GLUItake, etc...) to an AVI file.
%  
%  v = make_pulnix_movie(rawfilein, movieout, frame_rate);  
%   
%  where "rawfilein" is the filename of the input RAW file. 
%        "movieout"  is the filename for the output AVI file.
%        "frame_rate" is the frame_rate of the output AVI.
%   
%  ??/??/?? - created.  jcribb.
%  09/07/04 - added documentation and removed a bug that only
%             allowed one to capture 60 frames.  jcribb.
%  

tic; 

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

v=toc;
