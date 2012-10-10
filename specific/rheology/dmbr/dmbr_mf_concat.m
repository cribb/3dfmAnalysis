function dmbr_mf_concat(fname)
%
% 
% Last modified 10/08/12 (stithc and rardinb)
% Christian Stith <chstith@ncsu.edu>, 10/04/2012
% Ben Rardin <rardinb@live.unc.edu> 10/08/2012
% dmbr_adjust_report.m
% Uses an external filepicker GUI to select multiple *.seqdat.txt files
% for concatenation into a single new file, <fname>.seqdat.txt
% The program then runs dmbr_adjust_report which reinitialized the report
% genertating process of dmbr_multi_file_report
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


%Christian Attempt #1 that uses a system command: creates the end of file
%character that we don't want
%{
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
%}



fidout = fopen([fname '.seqdat.txt'],'w');
% creates the new text file where the combined text files will be placed
for i=1:x % loops through the input seqdat.txt files
    fidin = fopen(filelist{1,i}, 'r');
    tline = '';
    while ischar(tline)
        tline = fgetl(fidin);
        if ischar(tline)==1
        fprintf(fidout,'%s\n', tline); %writes old text lines to new file
        else
            break
        end
    
    end
end
fclose(fidin);
fclose(fidout);

%Runs dmbr_adjust_report with the newly created *.seqdat.txt file
dmbr_adjust_report(fname)

end