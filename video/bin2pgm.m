function bin2pgm(filename, outputpath, showTF)
% function outs = bin2pgm(filename, outputpath, showTF)

if nargin < 3 || isempty(showTF)
    showTF = false;
end

if nargin < 2 || isempty(outputpath)
    outputpath = strrep(filename, '.bin', '');
end

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
    
    if isempty(dir(outputpath))
        mkdir(outputpath);
    end

    fid = fopen(filename, 'r');
    
    rootdir = pwd;
    cd(outputpath);        

    if showTF
        h = figure;
    end
    

    frames_tens = round(frames, -1);
    
    count = 0;
%     for k = 1:10
    for k = 1:frames
        myframe = fread(fid, width*height, depth);
        framename = ['frame' num2str(k,'%05u') '.pgm'];
        myframe = reshape(myframe, height, width);

        if showTF
            figure(h);
            imagesc(myframe); 
            colormap(gray);
            drawnow;
        end
        
        imwrite(myframe, framename);
        

        if ~mod(k,200)
            disp([num2str(k), ' of ', num2str(frames), ' done.']);            
        end
    end
    
    fclose(fid);
    cd(rootdir);

%     outs = {width, height, frames, depth};
return
