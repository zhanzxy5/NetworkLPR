%% interpolation algorithm using Gaussin process
clear;clc;
raw_data=importdata('LF_07_09_departure.txt'); % 2014-1-17: 7:00-9:00
Nraw=length(raw_data(:,1));
% relabel the data
raw_data(:,1)=(1:Nraw)';
bpara=importdata('bpara_07_09.mat');
b=bpara(:,1); 
% here you can choose the record range 
up=length(raw_data(:,1))-20;
down=400;%1200;%370;%700;%280;
Iint_min=2;
Iint_max=169;
lane=3;
iniCT=120; % initial cycle length
data=raw_data(raw_data(:,1)<=up&raw_data(:,1)>=down,:);
data=data(data(:,13)==lane,:);
% Data format
% 1:ID 2:TTmin 3:TT 4:arr-h 5:arr-m 6:arr-s 7:dep-h 8:dep-m 9:dep-s
% 10:arr-direction 11:arr-lane 12:dep_direction 13:dep_lane
N=length(data(:,1));
data(:,1)=(1:N)';

h0=0.5;
lambda=0.2;
neta=0.1;
h1=0;

%% Draw departure curve
departT=zeros(N,2);% 1-ID, 2-time stamp, (3-speed)
departT(:,1)=data(:,1);
departT(:,2)=3600*data(:,7)+60*data(:,8)+data(:,9);
% departT(:,3)=data(:,15);
scatter(departT(:,2),departT(:,1),'.k');
hold on;
stairs(departT(:,2),departT(:,1),'-b');
hold on;

%% Arrival curve reconstruction : without speed profile

% plot valid arrivals
% first should be matched
% matched arrival data: 1-ID, 2-time stamp, 3-speed, 4-arr-lane, 5-pt
% type(1-start, 0-intermediate, 2-end), 6 arr-direction
for i=1:N
    if data(i,2)>0
        break;
    end
end
minimumT=data(i,2);
CarrT=zeros(1,6); 
CarrT(1,1)=data(i,1);
CarrT(1,2)=3600*data(i,4)+60*data(i,5)+data(i,6);
CarrT(1,3)=-1; % no speed available
CarrT(1,4)=data(i,11);
CarrT(1,6)=data(i,10);
n=2;% number of valid arrivals in data
n0=i+1;
% First Pass getting all data, initial filtering of FIFO voilation
for i=n0:N
    % only consider through movement,remove left turn
    if (data(i,4)~=-1) &&(data(i,2)>data(i-1,2))
        CarrT(n,1)=data(i,1);
        CarrT(n,2)=3600*data(i,4)+60*data(i,5)+data(i,6);
        CarrT(n,3)=0; % no speed
        CarrT(n,4)=data(i,11);
        CarrT(n,6)=data(i,10);
        n=n+1;
    end
end


% arrT=CarrT;
% Second Pass, further remove FIFO voilation
arrT=zeros(1,6); 
arrT(1:2,:)=CarrT(1:2,:);
n=3;
for i=3:length(CarrT(:,1))-1
    if CarrT(i,2)>CarrT(i-1,2) && CarrT(i,2)>CarrT(i-2,2) && CarrT(i,2)<CarrT(i+1,2)
        arrT(n,:)=CarrT(i,:);
        n=n+1;
    end
end

% all arrival data: 1-ID, 2-time stamp, 3-speed, 4-arr-lane, 
% 5-pt type(1-start_existing, 1.5-start_inferred, 0-intermediate_existing, 0.5-intermediate_inferred, 2-end_existing, 2.5_inferred)
arrD=zeros(N,6);
n=1;
for i=1:N
    if i+data(1,1)-1>max(arrT(:,1))
        break;
    end
    if i==arrT(n,1)-data(1,1)+1
        arrD(i,:)=arrT(n,:);
        n=n+1;
    end
end

