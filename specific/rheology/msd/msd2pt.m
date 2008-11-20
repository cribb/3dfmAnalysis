function d = msd2pt(filename,win);
% MSD2PT calculates the two particle correlation function
%
% 3DFM function
% specific\rheology\msd
% last modified 11/20/08 (krisford)
%  
%
% function d = msd2pt(filename);
%   filename is a *.dat file that has previously been created from
%   load_video tracking to only contain t, x, and y data
%   **  note, for this program to work, the data must have been loaded using
%       the absolute position setting!!!!!!
%
% outputs:  dr == the bead coordnate displacement vs tau info
%           dr_cross == the time averaged cross terms of each dr term, x.x
%           and y.y


%filename = 'data_txy.dat'
M = load(filename);

% transpose the matrix

M_data_raw = M';

% define the number of frames and the fps based on the 1st column

N_frames = length(M_data_raw(1,:));

N_samples = (length(M_data_raw(:,1))-1)/2

if N_samples == 1
    return;% safety to make sure that I don't calculate anything I don't need!
end

fps = 1/mean(diff(M_data_raw(1,:)))

% now it is time to get ride of the zero's 

dumby = 1;% dumby index to keep track of where I am in the data set
bad_one = 0;
for k = 1:length(M_data_raw(:,1)),
    if k ==1,
        M_data(dumby,:) = M_data_raw(k,:);
        dumby = dumby+1;
    elseif M_data_raw(k,1) == 0;
       statement = 'bad_one'
       bad_one = bad_one + 1
    else
        M_data(dumby,:) = M_data_raw(k,:);
        dumby = dumby + 1;
    end
end
        
N_samples = (length(M_data(:,1))-1)/2;


%convert = 10^(-6); %lets leave everything in micros for now

% now I can calculate the MSD just have I have done in other programs....

% define the window over which to calculate the MSD's

if win == 2,
    window = [1 2 5 10 30 50 100 200];
else
    window = [1 2 5 10 30 50 100 200 500 1000];
end
size_window = length(window);

% create the r window that will be used to seporate the beads based on the
% initial distance between them

%r_window = convert*[1 2 5 10 20 50]
r_window = [1 2 5 10 20 50 100];
size_r_window = length(r_window);


% fill array with the bead distances

k = 1; % dumby index to count thru the bead interactaions
for i = 1:N_samples-1
    for j = i+1:N_samples
        Rij(k) = sqrt((M_data(i+1,1) - M_data(j+1,1))^2 + (M_data(N_samples+i+1,1) - M_data(N_samples+j+1,1))^2);
        k = k+1;
    end
end
N_bead_dist_1 = k-1;
%clear i,j,k;
% calculate the delta_coords
for i = 1:N_samples*2;
    for j = 1:size_window;
        
        for k = 1:N_frames-window(j)
            
            dr(i,j,k) = M_data(i+1,window(j) + k) - M_data(i+1,k);
                        
        end
        
    end
end

% now it's time to calculate the cross terms, not really worring about any
% zeros just yet
k = 1
for i = 1:N_samples-1
    for j = i+1:N_samples
        
        dr_cross.x(k,:,:) = dr(i,:,:).*dr(j,:,:); % x cross terms
        dr_cross.y(k,:,:) = dr(i+N_samples,:,:).*dr(j+N_samples,:,:); % y cross terms
        k = k+1
    end
end

N_bead_dist_2 = k-1;

% need to compute the time averages of the dr_cross terms
% it is important to divide by the correct number, as each tau has a
% different number of terms

for i = 1:N_bead_dist_2
    for j = 1:size_window
        
        dr_cross_tave.x(i,j) = sum(dr_cross.x(i,j,:))/(N_frames - window(j)-1);
        dr_cross_tave.y(i,j) = sum(dr_cross.y(i,j,:))/(N_frames - window(j)-1);
    
    end
end


% now all I need to do is combine the two pieces and make sure that I
% believe the results, i might also want to not combine data until I am at
% the very end. Good day's codeing, I'm happy!



% putting a lot of stuff into d at the moment, it's kind of fun...
d.N_samples = N_samples;
d.Rij = Rij;
d.dr = dr;
d.dr_cross = dr_cross;
d.dr_cross_tave = dr_cross_tave;
d.tau = window/fps;
d.rw = r_window

% combine the time averaged cross terms into one matrix to save
% create something to save

data_out = zeros(N_bead_dist_2*2+1,size_window+1);
data_out(2:N_bead_dist_2+1,1) = Rij(:);
data_out(N_bead_dist_2+2:end,1) = Rij(:);
data_out(1,2:end) = d.tau;
data_out(2:N_bead_dist_2+1,2:end) = dr_cross_tave.x;
data_out(N_bead_dist_2+2:end,2:end) = dr_cross_tave.y;

%data_out;
%filename_out = strcat(filename,'msd2pt.txt');
%save('filename_out','data_out','-ASCII');
d.data_out = data_out;

% bin and sum the data based on Rij values

data_out_binned = zeros(size_r_window+1, size_window+2);
data_out_binned(1,2:size_window+1) = d.tau;
data_out_binned(2:end,1) = r_window';

for n = 2:size(data_out(:,2)),
    
    if data_out(n,1) <= window(1)
        
        data_out_binned(2,2:size_window+1) = data_out_binned(2,2:size_window+1) + data_out(n,2:size_window+1);
        data_out_binned(2,size_window+2) = data_out_binned(2,size_window+2) +1;
        
    elseif data_out(n,1) <= window(2)
        
        data_out_binned(3,2:size_window+1) = data_out_binned(3,2:size_window+1) + data_out(n,2:size_window+1);
        data_out_binned(3,size_window+2) = data_out_binned(3,size_window+2) +1;
        
    elseif data_out(n,1) <= window(3)
        
        data_out_binned(4,2:size_window+1) = data_out_binned(4,2:size_window+1) + data_out(n,2:size_window+1);
        data_out_binned(4,size_window+2) = data_out_binned(4,size_window+2) +1;
        
    elseif data_out(n,1) <= window(4)
        
        data_out_binned(5,2:size_window+1) = data_out_binned(5,2:size_window+1) + data_out(n,2:size_window+1);
        data_out_binned(5,size_window+2) = data_out_binned(5,size_window+2) +1;
        
    elseif data_out(n,1) <= window(5)
        data_out_binned(6,2:size_window+1) = data_out_binned(6,2:size_window+1) + data_out(n,2:size_window+1);
        data_out_binned(6,size_window+2) = data_out_binned(6,size_window+2) +1;
        
    else
        
        data_out_binned(7,2:size_window+1) = data_out_binned(7,2:size_window+1) + data_out(n,2:size_window+1);
        data_out_binned(7,size_window+2) = data_out_binned(7,size_window+2) +1;
    
    end
end

d.binned = data_out_binned;
