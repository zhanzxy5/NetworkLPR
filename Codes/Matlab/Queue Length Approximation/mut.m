%% mean function
function y=mut(theta,t,para)
%% new
% theta prameter
rTs=theta(1,1);
rTn=theta(2,1);
rR=theta(3,1);
rLs=theta(4,1);
rTn=theta(5,1);
ta=theta(6,1);
tb=theta(7,1);
T1=para(1,1);
T3=para(3,1)+para(1,1)+para(2,1);

% y=0;
if t<ta
    y=rTs*t+rR*t;
else
    if t<T1
        y=(rTs-rTn)*ta+rTn*t+rR*t;
    else
        if t<T3
            y=(rTs-rTn)*ta+rTn*T1+rR*t;
        else
            if t<T3+tb
                y=(rTs-rTn)*ta+rTn*T1+rR*t+rLs*(t-T3);
            else
                 y=(rTs-rTn)*ta+rTn*T1+rR*t+rLs*tb+rTn*(t-T3);
            end
        end
    end
end

% %% old
% % theta prameter
% rTs=theta(1,1);
% rTn=theta(2,1);
% rR=theta(3,1);
% rLs=theta(4,1);
% rTn=theta(5,1);
% ta=theta(6,1);
% tb=theta(7,1);
% t00=theta(11,1);
% r00=theta(12,1);
% 
% T1=para(1,1);
% T3=para(3,1)+para(1,1)+para(2,1);
% 
% y=0;
% if t<t00
%     y=r00*t+rR*t;
%     t=t-t00;
% else
%     y=r00*t00+rR*t00;
%     t=t-t00;
%     if t<ta
%         y=rTs*t+rR*t;
%     else
%         if t<T1
%             y=(rTs-rTn)*ta+rTn*t+rR*t;
%         else
%             if t<T3
%                 y=(rTs-rTn)*ta+rTn*T1+rR*t;
%             else
%                 if t<T3+tb
%                     y=(rTs-rTn)*ta+rTn*T1+rR*t+rLs*(t-T3);
%                 else
%                      y=(rTs-rTn)*ta+rTn*T1+rR*t+rLs*tb+rTn*(t-T3);
%                 end
%             end
%         end
%     end
% end