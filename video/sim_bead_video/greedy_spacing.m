function [allframepairs] = greedy_spacing(numpaths,frame_width,frame_height,num_frames)
%Can only be used for even number of spots, spots do not move
%if mod(numpaths,2) == 0 %even
    col_spots = numpaths;
    for a = 1:numpaths
        new_col = numpaths/a;
        if new_col < col_spots && new_col>a && round(new_col)==new_col
            col_spots = new_col;
        end
    end
    row_spots = numpaths/col_spots;
    
    space_x = frame_width/col_spots;
    space_y = frame_height/row_spots;
    
    %x = zeros(1, col_spots);
    x = zeros(col_spots,1);
    y = zeros(row_spots,1);
    
    for xpoints = 1:col_spots
        x(xpoints) = (space_x/2)+(space_x*(xpoints-1));
    end
    
    for ypoints = 1:row_spots
            y(ypoints) = (space_y/2)+(space_y*(ypoints-1));
    end
        
    %xcoordinates = repmat(x,row_spots,1);
    %ycoordinates = repmat(y,1,col_spots);
    [xcoords,ycoords] = meshgrid(x,y);
    pairs = [xcoords(:) ycoords(:)];
    
    allframepairs_1 = repmat(pairs,1,1,num_frames);
    
    allframepairs = permute(allframepairs_1,[3 2 1]);
    
end