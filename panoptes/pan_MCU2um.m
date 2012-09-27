function calibum = pan_MCU2um(MCUparam)
% PAN_MCU2UM  Converts Panoptes's MCU parameter to microns per pixel
%

    % Rescaled MCU parameter to distance mapping 
%   calibum = (0.0009192384 * MCUparam + 0.1338995737);     % (range from 31 to 76) (062011 by Jeremy)
%    calibum = (0.0012402498 * MCUparam + 0.1089275278);       % (range from 46 to 96) (091911 by Jeremy)
%    idx = find(MCUparam < 46 & MCUparam > 96);
%    if ~isempty(idx)
%        logentry('The input MCU parameter is out of range.  Setting to NaN');
%        calibum(idx) = NaN;
%    end
    
%     
%     for k = 1:length(MCUparam)
%         switch MCUparam(k)
%             case 25000
%                 calibum(k) = 0.166;
%             case 30000
%                 % calibum(k) = 0.1808;
%                 calibum(k) = 0.1766;
%             otherwise
%                 error('This calibration factor is unknown.');
%         end
%     end

    
    for k = 1:length(MCUparam)
        
       if  MCUparam(k) == -1
           logentry('Using a test MCUparameter of -1, meaning conversion is set to 1');
           calibum(k) = 1;           
       elseif MCUparam(k) == 0
           calibum(k) = 0.1;  
           logentry('calibum is set to a wrong value and needs to be fixed');           
       elseif MCUparam(k) >= 25000 && MCUparam(k) <= 30000
           
           mcu_range = [25000 30000]';
           calibum_range = [0.1659 0.1766]';
           
           interp_range = [mcu_range(1):mcu_range(2)]';
           interp_calibum = interp1(mcu_range,calibum_range,interp_range);
           
           % idx = find(interp_range == MCUparam(k));
           calibum(k) = interp_calibum(interp_range == MCUparam(k));
       else
           error('This calibration factor is unknown.');
       end
       
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
   


