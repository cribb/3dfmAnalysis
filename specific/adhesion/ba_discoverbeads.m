function outs = ba_discoverbeads(firstframe, lastframe, search_radius_low, search_radius_high, Fid)
% 
% calibum = 0.346; % [um/pixel]
% width = 1024;
% height = 768;
% bead_dia_um = 24;
% bead_dia_pix = bead_dia_um / calibum;
% bead_radius_pixels = bead_dia_pix / 2;
% 
% % Explain why
% disk_element_radius = floor(bead_radius_pix * 0.9);
% 
% SE = strel('disk', disk_element_radius);
% 
% search_radius_low  = floor(bead_radius_pixels * 0.4);
% search_radius_high =  ceil(bead_radius_pixels * 0.8);
% 

% imfcenters is the outputted locations in x,y of the circle centers.
[imfcenters, imfradii] = imfindcircles(firstframe, ...
                                       [search_radius_low, search_radius_high], ...
                                       'ObjectPolarity', 'bright', ...
                                       'Sensitivity', 0.92);

% [imlcenters, imlradii] = imfindcircles(lastframe, ...
%                                        [search_radius_low, search_radius_high], ...
%                                        'ObjectPolarity', 'bright', ...
%                                        'Sensitivity', 0.92);

first_bead_im = extract_bead_images(imfcenters, imfradii, firstframe, 'n');
last_bead_im = extract_bead_images(imfcenters, imfradii, lastframe, 'n');

first_maxintens = cell2mat(cellfun(@(x) max(x(:)),first_bead_im, 'UniformOutput', false));
last_maxintens = cell2mat(cellfun(@(x) max(x(:)),last_bead_im, 'UniformOutput', false));

outs.Fid = repmat(Fid, size(imfradii));
outs.BeadPosition = imfcenters;
outs.BeadRadius = imfradii;
outs.FirstImage= first_bead_im;
outs.LastImage = last_bead_im;
outs.FirstImageMax = first_maxintens;
outs.LastImageMax = last_maxintens;

outs = struct2table(outs);

end


function stack = extract_bead_images(beadcenters, beadradii, im, reportyn)

    if nargin < 4 || isempty(reportyn)
        reportyn = 'n';
    end

    if nargin < 3 || isempty(beadradii)
        beadradii = 15; % pixels
    end

    if nargin < 2
        error('Not enough inputs.');
    end

    if nargin < 1 || isempty(beadcenters)
       stack = [];
    end

    % check that we have only one frame in the data
    if isempty(beadcenters)
        error('No data.');
    end

    Nbeads = size(beadcenters, 1);

    width = size(im, 2);
    height = size(im, 1);


    stack = cell(Nbeads,1);

    r = floor(max(beadradii)*sqrt(2));
    tfs = 2*r;    

    for k = 1:Nbeads

        % extract x and y locations
        x = round(beadcenters(k, 1));
        y = round(beadcenters(k, 2));


        % determine boundaries for mini_image
        xmin = x - r;
        xmax = x + r;
        ymin = y - r;
        ymax = y + r;

        % determine boundaries in full inputted image
        if xmin <= 0
            x_under = abs(xmin)+1;
            x1_im = 1;
        else
            x_under = 0;
            x1_im = xmin;
        end

        if xmax > width
            x_over = xmax - width;
            x2_im = width;
        else
            x_over = 0;
            x2_im = xmax;
        end

        if ymin <= 0
            y_under = abs(ymin)+1;        
            y1_im = 1;
        else
            y_under = 0;
            y1_im = ymin;
        end    

        if ymax > height
            y_over = ymax - height;
            y2_im = height;
        else        
            y_over = 0;
            y2_im = ymax;
        end

        % switch from x,y of cartesian coords to matrix/pixel row,col location
        row1 = y1_im;
        row2 = y2_im-1;
        col1 = x1_im;
        col2 = x2_im-1;

        % extract the temporary matrix that describes what bit of image exist for
        % this particular trackerID
        tmp_im = im(row1:row2, col1:col2);

        % switch from x,y of cartesian coords to matrix/pixel row,col location
        row1 = 1+y_under;
        row2 = tfs-y_over;
        col1 = 1+x_under;
        col2 = tfs-x_over;    

        % set the default value in the mini-image to be the mean of the entire
        % available mini-image (sets unavailable pixels/edges to average value)
        mini_im = ones(tfs, tfs) * mean(tmp_im(:));    

        % convert tmp matrix into full-sized mini-image
        mini_im(row1:row2, col1:col2) = tmp_im;

        % put mini-image into proper location in outputted stack
        stack{k,1} = mini_im;

%         % calculate the cross-sectional area of the tracker and add it to the
%         % outputted data. I don't know a better place to put this at the moment    
%         scaled_tmp_im = tmp_im / max(tmp_im(:)) * 255;  % scale images to be 255 max
%         px_above_thresh = scaled_tmp_im > (255 * 0.5);  % assuming full 'width' at half max
%         newarea(k,1) = sum(px_above_thresh(:));

    end


end
