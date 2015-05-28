function [ A ] = readPixelsOverTimeTxt( file_name )
%    this function reads pixel intensity values over time 
%    assume the input file has format: every line contains intensity values
%      for a single pixel
%    different lines are for different pixels
    format = repmat('%i ', 1, 100);
    fid = fopen(file_name, 'r');
    A = fscanf(fid, format, [100,inf]);
    fclose(fid);
    
end

