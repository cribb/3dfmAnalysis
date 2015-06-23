function [SNR, EM, h] = tracking_image_SNR(filelist, err_thresh, report) %filename, 0.5, y

if nargin < 3 || isempty(report)
    report = 'n';
end

% filename = 'channel10_MCU0_2ms_exp_2umbead.pgm';

format long g;

files = dir(filelist);
if isempty(files)
    error('No files in list. Wrong filename?');
end

for fid = 1:length(files)

    filename = files(fid).name;
    
    logentry(['Loading '  files(fid).name '.']);

    % read in the filename
    im = imread(filename);
    im = im(:,:,1);
    
    %write a switch case, use funciton class, figure out to do conversion
    %from 16 -> 8, want output to be uint8. 
    
%     q = double(im);
%     q = q/2^16*2^8;
%     im = uint8(q);

%   this will determine if image is 16-bit or 8-bit. If 16-bit, will reduce
%   to 8-bit. If aready 8-bit, nothing happens. 
    picinfo = imfinfo(im);
    bit = picinfo.BitDepth;

    switch bit
        case 16
            q = double(im);
            q = q/2^16*2^8;
            im = uint8(q);
        case 8
            % No change required
        otherwise
            error('image neither 16-bit or 8-bit depth');
    end
%     class(im)
    % % create a mask using the disk structural element
    % mask = imopen(im, strel('disk',disk_radius));

    [level EM(fid)] = graythresh(im);
    mask = im2bw(im, level);
    mask = bwareaopen(mask, 50);


    dil_mask = mask;
    dilation_step_size = 1;

    c = 1;

    my_error = 1;
    % err_thresh = .01;
    while my_error > err_thresh

        % pull out all of the values
        noise_data = double(im(~dil_mask));
        mean_noise(c) = mean(noise_data(:));
        max_noise(c) = max(noise_data(:));
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

    sig_data = double(im(dil_mask > 0)) - noise(end);



    % images using the thresholded value
    % im_noise = double(im) .* double(~im_bw);
    % im_signal = (double(im)-noise) .* double(im_bw);

    im_signal = (double(im)-noise(end)) .* double(dil_mask);
    im_noise = double(im) .* double(~dil_mask);

    cc = bwconncomp(mask, 4);
    numbeads = cc.NumObjects;

    for k = 1:numbeads
        this_bead_idx = cc.PixelIdxList{k};
        this_bead_px = im(this_bead_idx);

        bead_sig(k) = double(max(this_bead_px(:)));
    end;

    % filter out any overexposed values
    % oe_idx = find(bead_sig >= 255);


    mean_max_sig = mean(bead_sig);

    SNR(fid) = (mean_max_sig - noise(end)) / noise(end);


    if strcmp(report, 'y')

        % Diagnostic Figure 1
        h(fid) = figure; 
        hfid = h(fid);
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