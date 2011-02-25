function [] = power_law_fitting(Time,Creep,Force);

% Input Variables
%     Time: Time data
%     Creep: Creep data
%     Force: Force data

% Selecting only the rise of the creep data
AvgF = mean(Force);
J = Creep(Force>AvgF);
t = Time(Force>AvgF);
F = Force(Force>AvgF);

% Removing zeros so log doesn't blow up
F = F(J~=0);
t = t(J~=0);
J = J(J~=0);

