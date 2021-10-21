% This code exemplifies the usage of superviolin.m
% superviolin.m has to be on your MATLAB path or in the current folder
% by Ingmar Schoen, RCSI (c) 2021

% simulate test data
% you can make changes to nrep or ndata to see effect of numbers of
% biological and technical replicates on the plots
nrep = 5; % number of replicates
ndata = round(random('Uniform',50,100,[1 nrep])); % number of data points per replicate
% means of replicates
mu0 = 10.;  % mean of normal distribution
sigma0 = 1.5; % std of normal distribution
replicate_means = normrnd(mu0,sigma0,[1 nrep]);
% standard deviationa of replicates
mu1 = 2.;  % mean of normal distribution
sigma1 = 0.5; % std of normal distribution
replicate_std = normrnd(mu1,sigma1,[1 nrep]);
% create cell array with data points of replicates
testdata = {};
for i=1:nrep
    testdata{i} = normrnd(replicate_means(i),replicate_std(i),[1 ndata(i)]);
end

% create plot
figure;
clf
superviolin(testdata);
ylim([0 20])
xlim([0 2])


% % example usage of optional parameters to customize plot
h=figure;
clf
set(h,'Position',[100 100 1200 400])
ax=gca;
superviolin(testdata,'Parent',ax,'Xposition',1);
superviolin(testdata,'Parent',ax,'Xposition',2,'Width',0.3);
superviolin(testdata,'Parent',ax,'Xposition',3,'FaceAlpha',0.35);
superviolin(testdata,'Parent',ax,'Xposition',4,'LUT','jet');
superviolin(testdata,'Parent',ax,'Xposition',5,'Centrals','robustmean');
superviolin(testdata,'Parent',ax,'Xposition',6,'Errorbars','ci');
superviolin(testdata,'Parent',ax,'Xposition',7,'Bandwidth',0.07);
superviolin(testdata,'Parent',ax,'Xposition',8,'LineWidth',0.1);
ylim([0 20])
xlim([0 9])

