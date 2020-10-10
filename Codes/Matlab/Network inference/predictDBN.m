%% Testing the prediction performance of the results
clear;clc;
%% Load the learned DBN
load('trainedDBN_smallP2_NT4_SL4_S4_diag_scale0.1_improve_Iter20.mat');

% Test engine
test_engine = jtree_unrolled_dbn_inf_engine(bnet3, 4);

% Reload filtered case data
cases = importdata('smallP2_NT4_SL1_S4_scale0.1.mat');

% prediction slices indices: remove for prediction
predInd = [2, 3, 4];
skip_cases = (1:139);

%% Configuration
% % For Link 102: small P1
% VarID = L102T;
% FFTT = 653.52/14.0601569; 

% For Link 24: small P2
VarID = L24T;
FFTT = 551.61/13.03904105;

% % For Link 25: small P2
% VarID = L25T;
% FFTT = 578.94/13.90399403;

NT = 4;

%% Prepare testing data
ntest = length(cases)/6;

% Get the cases 
test_cases = cases(1, ntest*3+1:ntest*4);

ground_truth = zeros(ntest, length(predInd));

for i = 1:ntest
    for j = 1:length(predInd)
        % Fill all the entries in the predInd
        predI = predInd(j);
        for m = 1:length(test_cases{1,i}(:,1))
            if m == VarID
                if ~isempty(test_cases{1,i}{m, predI})
                    ground_truth(i, j) = test_cases{1,i}{m, predI};
                else
                    ground_truth(i, j) = -999;
                end
            end
            test_cases{1,i}{m, predI} = [];
        end
    end
end

%% Now get the marginal distribution
results = cell(ntest, length(predInd));
results_mean = zeros(ntest,length(predInd));
results_std = zeros(ntest,length(predInd));

tic;
for i = 1:ntest
    if sum(skip_cases==i) > 0
        for j = 1:length(predInd)
            results_mean(i, j) = NaN;
        end
        continue;
    end
    evidence = test_cases{1, i};
    [test_engine, loglik] = enter_evidence(test_engine, evidence);
    for j = 1:length(predInd)
        predI = predInd(j);
        marg = marginal_nodes(test_engine, VarID, predI);
        results{i, j} = marg;
        results_mean(i, j) = marg.mu;
        results_std(i, j) = sqrt(marg.Sigma);
    end
    fprintf('Inference case: %d\n', i);
end
toc;
save('smallP2_414_improve20_24_234_part2.mat');