%% plot to visualize
    %% plot arrival data
    scatter(arrT(:,2),arrT(:,1),'.r');
    
    % Insert fixcycle time
    CT=iniCT; % Initial cycle length, need to be inputed
    bpara=bpara(bpara(:,1)>data(1,7)*3600+data(1,8)*60+data(1,9)-1*CT & bpara(:,1)<data(N,7)*3600+data(N,8)*60+data(N,9),:);
    b=bpara(:,1);
    Nb=length(b);
    cy=1;
    while cy<=length(b);
        plot([b(cy),b(cy)],[1,N],':k');
        hold on;
        cy=cy+1;
    end
    
    % determine cycle starting point from existing point
    cyc_thresh=10;
    cyc_d_ex=zeros(Nb-1,100);
    cyc_d_exT=zeros(Nb-1,100);
    for i=1:Nb-1
    %     temp_cyc_d=arrT((arrT(:,2)>=b(i)-cyc_thresh)&(arrT(:,2)<b(i+1)-cyc_thresh),1);
        temp_cyc_d=arrT((arrT(:,2)>=b(i)-0.2*cyc_thresh)&(arrT(:,2)<b(i+1)-cyc_thresh),1);
        cyc_d_ex(i,1:length(temp_cyc_d))=temp_cyc_d;
        cyc_d_exT(i,1:length(temp_cyc_d))=arrT((arrT(:,2)>=b(i)-0.2*cyc_thresh)&(arrT(:,2)<b(i+1)-cyc_thresh),2);
    end
    count_es=0;
    cyc_d_start=zeros(Nb-1,1); % starting arrival ID from existing data
    % find starting arrival ID from the existing point
    for i=1:Nb-1
        if cyc_d_ex(i,1)>0
            ind=find(arrT(:,1)==cyc_d_ex(i,1)); % first point
            if abs(arrT(ind,2)-b(i))<=cyc_thresh
                    arrT(ind,5)=1;
                    arrD(arrT(ind,1)-data(1,1)+1,5)=1;
                    arrD(arrT(ind,1)-data(1,1)+1,2)=data(arrT(ind,1)-data(1,1)+1,2);
                    arrD(arrT(ind,1)-data(1,1)+1,1)=data(arrT(ind,1)-data(1,1)+1,1);
                    arrD(arrT(ind,1)-data(1,1)+1,6)=data(arrT(ind,1)-data(1,1)+1,10);
                    arrD(arrT(ind,1)-data(1,1)+1,3)=-1;
                    arrD(arrT(ind,1)-data(1,1)+1,4)=data(ind,11);
                    scatter(arrT(ind,2),arrT(ind,1),'^b');
                    count_es=count_es+1;
                    cyc_d_start(i,1)=cyc_d_ex(i,1);
            else
                if ind>1 % find if previous arrival is in last time interval
                    if arrT(ind-1,1)==cyc_d_ex(i,1)-1
                        arrD(arrT(ind,1)-data(1,1)+1,5)=1;
                        arrD(arrT(ind,1)-data(1,1)+1,2)=data(arrT(ind,1)-data(1,1)+1,2);
                        arrD(arrT(ind,1)-data(1,1)+1,1)=data(arrT(ind,1)-data(1,1)+1,1);
                        arrD(arrT(ind,1)-data(1,1)+1,6)=data(arrT(ind,1)-data(1,1)+1,10);
                        arrD(arrT(ind,1)-data(1,1)+1,3)=-1;
                        arrD(arrT(ind,1)-data(1,1)+1,4)=data(ind,11);
                        scatter(arrT(ind,2),arrT(ind,1),'^b');
                        count_es=count_es+1;
                        cyc_d_start(i,1)=cyc_d_ex(i,1);
                    end
                end
            end
        end
    end
     count_ns=0;
    % infer starting arrival pt from unknown point: using interpolation
    for i=1:Nb-1 % Assuming first cycle has existing starting point
        if cyc_d_start(i,1)==0
            % take out data from the cycle and nearby cycle
            temp_cyc_arr=arrT((arrT(:,2)>=b(i-1))&(arrT(:,2)<=b(i+1)),:);
            temp_n=length(temp_cyc_arr(:,1));
            if temp_n>2 && ~isempty(arrT((arrT(:,2)>=b(i))&(arrT(:,2)<=b(i+1)),:)) && ~isempty(arrT((arrT(:,2)>=b(i-1))&(arrT(:,2)<=b(i)),:)) % 2 consecutive cycles
                % interpolation
                X=temp_cyc_arr(:,1);
                Y=temp_cyc_arr(:,2);
                xi=temp_cyc_arr(1,1):temp_cyc_arr(temp_n,1);
                yi=interp1(X,Y,xi,'pchip');
