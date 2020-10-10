%% function: initialize the data
function [Ab, A, V, T, X] = init_cycle_data(tempDir1, tempDir2, v_val, b_prev, phase_start, mode)
Nx = length(tempDir1(:,1)) + length(tempDir2(:,1));
T = zeros(Nx, 1);
V = zeros(Nx, 1);
X = zeros(Nx, 1);
n = length(tempDir1(:,1));
tval = [-1, 1]'; 
for i=1:n
    T(i,1) = -1;
    V(i,1) = v_val(1,1);
    X(i,1) = tempDir1(i,1) - phase_start;
end

for i = 1:length(tempDir2(:,1))
    T(i + n, 1) = 1;
    V(i + n, 1) = v_val(2,1);
    X(i + n ,1) = tempDir2(i,1) - phase_start;
end
% If mode = 1: dual problem, otherwise, primal problem
if mode == 1
    A = 0.1*ones(Nx, 1);
    Ab = [A;b_prev];
else
    % A is now \xi
    A = 0.1*ones(Nx, 1);
    Ab = [A;1;b_prev];
end
    