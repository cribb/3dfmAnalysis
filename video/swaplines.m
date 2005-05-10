function imnew = swaplines(im);


 oddlines = [1:2:size(im,1)]';
 evenlines = [2:2:size(im,1)]';
 
 imODD = im(oddlines, :);
 imEVEN = im(evenlines, :);
 
 imnew = zeros(size(im));
 
 imnew(oddlines,:) = imEVEN;
 imnew(evenlines,:) = imODD;
 