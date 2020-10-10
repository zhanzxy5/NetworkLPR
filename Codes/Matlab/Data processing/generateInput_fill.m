%% Generate the input data for learning the DBN model: filled missing entries
clear;clc;
%% Configurations
start_times = [7.5;9.5;13.5;17];
end_times = [9;12;16.5;19];
% Length for each time slot
slot_length = 180;
% Number of time slices for the DBN
NT = 4;
% Sliding window step size: increase data size
slide_size = 4;
dates = {'11', '12', '14', '15', '16', '17'};
NVar = 30;
link_config;
inputVar_mapping = input_data_mapping_smallP1;
% Column index of the slotted data to be filled
fill_indexes = [18, 20, 21, 22, 23, 24, 25, 26, 27, 28, 30, 31, 33, 34, 35, 37, 38, 39, 40, 41, 42, 43, 45, 46, 47, 49, 50, 51, 52, 54, 57, 59];

%% Generate cases
total_time = 0;
for i = 1:length(start_times)
    total_time = total_time + end_times(i) - start_times(i);
end
Nslot = total_time * 3600 / slot_length;

% Create a temporary cell array to store all the tests
temp_cases = cell(1, ceil(ceil(Nslot/slide_size))*length(dates));

ncases = 1;
for d = 1:length(dates)
    date = dates{d};
    slotFilename = strcat('C:\Temp\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\SlotData\3State\', date, '_slotted.csv');
%     slotFilename = strcat('D:\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\SlotData\3State\', date, '_slotted.csv');
    slot_data = importdata(slotFilename);
    
    % Generate cases:
    % Starting from the first time step, look at future NT steps, if all
    % times are separated by slot_length, then consider them as a case
    slot_index = 1;
    while slot_index + NT - 1 <= length(slot_data(:,1))
        start_time = slot_data(slot_index, 1);
        end_time = start_time + slot_length * (NT-1);
        if slot_data(slot_index + NT - 1, 1) == end_time
            % We find a proper block
            temp_data = slot_data(slot_index: slot_index + NT - 1, :);
            temp_cases{ncases} = cell(NVar, NT);
            % Adding data to this block
            for t = 1:NT
                for colIndex = 2:length(slot_data(1,:))
                    varID = inputVar_mapping(colIndex-1, 3);
                    if varID > 0
                        val = temp_data(t, colIndex);
                        if val ~= -999
                            temp_cases{ncases}{varID, t} = val;
                        else
                            if sum(fill_indexes==colIndex) > 0
                                % This column can be filled
                                % Starting from t=1 to t=NT, find the
                                % closest indices that has observable data
                                first = 0;
                                last = 0;
                                for s = 1:t-1
                                    if temp_data(s, colIndex) ~= -999
                                        first = s;
                                    end
                                end
                                for s = t+1:NT
                                    if temp_data(s, colIndex) ~= -999
                                        last = s;
                                        break;
                                    end
                                end
                                % Fill the entry based on different conditions
                                if first > 0
                                    if last > 0
                                        % Fill as the average of the first
                                        % and last
                                        for ss = first+1:last-1
                                            temp_data(ss, colIndex) = temp_data(first, colIndex) + (ss-first)/(last-first)*(temp_data(last, colIndex) - temp_data(first, colIndex));
                                        end
                                    else
                                        % If only the first is known, fill
                                        % the last with avg and scale
                                        % properly
                                        avgTT = mean(slot_data(slot_data(:,colIndex)~=-999, colIndex));
                                        temp_data(NT, colIndex) = avgTT;
                                        for ss = first+1:NT-1
                                            temp_data(ss, colIndex) = temp_data(first, colIndex) + (ss-first)/(NT-first)*(temp_data(NT, colIndex) - temp_data(first, colIndex));
                                        end
                                    end
                                else
                                    if last > 0
                                        % If only the last is observed
                                        avgTT = mean(slot_data(slot_data(:,colIndex)~=-999, colIndex));
                                        temp_data(1, colIndex) = avgTT;
                                        for ss = 2:last-1
                                            temp_data(ss, colIndex) = temp_data(1, colIndex) + (ss-1)/(last-1)*(temp_data(last, colIndex) - temp_data(1, colIndex));
                                        end
                                    else
                                        % None observed, fill with avgTT
                                        avgTT = mean(slot_data(slot_data(:,colIndex)~=-999, colIndex));
                                        for ss = 1:NT
                                            temp_data(ss, colIndex) = avgTT;
                                        end
                                    end
                                end
                                % Everything is filled, then add it to the case
                                temp_cases{ncases}{varID, t} = temp_data(t, colIndex);
                                
                            end
                        end
                    end
                end
            end
            
            ncases = ncases + 1;
            slot_index = slot_index + slide_size;
        else
            slot_index = slot_index + 1;
        end
        
    end
end
ncases = ncases - 1;
cases = temp_cases(1,1:ncases);