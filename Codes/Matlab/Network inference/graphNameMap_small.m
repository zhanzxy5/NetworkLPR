% Names of the network
node_names = {'L7Q', 'L8Q', 'L9Q', 'L10Q', 'L11Q', 'L12Q', ...
         'L66Q', 'L67Q', 'L93Q', 'L94Q', 'L102Q', 'L103Q', ...
         'L16Q', 'L17Q', 'L18Q', 'L19Q', 'L20Q', 'L21Q', ...
         'L68Q', 'L69Q', 'L81Q', 'L82Q', 'L95Q', 'L96Q', 'L104Q', 'L105Q', ...
         'L26Q', 'L27Q', 'L28Q', 'L29Q', 'L30Q', 'L31Q',...
         'L7T', 'L8T', 'L9T', 'L10T', 'L11T', 'L12T', ...
         'L66T', 'L67T', 'L93T', 'L94T', 'L102T', 'L103T', ...
         'L16T', 'L17T', 'L18T', 'L19T', 'L20T', 'L21T', ...
         'L68T', 'L69T', 'L81T', 'L82T', 'L95T', 'L96T', 'L104T', 'L105T', ...
         'L26T', 'L27T', 'L28T', 'L29T', 'L30T', 'L31T',...
         'P1T', 'P2T', 'P6T', 'P7T', 'P9T', 'P10T', 'P13T', 'P15T', 'P16T', 'P17T', 'P18T'};
% Name Map
L7Q = 1;
L8Q = 2;
L9Q = 3;
L10Q = 4;
L11Q = 5;
L12Q = 6;
L66Q = 7;
L67Q = 8;
L93Q = 9;
L94Q = 10;
L102Q = 11;
L103Q = 12;
L16Q = 13;
L17Q = 14;
L18Q = 15;
L19Q = 16;
L20Q = 17;
L21Q = 18;
L68Q = 19;
L69Q = 20;
L81Q = 21;
L82Q = 22;
L95Q = 23;
L96Q = 24;
L104Q = 25;
L105Q = 26;
L26Q = 27;
L27Q = 28;
L28Q = 29;
L29Q = 30;
L30Q = 31;
L31Q = 32;
L7T = 33;
L8T = 34;
L9T = 35;
L10T = 36;
L11T = 37;
L12T = 38;
L66T = 39;
L67T = 40;
L93T = 41;
L94T = 42;
L102T = 43;
L103T = 44;
L16T = 45;
L17T = 46;
L18T = 47;
L19T = 48;
L20T = 49;
L21T = 50;
L68T = 51;
L69T = 52;
L81T = 53;
L82T = 54;
L95T = 55;
L96T = 56;
L104T = 57;
L105T = 58;
L26T = 59;
L27T = 60;
L28T = 61;
L29T = 62;
L30T = 63;
L31T = 64;
P1T = 65;
P2T = 66;
P6T = 67;
P7T = 68;
P9T = 69;
P10T = 70;
P13T = 71;
P15T = 72;
P16T = 73;
P17T = 74;
P18T = 75;

% Observability:
% Observable queue length state nodes
obs_QLS_nodes = [L9Q, L11Q, L12Q, L18Q, L21Q, L26Q, L28Q, L29Q, L31Q, ...
                 L81Q, L93Q, L94Q, L95Q, L96Q, L103Q];
% Observable TT: without psuedo links
obs_TT_nodes_noPsuedo = [L11T, L12T, ...
                         L66T, L67T, L93T, L94T, L103T, ...
                         L95T, L96T, L104T, L105T, ...
                         L26T, L27T, L28T, L29T, L30T];
% Observable TT: with psuedo links
obs_TT_nodes_psuedo = [L11T, L12T, ...
                       L66T, L67T, L93T, L94T, L102T, L103T, ...
                       L21T, ...
                       L69T, L95T, L96T, L104T, L105T, ...
                       L26T, L27T, L28T, L29T, L30T, L31T];    
% Observable path TT
obs_path_nodes = [P1T, P2T, P6T, P7T, P9T, P10T, P13T, P15T, P16T, P17T, P18T];