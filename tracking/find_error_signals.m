function [ sense_data ] = find_error_signals(ground_truth,sense_dir,thresh_dir)
%Find Error Signals
%explain yourself

if nargin < 2
    error('Need two tracking files for comparison');
end

if isempty(ground_truth)
    error('Need ground truth simulation file for comparison')
end

if isempty(sense_dir)
    error('Need directory of test parameter files to compare')
    
end 
%metadata checks?
%load metadata? 

folder=sense_dir;
filelist=dir([sense_dir '\*.mat']);
num_files=length(filelist);
for i=1:num_files
    filename=filelist(i).name;
    filepath=fullfile(folder,filename);
    
    sense_data(i)=compare_tracking(ground_truth,filepath,5);
    meanABstdXsense(i)= mean(sense_data(i).stdABdiffXY(:,1));
    meanABstdYsense(i)= mean(sense_data(i).stdABdiffXY(:,2));
    num_Asense(i)=sense_data(i).num_A_only;
    num_Bsense(i)=sense_data(i).num_B_only;
end



folder=thresh_dir;
filelist=dir([thresh_dir '\*.mat']);
num_files=length(filelist);
for i=1:num_files
    filename=filelist(i).name;
    filepath=fullfile(folder,filename);
    
    thresh_data(i)=compare_tracking(ground_truth,filepath,5);
    meanABstdXthresh(i)=mean(thresh_data(i).stdABdiffXY(:,1));
    meanABstdYthresh(i)=mean(thresh_data(i).stdABdiffXY(:,2));
    num_Athresh(i)=thresh_data(i).num_A_only;
    num_Bthresh(i)=thresh_data(i).num_B_only;
end




%threshold plots
threshold=[.1,.2,.3,.4,.5,.6,.7];

subplot(2,3,1);
plot(threshold,meanABstdXthresh,threshold,meanABstdYthresh);
 title('Mean of Standard Deviation vs Threshold');
xlabel('Threshold');
ylabel('MeanABXYStdDev');

subplot(2,3,2);
plot(threshold,num_Athresh)
title('Number of Unidentified Trackers vs Threshold');
xlabel('Threshold');
ylabel('Number Unidentified Trackers');


subplot(2,3,3);
plot(threshold,num_Bthresh)
title('Number of extraneous Trackers vs Treshold');
xlabel('Threshold');
ylabel('Number Extraneous Trackers');

%sensitivity plots

sensitivity= [.05,.1,.15,.2,.25];

subplot(2,3,4);
plot(sensitivity,meanABstdXsense,sensitivity,meanABstdYsense);
 title('Mean of Standard Deviation vs Sensitivity');
xlabel('Sensitivity');
ylabel('MeanABXYStdDev');

subplot(2,3,5);
plot(sensitivity,num_Asense)
title('Number of Unidentified Trackers vs Sensitivity');
xlabel('Sensitivity');
ylabel('Number Unidentified Trackers');


subplot(2,3,6);
plot(sensitivity,num_Bsense)
title('Number of extraneous Trackers vs Sensitivity');
xlabel('Sensitivity');
ylabel('Number Extraneous Trackers');
