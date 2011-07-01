function [ndlim, len, outl] = count_dlim(ins, dlim, cmnt_str)
% COUNT_DLIM Returns the numbers of delimiters in input, line-by-line
%
% 3DFM function
% Utilities
% last modified 2008.11.14 (jcribb)
%
% count the number of delimiters (or other characters) found line-by-line in a text file

if nargin < 3
    cmnt_str = [];
end

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
    
    if ~ischar(tline)
        break
    else
        
        % cut any parts of the string that follow "comment" character(s)
        if ~isempty(cmnt_str)
            eol = strfind(tline, cmnt_str);    
            if ~isempty(eol)
                tline = tline(1:eol-1);    
            end
            
            tline = strtrim(tline);
        end
        
        q = regexp(tline, dlim);
        ndlim(count,1) = length(q);
        len(count,1) = length(tline);
        outl{count,1} = tline;
    end
    count = count + 1;
end

fclose(fid);

