function [avgSNR]= tracking_single_image_SNR_try2(image,err_thresh, report,thresh,bit)




if  nargin < 3 || isempty(report)
    report = 'n';    
end
    im=image;
    
    %I_sig > Th * (I_max - I_min) + I_min
   
    maxPixel=double(max(im(:)));
    minPixel=double(min(im(:)));
    medPixel=double(median(im(:)));
    threshold =thresh;
    signalLevel=threshold*(maxPixel-minPixel)+minPixel;
    
    if bit ==8
        level=signalLevel/256;
    elseif bit==16
        level=signalLevel/65537;
   
    end
        
        %[level EM(fid)] = graythresh(im);
    mask = im2bw(im, level);
    mask = bwareaopen(mask, 4);
    dil_mask = mask;
    dilation_step_size = 1;

    c = 1;

    my_error = 1;
    % err_thresh = .01;
    while my_error > err_thresh

        % pull out all of the values
        noise_data = double(im(~dil_mask));
        mean_noise(c) = mean(noise_data(:));
        %max_noise(c) = max(noise_data(:));
        noise(c) = std(noise_data(:));

        if c > 1
            my_error = abs(mean_noise(c-1) - mean_noise(c)) / ...
                        mean([mean_noise(c-1) , mean_noise(c)]);
        else
            my_error = 1;
        end

        delta_error(c) = my_error;

        
        if my_error < err_thresh 
            break;
        elseif c > 100 % set an arbitrary threshold of 100 pixel dilation
            logentry('Did not sufficently converge.');
            break;
        end

        dil_mask = imdilate(dil_mask, strel('disk', dilation_step_size));
        c = c + 1;
    end

    sig_data = double(im(dil_mask > 0)) - mean_noise(end);
    
   
    % images using the thresholded value
    % im_noise = double(im) .* double(~im_bw);
    % im_signal = (double(im)-noise) .* double(im_bw);

    im_signal = (double(im)-mean_noise(end)) .* double(dil_mask);
    im_noise = double(im) .* double(~dil_mask);

    cc = bwconncomp(mask, 8);
    numbeads = cc.NumObjects;
    kickedout=0;
    bead_num=1;
    for k = 1:numbeads
        this_bead_idx = cc.PixelIdxList{k};
        this_bead_px = im(this_bead_idx);
        tops=max(this_bead_px(:));
       if bit==8
        if double(max(this_bead_px(:))) <254
            bead_sig(bead_num) = double(max(this_bead_px(:)));
            bead_num=bead_num+1;
        else
            kickedout=kickedout+1;
        end
       elseif bit==16
           if double(max(this_bead_px(:))) <65535
             bead_sig(bead_num) = double(max(this_bead_px(:)));
             bead_num=bead_num+1;
           else
             kickedout=kickedout+1;
           end
       end
    end
    
if numbeads==kickedout
    logentry('All beads are overexposed, attempt lower threshold');
elseif kickedout>0
numout=num2str(kickedout);
numtotal=num2str(numbeads);
message=strcat(numout,' out of ', numtotal, ' beads removed due to overexposure.');
logentry(message);
end
    % filter out any overexposed values
    % oe_idx = find(bead_sig >= 255);
    
%     figure;
%     imhist(im,20);
%     title('imagehist');    
%     background=mean_noise(end)
%     figure;
%     hist(noise_data);
%     title('noisehist');
%     figure;
%     hist(sig_data);
%     title('sighist');
%     figure;
%     hist(bead_sig);
%     title('bead_sig');

     mean_max_sig = mean(bead_sig);
     max_bead_sig=max(bead_sig);
     min_bead_sig=min(bead_sig);
    signal_standard_error=std(bead_sig)/sqrt(length(bead_sig));
    background_standard_error=std(mean_noise)/sqrt(length(mean_noise));
    total_error=signal_standard_error+background_standard_error;
    avgSNR = (mean_max_sig - mean_noise(end)) / noise(end);
    maxSNR=(max_bead_sig-mean_noise(end))/noise(end);
    minSNR=(min_bead_sig-mean_noise(end))/noise(end);

    if strcmp(report, 'y')

        % Diagnostic Figure 1
        h = figure; 
        hfid = h;
        set(gcf, 'Units', 'Normalized');
        set(gcf, 'Position', [0.15 0.15 4/3*0.6 0.5]);
        subplot(2,4,1);
        imagesc(im); 
        colormap(gray(256));
        title('original image, scaled');

        figure(hfid);
        subplot(2,4,2);
        imagesc(dil_mask);
        title('Mask');

        figure(hfid);
        subplot(2,4,3);
        imagesc(im_noise);
        title('Noise pixels, scaled');

        figure(hfid);
        subplot(2,4,4);
        imagesc(im_signal);
        title('Signal pixels, scaled');

        figure(hfid);
        subplot(2,4,5);    
        [histy histx] = hist(noise_data, 15);
        plot(histx, histy, '.');
        set(gca, 'Xlim', [0 max(noise_data(:))]);
        set(gca, 'YScale', 'log');
        title('Noise Pixel Hist.');
        xlabel('pixel value');
        ylabel('count');    

        figure(hfid);
        subplot(2,4,6);    
        [histy histx] = hist(sig_data, 25);
        plot(histx, histy, '.');
        set(gca, 'Xlim', [0 max(sig_data(:))]);
        set(gca, 'YScale', 'log');
        title('Signal Pixel Hist.');
        xlabel('pixel value');
        ylabel('count');         

    %     % showing the thresholded image.
    %     figure(hfid);
    %     subplot(2,4,7);   
    %     imagesc(mask);
    %     title('Thresholded image');

    %     figure(hfid);
    %     subplot(2,4,7);   
    %     plot(noise, '.-');
    %     title('Noise');
    %     xlabel('iteration');

        figure(hfid);
        subplot(2,4,7);   
        plot((mean_max_sig - noise) ./ noise, '.-');
%         plot(SNR, '.-');
        title('SNR');
        xlabel('iteration');

        figure(hfid);
        subplot(2,4,8);
        plot(delta_error(2:end), '.-');
        xlabel('iteration');
        ylabel('error signal (\Delta noise)');

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
                   num2str(floor(logtime(6)), '%02i') ') '];
     headertext = [logtimetext 'tracking_image_SNR: '];
     
     fprintf('%s%s\n', headertext, txt);
     
     return;    