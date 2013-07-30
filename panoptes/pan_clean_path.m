function pan_clean_path(filepath)

cd(filepath)

try
    delete('*.evt.mat', '*.svg', '*.png', '*.fig', '*.html');
catch
    logentry('Some files were not deleted.');
end

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_clean_path: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    



