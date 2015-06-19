function plot_bead_image_stacks(bead_stacks)

tracker_halfsize = bead_stacks.halfsize;
bead_image_size = 2 * tracker_halfsize;

Nstacks = length(bead_stacks);

max_bead_count = 0; 
for k = 1:Nstacks; 
    tmp = size(bead_stacks(k).vid_table,1);
    if tmp > max_bead_count
        max_bead_count = tmp; 
    end; 
end;

big_im = ones(Nstacks * bead_image_size, max_bead_count * bead_image_size)*128;
big_im = uint8(big_im);

for k = 1:Nstacks
    imstack = bead_stacks(k).stack;
    imlist  = bead_stacks(k).vid_table;
    
    q = reshape(imstack, bead_image_size, bead_image_size*size(imlist,1));
    
    rows_to_add_to_image = [1:bead_image_size]+k*bead_image_size-bead_image_size;
    big_im(rows_to_add_to_image , 1:size(q,2) ) = q;
end

f = figure;

figure(f);
imagesc(big_im);
colormap(gray(256));

% panel1 = uipanel('Parent',f);
% panel2 = uipanel('Parent',panel1);
% set(panel1,'Position',[0 0 0.95 1]);
% set(panel2,'Position',[0 -1 1 2]);
% h = image;
% set(gca,'Parent',panel2);
% s = uicontrol('Style','Slider','Parent',1,...
%       'Units','normalized','Position',[0.95 0 0.05 1],...
%       'Value',1,'Callback',{@slider_callback1,panel2});
%   
% return;
% 
% function slider_callback1(src,eventdata,arg1)
%     val = get(src,'Value');
%     set(arg1,'Position',[0 -val 1 2])  
%     
%     return;
    