impath = 'D:\jcribb\data\Hercules\2003.08.08\';
imfile = 'stationary_bead_agarose_1um_hercules_02.bmp';
movfile = 'translating_bead_bmp_copy.avi';
file = [impath imfile];
im = imread(file);
im = im(:,:,1);

fig = figure(1);
set(fig,'Position', [100 100 900 700],...
        'DoubleBuffer','on',...
        'Renderer','zbuffer',...
        'Resize',  'on');

ax = gca;
set(ax, 'Units', 'Pixels',...
    ax, 'Position',[100 100 719 479]);

imagesc(im);
colormap(gray(256));

[rows cols pages] = size(im);
num_frames = cols;

frame_rate = 30;

mov = avifile(  movfile, ...
               'compression','none', ...
               'fps',30,...
               'quality',100);

for k=1:num_frames;
    im_lastcol = im(:,cols);

    im = [im_lastcol im];
    im(:,cols+1) = [];
    
    imagesc(im);
    colormap(gray(256));
    drawnow;
    
    h = imagesc(im);
    pause(0.01);
    set(h,'EraseMode','xor');
    F = getframe(gca);
    mov = addframe(mov,F);
    fprintf('\n current frame =  %i  of %i', k , num_frames);
end

mov = close(mov);