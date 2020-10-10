%% Queue length approximation
function [theta, tau, ql, muX0, oversaturate] = Gaussian_approx(theta, y, x, para)
N = length(x);
if N == 0
    theta = [0, 0, 0]';
    tau = 0;
    ql = 0;
    muX0 = y;
    oversaturate = 0;
else
    xini = x(1);
    yini = y(1);
    y = y - yini + 1;
    x = x - xini;
    TR = para(1,1);
    TG = para(2,1);
    h0 = para(3,1);
    lambda = para(4,1);
    neta = para(5,1);

    Niter = 7000;
    burn_in = 0.75;
    MH_theta = zeros(3,Niter);
    theta_p = theta;
    oversaturate = 0;
    
    n = 1;
    %% MCMC
    for k = 1:Niter
        if k>1 % first iteration, use initial theta
            % Sample new values
            theta(3,1) = rand() * TG * 1.25;
            theta(1,1) = rand() * N / theta(3,1);
            theta(2,1) = rand() * theta(1,1);
%             theta(2,1) = rand() * N / theta(3,1);
        end

        % Construct Gaussian kernel
        muX0 = zeros(N,1);
        % Two cases:
        if theta(3,1) >= TG
            for i = 1:N
                % two segments
                if x(i) <= TG
                    muX0(i,1) = theta(1,1) * x(i);
                else
                    muX0(i,1) = theta(1,1) * TG;
                end
            end
        else
            for i = 1:N
                if x(i) <= theta(3,1)
                    muX0(i,1) = theta(1,1)*x(i);
                else
                    if x(i) < TG
                         muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(x(i)-theta(3,1));
                    else
                        muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(TG-theta(3,1));
                    end
                end
            end
        end
%         for i = 1:N
%             if x(i) <= theta(3,1)
%                 muX0(i,1) = theta(1,1)*x(i);
%             else
%                 if x(i) < TG
%                      muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(x(i)-theta(3,1));
%                 else
%                     muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(TG-theta(3,1));
%                 end
%             end
%         end

        % Covariance matrix
        K00 = zeros(N,N);
        for i = 1:N
            for j = i+1:N
                K00(i,j)=KerXX(x(i,1),x(j,1),h0,lambda,neta);
            end
        end
        K00=K00+K00';
        for i=1:N
            K00(i,i)=K00(i,i)+KerXX(x(i,1),x(i,1),h0,lambda,neta);
        end

        Mstar=muX0;
        Cstar=K00;

        if k==1
            M_p=Mstar;
            C_p=Cstar;
            p_p=log(mvnpdf(y,M_p,C_p));
            MH_theta(:,1)=theta;
            n=n+1;
        else
            p_star=log(mvnpdf(y,Mstar,Cstar));
            r=min(p_star-p_p,0);
            if log(rand())<=r && p_star~=-Inf
                MH_theta(:,n)=theta;
                M_p=Mstar;
                C_p=Cstar;
                theta_p=theta;
                p_p = p_star;
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

    % get posterior mean
    for i=1:3
        theta(i,1)=mean(MH_theta(i,:));
    end

    % Re-evaluate prediction
    % Construct Gaussian kernel
     muX0 = zeros(N,1);
    % Two cases:
    if theta(3,1) >= TG
        for i = 1:N
            % two segments
            if x(i) <= TG
                muX0(i,1) = theta(1,1) * x(i);
            else
                muX0(i,1) = theta(1,1) * TG;
            end
        end
    else
        for i = 1:N
            if x(i) <= theta(3,1)
                muX0(i,1) = theta(1,1)*x(i);
            else
                if x(i) < TG
                     muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(x(i)-theta(3,1));
                else
                    muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(TG-theta(3,1));
                end
            end
        end
    end
    
%     for i = 1:N
%             if x(i) <= theta(3,1)
%                 muX0(i,1) = theta(1,1)*x(i);
%             else
%                 if x(i) < TG
%                      muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(x(i)-theta(3,1));
%                 else
%                     muX0(i,1) = theta(1,1) * theta(3,1) + theta(2,1)*(TG-theta(3,1));
%                 end
%             end
%         end
    muX0 = muX0 + yini - 1;

    % Final tau value
    tau = theta(3,1);
    if tau < TG * 0.98
        % check rates
        if theta(3,1) >=0.2 && tau < 10
            % The normal arrival rate is way too high, both belong to the
            % saturated regime
            ql = N;
            tau = TG;
            theta(3,1) = tau;
            oversaturate = 1;
        else
            queueItems = x(x<tau);
            ql = length(queueItems);
        end
    else
        if theta(1,1) < 0.2
            ql = 0;
        else
            ql = N; % N or N above
            oversaturate = 1;
        end
    end
end