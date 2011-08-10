function calibum = pan_MCU2um(MCUparam)
% PAN_MCU2UM  Converts Panoptes's MCU parameter to microns per pixel
%

    % Rescaled MCU parameter to distance mapping (062011 by Anya)
    calibum = (0.0009192384 * MCUparam + 0.1338995737);        
    
    idx = find(MCUparam < 31 & MCUparam > 76);
    if ~isempty(idx)
        logentry('The input MCU parameter is out of range.  Setting to NaN');
        calibum(idx) = NaN;
    end
    
    return;
    
    
% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_MCU2um: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;
   