%                 plot(yi,xi,'g');
                hold on;
                count_ns=count_ns+1;
                % infer the starting point
                for j=1:length(xi)-1
                    if yi(j)<b(i) && yi(j+1)>b(i)
                        [C,I]=min(abs([yi(j),yi(j+1)]-b(i)));
                        ind=xi(j+I-1)-data(1,1)+1;
                        if arrD(ind,1)==0
                            arrD(ind,1)=xi(j+I-1);
                            arrD(ind,2)=b(i);
                            arrD(ind,3)=-1;
                            arrD(ind,4)=0;
                            arrD(ind,5)=1.5;
                            scatter(arrD(ind,2),arrD(ind,1),'^g');
                            hold on;
                            break;
                        else
                            arrD(ind,5)=1;
                            scatter(arrD(ind,2),arrD(ind,1),'^b');
                        end
                    end
                end
                cyc_d_start(i,1)=ind+data(1,1)-1;
            else % 4 consecutive cycles
                if i==Nb-1
                    break;
                end
                temp_cyc_arr=arrT((arrT(:,2)>=b(i-2))&(arrT(:,2)<=b(i+2)),:);
                temp_n=length(temp_cyc_arr(:,1));
                % interpolation
                X=temp_cyc_arr(:,1);
                Y=temp_cyc_arr(:,2);
                xi=temp_cyc_arr(1,1):temp_cyc_arr(temp_n,1);
                yi=interp1(X,Y,xi,'pchip');
    %             plot(yi,xi,'g');
    %             hold on;
                count_ns=count_ns+1;
                % infer the starting point
                for j=1:length(xi)-1
                    if yi(j)<b(i) && yi(j+1)>b(i)
                        [C,I]=min(abs([yi(j),yi(j+1)]-b(i)));
                        ind=xi(j+I-1)-data(1,1)+1;
                        arrD(ind,1)=xi(j+I-1);
                        arrD(ind,2)=b(i);
                        arrD(ind,3)=-1;
                        arrD(ind,4)=0;
                        arrD(ind,5)=1.5;
                        scatter(arrD(ind,2),arrD(ind,1),'^g');
                        break;
                    end
                end
                cyc_d_start(i,1)=ind+data(1,1)-1;
            end
        end
    end
    
%% Getting data for tests
% put all arrivals into each cycle
ACd=zeros(Nb,100);
ACdID=zeros(Nb,100);
arrCDY=zeros(Nb,100);
arrCDX=zeros(Nb,100);
tempD=arrD(arrD(:,1)>0,:);
for i=1:Nb-1
    tempAD=tempD((tempD(:,2)>=b(i))&(tempD(:,2)<b(i+1)),2);
    tempADID=tempD((tempD(:,2)>=b(i))&(tempD(:,2)<b(i+1)),1);
    ACd(i,1:length(tempAD))=tempAD';
    ACdID(i,1:length(tempAD))=tempADID';
end
% Add pseudo reference pont to the end of each records
for i=1:Nb-2
    NACd=sum(ACd(i,:)>0);
    ACd(i,NACd+1)=min(ACd(i+1,1),b(i+1));
    ACdID(i,NACd+1)=ACdID(i+1,1);
