%% Cycle inference objective function: primal problem
function [fval, fgrad] = Fobj_primal(WX, X, b_prev, eta, C)
N = length(X);
xi = WX(1:N,1);
w = WX(N+1,1);
b = WX(N+2,1);

fval = 0.5 * w * w + C * sum(xi) + 0.5 * eta * (b - b_prev) * (b - b_prev);
fgrad = zeros(N+2,1);
fgrad(1:N,1) = ones(N,1) * C;
fgrad(N+1,1) = w;
fgrad(N+2,1) = eta * (b - b_prev);