function vfd_list = gen_vfd_list(pathname)

file_info = rdir(pathname);
vfd_list = file_info;

len = length(file_info);

logentry(['This may take a while.  There are ' num2str(len) ' files to process.']);

for k = 1 : len;    
    
    fprintf('file #%i, name: %s\n', k, file_info(k).name);
    try
        vfd_info = load(file_info(k).name);                
    catch
        logentry('Problem loading file. Moving to next one.');
        continue;
    end            
    
        if isfield(vfd_info, 'sent_signal')
            vfd_info = rmfield(vfd_info, 'sent_signal');
        end
        
        if isfield(vfd_info, 'pulseID')
            vfd_info = rmfield(vfd_info, 'pulseID');
        end        
        
        vfd_list(k).vfd = vfd_info;
        
%         if isfield(vfd_info, 'degauss')
%             vfd_info = rmfield(vfd_info, 'degauss');
%         end
%         
%         if isfield(vfd_info, 'deg_tau')
%             vfd_info = rmfield(vfd_info, 'deg_tau');
%         end
% 
%         if isfield(vfd_info, 'deg_loc')
%             vfd_info = rmfield(vfd_info, 'deg_loc');
%         end
%         
%         if isfield(vfd_info, 'deg_freq')
%             vfd_info = rmfield(vfd_info, 'deg_freq');
%         end
%         
%         % we want to put all of the metadata into a single "parameters" structure.
%         % However, because there are two places where metadata are inputted (once
%         % during the driveGUI and second through the analysisGUI) we have to munge
%         % the two structures together.
%         tmp=[];
%         
%         fnames = fieldnames(file_info);        
%         for m = 1:length(fnames); 
%             tmp = setfield(tmp, fnames{m}, getfield(file_info, fnames{m})); 
%         end;
%         
%         vnames = fieldnames(vfd_info);
%         for m = 1:length(vnames); 
%             tmp = setfield(tmp, vnames{m}, getfield(vfd_info, vnames{m})); 
%         end;
% 
%         if exist('vfd_list')
%             tmp = orderfields(tmp, vfd_list);
%         end
%         
%         vfd_list(k) = tmp;
    
end

return;





% Prints out a log message complete with timestamp.
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'gen_vfd: '];
     
     fprintf('%s%s\n', headertext, txt);
     
    return
