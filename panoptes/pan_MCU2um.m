function [calibum, calibum_err] = pan_MCU2um(MCUparam, systemid, wellid)
% PAN_MCU2UM  Converts Panoptes's MCU parameter to microns per pixel
%

    % Rescaled MCU parameter to distance mapping 
%   calibum = (0.0009192384 * MCUparam + 0.1338995737);     % (range from 31 to 76) (062011 by Jeremy)
%    calibum = (0.0012402498 * MCUparam + 0.1089275278);       % (range from 46 to 96) (091911 by Jeremy)
   
    if length(MCUparam) ~= length(wellid)
        error('Mismatch in number of MCU values and length of wells listed.');
    end
    
    if strcmp(systemid, 'panoptes')
        channelid = pan_get_channel_id(wellid);
    elseif strcmp(systemid, 'monoptes')
        channelid = 0;
    else
        error('Unknown system id, or none defined');
    end
    
%     channelid = 0;

    if channelid == 0     % case for monoptes
           calibum = (2.292106704e-6 * MCUparam + 0.1105463685);     % (range from 21000 to 60000) (112812 by Jeremy)
           idx = find(MCUparam < 21000);
           if ~isempty(idx)
               calibum(idx) = 0.157; % um/pixel 
           end

           idx = find(MCUparam > 60000);
           if ~isempty(idx)
               logentry('The input MCU parameter is out of range.  Setting to NaN');
               calibum(idx) = NaN;
           end

           calibum_err = NaN; % don't know this error
    elseif channelid > 0 % case for panoptes

        % calibrations for Panoptes channels 1-12 given an MCU parameter of zero.
        MCU_zero_calibum = [0.151447, 0.149707, 0.148812, 0.148333, 0.149083, 0.147706, 0.148374, 0.149008, 0.149312, 0.149215, 0.149227, 0.144805];
        MCU_zero_calibum_error = [0.00179751, 0.00373752, 0.00371864, 0.00218959, 0.00180049, 0.00124988, 0.00339845, 0.00153736, 0.00232281, 0.00248024, 0.000841523, 0.00206237];
        
        calibum = MCU_zero_calibum( channelid );
        calibum_err = MCU_zero_calibum_error( channelid );

    end
    
    
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

   
%     for k = 1:length(MCUparam)
%         
%        if  MCUparam(k) == -1
%            logentry('Using a test MCUparameter of -1, meaning conversion is set to 1');
%            calibum(k) = 1;           
%        elseif MCUparam(k) == 0
%            calibum(k) = 0.1;  
%            logentry('calibum is set to a wrong value and needs to be fixed');
%        elseif MCUparam(k) < 21000
%            calibum = 0.157;   % um/pixel
%        elseif MCUparam(k) >= 21000 && MCUparam(k) <= 60000
%            calibum(k) = (2.292106704e-6 * MCUparam + 0.1105463685);     % (range from 21000 to 60000) (112812 by Jeremy)
% %            mcu_range = [25000 30000]';
% %            calibum_range = [0.1659 0.1766]';
% %            
% %            interp_range = [mcu_range(1):mcu_range(2)]';
% %            interp_calibum = interp1(mcu_range,calibum_range,interp_range);
% 
% 
%            % idx = find(interp_range == MCUparam(k));
% %            calibum(k) = interp_calibum(interp_range == MCUparam(k));
%        else
%            error('This calibration factor is unknown.');
%        end
%        
%     end


    return;

% function for writing out stderr log messages
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'pan_MCU2um: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;
   


