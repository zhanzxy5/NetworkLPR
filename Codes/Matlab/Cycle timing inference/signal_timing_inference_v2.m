%% Inferring signal timing plan for a specific direction and lane
clear;clc;
%% configurables
date = '11';
intersectionID = '1310000001';
% intersectionID = 'test';

% Data preparation configures
filter_gap = 10;
buf_time = 120; % buffer time before and after the time boundary
identify_window = 20; % small window used to locate the first signal cycle
gap_window = 25; % gap of data points to be identified belong to two different cycles
N_identify = 3;
% For signal end outlier removal
forward_threshold = 0.5;
forward_len_threshold = 1.5;
probe_gap = 20; % Used for the new sequence identification approach

% Timing inference configures
initial_phase_length = 60; % in seconds
C = 0.1;
eta = 0.01;
max_phase_len = 75;
v_val = [0.5;1];
MMaxIter = 1000;

% Time length set up
start_hours = [7.5; 11; 14.5];
step_hours = 4;

start_time = 7 * 3600;
end_time = 18 * 3600 + buf_time;

% Load data
if ~strcmp(intersectionID, 'test')
    filename = strcat('D:/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', intersectionID, '.txt');
else
    filename = 'raw_downstream_11_26.txt';
end
delimiterIn = '\t';
headerlinesIn = 1;
rawData = importdata(filename,delimiterIn,headerlinesIn);
rawTimeData = rawData.data;
config_intersection;

%% Determining main direction: use the direction with more data as main direction
main_dir = 1;
dir1Count = sum(rawTimeData(:,4)==1);
dir2Count = sum(rawTimeData(:,4)==2);

if dir2Count > dir1Count
    main_dir = 2;
end

if main_dir <= 2
    dir = main_dir;
else
    dir = main_dir - 2;
end
if dir == 1
    op_dir = 2;
else
    op_dir = 1;
end


%% Data Extraction
intTimeData = zeros(length(rawTimeData(:,1)), 3);
intTimeData(:,1) = rawTimeData(:,1)*3600 + rawTimeData(:,2)*60 + rawTimeData(:,3);
intTimeData(:,2:3) = rawTimeData(:,4:5);
intTimeData = intTimeData(intTimeData(:,1)>=start_time,:);
intTimeData = intTimeData(intTimeData(:,1)<=end_time,:);


% Select lane data
for i = 1:length(intTimeData(:,1))
    d = intTimeData(i,2);
    l = intTimeData(i,3);
    
    switch d
        case 1
            if sum(laneDir1==l)==0
                intTimeData(i,1) = 0;
            end
        case 2
            if sum(laneDir2==l)==0
                intTimeData(i,1) = 0;
            end
        case 3
             if sum(laneDir3==l)==0
                intTimeData(i,1) = 0;
             end
        case 4
             if sum(laneDir4==l)==0
                intTimeData(i,1) = 0;
             end
        otherwise
            disp('Wrong direction!');
    end
end
intTimeData = intTimeData(intTimeData(:,1)>0,:);
    
dataDir1 = [intTimeData(intTimeData(:,2)==dir, :); intTimeData(intTimeData(:,2)==dir+2,:)];
dataDir1 = sortrows(dataDir1);
dataDir2 = [intTimeData(intTimeData(:,2)==op_dir, :); intTimeData(intTimeData(:,2)==op_dir+2, :)];
dataDir2 = sortrows(dataDir2);


%% Filtering isolated entries
% If both before and after had 10s gap
% First filter dataDir1
for i=2:length(dataDir1(:,1))-1
    gap1 = dataDir1(i,1) - dataDir1(i-1,1);
    gap2 = dataDir1(i+1,1) - dataDir1(i,1);
    if gap1 >= filter_gap && gap2 >= filter_gap
        dataDir1(i,:) = zeros(1,3);
    end
end
for i=2:length(dataDir2(:,1))-1
    gap1 = dataDir2(i,1) - dataDir2(i-1,1);
    gap2 = dataDir2(i+1,1) - dataDir2(i,1);
    if gap1 >= filter_gap && gap2 >= filter_gap
        dataDir2(i,:) = zeros(1,3);
    end
end
% Get rid of the first entry, as they are not being filtered
dataDir1(1,:) = zeros(1,3);
dataDir2(1,:) = zeros(1,3);

dataDir1 = dataDir1(dataDir1(:,2)>0,:);
dataDir2 = dataDir2(dataDir2(:,2)>0,:);

