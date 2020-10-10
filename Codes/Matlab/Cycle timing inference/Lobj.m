%% Cycle inference objective function
function [fval, fgrad] = Lobj(Ab, V, T, X, b_prev, eta)
Nx = length(Ab)-1;
A = Ab(1:Nx,1);
b = Ab(Nx+1,1);
Mvec = A.*V.*T;
Wvec = Mvec.*(X - b*ones(Nx,1));
sumW = sum(Wvec);
fval = -0.5*sum(sum(Wvec*Wvec')) + sum(A) - 0.5*eta*(b-b_prev)*(b-b_prev);
fgrad = zeros(Nx+1,1);
for i = 1:Nx
    fgrad(i,1) = 1 - V(i)*T(i)*(X(i)-b)*sumW;
end
fgrad(Nx+1,1) = sum(Mvec)*sumW - eta*(b-b_prev);

fval = -fval;
fgrad = -fgrad;

