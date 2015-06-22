function [] = image_downsample(image_name,scale_c,scale_r)
%Downsample an image by averaging the values of scale_c by scale_r
%sections of the matrix
%
%could also use imresize if this does not work well
%
%Inputs
%   -image_name is the filename of the image you want to downsample
%   -scale_r is the number that you want to scale the rows down by (ie. if you
%   have a four row matrix and want a two row matrix you would input 2 as
%   scale_r
%   -scale_c is the number that you want to scale the columns down by

image = imread(image_name);
imsize = size(image);

overallscale = scale_r*scale_c;
new_r = imsize(1)/scale_r;
new_c = imsize(2)/scale_c;

logentry(['new rows: ' num2str(new_r)]);
logentry(['new columns: ' num2str(new_c)]);
logentry(['overall scale is ' num2str(overallscale)]);

A = reshape(image,scale_r,new_r,scale_c,new_c);
B = sum(A,3);
C = sum(B,1);
D = C/overallscale;

final = reshape(D,new_r,new_c);
final = uint8(final);

imwrite(final,image_name,'Tiff');

end