% % Attach the data with indices
% dataDir1 = [dataDir1, (1:length(dataDir1(:,1)))'];
% dataDir2 = [dataDir2, (1:length(dataDir2(:,1)))'];

%% Plot data
plot(dataDir1(:,1), 0.4*ones(length(dataDir1(:,1)),1), '.b');
hold on;
plot(dataDir2(:,1), 1.4*ones(length(dataDir2(:,1)),1), '.r');

%% Identify starting cycle
% Starting from the first point, search until find at least N_identify points 
% inside the identify_window
identify_start = 1;
for i = 1:length(dataDir1(:,1))
    if dataDir1(i+N_identify-1,1) - dataDir1(i,1) < identify_window
        identify_start = i;
        break;
    end
end
cycle_start = dataDir1(identify_start,1);
scatter(cycle_start, 0.5, '^m');
hold on;

% identify the start vehicle of the oposite direction
% identify_op_start = 1;
for i = 1:length(dataDir2(:,1))
    if dataDir2(i,1) > cycle_start
        identify_op_start = i;
        break;
    end
end
cycle_op_start = dataDir2(identify_op_start,1);
scatter(cycle_op_start, 1.5, '^k');
hold on;

%% Cycle timing inference algorithm
b_prev_para = [initial_phase_length, initial_phase_length];

% Main steps
Ncycle = 20; % maximum number of phases
cycle_count = 1;
bpara_data = zeros(ceil(Ncycle/2), 4);
options = optimoptions('fmincon','Algorithm','interior-point', 'GradObj','on',...
    'Display','off','TolX', 1e-12,'TolFun',1e-8,'MaxIter',MMaxIter);

phase_start = cycle_start;
identify_start_dir = [identify_start, identify_op_start];
identify_start = identify_start_dir(dir);

empty_flag = zeros(2,1);% If empty flag is set to 1, no data exist in this cycle
tic;
for Titer = 1:Ncycle
    b_prev = b_prev_para(dir);
    
    % Use max_phase_len to probe the the longest obs sequence
    if dir == 1
        probeDir1 = dataDir1(dataDir1(:,1)>phase_start,:);
        probeDir1 = probeDir1(probeDir1(:,1)<=phase_start + max_phase_len, :);
        probeDir2 = dataDir2(dataDir2(:,1)>phase_start,:);
        probeDir2 = probeDir2(probeDir2(:,1)<=phase_start + 2*max_phase_len, :);
    else
        probeDir1 = dataDir2(dataDir2(:,1)>phase_start,:);
        probeDir1 = probeDir1(probeDir1(:,1)<=phase_start + max_phase_len, :);
        probeDir2 = dataDir1(dataDir1(:,1)>phase_start,:);
        probeDir2 = probeDir2(probeDir2(:,1)<=phase_start + 2*max_phase_len, :);
    end
    
    % Find the first longest obs sequence
    % Dir1:
    if ~isempty(probeDir1)
%         SeqTimeLen = [];
        SeqNCount = [];
        % Initialize if non-empty
        SeqStartInd = [1];

        seqCounter = 1;
        for i = 1:length(probeDir1(:,1))-1
            gap = probeDir1(i+1,1) - probeDir1(i,1);
            if gap > probe_gap
                SeqStartInd = [SeqStartInd;i+1];
%                 SeqTimeLen = [SeqTimeLen;probeDir1(i,1) - probeDir1(SeqStartInd(seqCounter),1)];
                SeqNCount = [SeqNCount;i+1 - SeqStartInd(seqCounter)];
                seqCounter = seqCounter + 1;
            end
        end
        % Complete info for the last sequence
%         SeqTimeLen = [SeqTimeLen; probeDir1(length(probeDir1(:,1)),1) - probeDir1(SeqStartInd(length(SeqStartInd)),1)];
        SeqNCount = [SeqNCount; length(probeDir1(:,1))-SeqStartInd(length(SeqStartInd))];
        
        % Two criteria: with maximum number
%         [C1, I1] = max(SeqTimeLen);
        [C2, I2] = max(SeqNCount);
        I = min(I1,I2);
        if I < seqCounter;
            tempDir1 = probeDir1(SeqStartInd(I):SeqStartInd(I+1)-1,:);
        else
            % Last one
            tempDir1 = probeDir1(SeqStartInd(I):length(probeDir1(:,1)),:);
        end
    else
        tempDir1 = [];
    end
    
    % Dir2:
    if ~isempty(probeDir2)
%         SeqTimeLen = [];
        SeqNCount = [];
        % Initialize if non-empty
        SeqStartInd = [1];

        seqCounter = 1;
        for i = 1:length(probeDir2(:,1))-1
            gap = probeDir2(i+1,1) - probeDir2(i,1);
            if gap > probe_gap
                SeqStartInd = [SeqStartInd;i+1];
%                 SeqTimeLen = [SeqTimeLen;probeDir2(i,1) - probeDir2(SeqStartInd(seqCounter),1)];
                SeqNCount = [SeqNCount;i+1 - SeqStartInd(seqCounter)];
                seqCounter = seqCounter + 1;
            end
        end
        % Complete info for the last sequence
%         SeqTimeLen = [SeqTimeLen; probeDir2(length(probeDir2(:,1)),1) - probeDir2(SeqStartInd(length(SeqStartInd)),1)];
        SeqNCount = [SeqNCount; length(probeDir2(:,1))-SeqStartInd(length(SeqStartInd))];
        
        % Two criteria: with maximum number
%         [C1, I1] = max(SeqTimeLen);
        [C2, I] = max(SeqNCount);
%         I = min(I1,I2);
        if I < seqCounter;
            tempDir2 = probeDir2(SeqStartInd(I):SeqStartInd(I+1)-1,:);
        else
            % Last one
            tempDir2 = probeDir2(SeqStartInd(I):length(probeDir2(:,1)),:);
        end
    else
        tempDir2 = [];
    end
    
    % Timing inference algorithm
    if (~isempty(tempDir1)) && (~isempty(tempDir2))
    %     % Dual problem
    %     % Get the data to run the solution algorithm
    %     [Ab0, A, V, T, X] = init_cycle_data(tempDir1, tempDir2, v_val, b_prev, phase_start, 1);
    %     
    %     lb = zeros(length(X)+1,1);
    %     ub = [C*ones(length(X),1);max_phase_len];
    %     
    %     [Abx, fval] = fmincon(@(Ab)Lobj(Ab, V, T, X, b_prev, eta), Ab0, [], [], [], [], lb, ub, @(Ab)Lcon(Ab, V, T, X, b_prev, eta), options);

        % Primal problem
        % Get the data to run the solution algorithm
        [Ab0, A, V, T, X] = init_cycle_data(tempDir1, tempDir2, v_val, b_prev, phase_start, 0);
        lb = zeros(length(X)+2, 1);
        lb(length(X)+2,1) = 20;

        [Abx, fval] = fmincon(@(Ab)Fobj_primal(Ab, X, b_prev, eta, C), Ab0, [], [], [], [], lb, [], @(Ab)Fcon(Ab, V, T, X), options);


        b = Abx(length(Abx));
        
        fprintf('Cycle=%d\tDir=%d:\tPhase %d - %d:\tSizeDir1=%d\tSizeDir2=%d\tPhase length=%f\tminX=%f\n', ...
            floor((Titer + 1)/2), dir, round(phase_start), round(phase_start + b), ...
            length(tempDir1(:,1)), length(tempDir2(:,1)), b, min(X));
    
        % Plotting
        if dir == 1
            scatter(tempDir1(1,1), 0.5, 'm');
            hold on;
            scatter(tempDir1(:,1),0.5*ones(length(tempDir1(:,1)),1), '.b');
        else
            scatter(tempDir1(1,1), 1.5, 'k');
            hold on;
            scatter(tempDir1(:,1),1.5*ones(length(tempDir1(:,1)),1), '.r');
        end
        hold on;
        
    else
        % If any of the cycle has data of only one direction, does not perform estimation.
        b = b_prev;
        fprintf('Cycle=%d\tDir=%d:\tPhase %d - %d:\tPhase length=%f\n', floor((Titer + 1)/2), dir, round(phase_start), round(phase_start + b), b);
    end
    
    % Plotting phase
    if dir == 1
        plot([phase_start + b, phase_start + b], [0;2], 'g');
    else
        plot([phase_start + b, phase_start + b], [0;2], 'k');
    end
    hold on;
    
    % Set the next phase
    b_prev_para(dir) = b;
%     identify_start_dir(dir) = next_identify_start;
    if dir == 1
        bpara_data(cycle_count,1) = phase_start;
        bpara_data(cycle_count,3) = b;
        dir = 2;
    else
        dir = 1;
        bpara_data(cycle_count,4) = b;
        bpara_data(cycle_count,2) = b + bpara_data(cycle_count,3);
        cycle_count = cycle_count + 1;
    end
    phase_start = phase_start + b;
    if phase_start > min(dataDir1(length(dataDir1(:,1)),1)-2*buf_time, dataDir2(length(dataDir2(:,1)),1)-2*buf_time)
        break;
    end
%     identify_start = identify_start_dir(dir);
end
toc;
%%
bpara_data = bpara_data(bpara_data(:,2)>0,:);
