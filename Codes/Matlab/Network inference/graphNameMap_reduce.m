% Names of the network
node_names = {'L11Q', 'L12Q', ...
         'L93Q', 'L94Q', 'L102Q', 'L103Q', ...
         'L14Q', 'L15Q', 'L16Q', 'L17Q', 'L18Q', 'L19Q', 'L20Q', 'L21Q', ...
         'L56Q', 'L57Q', 'L68Q', 'L69Q', 'L81Q', 'L82Q', 'L95Q', 'L96Q', 'L104Q', 'L105Q', ...
         'L24Q', 'L25Q', 'L26Q', 'L27Q', 'L28Q', 'L29Q', 'L30Q', 'L31Q',...
         'L11T', 'L12T', ...
         'L93T', 'L94T', 'L102T', 'L103T', ...
         'L14T', 'L15T', 'L16T', 'L17T', 'L18T', 'L19T', 'L20T', 'L21T', ...
         'L56T', 'L57T', 'L68T', 'L69T', 'L81T', 'L82T', 'L95T', 'L96T', 'L104T', 'L105T', ...
         'L24T', 'L25T', 'L26T', 'L27T', 'L28T', 'L29T', 'L30T', 'L31T',...
         'P6T', 'P7T', 'P9T', 'P10T', 'P11T', 'P12T', 'P15T', 'P16T', 'P18T'};
% Name Map
L11Q = 1;
L12Q = 2;
L93Q = 3;
L94Q = 4;
L102Q = 5;
L103Q = 6;
L14Q = 7;
L15Q = 8;
L16Q = 9;
L17Q = 10;
L18Q = 11;
L19Q = 12;
L20Q = 13;
L21Q = 14;
L56Q = 15;
L57Q = 16;
L68Q = 17;
L69Q = 18;
L81Q = 19;
L82Q = 20;
L95Q = 21;
L96Q = 22;
L104Q = 23;
L105Q = 24;
L24Q = 25;
L25Q = 26;
L26Q = 27;
L27Q = 28;
L28Q = 29;
L29Q = 30;
L30Q = 31;
L31Q = 32;
L11T = 33;
L12T = 34;
L93T = 35;
L94T = 36;
L102T = 37;
L103T = 38;
L14T = 39;
L15T = 40;
L16T = 41;
L17T = 42;
L18T = 43;
L19T = 44;
L20T = 45;
L21T = 46;
L56T = 47;
L57T = 48;
L68T = 49;
L69T = 50;
L81T = 51;
L82T = 52;
L95T = 53;
L96T = 54;
L104T = 55;
L105T = 56;
L24T = 57;
L25T = 58;
L26T = 59;
L27T = 60;
L28T = 61;
L29T = 62;
L30T = 63;
L31T = 64;
P6T = 65;
P7T = 66;
P9T = 67;
P10T = 68;
P11T = 69;
P12T = 70;
P15T = 71;
P16T = 72;
P18T = 73;

% Observability:
% Observable queue length state nodes
obs_QLS_nodes = [L11Q, L12Q, L18Q, L21Q, L25Q, L26Q, L28Q, L29Q, L31Q, ...
                 L81Q, L93Q, L94Q, L95Q, L96Q, L103Q];
% Observable TT: without psuedo links
obs_TT_nodes_noPsuedo = [L11T, L12T, ...
                         L93T, L94T, L103T, ...
                         L15T, ...
                         L57T, L95T, L96T, L104T, L105T, ...
                         L24T, L25T, L26T, L27T, L28T, L29T, L30T];
% Observable TT: with psuedo links
obs_TT_nodes_psuedo = [L11T, L12T, ...
                       L93T, L94T, L102T, L103T, ...
                       L14T, L15T, L21T, ...
                       L57T, L69T, L95T, L96T, L104T, L105T, ...
                       L24T, L25T, L26T, L27T, L28T, L29T, L30T, L31T];    
% Observable path TT
obs_path_nodes = [P6T, P7T, P9T, P10T, P11T, P12T, P15T, P16T, P18T];