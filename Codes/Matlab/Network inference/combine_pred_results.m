%% concatenate predicted results
breakIndex = 133;
% Load first part
load('smallP2_414_improve20_24_234_part1.mat');
results_mean1 = results_mean;
results_std1 = results_std;
load('smallP2_414_improve20_24_234_part2.mat');
results_mean = [results_mean1(1:breakIndex,:);results_mean(breakIndex+1:length(results_mean(:,1)),:)];
results_std = [results_std1(1:breakIndex,:);results_std(breakIndex+1:length(results_mean(:,1)),:)];