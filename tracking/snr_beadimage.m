function [snrmean, snrstd, T] = snr_beadimage(image, circle_radius, sensitivity, overfill, report)
% SNR_BEADIMAGE calculates signal-to-noise ratio for a microscopy image 
%
% The function snr_beadimage finds circular objects and segments them out
% in an attempt to calculate signal-to-noise (SNR). The maximum pixel
% intensity of each circular object is used as signal. The average value
% of the remaining pixels serves as the background measurement, while its
% standard deviation estimates the noise.
% 
% [snrmean, snrstd, T] = snr_beadimage(image, circle_radius, sensitivity, overfill, report)
% 
% Output parameters:
%   snrmean  mean SNR computed from each circular (signal) object
%   snrstd   standard deviation for signal distribution
%   T        output data table for individual objects.
%
% Input parameters:
%   image           input image for SNR computation
%   circle_radius   estimated average pixel radius for objects of interest
%   sensitivity     "dial" for optimizing object detection, usually between
%                   0.8 - 0.97. More than 0.97 risks false positive signals
%   overfill        size "factor" for object segmentation. A value of 1
%                   means the object mask will be the same as measured by
%                   the object finding algorithm, where a value of 2 would
%                   double the effective radii of objects in the image
%   report          'y' or 'n' switch for plotting results, 'n' is default.
%

    if  nargin < 5 || isempty(report)
        report = 'n';    
    end

    if nargin < 4 || isempty(overfill)
        overfill = 1.5;
    end

    if nargin < 3 || isempty(sensitivity)
        sensitivity = 0.95;
    end

    if nargin < 2 || isempty(circle_radius)
        error('Approximate tracker radius in pixels needed.');
    end

    if nargin < 1 || isempty(image)
        error('Image input needed.');
    end

    
    I = image;
    [imh, imw] = size(I);

    Id = double(I);    

    bit = bitdepth(I);

    dRange = [floor(circle_radius*0.5), ceil(circle_radius*1.5)];
    [centers,radii] = imfindcircles(I, dRange,'ObjectPolarity','bright', ...
                                              'Sensitivity',sensitivity);

    if isempty(centers)
        logentry('No signal pixels found.');
        snrmean = []; snrstd = []; T = [];
        return
    end

    N(:,1) = 1:size(centers,1);
    
    Mask = createCirclesMask([imh,imw], centers, radii*overfill);

    SignalPixels = Id(Mask);
    NoisePixels = Id(~Mask);

% % % % % %     pct_thresh = 99;
% % % % % %     p = prctile(NoisePixels,pct_thresh);
% % % % % %     NoiseBoundedLow = NoisePixels( NoisePixels < p);
% % % % % %
% % % % % %     foo = Id.*double(~Mask);
% % % % % %     foo(foo > p) = NaN;
% % % % % %     figure(808);
% % % % % %     surf(foo,'EdgeColor','none');colormap(hot);    
% % % % % %     zlim([0 6000])
% % % % % %     title(['noise, ' num2str(pct_thresh) '% percentile']);
% % % % % % 
% % % % % %     figure(809);
% % % % % %     imagesc(log10(foo));
% % % % % %     colorbar;
% % % % % %     axis square
% % % % % % 
% % % % % %     Background = mean(NoiseBoundedLow, 'all', 'double', 'omitnan');
% % % % % %     Noise = std( NoiseBoundedLow - Background, [], 'all', 'omitnan');

    Background = mean(NoisePixels, 'all', 'double', 'omitnan');
    Noise = std( NoisePixels - Background, [], 'all', 'omitnan');

    T = table(N, centers, radii, 'VariableNames',{'ID', 'Center', 'Radius'});
    
    Intensities = splitapply(@(x1,x2){sa_extract(x1, x2, I, overfill)}, T.Center, T.Radius, T.ID);

    T.MaxSignal = cell2mat(cellfun(@max,Intensities,'UniformOutput',false));
    
    snr = (double(T.MaxSignal) - Background) ./ Noise;
    snrmean = mean(snr);
    snrstd = std(snr);

    if strcmpi(report, 'y')
        create_report_figure(Id, Mask, NoisePixels, SignalPixels, T);
    end

