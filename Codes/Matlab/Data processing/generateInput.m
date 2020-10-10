%% Generate the input data for learning the DBN model
clear;clc;
%% Configurations
start_times = [7.5;9.5;13.5;17];
end_times = [9;12;16.5;19];
% Length for each time slot
slot_length = 180;
% Number of time slices for the DBN
NT = 4;
% Sliding window step size: increase data size
slide_size = 3;
dates = {'11', '12', '14', '15', '16', '17'};
NVar = 30;
linkTT_startIndex = 18;
scale_factor = 0.1;
link_config;
inputVar_mapping = input_data_mapping_smallP1;

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
%     slotFilename = strcat('C:\Temp\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\SlotData\4State\', date, '_slotted.csv');
    slotFilename = strcat('D:\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\SlotData\4State\', date, '_slotted.csv');
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
                            if colIndex >= linkTT_startIndex
                                temp_cases{ncases}{varID, t} = val * scale_factor;
                            else
                                temp_cases{ncases}{varID, t} = val;
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