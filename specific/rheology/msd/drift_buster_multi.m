% 3DFM function
% Rheology
% drift_buster_multi by DBH
% last modified 5-17-2004
%
% This function takes a set of position verse time data and subtracts any
% drift from the data
%
% inputs: Requires *.dat file containing bead time, x, and y data name
% *n.data, usually *position.dat
%
% outputs: Writes new *nodrift.dat file as well as a file with the drift
% coeffiecents (slope term of y = m*x + b) so that the amount of drift can
% be determined later
%
% DBH

clear all
close all

% create list with all position vs time bead data files written 

fu = dir('*.dat');

% determine the number of file with which need drift subtractions
num_files = size(fu);

% main operating loop which cycles through the individual files
for z = 1:num_files
    
    
    % load file into memory
    d = load(fu(z).name);
    
    % set time coordnate to same as perviously
    e(:,1) = d(:,1);
    
    endpt = length(d(1,:));

    % fit a line to each set and bust the drift
    for q = 2:endpt
        fit = polyfit(d(:,1),d(:,q),1);

        e(:,q) = d(:,q)-fit(1)*d(:,1)-fit(2);
        
    end
    
    



    % save the output

    filename_save = strcat(fu(z).name,'_nodrift.dat')
    save(filename_save,'e','-ascii');
    clear d;
    clear e;
    
end % end program and hope its all cool

