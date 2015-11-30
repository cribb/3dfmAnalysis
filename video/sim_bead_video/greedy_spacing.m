function [allframes] = greedy_spacing(numpaths,frame_width,frame_height,numframes)

%if isprime???
if numpaths == 1

    x = frame_width/2;
    y = frame_height/2;
    
    [xcoords,ycoords] = meshgrid(x,y);
    pairs = [xcoords(:) ycoords(:)];

    allframes = repmat(pairs,1,1,numframes);
    allframes = permute(allframes,[3 2 1]);
return;

if mod(numpaths,2) == 0
    numcolumns = numpaths;
elseif mod(numpaths,2) == 1;
    numcolumns = numpaths-1;
end

for c = 1:numpaths
    change_c = numpaths/c;
    if change_c < numcolumns && change_c >= c && mod(numpaths,c) == 0
        numcolumns = change_c;
    end
end

numrows = numpaths/numcolumns;
% 
% if numrows_r > numrows
%     extra_spaces = mod(numpaths,numcolumns);
%     extra_spots = 0;
% elseif numrows_r < numrows 
%     extra_spots = mod(numpaths,numcolumns);
%     extra_spaces = 0;
% elseif numrows_r == numrows
%     extra_spots = 0;
%     extra_spaces = 0;
% end

x_spacing = frame_width/numcolumns;
y_spacing = frame_height/numrows;

x = zeros(numcolumns,1);
for xpoints = 1:numcolumns
    x(xpoints) = (x_spacing/2) + (x_spacing*(xpoints-1));
end


y = zeros(numrows,1);
for ypoints = 1:numrows
    y(ypoints) = (y_spacing/2) + (y_spacing*(ypoints-1));  
end

[xcoords,ycoords] = meshgrid(x,y);
pairs = [xcoords(:) ycoords(:)];

allframes = repmat(pairs,1,1,numframes);
allframes = permute(allframes,[3 2 1]);
    
end