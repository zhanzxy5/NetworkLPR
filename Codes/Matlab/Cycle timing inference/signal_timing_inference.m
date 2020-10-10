%% Inferring signal timing plan for a specific direction and lane
clear;clc;
%% configurables
date = '11';
intersectionID = '1310000001';

filename = strcat('C:/Temp/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', intersectionID, '.txt');
delimiterIn = '\t';
headerlinesIn = 1;
rawData = importdata(filename,delimiterIn,headerlinesIn);
rawTimeData = rawData.data;
lane = 3; % Lane to be included for estimation
filter_gap = 10;
buf_time = 120; % buffer time before and after the time boundary
identify_window = 20; % small window used to locate the first signal cycle
gap_window = 35; % gap of data points to be identified belong to two different cycles
N_identify = 3;
% For signal end outlier removal
forward_threshold = 0.5;
forward_len_threshold = 1.8;

start_hours = [7.5; 11; 14.5];
step_hours = 4;

start_time = 13.5 * 3600;
end_time = 16 * 3600 + buf_time;


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
    
dataDir1 = [intTimeData(intTimeData(:,2)==dir, :); intTimeData(intTimeData(:,2)==dir+2,:)];
dataDir1 = sortrows(dataDir1);
dataDir2 = [intTimeData(intTimeData(:,2)==op_dir, :); intTimeData(intTimeData(:,2)==op_dir+2, :)];
dataDir2 = sortrows(dataDir2);

% % Resolve lanes
% intTimeData = intTimeData(intTimeData(:,3)==lane,:);


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

%% Plotting
% plot(dataDir1(:,1), 0.5*ones(length(dataDir1(:,1))), '.b');
% hold on;
% plot(dataDir2(:,1), 1.5*ones(length(dataDir2(:,1))), '.r');
% hold on;

% % plot(dataDir1(:,1), 0.5*ones(length(dataDir1(:,1))), '.b');
% % hold on;
% % plot(dataDir2(:,1), 1.5*ones(length(dataDir2(:,1))), '.r');
% % hold on;
% % plot(dataDir3(:,1), 0.5*ones(length(dataDir3(:,1))), '.c');
% % hold on;
% % plot(dataDir4(:,1), 1.5*ones(length(dataDir4(:,1))), '.m');
% % 
% % 
% % cycle_data = importdata('bpara_11_26_downstream.txt');
% % for i = 1:100
% %     plot([cycle_data(i,1), cycle_data(i,1)]', [0;2], '-k');
% %     hold on;
% %     plot([cycle_data(i,1)+cycle_data(i,3), cycle_data(i,1)+cycle_data(i,3)]', [0;2], '--g');
% % end
% % 
% % % test: compute the gap to identify breaks
% % gapDir1 =zeros(length(dataDir1(:,1))-1,2);
% % gapDir2 =zeros(length(dataDir2(:,1))-1,2);
% % for i=2:length(dataDir1(:,1))
% %     gapDir1(i-1,1) = dataDir1(i,1);
% %     gapDir1(i-1,2) = dataDir1(i,1) - dataDir1(i-1,1);
% % end
% % for i=2:length(dataDir2(:,1))
% %     gapDir2(i-1,1) = dataDir2(i,1);
% %     gapDir2(i-1,2) = dataDir2(i,1) - dataDir2(i-1,1);
% % end
% % plot(gapDir1(:,1),gapDir1(:,2)/100,'-c');
% % hold on;
% % plot(gapDir2(:,1),gapDir2(:,2)/100,'-m');
% % hold on;

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
initial_phase_length = 60; % in seconds
C = 0.1;
eta = 0.01;
max_phase_len = 90;
v_val = [0.5;1];
b_prev_para = [initial_phase_length, initial_phase_length];
MMaxIter = 1000;

% Main steps
dir = 1;
Ncycle = 200;
cycle_count = 1;
bpara_data = zeros(ceil(Ncycle/2), 4);
options = optimoptions('fmincon','Algorithm','interior-point', 'GradObj','on',...
    'Display','off','TolX', 1e-12,'TolFun',1e-8,'MaxIter',MMaxIter);


phase_start = cycle_start;
identify_start_dir = [identify_start, identify_op_start];
identify_start = identify_start_dir(dir);

empty_flag = zeros(2,1);% If empty flag is set to 1, no data exist in this cycle

for Titer = 1:Ncycle
    b_prev = b_prev_para(dir);
    % Find the start of the data points belong to the next cycle
    if dir == 1
        if empty_flag(dir,1) == 0
            % make sure identify_start no earlier than phase start
            temp_identify_start = 0;
            for i = identify_start:length(dataDir1(:,1))-1
                if dataDir1(i,1)>=phase_start
                    break;
                else
                    temp_identify_start = i;
                end
            end
            if temp_identify_start > 0
                identify_start = temp_identify_start;
                identify_start_dir(dir) = identify_start;
            end
            
            % Determine the next cycle start index
            for i = identify_start:length(dataDir1(:,1))-1
                gap = dataDir1(i+1,1) - dataDir1(i,1);
                if gap >= gap_window
                    next_identify_start = i+1;
                    break;
                end
            end

            % Another check to rule out outliers at the end of the signal cycle
            for i = next_identify_start:length(dataDir1(:,1))-1
                gap = dataDir1(i+1,1) - dataDir1(i,1);
                if gap >= gap_window
                    next_next_identify_start = i+1;
                    break;
                end
            end

            % Two conditions: 1) the items in this interval is smaller than
            % forward_threshold; 2) the combined phase length is smaller than
            % forward_len_threshold
            if next_next_identify_start - next_identify_start <= forward_threshold * (next_identify_start - identify_start)
                if dataDir1(next_next_identify_start - 1, 1) - dataDir1(identify_start, 1) <= forward_len_threshold * b_prev
                    next_identify_start = next_next_identify_start;
                end
                fprintf('Next start index revised: time=%d\n', dataDir1(identify_start, 1));
            end
            tempDir1 = dataDir1(identify_start:next_identify_start-1,:);
            tempDir2 = dataDir2(dataDir2(:,1)>=tempDir1(1,1),:);
            tempDir2 = tempDir2(tempDir2(:,1)<dataDir1(next_identify_start,1),:);
        else
            next_identify_start = identify_start;
            empty_flag(dir,1) = 2;
            tempDir1 = zeros(0,3);
            tempDir2 = dataDir2(dataDir2(:,1)>=dataDir1(identify_start - 1,1),:);
            tempDir2 = tempDir2(tempDir2(:,1)<dataDir1(next_identify_start,1),:);
        end
    else
        if empty_flag(dir,1) == 0
