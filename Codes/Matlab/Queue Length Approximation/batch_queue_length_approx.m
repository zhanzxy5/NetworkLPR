%% Batch estimation code for queue length approximation
clear;clc;
fpath = 'C:/Temp/Dropbox/China Camera Data/Network LPR/Matlab/Queue length approximation/QL_data/';
% fpath = 'D:/Dropbox/China Camera Data/Network LPR/Matlab/Queue length approximation/QL_data/';
start_hour = 7;
end_hour = 20;

dates = {'11', '12', '14', '15', '16', '17'};
intersectionIDs = {'1310000001', '1310000002', '1310000007', ...
                   '1310000034', '1310000056', '1310000068'};
% Link data: 1- ID, 2- dir, 3- downInt main dir
link_data =[11, 4, 1;
            12, 2, 1;
            25, 2, 2;
            26, 4, 2;
            28, 4, 1;
            29, 2, 2;
            31, 2, 1;
            93, 3, 1;
            94, 1, 1;
            95, 3, 1;
            103, 1, 1];
% Downstream intersection for the link
link_downInt = {'1310000068', '1310000001', '1310000056', '1310000007', ...
                '1310000034', '1310000007', '1310000034', '1310000002', ...
                '1310000001', '1310000034', '1310000068'};

% % For specific links
link_data = [18, 4, 1;
             21, 2, 1;
             81, 3, 2;
             96, 1, 1];
link_downInt = {'1310000002', '1310000002', '1310000007', '1310000002'};

%% main inference

for i = 1:length(link_data(:,1));
    for j = 1:length(dates)
        date = dates{j};
        linkID = link_data(i,1);
        linkDir = link_data(i,2);
        downIntMainDir = link_data(i,3);
        downstreamInt = link_downInt{i};
        
        
        saveFileName_prefix = strcat(fpath, date,'_',linkID,'_');
        
        [QL_data, Nlanes] = queue_length_approx(date, linkDir, downstreamInt, downIntMainDir, start_hour, end_hour);
        
%         % Saving output
%         saveFileName = strcat(fpath, date, '_', int2str(linkID), '_', int2str(Nlanes),'.csv');
%         dlmwrite(saveFileName, QL_data, ',');
    end
end
