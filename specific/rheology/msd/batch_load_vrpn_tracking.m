% loading stuff


clear all
close all



fu = dir('*.mat');

num_files = size(fu);


for z = 1:num_files,
    
    filename = fu(z).name;

    d = load_video_tracking(filename, 120,[],[],'rectangle','um',0.10458);

    data = [d.coord.t d.coord.x d.coord.y d.coord.z];

    filename_save_2 = strcat(filename,'_position.dat');
    save(filename_save_2, 'data', '-ASCII');

end