%% Creating the Hybrid dynamic Bayesian network structure
% The test network
% 1- Full connection; 2- Direct connection; 
% 3- Test, with intentially hidden observation, full connection
% 4- Test, with intentially hidden observation, directed connection
BayesNetID = 2;
% Set to 1 if pseudo links' TT are used; 0 if hidden
withPseudoLink = 1;
seed = 1; % For predictable random number generation

%% Graph preparation
rng(seed);
graphNameMap;

% Common net properties
NPseudoLink = 6; % Number of pseudo links
NPath = 13; % Number of paths
NLink = 42; % Number of links
Nnodes = NLink * 2 + NPath;
QLS_size = 4; % Queue lenth state sizes

% Queue length state nodes
QLS_nodes = [L5Q, L6Q, L7Q, L8Q, L9Q, L10Q, L11Q, L12Q, ...
             L54Q, L55Q, L66Q, L67Q, L93Q, L94Q, L102Q, L103Q, ...
             L14Q, L15Q, L16Q, L17Q, L18Q, L19Q, L20Q, L21Q, ...
             L56Q, L57Q, L68Q, L69Q, L81Q, L82Q, L95Q, L96Q, L104Q, L105Q, ...
             L24Q, L25Q, L26Q, L27Q, L28Q, L29Q, L30Q, L31Q]';
% Link travel time nodes
LTT_nodes = [L5T, L6T, L7T, L8T, L9T, L10T, L11T, L12T, ...
             L54T, L55T, L66T, L67T, L93T, L94T, L102T, L103T, ...
             L14T, L15T, L16T, L17T, L18T, L19T, L20T, L21T, ...
             L56T, L57T, L68T, L69T, L81T, L82T, L95T, L96T, L104T, L105T, ...
             L24T, L25T, L26T, L27T, L28T, L29T, L30T, L31T]';
% Path travel time nodes
PTT_nodes = [P1T, P2T, P6T, P7T, P9T, P10T, P11T, P12T, P13T, P15T, P16T, P17T, P18T]';

% Discrete nodes
discrete_nodes = QLS_nodes;
continuous_nodes = [LTT_nodes; PTT_nodes];

% Node size
node_size = ones(1, Nnodes);
node_size(discrete_nodes) = QLS_size;

% Intra-network topology: same for different network
intra = zeros(Nnodes);
% intra: queue length state to link travel times
intra(L5Q, L5T) = 1;
intra(L6Q, L6T) = 1;
intra(L7Q, L7T) = 1;
intra(L8Q, L8T) = 1;
intra(L9Q, L9T) = 1;
intra(L10Q, L10T) = 1;
intra(L11Q, L11T) = 1;
intra(L12Q, L12T) = 1;
intra(L54Q, L54T) = 1;
intra(L55Q, L55T) = 1;
intra(L66Q, L66T) = 1;
intra(L67Q, L67T) = 1;
intra(L93Q, L93T) = 1;
intra(L94Q, L94T) = 1;
intra(L102Q, L102T) = 1;
intra(L103Q, L103T) = 1;
intra(L14Q, L14T) = 1;
intra(L15Q, L15T) = 1;
intra(L16Q, L16T) = 1;
intra(L17Q, L17T) = 1;
intra(L18Q, L18T) = 1;
intra(L19Q, L19T) = 1;
intra(L20Q, L20T) = 1;
intra(L21Q, L21T) = 1;
intra(L56Q, L56T) = 1;
intra(L57Q, L57T) = 1;
intra(L68Q, L68T) = 1;
intra(L69Q, L69T) = 1;
intra(L81Q, L81T) = 1;
intra(L82Q, L82T) = 1;
intra(L95Q, L95T) = 1;
intra(L96Q, L96T) = 1;
intra(L104Q, L104T) = 1;
intra(L105Q, L105T) = 1;
intra(L24Q, L24T) = 1;
intra(L25Q, L25T) = 1;
intra(L26Q, L26T) = 1;
intra(L27Q, L27T) = 1;
intra(L28Q, L28T) = 1;
intra(L29Q, L29T) = 1;
intra(L30Q, L30T) = 1;
intra(L31Q, L31T) = 1;
% intra: link travel times to path travel times
intra(L7T, P1T) = 1;
intra(L9T, P1T) = 1;
intra(L10T, P2T) = 1;
intra(L8T, P2T) = 1;
intra(L16T, P6T) = 1;
intra(L18T, P6T) = 1;
intra(L19T, P7T) = 1;
intra(L17T, P7T) = 1;
intra(L20T, P9T) = 1;
intra(L103T, P9T) = 1;
intra(L20T, P10T) = 1;
intra(L104T, P10T) = 1;
intra(L56T, P11T) = 1;
intra(L24T, P11T) = 1;
intra(L68T, P12T) = 1;
intra(L25T, P12T) = 1;
intra(L68T, P13T) = 1;
intra(L26T, P13T) = 1;
intra(L16T, P15T) = 1;
intra(L81T, P15T) = 1;
intra(L82T, P16T) = 1;
intra(L17T, P16T) = 1;
intra(L19T, P17T) = 1;
intra(L81T, P17T) = 1;
intra(L18T, P18T) = 1;
intra(L82T, P18T) = 1;

