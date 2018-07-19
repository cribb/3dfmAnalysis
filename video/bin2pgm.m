function outs = bin2pgm(filename, outputpath)

    filename_suffix = regexpi(filename, '_\d+x\d+x\d+_uint\d+.bin', 'match');
    filename_suffix = filename_suffix{1};
    
    [s,e] = regexpi(filename_suffix, '^_\d+x');
    width = str2num(filename_suffix(s+1:e-1));   
    filename_suffix(s:e) = [];
    
    [s,e] = regexpi(filename_suffix, '^\d+x');
    height = str2num(filename_suffix(s:e-1));
    filename_suffix(s:e) = [];
    
    [s,e] = regexpi(filename_suffix, '^\d+_');
    frames = str2num(filename_suffix(s:e-1));
    filename_suffix(s:e) = [];
    
    depth = regexpi(filename_suffix, '^uint\d+', 'match');
    depth = depth{1};
    
    fid = fopen(filename, 'r');
    for k = 1:frames
%         myframe = fread(fid, width*height, depth);
        framename = ['frame' num2str(k,'%04u') '.pgm'];
%         imwrite(myframe, framename);
    end
    
    outs = {width, height, frames, depth};
return