end
%% test
% test interval
Iint=7;
theta=zeros(10,1);
% initialize theta
theta(6,1)=10;
theta(7,1)=10;
theta(1,1)=0.1;
theta(2,1)=0.05;
theta(3,1)=0.02;
theta(4,1)=0.06;
theta(5,1)=0.03;
theta(8,1)=h0;
theta(9,1)=lambda;
theta(10,1)=neta;
max_r=1;
rate_r=1.05;

for Iint=Iint_min:Iint_max
    % Signal timeing
    T1=bpara(Iint,3);
    T2=bpara(Iint,4);
    T3=bpara(Iint,5);
    T4=bpara(Iint,6);
    Tcyc=bpara(Iint,2);
    Nc=Tcyc+1;
    
    para=[T1;T2;T3;T4;Tcyc;h0;lambda;neta];
    
    if sum(ACd(Iint))==0
        break;
    end
    fprintf('Creating interpolation for cycle %d\n',Iint);
    testT=ACd(Iint,:)';
    testT=testT(testT>0,:);
    NAC=length(testT);
    testI=ACdID(Iint,1:NAC)';
    scatter(testT(1:NAC-1),testI(1:NAC-1),'sr');
    yini=ACdID(Iint-1,sum(ACdID(Iint-1,:)>0));

    x0=testT;
    y0=testI;
    [theta,Mx,My]=Gaussian_interp(theta,y0,x0,para,b(Iint),yini);
    plot(Mx,My(:,1),'g');
    hold on;
    plot(Mx,My(:,2),'--k');
    hold on;
    plot(Mx,My(:,3),'--k');
    
    %% FIFO filter
    FixY=My(:,1);

    % If posterior mean all below y(i), use linear interpolation between
    % y(i) and y(i+1)
    for i=1:NAC-1
        %find starting index
        int_l=x0(i)-b(Iint)+2;
        % ending index
        int_u=x0(i+1)-b(Iint);
        if int_u>=int_l
            if sum(FixY(int_l:int_u,1)<y0(i))==int_u-int_l+1
                for j=int_l:int_u
                    FixY(j,1)=(y0(i+1,1)-y0(i,1))/(x0(i+1,1)-x0(i,1))*(Mx(j,1)-x0(i,1))+y0(i,1);
%                     scatter(Mx(j,1),FixY(j,1),'^c');
                    hold on;
                end
            end
        end
    end
    
    n=0;
    % Simple FIFO
    for i=2:Nc-1
        if sum(x0==b(Iint)+i-1)==0
            if FixY(i,1)<FixY(i-1,1)
                FixY(i,1)=FixY(i-1,1);
            end
        end
    end
    
    % Filter max flow rate
    n=0;
    for i=1:Nc-1
        if sum(x0==b(Iint)+i-1)==0
            if n==0
                if FixY(i,1)<yini;
                    FixY(i,1)=yini;
                else
                    if FixY(i,1)>y0(n+1)-1
                        % use linear interpolation between My(i,1) and y0(n+1)
                        x0I=x0(n+1)-b(Iint)+1;
                        % do linear interplolation between i-1 and x0I
                        for j=1:x0I-1
                            FixY(j,1)=(y0(n+1,1)-yini)/(x0I-1)*j+yini;
%                             scatter(Mx(j,1),FixY(j,1),'^m');
                            hold on;
                        end
                        i=x0I+1;
                        continue;
                    end
                end
            else
                if FixY(i,1)<y0(n);
                    FixY(i,1)=y0(n);
                else
                    if n+1<=length(y0)
                        if FixY(i,1)>y0(n+1)-1
                            % use linear interpolation between My(i,1) and y0(n+1)
                            % get index of y0(n+1)
                            x0I=x0(n+1)-b(Iint)+1;
                            % do linear interplolation between i-1 and x0I
                            for j=i:x0I-1
                                FixY(j,1)=(y0(n+1,1)-FixY(i-1,1))/(x0I-i+1)*(j-i+1)+FixY(i-1,1);
    %                             scatter(Mx(j,1),FixY(j,1),'^m');
                                hold on;
                            end
                            i=x0I+1;
                            continue;
                        end
                    end
                end
            end
        else
            n=n+1;
        end
    end
    
