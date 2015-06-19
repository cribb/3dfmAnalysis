function h = plot_tracker_images(tracker_stack, sort_by)

if nargin < 2 || isempty(sort_by)
    sort_by = 'id';
end

sorted_stack = sort_tracker_images(tracker_stack, sort_by);

fullsize = 2 * sorted_stack.halfsize;
N = size(sorted_stack.vid_table, 1);

% scale images to be 255 max
for k = 1:length(tracker_stack.stack)
    tmp_im = sorted_stack.stack(:,:,k);
    tmp_im = tmp_im / max(tmp_im(:)) * 255;
    sorted_stack.stack(:,:,k) = tmp_im;
end

% [IM_ROWS IM_COLUMNS IMAGE_COUNT] reshaped to [IM_ROWS IM_COLUMNS*N_images]
bead_strip_image = reshape(sorted_stack.stack, fullsize, N*fullsize);

centered_locations_in_x = [fullsize/2:fullsize:(N*fullsize)-fullsize/2]+1;
tick_values_for_x = round(sorted_stack.sorted_vals, 1);

h = figure; 

figure(h);
    h1 = subplot(2,1,1); 
    imagesc(bead_strip_image); 
    colormap(gray(256)); 
    xlim([0 N*fullsize]);
    set(gca, 'XTick', centered_locations_in_x);
    set(gca, 'XTicklabel', tick_values_for_x);
    xlabel(sort_by);
    set(gca, 'YTick', []);
    
figure(h);
    h2 = subplot(2,1,2); 
    plot(sorted_stack.sorted_vals, '.-');
    xlabel('Index');
    ylabel(sorted_stack.sort_by);


    
N_sheet_row_tiles = ceil(sqrt(N * 3/4));
N_sheet_rows = N_sheet_row_tiles * fullsize;
N_sheet_col_tiles = ceil(4/3 * N_sheet_row_tiles);
N_sheet_cols = N_sheet_col_tiles * fullsize;


bead_sheet = uint8(ones(N_sheet_rows, N_sheet_cols) * 128);

for k = 1:N_sheet_row_tiles-1
     rows_to_add_to_image = [1:fullsize]+k*fullsize-fullsize;
     cols_to_add_to_image = [1:N_sheet_cols]+k*N_sheet_cols-N_sheet_cols;
     
     % handle the end/edge case where the number of bead images is shorter
     % than a full row.
     idx = ( cols_to_add_to_image <= size(bead_strip_image,2) );
     cols_to_add_to_image = cols_to_add_to_image(idx);
     
     bead_sheet(rows_to_add_to_image, 1:length(cols_to_add_to_image)) = bead_strip_image(1:fullsize, cols_to_add_to_image);
end

centered_locations_in_x = [fullsize/2:fullsize:(N_sheet_cols)-fullsize/2]+1;
centered_locations_in_x = centered_locations_in_x(5:5:end);
tick_values_for_x = [1:length(centered_locations_in_x)]*5;
centered_locations_in_y = [fullsize/2:fullsize:(N_sheet_rows)-fullsize/2]+1;
tick_values_for_y = round(sorted_stack.sorted_vals(1:N_sheet_row_tiles+1:end),1);
    
f = figure;
figure(f);
imagesc(bead_sheet);
title([sort_by ' (scaled)']);
colormap(gray(256));
    xlim([0 N_sheet_cols]);
    set(gca, 'XTick', centered_locations_in_x);
    set(gca, 'XTicklabel', tick_values_for_x);
    ylim([0 N_sheet_rows]);
    set(gca, 'YTick', centered_locations_in_y);
    set(gca, 'YTickLabel', tick_values_for_y);
    ylabel([sort_by ' in first column']);
drawnow;

h = 0;

% set(h, 'Units', 'Normalized');

% scrollsubplot(30*6, 1:30*2240, h1, h2);


% pos = get(h, 'Position');
% pos(1) = 0.1;
% pos(2) = 0.1;
% pos(4) = 3 * (pos(3) / length(tlist));
% set(h, 'Position', pos);



