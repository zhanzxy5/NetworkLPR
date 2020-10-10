% obtain the posterior mean and variance from Gaussian process
function c=KerXX(x1,x2,h0,lambda,neta)
c=h0*exp(-(x1-x2)^2/lambda);
if x1==x2
    c=c+neta^2;
end