%     % Flow rate modification, if exceeds max possible flow rate, use
%     linear interpolation before and after
    n=0;
    for i=1:Nc-1
        if sum(x0==b(Iint)+i-1)==0
            if n==0
                % only check what behind
                % index for x0(1)
                x01I=x0(1)-b(Iint)+1;
                for j=2:x01I-1
                    if y0(1)-FixY(j,1)>=max_r*(x01I-j)
                        % linear interpolation between j-1 to x01I
                        for s=j:x01I-1
                            FixY(s,1)=(y0(1,1)-FixY(j-1,1))/(x01I-j+1)*(s-j+1)+FixY(j-1,1);
%                             scatter(Mx(s,1),FixY(s,1),'y');
                            hold on;
                        end
                    end
                end
            else
                % need check both before and after
                x0a=x0(n)-b(Iint)+1;
                x0b=x0(n+1)-b(Iint)+1;
                % if entire flow rate is high
                if y0(n+1,1)-y0(n)>max_r*(x0b-x0a)
                    % linear interpolation
                    for s=x0a+1:x0b-1
                        FixY(s,1)=(y0(n+1,1)-y0(n))/(x0b-x0a)*(s-x0a)+y0(n);
%                         scatter(Mx(s,1),FixY(s,1),'sb');
                        hold on;
                    end
                else
                    flag_backward=0;
                    flag_forward=0;
                    % check flow rate before
                    for j=x0a+1:x0b-1
                        if FixY(j,1)-y0(n)>max_r*(j-x0a)
                            flag_backward=1;
                        end
                        if FixY(j+1,1)-y0(n)<=max_r*(j+1-x0a) && flag_backward==1
                            % interpolate end here
                            for s=x0a+1:j
                                FixY(s,1)=(FixY(j+1,1)-y0(n))/(j+1-x0a)*(s-x0a)+y0(n);
%                                 scatter(Mx(s,1),FixY(s,1),'sb');
                                hold on;
                            end
                            flag_backward=0;
                        end
                    end
                    % check flow rate after
                    for j=x0a+1:x0b-1
                        if y0(n+1)-FixY(j,1)>max_r*(x0b-j)
                            flag_forward=1;
                        end
                        if y0(n+1)-FixY(j-1,1)<=max_r*(x0b-j+1) && flag_forward==1
                            % interpolate end here
                            for s=j:x0b-1
                                FixY(s,1)=(y0(n+1)-FixY(j-1,1))/(x0b-j+1)*(s-j+1)+FixY(j-1);
%                                 scatter(Mx(s,1),FixY(s,1),'sb');
                                hold on;
                            end
                            flag_forward=0;
                        end
                    end
                end
            end
        else
            n=n+1;
        end
        if n==length(x0)
            break;
        end
    end
    
