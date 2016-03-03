function figh = plot_tracking_xy(vstdata, figh, background_image, field_hw, plotopts)
% want to overlay the trajectories over an image of them (could be a single
% image, a MIP, or whatever).
%
% what are units and how do deal with unit conversion?
% image input MUST be in pixels, so DEFINE the input unit for the vstdata
% and then include the conversion factor for the image.
video_tracking_constants;

if nargin < 5 || isempty(plotopts)
    plotopts = 'b.';
end

if nargin < 4 || isempty(field_hw)
    field_hw(1,:) = max(vstdata(:,X:Y)) * 1.10;
end

if nargin < 3 || isempty(background_image)
    background_image = [];
else
    field_hw = size(background_image);    
end 

if nargin < 2 || isempty(figh)
    figh = figure;
end

if nargin < 1 || isempty(vstdata)
    error('No tracking data to plot!');
end

vstdata = load_video_tracking(vstdata, [], 'pixels', 1, 'absolute', 'no', 'table');

    figure(figh);   
    
    if ~isempty(background_image)
        imagesc(background_image);
        colormap(gray);
    end

    hold on;
    plot(vstdata(:,X), vstdata(:,Y), plotopts); 
    hold off;
    
    xlabel(['X [pixels]']);
    ylabel(['Y [pixels]']);    
    axis([0 field_hw(2) 0 field_hw(1)]);
    set(figh, 'DoubleBuffer', 'on');
    set(figh, 'BackingStore', 'off');
       
    return;
    