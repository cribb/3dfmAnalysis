%TO AVOID DOING THE MIP EVERY TIME, DO THIS IN THE MAIN MATLAB WORKSPACE
%   g = mip('filename.raw',startindex,stopindex,1,'max');
%
%   such as: g = mip('8.raw',1100,1400,1,'max');

close all;

circleCenterX = 284;
circleCenterY = 192;

%Here, add a space seperated value... one for each circle
radius = [77 47];
startIndex = [498 53];
stopIndex = [395 418];

index = 0:.01:2*pi;

imagesc(g);colormap(gray);
hold on
for i = 1:length(radius)

    y = cos(index);
    x = sin(index);
    x = radius(i)*x + circleCenterX;
    y = radius(i)*y + circleCenterY;

    plot(x,y,'r');
    plot(x(startIndex(i)),y(startIndex(i)),'xr');
    plot(x(stopIndex(i)),y(stopIndex(i)),'xr');

    x1 = x(startIndex(i));
    y1 = y(startIndex(i));
    x2 = x(stopIndex(i));
    y2 = y(stopIndex(i));

    a = radius(i);
    b = sqrt((x1-x2)^2 + (y1-y2)^2);
    c = radius(i);


    ANGLE(i) = acos((a^2 + c^2 - b^2)/(2*a*c));
end

ANGLE