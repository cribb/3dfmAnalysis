function make_3dfmAnalysis_docs(directory)
% 3DFM function  
% Utilities 
% last modified 03/12/2004
%  
% This function creates a "docs" directory that contains the help text associated with 
% any matlab file found in the directory passed to it.  The files made are in html, so that
% they can be uploaded to a website as a reference to which matlab routines
% are available for the 3dfm, and how to use them.
%  
%  [outputs] = make_3dfmAnalysis_docs(directory);  
%   
%  where "files" is a filename or directory name (wildcards may be used) 
%  
%  Notes:  
%   
%  03/12/2004 - created; jcribb
%   
%  

rootdocs = './docs';
files = dir(directory);

if (length(dir(rootdocs)))
    fprintf('Warning: Removing existing documentation files......\n');
    rmdir(rootdocs,'s');
    mkdir(rootdocs);
else
    mkdir(rootdocs);
end

% discover which entries are subdirectories

for k = 1 : length(files)
    if (files(k).isdir == 1) & ((files(k).name ~= '.') | (files(k).name ~= '..'))
        subdir = files(k).name;
        mkdir([rootdocs '/' subdir]);
        
        chdir([rootdocs '/' subdir]);
        
        mfiles = dir('*.m');
        
        for g = 1 : length(mfiles)
            
            thisfile = mfiles(g).name;
            h = help(thisfile);
            
            output = ['<pre> \n' h '</pre>'];
            
            thisfile = [thisfile(1:end-2) '.html'];
            
            save(thisfile, 'output');
        end
        
        chdir('../');
    end
end