%     plot(Mx,FixY,'--r')
    

    %% Infer arrival points
    Ny=y0(NAC)-y0(1);
    arrCyc=zeros(Ny,2);% y and x   
    % put data already there
    for i=1:NAC-1
        arrCyc(y0(i)-y0(1)+1,1)=y0(i);
        arrCyc(y0(i)-y0(1)+1,2)=x0(i);
    end        
    
    for i=1:NAC-1
        x0a=x0(i)-b(Iint)+1;
        x0b=x0(i+1)-b(Iint)+1;
        if y0(i+1)-y0(i)==1
            continue;
        else
            n=x0a+1;
            for j=y0(i)+1:y0(i+1)-1
                if x0b-x0a==1
                    arrCyc(j-y0(1)+1,1)=j;
                    arrCyc(j-y0(1)+1,2)=Mx(x0a,1)+(j-FixY(x0a,1))/(FixY(x0b,1)-FixY(x0a,1));
                    continue;
                else
                    for s=x0a+1:x0b-1
                        if FixY(s,1)==j
                            arrCyc(j-y0(1)+1,1)=j;
                            arrCyc(j-y0(1)+1,2)=s+b(Iint)-1;
                        else
                            if FixY(s-1,1)<j && FixY(s+1,1)>j
                                arrCyc(j-y0(1)+1,1)=j;
                                arrCyc(j-y0(1)+1,2)=Mx(s-1,1)+(j-FixY(s-1,1))/(FixY(s+1,1)-FixY(s-1,1))*2;
                                break;
                            end
                        end
                    end
                end
            end
                        
        end
    end
    
    NDcyc=length(arrCyc(:,1));
    arrDY(Iint,1:NDcyc)=arrCyc(:,1);
    arrDX(Iint,1:NDcyc)=arrCyc(:,2);
    
%     scatter(arrCyc(:,2),arrCyc(:,1),'.r')
%     stairs(arrCyc(:,2),arrCyc(:,1),'-r');
end

%% compile results
Ndata=length(departT(:,1));
NI=length(arrDY(:,1));
arriveT=zeros(Ndata,2); %1-ID, 2-time
n=0;
for i=1:NI
    if sum(arrDY(i,:)')>0
        NDcyc=length(arrDY(i,arrDY(i,:)>0));
        arriveT(n+1:n+NDcyc,1)=arrDY(i,1:NDcyc)';
        arriveT(n+1:n+NDcyc,2)=arrDX(i,1:NDcyc)';
        n=n+NDcyc;
    end
end
arriveT=arriveT(arriveT(:,1)>0,:);
% re-filter in case something weired happens
n=1;
currentN=arriveT(1,1);
for i=2:length(arriveT(:,1))
    if arriveT(i,1)<=currentN
        arriveT(i,2)=0;
    else
        currentN=arriveT(i,1);
    end
end
arriveT=arriveT(arriveT(:,2)>0,:);
tempArrT=arriveT;
% if miss something, linear interpolation
tempN=arriveT(length(arriveT(:,1)),1)-arriveT(1,1)+1;
arriveT=zeros(tempN,2);
currentN=arriveT(1,1);
arriveT(1,:)=tempArrT(1,:);
n=2;
for i=2:length(tempArrT(:,1))
    if tempArrT(i,1)-tempArrT(i-1,1)==1
        arriveT(n,:)=tempArrT(i,:);
        n=n+1;
    else
        % linear interpolation
        interpN=tempArrT(i,1)-tempArrT(i-1,1)-1; % # of interp points needed
        dx=tempArrT(i,2)-tempArrT(i-1,2);
        for j=1:interpN
            arriveT(n,1)=tempArrT(i-1,1)+j;
            arriveT(n,2)=tempArrT(i-1,2)+dx/(interpN+1)*j;
            n=n+1;
        end
        arriveT(n,:)=tempArrT(i,:);
        n=n+1;
    end
end

scatter(arriveT(:,2),arriveT(:,1),'.r')
stairs(arriveT(:,2),arriveT(:,1),'-r');

% Recompile final data
Narr=length(arriveT(:,1));
arr_dept=zeros(Narr,7); % ID, arrive time, departure time
arr_dept(:,1)=arriveT(:,1);
arr_dept(:,2)=arriveT(:,2);
arr_dept(:,3)=departT(arriveT(1,1):arriveT(Narr,1),2);
arr_dept(:,5)=arr_dept(:,3)-arr_dept(:,2);
arr_dept(:,6)=-ones(Narr,1);
arr_dept(:,7)=-ones(Narr,1);
for i=1:Narr
    if sum(arrD(:,1)==arr_dept(i,1))>0
        arr_dept(i,4)=arrD(arrD(:,1)==arr_dept(i,1),4);
    else
        arr_dept(i,4)=-1;
    end
end
    
        
    