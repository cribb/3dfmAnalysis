function file_handling(filepath)

files = dir(filelist);
num_files=length(files);
if isempty(files)
    error('No files in list. Wrong filename?');
elseif num_files ==1
    info=imfinfo(files.name);
    num_images=numel(info);
    if num_images > 1
        %do something with images
    else
        %do something with one image
    end
else 
    for i=1:num_files
        info=imfinfo(files(i).name)
        num_images=numel(info);
        if num_images > 1
            %do something with images
        else
             %do something with images
        end
    end
end



% 1 file, 1 image
% 1 file, multiple images
% n files w/ 1 image each
%n files w mimages each 