
%%%mouser  return the X and Y location of the mouse crosshair after a left click. Also return button state. 
%%but=1 means ledt click
%%but=3 means right click
%%Nagi Hatoum 3/2/03
function [x,y,but]=mouser(height, width);


but = 0;
n=0;

while 1
    [xi,yi,but] = ginput(1);
   if (but==1 & xi <= width & yi <= height)
      n = n+1;
      x(n,1) = xi;
      y(n,1) = yi;
		break
   end
   
   if (xi <= width | yi <= height)
        error = 'You did not click on the image'   
    end
        
        
    if or(but==3,n==1);x=[];y=[];break;end
end

