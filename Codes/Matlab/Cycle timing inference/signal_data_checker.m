%% Signal data checker
clear;clc;
%% configurables
date = '11';
intersectionID = '1310000019';
% % Lane configurations: for through movement only

% filename = strcat('C:/Temp/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', intersectionID, '.txt');
filename = strcat('D:/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', intersectionID, '.txt');
delimiterIn = '\t';
headerlinesIn = 1;
rawData = importdata(filename,delimiterIn,headerlinesIn);
rawTimeData = rawData.data;



%% Data Extraction
intTimeData = zeros(length(rawTimeData(:,1)), 3);
intTimeData(:,1) = rawTimeData(:,1)*3600 + rawTimeData(:,2)*60 + rawTimeData(:,3);
intTimeData(:,2:3) = rawTimeData(:,4:5);

%% Data check: Plot raw data
tempData = intTimeData(intTimeData(:,2)==1,:);
plot(tempData(:,1)/3600, 1*ones(length(tempData(:,1)),1)+0.25*tempData(:,3), '.b');
hold on;
tempData = intTimeData(intTimeData(:,2)==2,:);
plot(tempData(:,1)/3600, 1*ones(length(tempData(:,1)),1)+0.25*tempData(:,3), '.r');
hold on;
tempData = intTimeData(intTimeData(:,2)==3,:);
plot(tempData(:,1)/3600, 1*ones(length(tempData(:,1)),1)+0.25*tempData(:,3), '.c');
hold on;
tempData = intTimeData(intTimeData(:,2)==4,:);
plot(tempData(:,1)/3600, 1*ones(length(tempData(:,1)),1)+0.25*tempData(:,3), '.m');

axis([7 20 0 3]);