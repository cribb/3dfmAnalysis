function [] = spot_sim(folder,in_struct)

video_tracking_constants;

mkdir(folder);
logentry(['created directory: ' folder]);

cd(folder);
logentry(['current folder: ' folder]);

traj = sim_video_diff_expt(folder,in_struct);
xtraj = traj(:,X);
ytraj = traj(:,Y);

blank = zeros(in_struct.field_height,in_struct.field_width);

%may be a better way to do this part - instead of 2 for loops make the 
%'center' input to new_guass a vector instead of a point

numframes = length(xtraj)/in_struct.numpaths;

logentry(['number of frames: ' num2str(numframes)]);
frames = 0;

bead_r_m = in_struct.bead_radius;
bead_r_um = bead_r_m*1000000;
bead_d = 2*bead_r_um;
bead_pix = bead_d/in_struct.calib_um;
var = bead_pix^2;

%need to change sigma (st dev) into an input so that particle size can be
%changed easily
for i = 1:numframes
    paths = blank;
    for spot = 1:numframes:(length(xtraj)-1);
        paths = paths + gauss2d(blank,var,[xtraj(frames+spot),ytraj(frames+spot)],0.785);
    end
    frame = paths;
    filename = ['frame_' sprintf('%04d',i-1) '.tif'];
    imwrite(frame, filename, 'Tiff');
    frames = frames+1;
end
frame = blank;

logentry('finished creating spots');
end



