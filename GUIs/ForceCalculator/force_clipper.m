function [x,y,r, begin_clip, end_clip] = force_clipper(begin_clip, end_clip, x, y, r)


    d.video.x = x;
    d.video.y = y;
    d.video.r = r;

    
    num_columns = (size(d.video.x));
    num_columns = num_columns(1,2);
    


    



%If the user does not enter a beginning clip, (s)he is prompted to enter
%beginning and ending points based on plots that are brought up
if(length(begin_clip) == 0)
    
    
%Gets the clipping data from the user
fprintf('\nCurrently running the most recent version\n');
fprintf('\nThere are %d beads that have been tracked.\n',num_columns);    
fprintf('--------------------------------------------\n');    
    
    
for n = 1:num_columns
    figure(n);
    clf(n);
    
    plot(d.video.r(:,n));
    begin_clip(n) = input('Where do you want to clip the beginning of the data: ');
    end_clip(n) = input('Where do you want to clip the end of the data: ');
    fprintf('\n');
    
    close;  
end

end


%These values are saved for a particular data set
%(4Volt_120u_Above_Surface.vrpn.mat)
% begin_clip = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 15 1 17 17 1]'
% end_clip = [1 60 111 457 290 255 213 76 1 115 151 216 54 56 148 325 96 104 76 1]'

%(1-4volts_1sec.vrpn.mat)
%begin_clip = [1 1 95 98 100 93];
%end_clip = [1 1 395 808 1254 1153];

%(ThreeBeads.vrpn.mat)
%begin_clip = [62 120 190 1 1];
%end_clip = [454 645 546 1 1];

%(New3Beads.vrpn.mat)
%begin_clip = [88 72 88];
%end_clip = [479 589 444];


%This is an array where we store whether or not we're going clip a column
%(By 'clipping a column', I mean eliminating a bead.  Some of the tracking
%data is funky, so we can easily remove those individual tracks).
column_cut_index = zeros(num_columns,1);

begin_clip = begin_clip';
end_clip = end_clip';
%If we DO want to get rid of a particular bead, we set the value of the
%array at the particular index to 1
    for index = 1:num_columns        
        if(begin_clip(index)==end_clip(index))
            column_cut_index(index) = 1;  
        end
    end
    
    
%These loops go through every column that we're supposed to delete and deletes them    
    for index = num_columns:-1:1
        if(column_cut_index(index)==1)
            d.video.x = [d.video.x(:,1:index-1) d.video.x(:,index+1:end)];
            d.video.y = [d.video.y(:,1:index-1) d.video.y(:,index+1:end)];   
            d.video.r = [d.video.r(:,1:index-1) d.video.r(:,index+1:end)];
            
            begin_clip = [begin_clip(1:index-1) ; begin_clip(index+1:end)];
            end_clip = [end_clip(1:index-1) ; end_clip(index+1:end)];
        end 
    end
            

    
%Recalculates the number of columns once some have been deleted
num_columns = min(size(d.video.x));
num_rows = max(size(d.video.x));
    
%Clips the data based on the ending values.  Once the data is clipped, the
%final value is repeated (to fill out the matrix)
    for index = 1:num_columns 
            d.video.x(end_clip(index):end,index) = d.video.x(end_clip(index),index);
            d.video.y(end_clip(index):end,index) = d.video.y(end_clip(index),index);
            d.video.r(end_clip(index):end,index) = d.video.r(end_clip(index),index);
    end
        
    
%Clips the data based on the beginning values
    for index = 1:num_columns
        for rows = 1:(num_rows-begin_clip(index))
            d.video.x(rows,index) = d.video.x(begin_clip(index)+rows,index);
            d.video.y(rows,index) = d.video.y(begin_clip(index)+rows,index);
            d.video.r(rows,index) = d.video.r(begin_clip(index)+rows,index);        
        end
    end
    
    x = d.video.x;
    y = d.video.y;
    r = d.video.r;