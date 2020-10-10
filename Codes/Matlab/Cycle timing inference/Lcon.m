%% Cycle inference cosntraint function
function [c, ceq] = Lcon(Ab, V, T, X, b_prev, eta)
Nx = length(Ab)-1;
A = Ab(1:Nx,1);
b = Ab(Nx+1,1);
c = 0;
Mvec = A.*V.*T;
Wvec = Mvec.*(X - b*ones(Nx,1));
ceq = eta*(b-b_prev)/sum(Wvec) + sum(Mvec);
% ceq = sum(Wvec)* sum(Mvec);