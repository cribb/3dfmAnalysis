function outv = pole_locator(filename, MIPfile, plot_results, h);
% 3DFM function  
% Magnetics
% last modified 11/09/07 
%  
% Locates poletip via intersection of tracker paths.
%  
%    outv = pole_locator(filename, MIPfile, plot_results, h);
% 
%     'filename' is the .evt.mat file containing the bead tracks OR the tabulated
%                output of load_video_tracking.
%     'MIPfile' is the filename of the MIP image OR the image itself.
%     'plot_results' is 'y' or 'n'
%     'h' is the figure handle.
%

if nargin < 4 || isempty(h)
    h = figure;
end

if nargin < 3 || isempty(plot_results)
    plot_results = 'y';
end

if nargin < 2 || isempty(MIPfile)
    logentry('No MIP file defined.');  
    MIPsuccess = 0;
elseif isnumeric(MIPfile)
    im = MIPfile;
    MIPsuccess = 1;
else
    % try loading the MIP file
    try 
        im = imread(MIPfile, 'BMP');
        logentry('Successfully loaded MIP image...');
        MIPsuccess = 1;
    catch
        logentry('MIP file was not found.'); 
        MIPsuccess = 0;
    end
end

if nargin < 1 || isempty(filename)
    logentry('No input file defined. Exiting now.');
    outv = [];
    return;
end

if ~isnumeric(filename)
    % load the datafile
    logentry('Loading dataset... ');
    try
        data = load_video_tracking(filename, [], [], [], 'absolute', 'yes', 'table');
    catch
        msgbox('File Not Found!', 'Error.');
        return;
    end
    logentry(['Dataset, ' filename ', successfully loaded...']);
else
    data = filename;
end

   video_tracking_constants; 

    % assign data variables
    table = sortrows(data,ID);
    beadID = table(:,ID);
    x = table(:,X);
    y = table(:,Y);
    
    % beginning of plot routine 
    plot_results = strncmpi(plot_results, 'y', 1);
    
    if plot_results
        % Display MIP
        figure(h);
        if MIPsuccess
            imagesc(1:648, 1:484, im);
            colormap(gray(256));
        end        
    end
    
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
                
                if plot_results
                figure(h);
                    hold on;
                        plot(x(idx_min:idx_max),y(idx_min:idx_max),'r',x_fit,y_fit,'b')
                    hold off;
                end
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
  
  logentry(['Pole is located at x=' num2str(x_final) ', y=' num2str(y_final) ' pixels.']);
      
    if plot_results
        hold on;
            plot(x_final,y_final,'w*')
        hold off;
    end

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
