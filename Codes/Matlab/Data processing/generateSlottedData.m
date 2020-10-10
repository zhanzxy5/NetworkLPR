%% Generate the slotted data for DBN model
clear;clc;
%% Configurations
start_times = [7.5;9.5;13.5;17];
end_times = [9;12;16.5;19];
% Length for each time slot
slot_length = 180;
% Number of time slices for the DBN
NT = 4;
% Sliding window step size
slide_size = 4;
dates = {'11', '12', '14', '15', '16', '17'};
link_config;

%% Creating matrix store slotted data
total_time = 0;
for i = 1:length(start_times)
    total_time = total_time + end_times(i) - start_times(i);
end
Nslot = total_time * 3600 / slot_length;

% Total number of variables in the data: include pseudo links
% First block: queue length data; Second block: observed TT data;
% Third block: pseudo link data; Fourth block: path TT data;
Nvariables = NQL + NTT_obs + NTT_pseudo + NPATH;
% Store the starting time stamp
slot_data_timestamp = zeros(Nslot, 1);
n = 1;
for i = 1:length(start_times)
    start_t = start_times(i,1)*3600;
    end_t = end_times(i,1)*3600;
    tL = end_t - start_t;
    ns = tL/slot_length;
    for j = n:n + ns -1
        slot_data_timestamp(j, 1) = start_t + (j-n)*slot_length;
    end
    n = n + ns;
end

%% Adding data to the slot_data
for d = 1:length(dates)
    date = dates{d};
    slot_data = zeros(Nslot, Nvariables+1);
    slot_data(:,1) = slot_data_timestamp;
    fprintf('Processing day:\t%s\nProcessing queue lengths\n', date);
    %% First process queue length data
    for i = 1:NQL
        linkID = obs_QL_link(i,1);
        fprintf('Loading queue length data from Link:\t%d\tColumn\t%d\n', linkID, i+1);
%         QL_filename = strcat('D:\Dropbox\China Camera Data\Network LPR\Matlab\Queue length approximation\QL_data\QL_results\', ...
%                       date, '_', int2str(linkID), '_2.csv');
        QL_filename = strcat('C:\Temp\Dropbox\China Camera Data\Network LPR\Matlab\Queue length approximation\QL_data\QL_results\', ...
                      date, '_', int2str(linkID), '_2.csv');
        % Load data
        ori_data= importdata(QL_filename);
        
        for j = 1:Nslot
            start_t = slot_data(j, 1);
            end_t = start_t + slot_length;
            temp_data = ori_data(ori_data(:,1)>=start_t, :);
            temp_data = temp_data(temp_data(:,1)<end_t, :);
            if isempty(temp_data)
                % If no data entry: set the data to -1
                slot_data(j, 1+i) = -999;
            else
                % if there is data entry, compute the average QL
                qlsum = 0;
                nvsum = 0;
                for s = 1:length(temp_data(:,1))
                    qlsum = qlsum + temp_data(s, 3)*temp_data(s, 5) + temp_data(s, 4)*temp_data(s, 6);
                    nvsum = nvsum + temp_data(s, 5) + temp_data(s, 6);
                end
                ql = 0;
                if nvsum > 0
                    ql = qlsum/nvsum;
                end
                
              %% Queue length discretization
              % Four states
                if ql < 6
                    qls = 1;
                else
                    if ql < 11
                        qls = 2;
                    else
                        if ql < 16
                            qls = 3;
                        else
                            qls = 4;
                        end
                    end
                end
                
%                 % Three states
%                 if ql < 8
%                     qls = 1;
%                 else
%                     if ql < 15
%                         qls = 2;
%                     else
%                         qls = 3;
%                     end
%                 end
                
                 slot_data(j, 1+i) = qls;
            end
        end
    end
    
    %% Next load observed link TTs
    fprintf('Processing observed link TTs\n');
    for i = 1:NTT_obs
        linkID = obs_TT_link(i,1);
        varID = linkID2VarID(linkID);
        fprintf('Loading TT data from observed Link:\t%d\tColumn\t%d\n', linkID, i + NQL + 1);
