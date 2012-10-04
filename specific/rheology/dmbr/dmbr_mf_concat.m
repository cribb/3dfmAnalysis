function dmbr_mf_concat(fname)
%
% 
% Last modified 10/04/12 (stithc)
% Christian Stith <chstith@ncsu.edu>, 10/04/2012
% dmbr_adjust_report.m
% Uses an external filepicker GUI to select multiple *.seqdat.txt files
% for concatenation into a single new file, <fname>.seqdat.txt
% 
% KNOWN BUG: Any characters on the last line must be removed. The
% file must end on a newline followed by no characters. Check
% for whitespace.
% 
% Required Parameters:
%   name: the root name of the concatenation file
% Returns:
%   N/A
%
% Command Line Syntax:
%   dmbr_mf_concat(<New_Analysis_Name>)
% Example:
%   dmbr_mf_concat('CombinedRuns')
%
filelist = uipickfiles('FilterSpec', '*.seqdat.txt');

x = length(filelist);

com = 'copy ';

for i=1:x
    [pathname, filename_root, ext] = fileparts(filelist{1,i});
    com = [com '"' filelist{1,i} '"'];
    if i~=x
        com = [com '+'];
    end
end

globe = [ '"' pwd filesep fname '.seqdat.txt"' ];
com = [com ' ' globe];

system(com);

%{
seq = [ '"' pwd filesep fname '.seqdat.txt"' ];
fidin = fopen(globe);
fidout = fopen(seq);
tline = '';
while ischar(tline)
    tline = fgets(fidin);
    fprintf(fidout,tline);
end
fclose(fidin);
fclose(fidout);
%}
end