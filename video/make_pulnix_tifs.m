function v = make_pulnix_tifs(rawfilein)
% 3DFM function  
% Video 
% last modified 09/07/2004 
%  
% This function converts RAW files from the Pulnix camera
% (via take, GLUItake, etc...) to a stack of TIFFs.
%  
%  v = make_pulnix_tifs(rawfilein);  
%   
%  where "rawfilein" is the filename of the input RAW file. 
%  
%   
%  ??/??/?? - created.  jcribb.
%  09/07/04 - added documentation and removed a bug that only
%             allowed one to capture 60 frames.  jcribb.
%  

% get input file information
file = dir(rawfilein);

% setup the input file
fid = fopen(rawfilein);

% frame properties
rows = 484;
cols = 648;
color_depth = 1;   % byte
frame_size = rows * cols * color_depth;
number_of_frames = (file.bytes) / frame_size;

% initialize figure and set initial properties
fig = figure('visible','off');
set(fig,'Position', [100 100 cols rows]);
set(fig,'DoubleBuffer','on');
set(fig,'Renderer','zbuffer',...
        'Resize',  'on');

% set axes properties
ax = axes;
set(ax, 'Units', 'Pixels');
set(ax, 'Position',[1 1 cols rows]);
axis square;

% number_of_frames = 60;

for k=1:number_of_frames
  im = fread(fid, [648,484],'uint8');   % read in the next frame
  imagesc(im','parent',ax);             % puts image in invisible axes  
  colormap(gray(256));
  axis off;
  
  % setup the output file(s)
  myfile =  rawfilein(1:end-3);
  %filename_out = [myfile num2str(k) '.tif']

  f = getframe(gcf);
  [X, MAP] = frame2im(f);
  imwrite(X, [myfile num2str(k,'%.4d') '.tif'], 'TIF');

  status = fseek(fid, frame_size*k, 'bof');  % advance to next frame
  pause(0.01);
end 


close(fig);    % closes the handle to invisible figure

v=im';
