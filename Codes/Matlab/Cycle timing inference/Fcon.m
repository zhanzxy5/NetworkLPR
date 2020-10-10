%% Cycle inference cosntraint function: primal problem
function [c, ceq] = Fcon(WX, V, T, X)
N = length(X);
xi = WX(1:N,1);
w = WX(N+1,1);
b = WX(N+2,1);

Mvec = V.*T.*(X - b*ones(N,1));
c = ones(N,1) - xi - w * Mvec;
ceq = 0;
% ceq = sum(Wvec)* sum(Mvec);