%             % make sure identify_start no earlier than phase start
%             temp_identify_start = 0;
%             for i = identify_start:length(dataDir2(:,1))-1
%                 if dataDir2(i,1)>=phase_start
%                     break;
%                 else
%                     temp_identify_start = i;
%                 end
%             end
%             if temp_identify_start > 0
%                 identify_start = temp_identify_start;
%                 identify_start_dir(dir) = identify_start;
%             end
            % Determine the next cycle start index  
            for i = identify_start:length(dataDir2(:,1))-1
                gap = dataDir2(i+1,1) - dataDir2(i,1);
                if gap >= gap_window
                    next_identify_start = i+1;
                    break;
                end
            end

            % Another check to rule out outliers at the end of the signal cycle
            for i = next_identify_start:length(dataDir2(:,1))-1
                gap = dataDir2(i+1,1) - dataDir2(i,1);
                if gap >= gap_window
                    next_next_identify_start = i+1;
                    break;
                end
            end

            % Two conditions: 1) the items in this interval is smaller than
            % forward_threshold; 2) the combined phase length is smaller than
            % forward_len_threshold
            if next_next_identify_start - next_identify_start <= forward_threshold * (next_identify_start - identify_start)
                if dataDir2(next_next_identify_start - 1, 1) - dataDir2(identify_start, 1) <= forward_len_threshold * b_prev
                    next_identify_start = next_next_identify_start;
                end
                fprintf('Next start index revised: time=%d\n', dataDir2(identify_start, 1));
            end
            tempDir1 = dataDir2(identify_start:next_identify_start-1,:);
            tempDir2 = dataDir1(dataDir1(:,1)>=tempDir1(1,1),:);
            tempDir2 = tempDir2(tempDir2(:,1)<dataDir2(next_identify_start,1),:);
        else
            next_identify_start = identify_start;
            empty_flag(dir,1) = 2;
            tempDir1 = zeros(0,3);
            tempDir2 = dataDir1(dataDir1(:,1)>=dataDir2(identify_start - 1,1),:);
            tempDir2 = tempDir2(tempDir2(:,1)<dataDir2(next_identify_start,1),:);
        end
        
    end
    
    if (~isempty(tempDir1)) && (~isempty(tempDir2))
    %     % Filtering out signal end outliers
    %     if dataDir1(next_identify_start,1) < tempDir2(round(length(tempDir2(:,1))* forward_threshold),1)
    %         % Another check to rule out outliers at the end of the signal cycle
    %         for i = next_identify_start:length(dataDir1(:,1))-1
    %             gap = dataDir1(i+1,1) - dataDir1(i,1);
    %             if gap >= gap_window
    %                 next_next_identify_start = i+1;
    %                 break;
    %             end
    %         end
    %         next_identify_start = next_next_identify_start;
    %         tempDir1 = dataDir1(identify_start:next_identify_start-1,:);
    % %         tempDir2 = dataDir2(dataDir2(:,1)>=tempDir1(1,1),:);
    % %         tempDir2 = tempDir2(tempDir2(:,1)<dataDir1(next_identify_start,1),:);
    %     end


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
            scatter(dataDir1(next_identify_start,1), 0.5, 'm');
            hold on;
            scatter(tempDir1(:,1),0.5*ones(length(tempDir1(:,1)),1), '.b');
        else
            scatter(dataDir2(next_identify_start,1), 1.5, 'k');
            hold on;
            scatter(tempDir1(:,1),1.5*ones(length(tempDir1(:,1)),1), '.r');
        end
        hold on;
        
    else
        % If any of the cycle has data of only one direction, does not
        % perform estimation. This will impact both directions
        b = b_prev;
        if isempty(tempDir1)
            empty_dir = dir;
        else
            empty_dir = 3-dir;
        end
        if empty_flag(empty_dir,1) < 2
            empty_flag(empty_dir,1) = 1;
        else
            empty_flag(empty_dir,1) = 0;
        end
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
    identify_start_dir(dir) = next_identify_start;
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
    identify_start = identify_start_dir(dir);
end

%%
bpara_data = bpara_data(bpara_data(:,2)>0,:);