end % end of main function


function outs = sa_extract(center, radius, image, overfill)

    mask = createCirclesMask(size(image), center, radius*overfill);

    outs = image(mask);
end


function bit = bitdepth(image)
    c = class(image);
    switch c
        case 'uint8'
            bit = 8;
        case 'uint16'
            bit = 16;
        otherwise
            error('bit depth unknown');
    end
end


function create_report_figure(Id, Mask, NoisePixels, SignalPixels, T)

    edge2bin = @(x) mean(diff(x))/2 + x(1:end-1);

    % Diagnostic Figure 1
    h = figure; 
    set(gcf, 'Units', 'Normalized');
    set(gcf, 'Position', [0.15 0.15 4/3*0.6 0.5]);
    subplot(2,4,1);
    imagesc(Id);
    axis image
    colormap(hot(256));
    title('original image, scaled');

    figure(h);
    subplot(2,4,2);
    imagesc(Mask);
    axis image
    title('Mask');

    figure(h);
    subplot(2,4,3);
    imagesc(log10(Id .* double(~Mask)));
    axis image
    title('log(Noise pixels), scaled');
    colorbar;

    figure(h);
    subplot(2,4,4);
    imagesc(log10(Id .* double(Mask)));
    axis image
    title('Signal pixels, scaled');
    colorbar;

    figure(h);
    subplot(2,4,5);    
    [histy, edges] = histcounts(NoisePixels);
    hold on;
        mex = mean(NoisePixels);
        [~,minidx] = min(abs(edge2bin(edges) - mex));
        mey = histy(minidx);
    
        medx = median(NoisePixels);
        [~,minidx] = min(abs(edge2bin(edges) - mex));
        medy = histy(minidx);
    
        plot(edge2bin(edges), histy, '.');
        plot(edge2bin(edges), cumsum(histy), 'c.');
        plot(mex, mey, '^k');
        plot(medx, medy, 'or');        
    hold off;
    set(gca, 'Xlim', [0 max(NoisePixels)]);
    set(gca, 'YScale', 'log');
    legend('pdf', 'cdf', 'mean', 'median');
    title('Noise Pixel Hist.');
    xlabel('pixel value');
    ylabel('count');    

    figure(h);
    subplot(2,4,6);
    [histy, edges] = histcounts(SignalPixels(:));
    topdecile = prctile(SignalPixels,99);
    hold on
        plot(edge2bin(edges), histy, '.');
        ax = gca;
        ax.XLim = [0 max(SignalPixels(:))];
        ax.YScale = 'log';
        line([topdecile topdecile], ax.YLim, 'LineStyle', '--', 'Color', [0.5 0.5 0.5]);
    hold off
    title('Signal Pixel Hist.');
    legend('pdf','99% prctile');
    xlabel('pixel value');
    ylabel('count');      

    figure(h);
    subplot(2,4,7);
    histogram(T.Radius);
    title('Object size distribution');
    xlabel('Radius [pixels]');
    ylabel('count');

    figure(h);
    subplot(2,4,8);
    histogram(T.MaxSignal);
    title('Object MaxIntensity distribution');
    xlabel('Max Intensity []');
    ylabel('count');
end

% % function for writing out stderr log messages
% function logentry(txt)
%     logtime = clock;
%     logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
%                    num2str(logtime(2),        '%02i') '.' ...
%                    num2str(logtime(3),        '%02i') ', ' ...
%                    num2str(logtime(4),        '%02i') ':' ...
%                    num2str(logtime(5),        '%02i') ':' ...
%                    num2str(floor(logtime(6)), '%02i') ') '];
%      headertext = [logtimetext 'tracking_image_SNR: '];
%      
%      fprintf('%s%s\n', headertext, txt);
%      
%      return;    