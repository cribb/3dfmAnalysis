function [ err_sig ] = find_error_signals(ground_truth,sense_dir,thresh_dir)
%Find Error Signals
%explain yourself

if nargin < 2
    error('Need two tracking files for comparison');
end

if isempty(ground_truth)
    error('Need ground truth simulation file for comparison')
end

if isempty(test_dir)
    error('Need directory of test parameter files to compare')
    
end 
%metadata checks?
%load metadata? 


filelist=dir(sense_dir);
num_files=length(filelist);
for i=1:num_files
    sense_data(i)=compare_tracking(ground_truth,filelist(i),1);
    

end

filelist=dir(thresh_dir);
num_files=length(filelist);
for i=1:num_files
    thresh_data(i)=compare_tracking(ground_truth,filelist(i),1);
end

%threshold plot

threshold=[.1,.2,.3,.4,.5,.6,.7];

figure;
subplot(2,3,1);
plot(thresh_data.meanABdiffXY,threshold);
title('Mean Difference vs Threshold');
xlabel('Threshold');
ylabel('MeanABXYDiff');

subplot(2,3,2);
plot(thresh_data.num_A_only,threshold)
title('Number of Unidentified Trackers vs Threshold');
xlabel('Threshold');
ylabel('Number Unidentified Trackers');


subplot(2,3,3);
plot(thresh_data.num_B_only,threshold)
title('Number of extraneous Trackers vs Threshold');
xlabel('Threshold');
ylabel('Number Extraneous Trackers');


% sensitivity plot


sensitivity= [.05,.1,.15,.2,.25];

subplot(2,3,4);
plot(sense_data.meanABdiffXY,sensitivity);
title('Mean Difference vs Sensitivity');
xlabel('Sensitivity');
ylabel('MeanABXYDiff');

subplot(2,3,5);
plot(sense_data.num_A_only,sensitivity)
title('Number of Unidentified Trackers vs Sensitivity');
xlabel('Sensitivity');
ylabel('Number Unidentified Trackers');


subplot(2,3,6);
plot(sense_data.num_B_only,sensitivity)
title('Number of extraneous Trackers vs Sensitivity');
xlabel('Sensitivity');
ylabel('Number Extraneous Trackers');
