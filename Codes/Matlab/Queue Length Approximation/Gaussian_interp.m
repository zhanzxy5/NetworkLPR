%% Interpolation using Gaussian process
function [theta,Mx,My]=Gaussian_interp(theta,y0,x0,para,t0,yini)
% ¦È=1: r_(T_s ), 2: r_(T_n ), 3: r_R, 4: r_(L_s ), 5: r_(L_n ), 6: t_a, 7: t_b
x0=x0-t0;
y0=y0-yini;
x=(0:para(5,1))';
N=length(x);
x=setdiff(x,x0);
N0=length(x0);
Ny=y0(N0)-y0(1)+1;

h0=para(6,1);
lambda=para(7,1);
neta=para(8,1);
rho=0.4;

Niter=10000;
burn_in=0.5; % burn-in ratio
MH_theta=zeros(10,Niter);
theta_p=theta;
% M_p=zeros(N-N0,1);
% C_p=eye(N-N0);

n=1;
%% MCMC
for k=1:Niter
    if k>1 % first iteration, use initial theta
        %% sample new values
        theta(6,1)=rand()*para(1,1);
        theta(7,1)=max(rand()-rho,0)*para(4,1)/(1-rho);
        theta(1,1)=max(rand()-rho,0)*Ny/theta(6,1)/(1-rho);
        theta(2,1)=max(rand()-rho,0)*Ny/(1-theta(1,1))/(1-rho);
        theta(3,1)=max(rand()-rho,0)*Ny/para(5,1)/(1-rho);
        theta(4,1)=min(max(rand()-rho,0)*Ny/theta(6,1),Ny/theta(7,1))/(1-rho);
        theta(5,1)=max(rand()-rho,0)*theta(4,1)/(1-rho);
        
        theta(1,1)=min(theta(1,1),1);
        theta(2,1)=min(theta(2,1),1);
        theta(3,1)=min(theta(3,1),1);
        theta(4,1)=min(theta(4,1),1);
        theta(5,1)=min(theta(5,1),1);

        theta(8,1)=rand()*10;
        theta(9,1)=rand()*10;
        theta(10,1)=rand()*10;
    end
    para(6:8,1)=theta(8:10);
    h0=para(6,1);
    lambda=para(7,1);
    neta=para(8,1);
    %% construct Gaussian kernel
    % compute mu(x)
    muX0=zeros(N0,1);
%     muXu=zeros(N-N0,1);
    for i=1:N0
        muX0(i,1)=mut(theta,x0(i),para);
    end
%     for i=1:N-N0
%         muXu(i,1)=mut(theta,x(i),para,t0);
%     end
    % covariance matrix
    K00=zeros(N0,N0);
%     Ku0=zeros(N-N0,N0);
%     Kuu=zeros(N-N0,N-N0);
    % compute K(x0,x0)
    for i=1:N0
        for j=i+1:N0
            K00(i,j)=KerXX(x0(i,1),x0(j,1),h0,lambda,neta);
        end
    end
    K00=K00+K00';
    for i=1:N0
        K00(i,i)=K00(i,i)+KerXX(x0(i,1),x0(i,1),h0,lambda,neta);
    end
%     % compute K(xu,x0)
%     for i=1:N-N0
%         for j=1:N0
%             Ku0(i,j)=KerXX(x(i,1),x0(j,1),h0,lambda,neta);
%         end
%     end
%     % compuate K(xu,xu)
%     for i=1:N-N0
%         for j=i+1:N-N0
%             Kuu(i,j)=KerXX(x(i,1),x(j,1),h0,lambda,neta);
%         end
%     end
%     Kuu=Kuu+Kuu';
%     for i=1:N-N0
%         Kuu(i,i)=Kuu(i,i)+KerXX(x(i,1),x(i,1),h0,lambda,neta);
%     end

