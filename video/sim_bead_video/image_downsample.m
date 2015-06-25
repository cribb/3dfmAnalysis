function final = image_downsample(image,scale)
%Downsample an image by averaging the values of scale by scale sections of
%the matrix
%
%could also use imresize if this does not work well
%
%Inputs
%   -image is the matrix you want to downsample
%   -scale is the number by which you want to scale each dimension of the
%   image

imsize = size(image);

overallscale = scale^2;
new_r = imsize(1)/scale;
new_c = imsize(2)/scale;

%logentry(['overall scaling factor is ' num2str(overallscale)]);
%logentry(['new image has ' num2str(new_r) ' rows']);
%logentry(['new image has ' num2str(new_c) ' columns']);

A = reshape(image,scale,new_r,scale,new_c);
B = sum(A,3);
C = sum(B,1);
D = C/overallscale;

final = reshape(D,new_r,new_c);
final = uint8(final);

end