%         TT_filename = strcat('D:\Dropbox\China Camera Data\Network LPR\Data\New Data\new_data_with_wp\', ...
%                       date, '\LinkTT\', int2str(linkID), '.txt');
        TT_filename = strcat('C:\Temp\Dropbox\China Camera Data\Network LPR\Data\New Data\new_data_with_wp\', ...
                      date, '\LinkTT\', int2str(linkID), '.txt');
        % Load data
        delimiterIn = '\t';
        headerlinesIn = 1;
        rawData = importdata(TT_filename,delimiterIn,headerlinesIn);
        ori_data = rawData.data;
        
        % Perform data filtering: remove entries differ more than
        %  mean +/- 2*std values
        meanTT = mean(ori_data(:,3));
        stdTT = std(ori_data(:,3));
        upper = meanTT + 2*stdTT;
        lower = meanTT - 2*stdTT;
        
        for j = 1:Nslot
            start_t = slot_data(j, 1);
            end_t = start_t + slot_length;
            temp_data = ori_data(ori_data(:,1)>=start_t, :);
            temp_data = temp_data(temp_data(:,1)<end_t, :);
            % Filter out unreasonable entries
            temp_data = temp_data(temp_data(:,3) <=upper,:);
            temp_data = temp_data(temp_data(:,3)>=lower,:);
            if isempty(temp_data)
                % If no data entry: set the data to -1
                slot_data(j, 1 + NQL + i) = -999;
            else
                % if there is data entry, compute the average TT
                avgTT = mean(temp_data(:,3));
                % Remove the free flow TT
                TT = avgTT - link_data(varID, 6);
                % Add to the slot_data
                slot_data(j, 1 + NQL + i) = TT;
%                 % For std
%                 slot_data(j, 1 + NQL + i) = std(temp_data(:,3));
            end
        end
    end
    
    %% Load pseudo link TTs
    fprintf('Processing pseudo link TTs\n');
    for i = 1:NTT_pseudo
        linkID = pseudo_TT_link(i,1);
        varID = linkID2VarID(linkID);
        pathID = pseudo_TT_link(i,2);
        fprintf('Loading TT data from p:\t%d\tColumn\t%d\n', linkID, i + NQL + NTT_obs + 1);
%         TT_filename = strcat('D:\Dropbox\China Camera Data\Network LPR\Data\New Data\new_data_with_wp\', ...
%                       date, '\PathTT\', int2str(pathID), '.txt');
        TT_filename = strcat('C:\Temp\Dropbox\China Camera Data\Network LPR\Data\New Data\new_data_with_wp\', ...
                      date, '\PathTT\', int2str(pathID), '.txt');
        % Load data
        delimiterIn = '\t';
        headerlinesIn = 1;
        rawData = importdata(TT_filename,delimiterIn,headerlinesIn);
        ori_data = rawData.data;
        
        % Perform data filtering: remove entries differ more than
        %  mean +/- 2*std values
        meanTT = mean(ori_data(:,3));
        stdTT = std(ori_data(:,3));
        upper = meanTT + 2*stdTT;
        lower = meanTT - 2*stdTT;
        
        for j = 1:Nslot
            start_t = slot_data(j, 1);
            end_t = start_t + slot_length;
            temp_data = ori_data(ori_data(:,1)>=start_t, :);
            temp_data = temp_data(temp_data(:,1)<end_t, :);
            % Filter out unreasonable entries
            temp_data = temp_data(temp_data(:,3) <=upper,:);
            temp_data = temp_data(temp_data(:,3)>=lower,:);
            if isempty(temp_data)
                % If no data entry: set the data to -1
                slot_data(j, 1 + NQL + NTT_obs + i) = -999;
            else
                % if there is data entry, compute the average TT
                avgTT = mean(temp_data(:,3));
                % Remove the free flow TT
                TT = avgTT - link_data(varID, 6);
                % Add to the slot_data
                slot_data(j, 1 + NQL + NTT_obs + i) = TT;
%                 % For std
%                 slot_data(j, 1 + NQL + NTT_obs + i) = std(temp_data(:,3));
            end
        end
    end
    
    %% Load path TT data
    fprintf('Processing path TTs\n');
    for i = 1:NPATH
        pathID = path_data(i,1);
        fprintf('Loading TT data from path:\t%d\tColumn\t%d\n', pathID, i + NQL + NTT_obs + NTT_pseudo + 1);
%         TT_filename = strcat('D:\Dropbox\China Camera Data\Network LPR\Data\New Data\new_data_with_wp\', ...
%                       date, '\PathTT\', int2str(pathID), '.txt');
        TT_filename = strcat('C:\Temp\Dropbox\China Camera Data\Network LPR\Data\New Data\new_data_with_wp\', ...
                      date, '\PathTT\', int2str(pathID), '.txt');
        % Load data
        delimiterIn = '\t';
        headerlinesIn = 1;
        rawData = importdata(TT_filename,delimiterIn,headerlinesIn);
        ori_data = rawData.data;
        
        % Perform data filtering: remove entries differ more than
        %  mean +/- 2*std values
        meanTT = mean(ori_data(:,3));
        stdTT = std(ori_data(:,3));
        upper = meanTT + 1.5*stdTT;
        lower = meanTT - 1.5*stdTT;
        
        for j = 1:Nslot
            start_t = slot_data(j, 1);
            end_t = start_t + slot_length;
            temp_data = ori_data(ori_data(:,1)>=start_t, :);
            temp_data = temp_data(temp_data(:,1)<end_t, :);
            % Filter out unreasonable entries
            temp_data = temp_data(temp_data(:,3) <=upper,:);
            temp_data = temp_data(temp_data(:,3)>=lower,:);
            if isempty(temp_data)
                % If no data entry: set the data to -1
                slot_data(j, 1 + NQL + NTT_obs + NTT_pseudo + i) = -999;
            else
                % if there is data entry, compute the average TT
                avgTT = mean(temp_data(:,3));
                % Remove the free flow TT
                TT = avgTT - path_data(i, 5);
                % Add to the slot_data
                slot_data(j, 1 + NQL + NTT_obs + NTT_pseudo + i) = TT;
%                 % For std
%                 slot_data(j, 1 + NQL + NTT_obs + NTT_pseudo + i) = std(temp_data(:,3));
            end
        end
    end
    
    %% Saving output
%     saveFileName = strcat('D:\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\SlotData\',...
%         date, '_slotted.csv');
    saveFileName = strcat('C:\Temp\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\SlotData\',...
        date, '_slotted.csv');
    dlmwrite(saveFileName, slot_data, ',');
end

    