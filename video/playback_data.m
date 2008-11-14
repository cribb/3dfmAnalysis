function playback_data(coords, fps, movfile)
% PLAYBACK_DATA plots 2D/3D data at a given framerate and outputs to an AVI
%
% 3DFM function  
% Video 
% last modified 2008.11.14 (jcribb) 
%  
% This function will create an AVI file that plays back a 2D or 3D
% dataset at a desired framerate.  There is no filtering or resampling
% of the input; it is assumed that such operations are already done.
%  
%  playback_data(coords, fps, movfile);  
%   
%  where "coords" contains the data for plotting (2D or 3D).
%        "fps"  is frames per second for the output AVI.
%        "movfile" is the filename for the output AVI.
%   

% coords should be an n x 2 or n x 3 matrix, oriented as [x y z]
% all resampling, etc, is assumed to have been done before this
% function is called
[rows cols] = size(coords);
if cols > rows
    coords = coords';
    [rows cols] = size(coords);
end

switch cols
    case 2       
		x = coords(:,1);
		y = coords(:,2); 
    case 3
		x = coords(:,1);
		y = coords(:,2);         
		z = coords(:,3);
    otherwise
        error(['playback_data: Method for plotting ' num2str(cols) '-D data is unknown.']);
    end

[timefig,timetext] = init_timerfig;
    
fig = figure;
set(fig,'DoubleBuffer','on');
set(fig,'Renderer','zbuffer',...
        'Resize',  'on');
    
mov = avifile(movfile,'compression','none','fps',fps);

for k = 1:rows;
	tic;
        
        switch cols
            case 2
                plot(x(1:k), y(1:k), 'r');
                xlabel('X');
                ylabel('Y'); 
				axis([min(x) max(x) min(y) max(y)]);    
                
            case 3
                plot3(x(1:k), y(1:k), z(1:k), 'r');
                xlabel('X');
                ylabel('Y'); 
                zlabel('Z');    
				axis([min(x) max(x) min(y) max(y) min(z) max(z)]);                    
        end
        
     	axis square;
		grid on;
		pretty_plot;
        drawnow;
          
    F = getframe(fig);
    mov = addframe(mov,F);
    
    % reporting time left
    itertime = toc;
    if k == 1
        totaltime = itertime;
    else
        totaltime = totaltime + itertime;
    end    
    meantime = totaltime / k;
    timeleft = (rows-k) * meantime;
    outs = [num2str(timeleft, '%5.0f') ' sec.'];
    set(timetext, 'String', outs);
end


mov = close(mov);

close(fig);
close(timefig);

