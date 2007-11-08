function outv = pole_locator(filename, MIPfile);
%     Syntax:
%     
%         function outv = locator(filename, MIPfile);
% 
%     filename is the .evt file
%     MIP is the MIP of the well
%     

    video_tracking_constants;
    
    % load the datafile
    logentry('Loading dataset... ');
    try
        data = load_video_tracking(filename, [], [], [], 'absolute', 'yes', 'table');
    catch
        msgbox('File Not Found!', 'Error.');
        return;
    end
    logentry(['Dataset, ' filename ', successfully loaded...']);
    
    % try loading the MIP file
    try 
        im = imread(MIPfile, 'BMP');
        logentry('Successfully loaded MIP image...');
    catch
        logentry('MIP file was not found.'); 
    end
    

    % assign data variables
    table = sortrows(data,ID);
    beadID = table(:,ID);
    x = table(:,X);
    y = table(:,Y);
    
    % Display MIP
    figure;
    imagesc(1:648, 1:484, im);
    colormap(gray(256));
    hold on
    
    % Plot polynomial fits to bead trajectories
    % Loop over beads
    ii=0;
    for i=0:max(beadID)
           % Find indicies of bead start and stop within beadID
           idx_min=find(beadID==i,1,'first');
           idx_max=find(beadID==i,1,'last');
           if idx_max-idx_min>40;  %Exclude beads w/<40 datapoints
               % polyfit last 40 datapoints
                ii=ii+1;
                [p,s]=polyfit(x(idx_max-40:idx_max),y(idx_max-40:idx_max),1);
                fits(ii,1:2)=p;
                x_fit=[1:600];
                y_fit=polyval(p,x_fit);
                plot(x(idx_min:idx_max),y(idx_min:idx_max),'r',x_fit,y_fit,'b')
           end
    end 
    min_dsum=10^8;
  
  %Find intersection point
  for i=0:2
   % Find to within 10 pixels
   if i==0
        minx=-1000;
        miny=-1000; 
        maxx=1000;
        maxy=1000;
        step=10;
   else
        %increase precision to original step / 10^i(max)
       minx=x_final-maxx/(2*10^i);
        miny=y_final-maxy/(2*10^i);
        maxx=x_final+maxx/(2*10^i);
        maxy=y_final+maxy/(2*10^i);
        step=step/(10^i);
   end
    % find intersection by minimizing orthogonal distance to fits
    for x0=minx:step:maxx;
        for y0=miny:step:maxy;
                dsum=0;
                for ii=1:length(fits)
                      m=fits(ii,1);
                      b=fits(ii,2);
                      x=0;
                      y=m*x+b;
                      x1=(x0+m*y0-m*b)/(1+m^2);
                      y1=m*x1+b;
                      d=sqrt((x0-x1)^2+(y0-y1)^2); 
                         dsum=d+dsum;
                end
                if dsum<min_dsum;
                    min_dsum=dsum;
                    x_final=x0;
                    y_final=y0;
                end
        end
    end
  end
    x_final
    y_final
    plot(x_final,y_final,'w*')
    
    outv = [x_final y_final];
    
function logentry(txt)
    logtime = clock;
    logtimetext = [ '(' num2str(logtime(1),  '%04i') '.' ...
                   num2str(logtime(2),        '%02i') '.' ...
                   num2str(logtime(3),        '%02i') ', ' ...
                   num2str(logtime(4),        '%02i') ':' ...
                   num2str(logtime(5),        '%02i') ':' ...
                   num2str(round(logtime(6)), '%02i') ') '];
               
     headertext = [logtimetext 'pole_locator: '];
     
     fprintf('%s%s\n', headertext, txt);
