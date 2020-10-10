%% Training the DBN
clear;clc;
% Disable warnings
% warning('off', 'MATLAB:singularMatrix');

% Generate the DBN graph
generateGraph_smallP1;
% Loading the cases for training
cases = importdata('smallP1_NT4_SL2_S4_scale0.1.mat');
% cases = importdata('C:\Temp\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\CaseData\smallP2_NT4_SL4_S3.mat');
% cases = importdata('D:\Dropbox\China Camera Data\Network LPR\Matlab\Data processing\CaseData\small_NT4_SL4.mat');
% cases = cases(1:10);


% Inference engine
% engine = smoother_engine(jtree_2TBN_inf_engine(bnet));
% engine = jtree_dbn_inf_engine(bnet);
engine = jtree_unrolled_dbn_inf_engine(bnet, 4);

% Parameter learning through EM
tic;
[bnet2, LLtrace] = learn_params_dbn_em(engine, cases, 'max_iter', 25, 'thresh', 1e-6);
toc;
save('trainedDBN_smallP1_NT4_SL2_S4_diag_WS_scale0.1_Iter25.mat');