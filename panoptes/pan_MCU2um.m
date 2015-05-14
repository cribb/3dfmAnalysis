function [calibum, calibum_err] = pan_MCU2um(MCUparam, systemid, wellid, metadata)
% PAN_MCU2UM  Converts Panoptes's MCU parameter to microns per pixel
%

    if length(MCUparam) ~= length(wellid)
        error('Mismatch in number of MCU values and length of wells listed.');
    end
    
    if isfield(metadata.instr, 'scales')
        scales = metadata.instr.scales;
    else
        error('No scaling factors defined. You need to update the ExperimentConfig file.');
    end
    
    if strcmp(systemid, 'panoptes')
        channelid = pan_get_channel_id(wellid);
    elseif strcmp(systemid, 'monoptes')
        channelid = 0;
    else
        error('Unknown system id, or none defined');
    end    

    if strcmp(systemid, 'monoptes')     % case for monoptes
        
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
           
    elseif strcmp(systemid, 'panoptes') % case for panoptes

        CHANNELID = 1;
        SLOPE = 2;
        INTERCEPT = 3;
        LIMIT_LOW = 4;
        LIMIT_HIGH = 5;
        
%         for chanIDX = 1:length(channelid)
%             idx = find(scales(:,CHANNELID) == channelid(chanIDX));
        
        
            % If the MCU value is less than the lower limit, then the calibration
            % factor becomes the value reported AT the lower limit.
            %
            % If the MCU value is between the lower and upper limits, then just
            % apply the calibrations as usual.
            %
            % If the MCU value is beyond the upper limit, then we are no longer
            % in the calibrated range.
            
            for q = 1:length(MCUparam)
                
                mywell = wellid(q);
                mychan = pan_get_channel_id(mywell);
                
                idx = find(scales(:,CHANNELID) == mychan);
                lim_hi = scales(idx, LIMIT_HIGH);
                lim_lo = scales(idx, LIMIT_LOW);
                
                if isnan(MCUparam(q))
                    logentry('MCU parameter value is NaN. Returning NaN');
                    calibum(q) = NaN;
                elseif MCUparam(q) < lim_lo
                    calibum(chanIDX,q) = scales(idx, SLOPE) * lim_lo + scales(idx, INTERCEPT);          
                elseif MCUparam(q) < lim_hi && MCUparam(q) > lim_lo
                    calibum(q) = scales(idx, SLOPE) .* MCUparam(q) + scales(idx,INTERCEPT);
                elseif MCUparam(q) > lim_hi
                    logentry('Outside the calibrated varioptic range. Returning NaN');
                    calibum(q) = NaN;
                end
            end
%         end
        
        calibum_err = NaN; % don't know this error with the data given
        
        % calibum = 3.83546355058471e-006 *MCUparam + 0.0353824501440064; % 2015.04.24 avg calibration function across 12 channels 

        
%            calibum = (2.292106704e-6 * MCUparam + 0.1105463685);     % (range from 21000 to 60000) (112812 by Jeremy)
%            idx = find(MCUparam < 21000);
%            if ~isempty(idx)
%                calibum(idx) = 0.157; % um/pixel 
%            end
% 
%            idx = find(MCUparam > 60000);
%            if ~isempty(idx)
%                logentry('The input MCU parameter is out of range.  Setting to NaN');
%                calibum(idx) = NaN;
%            end
% 
%            calibum_err = NaN; % don't know this error

    end
    
    
    return;
