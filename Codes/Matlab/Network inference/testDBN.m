%% Testing the performance of the results
clear;clc;
%% Load the learned DBN
load('trainedDBN_smallP2_NT4_SL4_S4_diag_scale0.1_improve_Iter20.mat');

% Test engine
test_engine = jtree_unrolled_dbn_inf_engine(bnet2, 4);

%% Reload filtered case data
% cases = importdata('smallP1_NT4_SL4_S4_scale0.1_filter.mat');

%% Configuration
% % For Link 102: small P1
% VarID = L102T;
% FFTT = 653.52/14.0601569; 

% % For Link 103: small P1
% VarID = L103T; 
% FFTT = 640.93/14.79511808;

% % For Link 105: small P1
% VarID = L105T;
% FFTT = 740.43/22.43727273;

% % For Link 24: small P2
% VarID = L24T;
% FFTT = 551.61/13.03904105;

% For Link 25: small P2
VarID = L25T;
FFTT = 578.94/13.90399403;

% % For Link 26: small P2
% VarID = L26T;
% FFTT = 524.77/6.226356805;

% % For Link 27: small P2
% VarID = L27T;
% FFTT = 595.88/21.25129487;

% % For Link 28: small P2
% VarID = L28T;
% FFTT = 623.5/19.5250947;

% % For Link 29: small P2
% VarID = L29T;
% FFTT = 618.11/6.526319566;

NT = 4;

%% Prepare testing data
ntest = length(cases)/6;

% Get the cases 
test_cases = cases(1, ntest*3+1:ntest*4);

ground_truth = zeros(ntest, NT);

for i = 1:ntest
    for j = 1:NT
        if ~isempty(test_cases{1,i}{VarID, j})
            ground_truth(i, j) = test_cases{1,i}{VarID, j};
            test_cases{1,i}{VarID, j} = [];
        else
            ground_truth(i, j) = -999;
        end
    end
end

%% Now get the marginal distribution
results = cell(ntest,NT);
results_mean = zeros(ntest, NT);
results_std = zeros(ntest, NT);

tic;
for i = 1:ntest
    evidence = test_cases{1, i};
    [test_engine, loglik] = enter_evidence(test_engine, evidence);
    for j = 1:NT
        marg = marginal_nodes(test_engine, VarID, j);
        results{i, j} = marg;
        results_mean(i, j) = marg.mu;
        results_std(i, j) = sqrt(marg.Sigma);
    end
    fprintf('Inference case: %d\n', i);
end
toc;
%% Evaluation
% Convert the results into a vector and handle the missing cases
vect_GT = reshape(ground_truth, [ntest*NT, 1]);
vect_avg = reshape(results_mean, [ntest*NT, 1]);
vect_std = reshape(results_std, [ntest*NT, 1]);
xData = [27000;27180;27360;27540;27720;27900;28080;28260;28440;28620;28800;28980;29160;29340;29520;29700;29880;30060;30240;30420;30600;30780;30960;31140;31320;31500;31680;31860;34200;34380;34560;34740;34920;35100;35280;35460;35640;35820;36000;36180;36360;36540;36720;36900;37080;37260;37440;37620;37800;37980;38160;38340;38520;38700;38880;39060;39240;39420;39600;39780;39960;40140;40320;40500;40680;40860;41040;41220;41400;41580;41760;41940;42120;42300;42480;42660;48600;48780;48960;49140;49320;49500;49680;49860;50040;50220;50400;50580;50760;50940;51120;51300;51480;51660;51840;52020;52200;52380;52560;52740;52920;53100;53280;53460;53640;53820;54000;54180;54360;54540;54720;54900;55080;55260;55440;55620;55800;55980;56160;56340;56520;56700;56880;57060;57240;57420;57600;57780;57960;58140;58320;58500;58680;58860;59040;59220;61200;61380;61560;61740;61920;62100;62280;62460;62640;62820;63000;63180;63360;63540;63720;63900;64080;64260;64440;64620;64800;64980;65160;65340;65520;65700;65880;66060;66240;66420;66600;66780;66960;67140;67320;67500;67680;67860;68040;68220];
% Get rid of missing entries
vect_avg = vect_avg(vect_GT~=-999,1) * 10;
vect_std = vect_std(vect_GT~=-999,1) * 10;
xData = xData(vect_GT~=-999,1);
vect_GT = vect_GT(vect_GT~=-999,1) * 10;

N = length(vect_avg);
Diff = abs(vect_avg-vect_GT);
MAE = sum(Diff)/N;
RMSE = sqrt(sum(Diff.*Diff)/N);
MAPE = sum(Diff./(vect_GT + FFTT))/N;
% Compute the amount of data that fall within mu+/-std
conf_count = (vect_GT<=(vect_avg+vect_std)).*(vect_GT>=(vect_avg-vect_std));
conf_count2 = (vect_GT<=(vect_avg+2*vect_std)).*(vect_GT>=(vect_avg-2*vect_std));
fprintf('VarID=%d\tMAE=\t%f\tRMSE=\t%f\tMAPE=\t%f\nmu+/-std=\t%f\tmu+/-2std=\t%f\n', VarID, MAE, RMSE, MAPE, sum(conf_count)/N, sum(conf_count2)/N);

%% Plot all results
% Determine the indices for the four time intervals
startIndices = zeros(4,1);
endIndices = zeros(4,1);
startIndices(1,1) = 1;
endIndices(4,1) = length(xData);
temp_n = 1;
for i = 1:length(xData)-1
    if xData(i+1,1) - xData(i,1) > 360
        startIndices(temp_n+1,1) = i+1;
        endIndices(temp_n,1) = i;
        temp_n = temp_n+1;
    end
end
xData = (xData + 90)/3600;
for i = 1:4
    plot(xData(startIndices(i,1):endIndices(i,1),1), vect_GT(startIndices(i,1):endIndices(i,1),1) + FFTT, '-b');
    hold on;
    plot(xData(startIndices(i,1):endIndices(i,1),1), vect_avg(startIndices(i,1):endIndices(i,1),1) + FFTT, '-r');
    hold on;
    plot(xData(startIndices(i,1):endIndices(i,1),1), vect_avg(startIndices(i,1):endIndices(i,1),1) + vect_std(startIndices(i,1):endIndices(i,1),1) + FFTT, '--c');
    hold on;
    plot(xData(startIndices(i,1):endIndices(i,1),1), vect_avg(startIndices(i,1):endIndices(i,1),1) - vect_std(startIndices(i,1):endIndices(i,1),1) + FFTT, '--c');
    hold on;
end
% Plot unobserved dash lines
for i = 1:4
    plot([xData(startIndices(i,1)); xData(startIndices(i,1))], [0,120], '--k');
    hold on;
    plot([xData(endIndices(i,1)); xData(endIndices(i,1))], [0,120], '--k');
    hold on;
end
xlim([7,19]);
ylim([0,120]);
xlabel('Time (hour)', 'FontSize', 14);
ylabel('Average link travel time (s)', 'FontSize', 14);
hleg = legend('Ground truth','Posterial mean estimate \mu_l^P','\mu_l^P \pm \sigma_l^P');
set(hleg,'FontSize',11)