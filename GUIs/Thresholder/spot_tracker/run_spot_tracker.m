function v = run_spot_tracker(file)
% function v = run_spot_tracker(file, xc, yc, rc)

mov = aviread(file);

figure(1);
imagesc(mov(1).cdata(:,:,1));
colormap(gray(256));

xc = input('X coordinate: ');
yc = input('Y coordinate: ');
rc = input('Approximate Radius in pixels: ');

x_start = xc;
y_start = yc;

figure(1);

for k = 1:length(mov)
    
    im = mov(k).cdata(:,:,1);
    imagesc(im);
    colormap(gray(256));
    
    hold on;
%    plot(x_start,y_start,'bx');

    [xc,yc,rc] = spot_tracker(im,xc,yc,rc,0);

    % fprintf(' x= %f   y= %f   r= %f  ',xc,yc,rc);
        
    plot(xc,yc,'r+');
    
    data(k,1) = xc;
    data(k,2) = yc;
    data(k,3) = rc;
    
%     plot(data(:,1),data(:,2),'b.');
    hold off;

    drawnow;
    
end

v = data;

