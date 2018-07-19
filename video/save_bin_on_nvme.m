function outs = save_bin_on_nvme(data, basefilename)
% SAVE_BIN_ON_NVME should be used for saving video data as bin file
%
%  outs = save_bin_on_nvme(data, basefilename)
%
%  where data = video data in XxYx1xFRAMES shape

    machinefmt = 'ieee-le';
    
    [rows, cols, rgb, frames] = size(data);
    datatype = class(data);
   
    if rgb ~= 1
        error('Incorrect format for input. Must be X x Y x RGB x FRAMES, RGB = 1.');
    end
   
    switch datatype
        case 'uint8'
            depth = '8';
            encodingOut = 'US-ASCII';
        case 'uint16'
            depth = '16';
            encodingOut = '';
        otherwise
            error('Type not found.');
    end 
   
    [mypath, myname, myext] = fileparts(basefilename);
   
    rootpath = pwd;
    filepath = cd(mypath);
                  
    filename = strcat([myname, '_', ...
                       num2str(cols), 'x', ...
                       num2str(rows), 'x', ...
                       num2str(frames), '_', ...
                       datatype, ...
                       '.bin']);

    fid = fopen(filename, 'w');

    fwrite(fid, data, datatype);
    fclose(fid);
   
    disp(['Saved ' mypath filesep filename '.']);
    cd(rootpath);
    outs = filename;

return
