function v = make_pulnix_avi(directory,movfile)
% make pulnix avi

cd(directory)
files = dir('*.raw');

% [rows cols] = size(im);
rows = 484;
cols = 648;

frame_rate = 30;
% movfile = 'bacteria_with_2p8_bead.avi';


fig = figure(1);
set(fig,'Position', [100 100 floor(cols*1.25) floor(rows*1.25)]);
set(fig,'DoubleBuffer','on');
set(fig,'Renderer','zbuffer',...
        'Resize',  'on');

ax = gca;
set(ax, 'Units', 'Pixels');
set(ax, 'Position',[floor(cols*0.1) floor(rows*0.1) cols rows]);
axis square;

mov = avifile(movfile,'compression','none','fps',frame_rate);

tic;
for k = 1:length(files);
    fid = fopen(files(k).name);
    im = fread(fid,[648,inf],'uint8');
    axis off;
    h = imagesc(im');
    colormap(gray(256));
    drawnow;
    set(h,'EraseMode','xor');
    F = getframe(gca);
    mov = addframe(mov,F);
    fprintf('\n current frame =  %i  of %i', k , length(files));
    fclose(fid);
end

mov = close(mov);

v = toc;