% Define equivalent classes
% Class for prior term in slice 1
eclass1 = 1:Nnodes;
eclass2 = [QLS_nodes'+Nnodes, length(QLS_nodes)+1:Nnodes];
eclass = [eclass1 eclass2];

switch BayesNetID
    case 1
       %% Test HDBN 1: full connection
        % Observed nodes:
        % Type 1&2 queue length states, Type 1 link travel times, path trave times
        if withPseudoLink == 0
            % Without pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_noPsuedo, obs_path_nodes];
        else
            % With pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_psuedo, obs_path_nodes];
        end
        
        % Inter-network topology
        inter = zeros(Nnodes);
        % Self to self is always connected
        for i = 1:length(QLS_nodes)
            inter(QLS_nodes(i), QLS_nodes(i)) = 1;
        end
        inter(L55Q, L5Q) = 1;
        inter([L8Q, L67Q], L6Q) = 1;
        inter([L5Q, L67Q], L7Q) = 1;
        inter(L10Q, L8Q) = 1;
        inter(L7Q, L9Q) = 1;
        inter([L94Q, L12Q], L10Q) = 1;
        inter([L94Q, L9Q], L11Q) = 1;
        inter(L103Q, L12Q) = 1;
        inter(L6Q, L54Q) = 1;
        inter([L57Q, L15Q], L55Q) = 1;
        inter([L5Q, L8Q], L66Q) = 1;
        inter([L14Q, L17Q, L69Q], L67Q) = 1;
        inter([L9Q, L12Q], L93Q) = 1;
        inter([L18Q, L21Q, L96Q], L94Q) = 1;
        inter(L11Q, L102Q) = 1;
        inter([L20Q, L105Q], L103Q) = 1;
        inter([L54Q, L57Q], L14Q) = 1;
        inter([L66Q, L17Q, L69Q], L15Q) = 1;
        inter([L14Q, L66Q, L69Q], L16Q) = 1;
        inter([L82Q, L19Q], L17Q) = 1;
        inter([L16Q, L82Q], L18Q) = 1;
        inter([L96Q, L21Q, L93Q], L19Q) = 1;
        inter([L18Q, L96Q, L93Q], L20Q) = 1;
        inter([L102Q, L105Q], L21Q) = 1;
        inter([L54Q, L15Q], L56Q) = 1;
        inter(L25Q, L57Q) = 1;
        inter([L14Q, L66Q, L17Q], L68Q) = 1;
        inter([L24Q, L27Q], L69Q) = 1;
        inter([L16Q, L19Q], L81Q) = 1;
        inter([L26Q, L29Q], L82Q) = 1;
        inter([L18Q, L21Q, L93Q], L95Q) = 1;
        inter([L28Q, L31Q], L96Q) = 1;
        inter([L20Q, L102Q], L104Q) = 1;
        inter(L30Q, L105Q) = 1;
        inter(L56Q, L24Q) = 1;
        inter([L68Q, L27Q], L25Q) = 1;
        inter([L24Q, L68Q], L26Q) = 1;
        inter([L81Q, L29Q], L27Q) = 1;
        inter([L26Q, L81Q], L28Q) = 1;
        inter([L95Q, L31Q], L29Q) = 1;
        inter([L28Q, L95Q], L30Q) = 1;
        inter(L104Q, L31Q) = 1;
        
    case 2
       %% Test HDBN 2: only direct upstream neighbor
        % Observed nodes:
        % Type 1&2 queue length states, Type 1 link travel times, path trave times
        if withPseudoLink == 0
            % Without pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_noPsuedo, obs_path_nodes];
        else
            % With pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_psuedo, obs_path_nodes];
        end
        
        % Inter-network topology
        inter = zeros(Nnodes);
        % Self to self is always connected
        for i = 1:length(QLS_nodes)
            inter(QLS_nodes(i), QLS_nodes(i)) = 1;
        end
        inter(L8Q, L6Q) = 1;
        inter(L5Q, L7Q) = 1;
        inter(L10Q, L8Q) = 1;
        inter(L7Q, L9Q) = 1;
        inter(L12Q, L10Q) = 1;
        inter(L9Q, L11Q) = 1;
        inter(L57Q, L55Q) = 1;
        inter(L69Q, L67Q) = 1;
        inter(L96Q, L94Q) = 1;
        inter(L105Q, L103Q) = 1;
        inter(L17Q, L15Q) = 1;
        inter(L14Q, L16Q) = 1;
        inter(L19Q, L17Q) = 1;
        inter(L16Q, L18Q) = 1;
        inter(L21Q, L19Q) = 1;
        inter(L18Q, L20Q) = 1;
        inter(L54Q, L56Q) = 1;
        inter(L66Q, L68Q) = 1;
        inter(L93Q, L95Q) = 1;
        inter(L102Q, L104Q) = 1;
        inter(L27Q, L25Q) = 1;
        inter(L24Q, L26Q) = 1;
        inter(L29Q, L27Q) = 1;
        inter(L26Q, L28Q) = 1;
        inter(L31Q, L29Q) = 1;
        inter(L28Q, L30Q) = 1;
        
        
    case 3
        %% Test HDBN 3: full connectiontest - net with certain links left hidden
        % Observed nodes:change accordingly
        % Type 1&2 queue length states, Type 1 link travel times, path trave times
        if withPseudoLink == 0
            % Without pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_noPsuedo, obs_path_nodes];
        else
            % With pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_psuedo, obs_path_nodes];
        end
        
        % Inter-network topology
        inter = zeros(Nnodes);
        % Self to self is always connected
        for i = 1:length(QLS_nodes)
            inter(QLS_nodes(i), QLS_nodes(i)) = 1;
        end
        inter(L55Q, L5Q) = 1;
        inter([L8Q, L67Q], L6Q) = 1;
        inter([L5Q, L67Q], L7Q) = 1;
        inter(L10Q, L8Q) = 1;
        inter(L7Q, L9Q) = 1;
        inter([L94Q, L12Q], L10Q) = 1;
        inter([L94Q, L9Q], L11Q) = 1;
        inter(L103Q, L12Q) = 1;
        inter(L6Q, L54Q) = 1;
        inter([L57Q, L15Q], L55Q) = 1;
        inter([L5Q, L8Q], L66Q) = 1;
        inter([L14Q, L17Q, L69Q], L67Q) = 1;
        inter([L9Q, L12Q], L93Q) = 1;
        inter([L18Q, L21Q, L96Q], L94Q) = 1;
        inter(L11Q, L102Q) = 1;
        inter([L20Q, L105Q], L103Q) = 1;
        inter([L54Q, L57Q], L14Q) = 1;
        inter([L66Q, L17Q, L69Q], L15Q) = 1;
        inter([L14Q, L66Q, L69Q], L16Q) = 1;
        inter([L82Q, L19Q], L17Q) = 1;
        inter([L16Q, L82Q], L18Q) = 1;
        inter([L96Q, L21Q, L93Q], L19Q) = 1;
        inter([L18Q, L96Q, L93Q], L20Q) = 1;
        inter([L102Q, L105Q], L21Q) = 1;
        inter([L54Q, L15Q], L56Q) = 1;
        inter(L25Q, L57Q) = 1;
        inter([L14Q, L66Q, L17Q], L68Q) = 1;
        inter([L24Q, L27Q], L69Q) = 1;
        inter([L16Q, L19Q], L81Q) = 1;
        inter([L26Q, L29Q], L82Q) = 1;
        inter([L18Q, L21Q, L93Q], L95Q) = 1;
        inter([L28Q, L31Q], L96Q) = 1;
        inter([L20Q, L102Q], L104Q) = 1;
        inter(L30Q, L105Q) = 1;
        inter(L56Q, L24Q) = 1;
        inter([L68Q, L27Q], L25Q) = 1;
        inter([L24Q, L68Q], L26Q) = 1;
        inter([L81Q, L29Q], L27Q) = 1;
        inter([L26Q, L81Q], L28Q) = 1;
        inter([L95Q, L31Q], L29Q) = 1;
        inter([L28Q, L95Q], L30Q) = 1;
        inter(L104Q, L31Q) = 1;
    case 4
        %% Test HDBN 4: only direct upstream neighbor - net with certain links left hidden
        % Observed nodes: change accordingly
        % Type 1&2 queue length states, Type 1 link travel times, path trave times
        if withPseudoLink == 0
            % Without pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_noPsuedo, obs_path_nodes];
        else
            % With pseudo links
            observed_nodes = [obs_QLS_nodes, obs_TT_nodes_psuedo, obs_path_nodes];
        end
        
        % Inter-network topology
        inter = zeros(Nnodes);
        % Self to self is always connected
        for i = 1:length(QLS_nodes)
            inter(QLS_nodes(i), QLS_nodes(i)) = 1;
        end
        inter(L8Q, L6Q) = 1;
        inter(L5Q, L7Q) = 1;
        inter(L10Q, L8Q) = 1;
        inter(L7Q, L9Q) = 1;
        inter(L12Q, L10Q) = 1;
        inter(L9Q, L11Q) = 1;
        inter(L57Q, L55Q) = 1;
        inter(L69Q, L67Q) = 1;
        inter(L96Q, L94Q) = 1;
        inter(L105Q, L103Q) = 1;
        inter(L17Q, L15Q) = 1;
        inter(L14Q, L16Q) = 1;
        inter(L19Q, L17Q) = 1;
        inter(L16Q, L18Q) = 1;
        inter(L21Q, L19Q) = 1;
        inter(L18Q, L20Q) = 1;
        inter(L54Q, L56Q) = 1;
        inter(L66Q, L68Q) = 1;
        inter(L93Q, L95Q) = 1;
        inter(L102Q, L104Q) = 1;
        inter(L27Q, L25Q) = 1;
        inter(L24Q, L26Q) = 1;
        inter(L29Q, L27Q) = 1;
        inter(L26Q, L28Q) = 1;
        inter(L31Q, L29Q) = 1;
        inter(L28Q, L30Q) = 1;
    otherwise
        fprintf('No HDBN selected!\n');
end

%% DBNet construction
bnet = mk_dbn(intra, inter, node_size, 'names', node_names, 'discrete', discrete_nodes', ...
              'observed', observed_nodes, 'eclass1', eclass1, 'eclass2', eclass2);
% Initialize the CPD
% Initialize the queue length state varialbes: just use the random variable
for i = 1:length(QLS_nodes)
    % varialbe in first time slice
    n = QLS_nodes(i);
    bnet.CPD{n} = tabular_CPD(bnet, n);
    % variable in the following time slices
    n2 = n + Nnodes;
    bnet.CPD{n2} = tabular_CPD(bnet, n2);
end
% Initialize the travel time variable: conditional Gaussian
for i = 1:length(LTT_nodes)
    n = LTT_nodes(i);
    bnet.CPD{n} = gaussian_CPD(bnet, n);
end
% Initialize the path travel time variable: conditional Gaussian
for i = 1:length(PTT_nodes)
    n = PTT_nodes(i);
    np = parents(intra, n);
    % resolve weight
    W = ones(1, length(np));
    bnet.CPD{n} = gaussian_CPD(bnet, n, 'weights', W, 'clamp_weights', 1);
end