impath = 'D:\jcribb\data\Hercules\2003.08.08\';
imfile = 'stationary_bead_agarose_1um_hercules_02.bmp';
movfile = 'stat_bead_bmp_copy2.avi';
frame_rate = 30;
duration = 100;

imagesc(im);
colormap(gray(256));
num_frames = frame_rate * duration;

mov = avifile(movfile,'compression','none','fps',frame_rate);

for k=1:num_frames;
    axis off;
    h = image(im);
    colormap(gray(256));
    axis off;
    set(h,'EraseMode','xor');
    F = getframe(gca);
    mov = addframe(mov,F);
    fprintf('\n current frame =  %i  of %i', k , num_frames);
end

mov = close(mov);


