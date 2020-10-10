%% Plot signal cycle estimation results
% whether 1- plot single trace with reference lines;
%         2- plot trace only
%         3- test/bench results
%         4- plot data with the given bpara_data
plot_trace = 4;
bpara_data_name = '17_1310000034_1.csv';
start_hour = 7;
end_hour = 20;

switch plot_trace
    case 1
        %% plot the trace
        NT = length(bpara_data(:,1));
        subplot(3, 1, 1);
        plot(bpara_data(1:NT,1), bpara_data(1:NT,3),'o-b');
        hold on;
        plot([bpara_data(1,1), 31950, 31950, bpara_data(NT,1)], [64, 64, 62, 62], 'k');
        % title('Green Phase length', 'FontSize', 12);
        legend('Green Phase length', 'True length');
        xlabel('Time (seconds)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);

        subplot(3, 1, 2);
        plot(bpara_data(1:NT,1), bpara_data(1:NT,4),'o-r');
        hold on;
        plot([bpara_data(1,1), 31950, 31950, bpara_data(NT,1)], [56, 56, 38, 38], 'k');
        % title('Red Phase length', 'FontSize', 12);
        legend('Red Phase length', 'True length');
        xlabel('Time (seconds)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);

        subplot(3, 1, 3);
        plot(bpara_data(1:NT,1), bpara_data(1:NT,2),'o-c');
        hold on;
        plot([bpara_data(1,1), 31950, 31950, bpara_data(NT,1)], [120, 120, 100, 100], 'k');
        % title('Signal Cycle length', 'FontSize', 12);
        legend('Signal Cycle length', 'True length');
        xlabel('Time (seconds)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);

        %% Compute the metrics
        Nplan = 2;
        TCplan = [bpara_data(1,1), 31950, bpara_data(NT,1)];
        TL = [120;100];
        GL = [64;62];
        RL = [56;38];
        MAE_T = 0;
        MAE_G = 0;
        MAE_R = 0;
        sumT = 0;
        sumG = 0;
        sumR = 0;

        % calculation
        plan = 1;
        for i = 1:length(bpara_data(:,1))
            for j = 1:length(TCplan)-1
                if TCplan(j) <= bpara_data(i,1) && TCplan(j+1) > bpara_data(i,1)
                    plan = j;
                end
                MAE_T = MAE_T+abs(bpara_data(i,2)-TL(plan));
                sumT = sumT + TL(plan);
                MAE_G = MAE_G+abs(bpara_data(i,3)-GL(plan));
                sumG = sumG + GL(plan);
                MAE_R = MAE_R+abs(bpara_data(i,4)-RL(plan));
                sumR = sumR + RL(plan);
            end
        end
        MRE_T = MAE_T/sumT;
        MRE_G = MAE_G/sumG;
        MRE_R = MAE_R/sumR;
        MAE_T = MAE_T/NT;
        MAE_G = MAE_G/NT;
        MAE_R = MAE_R/NT;
        fprintf('Number of Signal Cycles=\t%d\n',NT);
        fprintf('Cycle length\tMAE=\t%f\tMRE=\t%f\n', MAE_T, MRE_T);
        fprintf('Green phase length\tMAE=\t%f\tMRE=\t%f\n', MAE_G, MRE_G);
        fprintf('Red phase length\tMAE=\t%f\tMRE=\t%f\n', MAE_R, MRE_R);
    case 2
        %% plot single trace only
        NT = length(bpara_data(:,1));
        subplot(3, 1, 1);
        plot(bpara_data(1:NT,1)/3600, bpara_data(1:NT,3),'o-b');
        % title('Green Phase length', 'FontSize', 12);
        xlabel('Time (seconds)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);

        subplot(3, 1, 2);
        plot(bpara_data(1:NT,1)/3600, bpara_data(1:NT,4),'o-r');
        % title('Red Phase length', 'FontSize', 12);
        xlabel('Time (seconds)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);

        subplot(3, 1, 3);
        plot(bpara_data(1:NT,1)/3600, bpara_data(1:NT,2),'o-c');
        % title('Signal Cycle length', 'FontSize', 12);
        xlabel('Time (seconds)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);
    case 3
        %% plot the comparison graph
        % import data
        bpara_data = importdata('Cycle timing inference/Benchmark results/result_c0.1_eta0.02_0.5-1_140.mat');
        bench_bpara_data = importdata('Cycle timing inference/Benchmark results/bench_c0.1_eta0_0.5-1_140.mat');

        bpara_data(:,1) = bpara_data(:,1)/3600;
        bench_bpara_data(:,1) = bench_bpara_data(:,1)/3600;

        NT = length(bpara_data(:,1));
        subplot(3, 1, 1);
        plot(bpara_data(1:NT,1), bpara_data(1:NT,3),'o-b','MarkerSize', 5);
        hold on;
        plot(bench_bpara_data(1:NT,1), bench_bpara_data(1:NT,3),'x-k');
        hold on;
        plot([bpara_data(1,1), 31950/3600, 31950/3600, bpara_data(NT,1)], [64, 64, 62, 62], 'k', 'LineWidth', 1.5);
        title('Green Phase length', 'FontSize', 12);
        legend('CWSMM', 'Benchmark: WSMM', 'True length');
        xlabel('Time (Hours)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);

        subplot(3, 1, 2);
        plot(bpara_data(1:NT,1), bpara_data(1:NT,4),'o-r');
        hold on;
        plot(bench_bpara_data(1:NT,1), bench_bpara_data(1:NT,4),'x-k');
        hold on;
        plot([bpara_data(1,1), 31950/3600, 31950/3600, bpara_data(NT,1)], [56, 56, 38, 38], 'k', 'LineWidth', 1.5);
        title('Red Phase length', 'FontSize', 12);
        legend('CWSMM', 'Benchmark: WSMM', 'True length');
        xlabel('Time (Hours)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);

        subplot(3, 1, 3);
        plot(bpara_data(1:NT,1), bpara_data(1:NT,2),'o-c');
        hold on;
        plot(bench_bpara_data(1:NT,1), bench_bpara_data(1:NT,2),'x-k');
        hold on;
        plot([bpara_data(1,1), 31950/3600, 31950/3600, bpara_data(NT,1)], [120, 120, 100, 100], 'k', 'LineWidth', 1.5);
        title('Signal Cycle length', 'FontSize', 12);
        legend('CWSMM', 'Benchmark: WSMM', 'True length');
        xlabel('Time (Hours)', 'FontSize', 12);
        ylabel('Seconds', 'FontSize', 12);
    case 4
        %% Plot with the saved bpara data and raw LPR data
        strList = strsplit(bpara_data_name, '_');
        date = strList{1};
        intersectionID = strList{2};
        dirList = strsplit(strList{3}, '.');
        dir = str2num(dirList{1});
        bpara_data = importdata(bpara_data_name);
        NT = length(bpara_data(:,1));
        
        % Get data
        if dir == 1
            op_dir = 2;
        else
            op_dir = 1;
        end
        
        % Load data
        filename = strcat('C:/Temp/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', intersectionID, '.txt');
%         filename = strcat('D:/Dropbox/China Camera Data/Network LPR/Data/New Data/new_data_with_wp/', date, '/', intersectionID, '.txt');
        delimiterIn = '\t';
        headerlinesIn = 1;
        rawData = importdata(filename,delimiterIn,headerlinesIn);
        rawTimeData = rawData.data;
        config_intersection;
        
        % Time length set up
        start_time = start_hour * 3600;
        end_time = end_hour * 3600;
        
        % Data Extraction
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
        
        % Plotting
        plot(dataDir1(:,1)/3600, 0.5*ones(length(dataDir1(:,1)),1), '.b');
        hold on;
        plot(dataDir2(:,1)/3600, 1.5*ones(length(dataDir2(:,1)),1), '.r');
        hold on;
        
        % Plotting phase
        for i = 1:NT
            plot([bpara_data(i,1)/3600, bpara_data(i,1)/3600], [0;2], 'k');
            hold on;
            if dir == 1
                plot([(bpara_data(i,1) + bpara_data(i,3))/3600, (bpara_data(i,1) + bpara_data(i,3))/3600], [0;2], 'g');
            else
                plot([(bpara_data(i,1) + bpara_data(i,4))/3600, (bpara_data(i,1) + bpara_data(i,4))/3600], [0;2], 'g');
            end
            hold on;
        end
end
