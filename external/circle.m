function h = circle(x,y,r,linespec, fillspec)

if nargin < 5 || isempty(fillspec)
    fillspec = 'n';
end

hold on
th = 0:pi/256:2*pi;
xunit = r * cos(th) + x;
yunit = r * sin(th) + y;
h = plot(xunit, yunit,linespec);

if fillspec =='y'
    h = fill(xunit, yunit, linespec);
end
   
hold off
