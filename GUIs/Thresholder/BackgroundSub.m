function g = BackgroundSub(file)


close all
I = imread(file);

I = ~I;


background = imopen(I,strel('disk',10));


figure(3); surf(double(background(1:8:end,1:8:end))),zlim([0 255]);
set(gca,'ydir','reverse');

I2 = imsubtract(I,background); 


I3 = imadjust(I2, stretchlim(I2), [0 1]);



figure(6); 
subplot(2,2,1); imshow(I);  title('Original Image');
subplot(2,2,2); imshow(background);  title('Background');
subplot(2,2,3); imshow(I2);  title('Image minus Background');
subplot(2,2,4); imshow(I3);  title('Final Product');