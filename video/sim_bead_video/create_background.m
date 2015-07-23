function [background_mat,bg_mean,noise,need_noise] = create_background(background,intensity,SNR,field_height,field_width)

if (isnumeric(background) && (length(background) <=1 || length(background) <=3)) == 1
    bg_mean = background;
    logentry(['Mean background intensity = ' num2str(bg_mean) '. Background is a matrix of ' num2str(bg_mean) 's.']);
    noise = (intensity-bg_mean)/SNR;
    background_mat = repmat(bg_mean, field_height, field_width);
    background_mat = uint8(background_mat);
    need_noise = 0;
    
elseif (isnumeric(background) && length(background) > 3) == 1;
    logentry('Background is an image matrix.');
    background_mat = double(background);
    bg_mean = mean(mean(background_mat));
    logentry(['Mean background intensity = ' num2str(bg_mean) '.']);
    existingnoise = std(std(background_mat));
    noise = (intensity-bg_mean)/SNR;
    background_mat = uint8(background_mat);
    if existingnoise > noise
        error('Too much noise in the background for this SNR.');
    else need_noise = noise - existingnoise;
    end
    
elseif ischar(background) == 1 ;
    if exist(background, 'file') ~= 2
        error('Background image file does not exist. Please add file to Matlab path.');
    end
    logentry('Background is an image file.');
    background_mat = double(imread(background));
    bg_mean = mean(mean(background_mat));
    logentry(['Mean background intensity = ' num2str(bg_mean) '.']);
    existingnoise = std(std(background_mat));
    noise = (intensity-bg_mean)/SNR;
    background_mat = uint8(background_mat);
    if existingnoise > noise
        error('Too much noise in the background for this SNR.');
    else need_noise = noise - existingnoise;
    end
end
% imwrite(background_mat,'background.tif','tiff');
end