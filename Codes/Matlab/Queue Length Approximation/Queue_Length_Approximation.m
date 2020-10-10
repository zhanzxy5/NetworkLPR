%% Queue length approximation test
clear;clc;
%% Load the old link-based data for testing
raw_data=importdata('LF_11_26_departure.txt');
Nraw=length(raw_data(:,1));
% here you can choose the record range 
up=length(raw_data(:,1));
down=5;
lane=2;

% Cycles to be tested
Iint_min=1;
Iint_max=120;

data=raw_data(raw_data(:,1)<=up&raw_data(:,1)>=down,:);
data=data(data(:,13)==lane,:);
% Data format
% 1:ID 2:TTmin 3:TT 4:arr-h 5:arr-m 6:arr-s 7:dep-h 8:dep-m 9:dep-s
% 10:arr-direction 11:arr-lane 12:dep_direction 13:dep_lane
N=length(data(:,1));
data(:,1)=(1:N)'; % re-indexing

%% Hyper parameters for the Gaussian interpolation model
h0=0.5;
lambda=2;
neta=1;

%% Draw departure curve
departT=zeros(N,2);% 1-ID, 2-time stamp, (3-speed)
departT(:,1)=data(:,1);
departT(:,2)=3600*data(:,7)+60*data(:,8)+data(:,9);
% departT(:,3)=data(:,15);
scatter(departT(:,2),departT(:,1),'.k');
hold on;
stairs(departT(:,2),departT(:,1),'-b');
hold on;

% Load the cycle times
bpara = importdata('bpara_11_26_downstream.txt');
offset = 4;

% bpara = importdata('Cycle timing inference/Benchmark results/result_c0.1_eta0.02_0.5-1_140.mat');
% offset = 0;
b = bpara(:,1);
b = b + offset;
for i=1:length(b)
    plot([b(i),b(i)]', [1, N]', ':k');
    hold on;
    plot([b(i)+bpara(i,4),b(i)+bpara(i,4)]', [1, N]', ':r');
    hold on;
end

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

queue_length = zeros(Iint_max - Iint_min + 1, 7); % Interval; queue length; tau; Nveh; r1; r2; oversaturate
n = 1;

tic;
for Iint=Iint_min:Iint_max
    fprintf('Computing cycle %d\n',Iint);
    para(1,1) = bpara(Iint,4); % red time
    para(2,1) = bpara(Iint, 3); % green time
    
    % Preparing data
    Tstart = b(Iint,1);
    Tend = b(Iint+1,1);
    tempData = departT(departT(:,2)>=Tstart, :);
    tempData = tempData(tempData(:,2)<Tend, :);
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
    plot(x0, muX0, '--g');
    hold on;
    
    queue_length(Iint-Iint_min + 1, :) = [Iint, ql, tau, length(y0), theta(1,1), theta(2,1), oversaturate];
end
toc;