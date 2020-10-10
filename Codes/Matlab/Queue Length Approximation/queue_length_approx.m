%% Function for queue length approximation
function [QL_data, Nlanes] = queue_length_approx(date, linkDir, downstreamInt, downIntMainDir, start_hour, end_hour)
%% Hyper parameters for the Gaussian interpolation model
h0=0.5;
lambda=2;
neta=1;
sig_buff = 10;

%% Load data for testing
filename = strcat('C:/Temp/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', downstreamInt, '.txt');
% filename = strcat('D:/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', downstreamInt, '.txt');
delimiterIn = '\t';
headerlinesIn = 1;
rawData = importdata(filename,delimiterIn,headerlinesIn);
rawTimeData = rawData.data;
intersectionID = downstreamInt;
config_intersection;
switch linkDir
    case 1
        lanes = laneDir1;
    case 2
        lanes = laneDir2;
    case 3
        lanes = laneDir3;
    case 4
        lanes = laneDir4;
end
Nlanes = length(lanes);

% Time length set up
buf_time = 120; % buffer time before and after the time boundary
start_time = start_hour * 3600;
end_time = end_hour * 3600 + buf_time;

intTimeData = zeros(length(rawTimeData(:,1)), 3);
intTimeData(:,1) = rawTimeData(:,1)*3600 + rawTimeData(:,2)*60 + rawTimeData(:,3);
intTimeData(:,2:3) = rawTimeData(:,4:5);
intTimeData = intTimeData(intTimeData(:,1)>=start_time,:);
intTimeData = intTimeData(intTimeData(:,1)<=end_time,:);
% Extract the appropriate direction
intTimeData = intTimeData(intTimeData(:,2)==linkDir, :);
intTimeData = sortrows(intTimeData, 1);

% Timing plan data
bpara_fileName = strcat('C:/Temp/Dropbox/China Camera Data/Network LPR/Matlab/Cycle timing inference/TimingData/selected/',...
                        date, '_', downstreamInt, '_', int2str(downIntMainDir), '.csv');
% bpara_fileName = strcat('D:/Dropbox/China Camera Data/Network LPR/Matlab/Cycle timing inference/TimingData/selected/',...
%     date, '_', downstreamInt, '_', int2str(downIntMainDir), '.csv');
bpara = importdata(bpara_fileName);
if downIntMainDir == 1
    if mod(linkDir, 2) == 1
        green_Index = 3;
        red_Index = 4;
    else
        green_Index = 4;
        red_Index = 3;
    end
else 
    if mod(linkDir, 2) == 1
            green_Index = 4;
            red_Index = 3;
        else
            green_Index = 3;
            red_Index = 4;
    end
end
% Transform the bpara data so that it satisfies the requirement:
% Cycle needs to start with the red phase
totCycle = length(bpara(:,1));
if green_Index == 3
    temp_bpara = zeros(totCycle-1, 4);
    for i = 1:totCycle - 1
        temp_bpara(i, 1) = bpara(i, 1) + bpara(i,3);
        temp_bpara(i, 2) = bpara(i, 4) + bpara(i+1, 3);
        temp_bpara(i, 3) = bpara(i, 4);
        temp_bpara(i, 4) = bpara(i+1, 3);
    end
    bpara = temp_bpara;
    totCycle = totCycle - 1;
end
b = bpara(:,1);

% Data to be returned: stored as 1-cycle start time; 2- cycle end time; 
% 3- max QL for lane 1; 4- max QL for lane 2,...
% 3+Nlanes: Nveh for lane 1; 4+Nlanes: Nveh for lane 2, ...
QL_data = zeros(totCycle, Nlanes * 2 + 2);
QL_data(:,1) = bpara(:,1);
QL_data(:,2) = bpara(:,1) + bpara(:,2);

%% Main iterations: infer queue length for each lane
for l = 1:Nlanes
    lane = lanes(l);
    %% Data Extraction
    data = intTimeData(intTimeData(:,3) == lane, :);
    N = length(data(:,1));
	departT = zeros(N, 2);
    departT(:,1) = (1:N)';
    departT(:,2) = data(:,1);
    
    %% Draw departure curve
%     scatter(departT(:,2)/3600,departT(:,1),'.k');
%     hold on;
%     stairs(departT(:,2)/3600,departT(:,1),'-b');
%     hold on;
% 
%     % Draw signal timing plan
%     for i=1:length(b)
%         plot([b(i),b(i)]'/3600, [1, N]', 'k');
%         hold on;
%         plot([b(i)+bpara(i,3),b(i)+bpara(i,3)]'/3600, [1, N]', ':r');
%         hold on;
%     end
    
    %% Gaussian interpolation
    theta = zeros(3,1);
    % Initialize theta
    theta(1,1) = 0.1; % r_s
    theta(2,1) = 0.05; % r_n
    theta(3,1) = 10; % tau
    para = zeros(5,1); % known parameters
    para(3,1) = h0;
    para(4,1) = lambda;
    para(5,1) = neta;

    queue_length = zeros(totCycle, 7); % Interval; queue length; tau; Nveh; r1; r2; oversaturate
    for Iint=1:totCycle - 1
        fprintf('Lane:\t%d\tComputing cycle %d\n',lane, Iint);
        para(1,1) = bpara(Iint,red_Index); % red time
        para(2,1) = bpara(Iint, green_Index); % green time

        % Preparing data
        Tstart = b(Iint,1) + 0.75 * bpara(Iint, 3); % Allow some buffer for early arrivals
        Tend = b(Iint+1,1) + sig_buff; % Allow some buffer at the end of the cycle
        tempData = departT(departT(:,2)>=Tstart, :);
        tempData = tempData(tempData(:,2)<Tend + sig_buff, :);
        y0 = tempData(:,1);
        x0 = tempData(:,2);

        % Data filtering: resolve the case that two vehicles arrive at the same
        % time
        for i = 1:length(x0)-1
            if x0(i) == x0(i+1)
                if i > 1
                    x0(i) = 0.5 * (x0(i-1) + x0(i+1));
                else
                    x0(i) = x0(i) - 0.5;
                end
            end
        end

        [theta, tau, ql, muX0, oversaturate] = Gaussian_approx(theta, y0, x0, para);
%         plot(x0/3600, muX0, '--g');
%         hold on;

        queue_length(Iint, :) = [Iint, ql, tau, length(y0), theta(1,1), theta(2,1), oversaturate];
    end
    %% store the data
    QL_data(:, 2+l) = queue_length(:, 2);
    QL_data(:, 2 + Nlanes + l) = queue_length(:, 4);
end





