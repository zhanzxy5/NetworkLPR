%% Analyze free flow travel time data for the links
clear;clc;
% fpath = 'C:/Temp/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/';
fpath = 'D:/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/';
start_hour = 7;
end_hour = 20;
% Mode 1: compute the overall link statistics
% Mode 2: draw histogram for normal links
% Mode 3: compute the pseudo link statistics
% Mode 4: draw histogram for pseudo links
mode = 1;
linkID = 14;

dates = {'11', '12', '14', '15', '16', '17'};
% Link data: 1- ID, 2- dir, 3- downInt main dir
link_data = [
5	1310000018	1310000012	1	4	503.25
6	1310000012	1310000018	1	2	496.66
11	1310000001	1310000068	1	4	613.88
12	1310000068	1310000001	1	2	629.88
15	1310000053	1310000019	1	2	492.51
24	1310000056	1310000054	1	4	551.61
25	1310000054	1310000056	1	2	578.94
26	1310000054	1310000007	1	4	524.77
27	1310000007	1310000054	1	2	534.71
28	1310000007	1310000034	1	4	623.5
29	1310000034	1310000007	1	2	618.11
30	1310000034	1310000028	1	4	682.35
55	1310000019	1310000018	1	1	734.1
57	1310000056	1310000019	1	1	528.99
66	1310000012	1310000053	1	3	706.35
67	1310000053	1310000012	1	1	699.84
93	1310000001	1310000002	1	3	657.68
94	1310000002	1310000001	1	1	644.24
95	1310000002	1310000034	1	3	701.31
96	1310000034	1310000002	1	1	715.69
103	1310000069	1310000068	1	1	640.93
104	1310000069	1310000028	1	3	725.82
105	1310000028	1310000069	1	1	740.43
];

% link data for pseudo links: 4th column is the path ID
pseudo_link_data = [
14	1310000019	1310000053  5	4	504.41
21	1310000069	1310000002  8	2	640.48
31	1310000028	1310000034  19	2	671.4
54	1310000018	1310000019  3	3	741.25
69	1310000054	1310000053  14	1	635.05
102	1310000068	1310000069  4	3	653.52
];

switch mode
    case 1
    %% compute for all the data
    % Create a data structure to store the free flow data
    % 1- linkID; 2- Average of the 97.5 percentile; 3- max speed for day 1; 
    % 4- 95 percentile speed for day 1;
    % 5- 97.5 percentile speed for day 1; 
    % 6- ... for other days
    FFdata = zeros(length(link_data(:,1)), 1 + 3 * length(dates));
    
    for i = 1:length(link_data(:,1))
        linkID = link_data(i,1);
        FFdata(i, 1) = linkID;
        sumFSD = 0;
        for j = 1:length(dates)
            date = dates{j};
            filename = strcat(fpath, date, '/LinkTT/', int2str(linkID), '.txt');
            delimiterIn = '\t';
            headerlinesIn = 1;
            rawData = importdata(filename,delimiterIn,headerlinesIn);
            TTdata = rawData.data;

            TT = (link_data(i,6) * ones(length(TTdata(:,1)),1)) ./ TTdata(:,3);
            MaxSpeed = max(TT);
            FFdata(i, j*3) = MaxSpeed;
            FFdata(i, j*3 + 1) = prctile(TT, 95);
            FFdata(i, j*3 + 2) = prctile(TT, 97.5);
            sumFSD = sumFSD + FFdata(i, j*3 + 2);
        end
        FFdata(i, 2) = sumFSD/j;
        fprintf('Processed Link %d\n', i);
    end
    case 2
       %% Draw Histogram
       % find the link ID
       for i = 1:length(link_data(:,1))
           if linkID == link_data(i,1)
               break;
           end
       end
       TT= [];
        for j = 1:length(dates)
            date = dates{j};
            filename = strcat(fpath, date, '/LinkTT/', int2str(linkID), '.txt');
            delimiterIn = '\t';
            headerlinesIn = 1;
            rawData = importdata(filename,delimiterIn,headerlinesIn);
            TTdata = rawData.data;

            TT = [TT;(link_data(i,6) * ones(length(TTdata(:,1)),1)) ./ TTdata(:,3)];
        end
        hist(TT, 50);
        fprintf('Processed Link %d\n', i);
    case 3
        %% For pseudo links
        % Create a data structure to store the free flow data
        % 1- linkID; 2- Average of the 97.5 percentile; 3- max speed for day 1; 
        % 4- 95 percentile speed for day 1;
        % 5- 97.5 percentile speed for day 1; 
        % 6- ... for other days
        FFdata = zeros(length(pseudo_link_data(:,1)), 1 + 3 * length(dates));
        
        for i = 1:length(pseudo_link_data(:,1))
            pathID = pseudo_link_data(i,4);
            FFdata(i, 1) = pseudo_link_data(i,1);
            sumFSD = 0;
            for j = 1:length(dates)
                date = dates{j};
                filename = strcat(fpath, date, '/PathTT/', int2str(pathID), '.txt');
                delimiterIn = '\t';
                headerlinesIn = 1;
                rawData = importdata(filename,delimiterIn,headerlinesIn);
                TTdata = rawData.data;

                TT = (pseudo_link_data(i,6) * ones(length(TTdata(:,1)),1)) ./ TTdata(:,3);
                MaxSpeed = max(TT);
                FFdata(i, j*3) = MaxSpeed;
                FFdata(i, j*3 + 1) = prctile(TT, 95);
                FFdata(i, j*3 + 2) = prctile(TT, 97.5);
                sumFSD = sumFSD + FFdata(i, j*3 + 2);
            end
            FFdata(i, 2) = sumFSD/j;
            fprintf('Processed Link %d\n', i);
        end
    case 4
        %% Draw Histogram for pseudo links
       % find the link ID
       for i = 1:length(pseudo_link_data(:,1))
           if linkID == pseudo_link_data(i,1)
               break;
           end
       end
       pathID = pseudo_link_data(i,4);
       TT= [];
        for j = 1:length(dates)
            date = dates{j};
            filename = strcat(fpath, date, '/PathTT/', int2str(pathID), '.txt');
            delimiterIn = '\t';
            headerlinesIn = 1;
            rawData = importdata(filename,delimiterIn,headerlinesIn);
            TTdata = rawData.data;

            TT = [TT;(pseudo_link_data(i,6) * ones(length(TTdata(:,1)),1)) ./ TTdata(:,3)];
        end
        hist(TT, 50);
        fprintf('Processed Link %d\n', i);
end
