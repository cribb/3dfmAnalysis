function v = run_spot_tracker(file, xc, yc, rc)

mov = aviread(file);

x_start = xc;
y_start = yc;

figure(1);
fprintf('\n start here \n ------------ \n');

for k = 1:length(mov)
    
    im = mov(k).cdata(:,:,1);
    imagesc(im);
    colormap(gray(256));
    
    hold on;
    plot(x_start,y_start,'bx');

    [xc,yc,rc] = spot_tracker(im,xc,yc,rc);

    fprintf(' x= %f   y= %f   r= %f  ',xc,yc,rc);
        
    plot(xc,yc,'r+');
    
    data(k,1) = [xc yc rc];
    
    plot(data(:,1),data(:,2),'b.');
    hold off;

    drawnow;
    
end

v = data;

