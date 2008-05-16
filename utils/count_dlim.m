function [ndlim, len, outl] = count_dlim(ins, dlim)
% count the number of delimiters (or other characters) found line-by-line in a text file

if ~isempty(dir(ins))
    fid=fopen(ins);
else
    error('file not found');
    % trying to use this in counting instances in the file or just operating on the file
    % already opened
end

count = 1;
while 1
    tline = fgetl(fid);
    
    if ~ischar(tline), 
        break,   
    else
        q = regexp(tline, dlim);
        ndlim(count,1) = length(q);
        len(count,1) = length(tline);
        outl{count,1} = tline;
    end
    count = count + 1;
end

fclose(fid);

