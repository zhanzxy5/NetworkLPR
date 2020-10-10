%% Batch estimation code for signal timing inference
clear;clc;
fpath = 'C:/Temp/Dropbox/China Camera Data/Network LPR/Matlab/Cycle timing inference/TimingData/';
% fpath = 'D:/Dropbox/China Camera Data/Network LPR/Matlab/Cycle timing inference/TimingData/';
start_hour = 7;
end_hour = 8;

dates = {'11', '12', '14', '15', '16', '17'};
intersectionIDs = {'1310000001', '1310000002', '1310000007', '1310000012',...
                   '1310000034', '1310000053'};
intersectionIDs_1missing = {'1310000018', '1310000019', '1310000028', ...
                            '1310000056', '1310000068'};
intersectionIDs_2missing = {'1310000054', '1310000069'};

%% main inference
intList = {'1310000001'};%[intersectionIDs, intersectionIDs_1missing];
dates = {'11'};
for i = 1:length(intList);
    for j = 1:length(dates)
        date = dates{j};
        intersectionID = intList{i};
        tic;
        [bpara_data, main_dir] = SigTimeInference(date, intersectionID, start_hour, end_hour);
        toc;
%         % Saving output
%         saveFileName = strcat(fpath, date,'_',intersectionID,'_', int2str(main_dir),'.csv');
%         dlmwrite(saveFileName, bpara_data, ',');
    end
end

