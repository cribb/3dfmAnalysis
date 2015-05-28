function [ r_values, r_image, b_image] = corrTestOnPixels( A, window_height, window_width, dim1, dim2 )
% this function tests the correlation of every pixel over nearby pixels. 
% the plot of p-values from tests on all pixels are plotted.
% inputs: 
%        A: each column of A contains one pixel intensity values over time
%        window_height: the neighboring window's height
%        window_width: the neighboring window's width
%        dim1: the height of the video frame
%        dim2: the width of the video frame 
 
% current approach in computing the correlation:
%     use the built-in function corrcoef() 
% for two vectors, it will return a 2x2 matrix that has diaglonal entries 1
% the other two entries are the R values for the correlation between these
% two vectors.

r_values = zeros(1,size(A,2));
% for every column, compute the neighbor's index in columns of A. And
% compute the r values and sum up.
for i = 1 : size(A,2)
    curr_pixel = A(:,i);
    r_lst = [];
    neighbor_indices = returnNeighborIndices(i, window_height, window_width, dim1, dim2); 
    for ind = neighbor_indices
        corr_mat = corrcoef(curr_pixel, A(:,ind));
        curr_r = corr_mat(2);
        r_lst = [r_lst, abs(curr_r)];
    end
    r_values(i) = max(r_lst);
end

% plot the r_values
r_image = reshape(r_values,dim2,dim1)';
r_image_scale = r_image .* 255.0 ;
imagesc(r_image_scale);
colormap('hot');
colorbar;
caxis([0 255.0]);
truesize;
b_image = (r_image_scale > 255.0*0.9) * 255.0;


end

