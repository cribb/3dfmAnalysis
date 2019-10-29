function ba_stack2bin
% BA_STACK2BIN (incomplete) function that converts an image stack into a bin file.
%

startdir = pwd;
filelist = dir('*_uint16');
for k = 1:length(filelist)
    stackdir = filelist(k).name; 
    fid = fopen([stackdir '.bin'], 'w');
    cd(stackdir)
    imlist = dir('frame*.pgm');
    for m = 1:length(imlist)
        im = imread(imlist(m).name);
        fwrite(fid, im, 'uint16');
        if ~mod(m,100)
            disp(['Binning ' num2str(m) ' of ' num2str(length(imlist)) ' frames.']);
        end
    end
    fclose(fid);
    cd(startdir);
end