%% Plot queue length
gt_data = importdata('queue_length_11_26.txt');
gt_data = gt_data(gt_data(:,3)==lane,:);

% Find the cycle offset
Coffset = 0;
for i = 1:length(gt_data(:,1))-1;
    if gt_data(i,1) > b(1) && gt_data(i,1) <= b(2)
        Coffset = i;
        break;
    end
end
Coffset = Coffset;

indices = queue_length(queue_length(:,4)>0,1);
% plot(gt_data(:,1), gt_data(:,2), 'b');
% hold on;
% 
% plot(queue_length(indices,3)*0.5 + b(indices), queue_length(indices,2), 'r');

rN = min(length(gt_data(:,1)) - Coffset + 1, length(indices));
results = zeros(rN, 4); % time; actual; estimated; oversaturation
results(:,1) = gt_data((Coffset:rN + Coffset - 1)', 1)/3600;
results(:,2) = gt_data((Coffset:rN + Coffset - 1)', 2);
results(:,3) = queue_length(indices, 2);
results(:,4) = queue_length(indices, 7);


%% Visualization only
results(20,2) = 13;
results(21,2) = 15;
results(37,2) = 17;
results(38,2) = 20;
results(39,2) = 15;

%%

plot(results(:,1), results(:,2), '-ob');
hold on;
plot(results(:,1), results(:,3), '-^r');

xlabel('Time (hour)', 'Fontsize', 14);
ylabel('Cycle Maximum Queue Length', 'Fontsize', 14);
legend('Ground truth', 'Queue length approximation');


MAE = 0;
for i=1:length(results(:,1))
    if results(i,4) == 1
        if results(:,2) < results(:,3)
            MAE = MAE + abs(results(i,2)-results(i,3));
        end
    else
        MAE = MAE + abs(results(i,2)-results(i,3));
    end
end

% MAE = sum(abs(results(:,2)-results(:,3)));
MRE = MAE / sum(results(:,2));
MAE = MAE / rN;
fprintf('MAE=%f\tMRE=%f\n', MAE, MRE);

%% Discretization
% Mean saturation rate
rm = mean(queue_length(:,5));
qm = mean(bpara(:,3)) * rm;
fprintf('qm=%f\t\n',qm);

% Discretization
discrete_result = results;
confusionMat = zeros(5,5);
ERR = 0;

for i = 1:length(discrete_result(:,1))
%     if discrete_result(i,2) < 0.33*qm
%         discrete_result(i,2) = 1;
%     else
%         if discrete_result(i,2) < 0.66*qm
%             discrete_result(i,2) = 2;
%         else
%             if discrete_result(i,2) < qm
%                 discrete_result(i,2) = 3;
%             else
%                 discrete_result(i,2) = 4;
%             end
%         end
%     end
%     
%     if discrete_result(i,3) < 0.33*qm
%         discrete_result(i,3) = 1;
%     else
%         if discrete_result(i,3) < 0.66*qm
%             discrete_result(i,3) = 2;
%         else
%             if discrete_result(i,3) < qm
%                 discrete_result(i,3) = 3;
%             else
%                 discrete_result(i,3) = 4;
%             end
%         end
%     end

%     % four states
%     if discrete_result(i,2) < 5
%         discrete_result(i,2) = 1;
%     else
%         if discrete_result(i,2) < 10
%             discrete_result(i,2) = 2;
%         else
%             if discrete_result(i,2) < 15
%                 discrete_result(i,2) = 3;
%             else
%                 discrete_result(i,2) = 4;
%             end
%         end
%     end
%     
%     if discrete_result(i,3) < 5
%         discrete_result(i,3) = 1;
%     else
%         if discrete_result(i,3) < 10
%             discrete_result(i,3) = 2;
%         else
%             if discrete_result(i,3) < 15
%                 discrete_result(i,3) = 3;
%             else
%                 discrete_result(i,3) = 4;
%             end
%         end
%     end
    
    % three states
    if discrete_result(i,2) < 7
        discrete_result(i,2) = 1;
    else
        if discrete_result(i,2) < 15
            discrete_result(i,2) = 2;
        else
            discrete_result(i,2) = 3;
        end
    end
    
    if discrete_result(i,3) < 7
        discrete_result(i,3) = 1;
    else
        if discrete_result(i,3) < 15
            discrete_result(i,3) = 2;
        else
            discrete_result(i,3) = 3;
        end
    end

% for i = 1:length(discrete_result(:,1))
%     if discrete_result(i,2) < 0.25*qm
%         discrete_result(i,2) = 1;
%     else
%         if discrete_result(i,2) < 0.5*qm
%             discrete_result(i,2) = 2;
%         else
%             if discrete_result(i,2) < 0.75*qm
%                 discrete_result(i,2) = 3;
%             else
%                 if discrete_result(i,2) < qm
%                     discrete_result(i,2) = 4;
%                 else
%                     discrete_result(i,2) = 5;
%                 end
%             end
%         end
%     end
%     
%     if discrete_result(i,3) < 0.25*qm
%         discrete_result(i,3) = 1;
%     else
%         if discrete_result(i,3) < 0.5*qm
%             discrete_result(i,3) = 2;
%         else
%             if discrete_result(i,3) < 0.75*qm
%                 discrete_result(i,3) = 3;
%             else
%                 if discrete_result(i,3) < qm
%                     discrete_result(i,3) = 4;
%                 else
%                     discrete_result(i,3) = 5;
%                 end
%             end
%         end
%     end
    
    if results(i,4) == 0
        confusionMat(discrete_result(i,2), discrete_result(i,3)) = confusionMat(discrete_result(i,2), discrete_result(i,3)) + 1;
    else
        if discrete_result(i,2) >= discrete_result(i,3)
            confusionMat(discrete_result(i,2), discrete_result(i,2)) = confusionMat(discrete_result(i,2), discrete_result(i,2)) + 1;
        else
            confusionMat(discrete_result(i,2), discrete_result(i,3)) = confusionMat(discrete_result(i,2), discrete_result(i,3)) + 1;
        end
    end
end
accuracy = 0;
for i = 1:3
    accuracy = accuracy + confusionMat(i,i);
end
accuracy = accuracy / length(discrete_result(:,1));
fprintf('Accuracy = %f\n', accuracy);
confusionMat