%     % construct kernel
%     Mstar=muXu+Ku0*(K00\(y0-muX0));
%     Cstar=Kuu-Ku0*(K00\Ku0');
    Mstar=muX0;
    Cstar=K00;
    
    if k==1
        M_p=Mstar;
        C_p=Cstar;
        p_p=log(mvnpdf(y0,M_p,C_p));
        MH_theta(:,1)=theta;
        n=n+1;
    else
        p_star=log(mvnpdf(y0,Mstar,Cstar));
        r=min(p_star-p_p,0);
        if log(rand())<=r && p_star~=-Inf
            MH_theta(:,n)=theta;
            M_p=Mstar;
            C_p=Cstar;
            theta_p=theta;
%             fprintf('Totiter=%d\tIter=%d\tP_star=%f\tta=%f\ttb=%f\n',k,n,p_star,theta(6,1),theta(7,1));
            n=n+1;
        else
            theta=theta_p;
        end
    end
end
MH_theta=MH_theta(:,1:n-1);
% throw out burn-in
Nburn=floor(burn_in*n);
MH_theta=MH_theta(:,Nburn:n-1);
% filtering: twice
for k=1:2
    for i=1:7
        mtemp=mean(MH_theta(i,:));
        stdtemp=std(MH_theta(i,:));
        MH_theta=MH_theta(:,(MH_theta(i,:)>mtemp-5*stdtemp)&(MH_theta(i,:)<mtemp+5*stdtemp));
    end
end

% get posterior mean
for i=1:7
    theta(i,1)=mean(MH_theta(i,:));
end

%% Perform prediction
% re-evaluate Gaussian kernel
% compute mu(x)
    muX0=zeros(N0,1);
    muXu=zeros(N-N0,1);
    for i=1:N0
        muX0(i,1)=mut(theta,x0(i),para);
    end
    for i=1:N-N0
        muXu(i,1)=mut(theta,x(i),para);
    end
    % covariance matrix
    K00=zeros(N0,N0);
    Ku0=zeros(N-N0,N0);
    Kuu=zeros(N-N0,N-N0);
    % compute K(x0,x0)
    for i=1:N0
        for j=i+1:N0
            K00(i,j)=KerXX(x0(i,1),x0(j,1),h0,lambda,neta);
        end
    end
    K00=K00+K00';
    for i=1:N0
        K00(i,i)=K00(i,i)+KerXX(x0(i,1),x0(i,1),h0,lambda,neta);
    end
    % compute K(xu,x0)
    for i=1:N-N0
        for j=1:N0
            Ku0(i,j)=KerXX(x(i,1),x0(j,1),h0,lambda,neta);
        end
    end
    % compuate K(xu,xu)
    for i=1:N-N0
        for j=i+1:N-N0
            Kuu(i,j)=KerXX(x(i,1),x(j,1),h0,lambda,neta);
        end
    end
    Kuu=Kuu+Kuu';
    for i=1:N-N0
        Kuu(i,i)=Kuu(i,i)+KerXX(x(i,1),x(i,1),h0,lambda,neta);
    end

    % construct kernel
    Mstar=muXu+Ku0*(K00\(y0-muX0));
    Cstar=Kuu-Ku0*(K00\Ku0');
    
    % recompile the solution
    Mx=(1:N)'+t0-1;
    My=zeros(N,3);
    for i=1:length(x0)
        My(x0(i)+1,1)=y0(i);
        My(x0(i)+1,2)=My(x0(i)+1,1);
        My(x0(i)+1,3)=My(x0(i)+1,1);
    end
    n=1;
    for i=1:N-1
        if sum(x0==i-1)==0
            My(i,1)=Mstar(n,1);
            My(i,2)=My(i,1)-1*sqrt(Cstar(n,n));
            My(i,3)=My(i,1)+1*sqrt(Cstar(n,n));
            n=n+1;
        end
    end
    My(:,1)=My(:,1)+yini;
    My(:,2)=My(:,2)+yini;
    My(:,3)=My(:,3)+yini;