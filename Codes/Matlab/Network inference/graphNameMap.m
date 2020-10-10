% Names of the network
node_names = {'L5Q', 'L6Q', 'L7Q', 'L8Q', 'L9Q', 'L10Q', 'L11Q', 'L12Q', ...
         'L54Q', 'L55Q', 'L66Q', 'L67Q', 'L93Q', 'L94Q', 'L102Q', 'L103Q', ...
         'L14Q', 'L15Q', 'L16Q', 'L17Q', 'L18Q', 'L19Q', 'L20Q', 'L21Q', ...
         'L56Q', 'L57Q', 'L68Q', 'L69Q', 'L81Q', 'L82Q', 'L95Q', 'L96Q', 'L104Q', 'L105Q', ...
         'L24Q', 'L25Q', 'L26Q', 'L27Q', 'L28Q', 'L29Q', 'L30Q', 'L31Q',...
         'L5T', 'L6T', 'L7T', 'L8T', 'L9T', 'L10T', 'L11T', 'L12T', ...
         'L54T', 'L55T', 'L66T', 'L67T', 'L93T', 'L94T', 'L102T', 'L103T', ...
         'L14T', 'L15T', 'L16T', 'L17T', 'L18T', 'L19T', 'L20T', 'L21T', ...
         'L56T', 'L57T', 'L68T', 'L69T', 'L81T', 'L82T', 'L95T', 'L96T', 'L104T', 'L105T', ...
         'L24T', 'L25T', 'L26T', 'L27T', 'L28T', 'L29T', 'L30T', 'L31T',...
         'P1T', 'P2T', 'P6T', 'P7T', 'P9T', 'P10T', 'P11T', 'P12T', 'P13T', 'P15T', 'P16T', 'P17T', 'P18T'};
% Name Map
L5Q = 1;
L6Q = 2;
L7Q = 3;
L8Q = 4;
L9Q = 5;
L10Q = 6;
L11Q = 7;
L12Q = 8;
L54Q = 9;
L55Q = 10;
L66Q = 11;
L67Q = 12;
L93Q = 13;
L94Q = 14;
L102Q = 15;
L103Q = 16;
L14Q = 17;
L15Q = 18;
L16Q = 19;
L17Q = 20;
L18Q = 21;
L19Q = 22;
L20Q = 23;
L21Q = 24;
L56Q = 25;
L57Q = 26;
L68Q = 27;
L69Q = 28;
L81Q = 29;
L82Q = 30;
L95Q = 31;
L96Q = 32;
L104Q = 33;
L105Q = 34;
L24Q = 35;
L25Q = 36;
L26Q = 37;
L27Q = 38;
L28Q = 39;
L29Q = 40;
L30Q = 41;
L31Q = 42;
L5T = 43;
L6T = 44;
L7T = 45;
L8T = 46;
L9T = 47;
L10T = 48;
L11T = 49;
L12T = 50;
L54T = 51;
L55T = 52;
L66T = 53;
L67T = 54;
L93T = 55;
L94T = 56;
L102T = 57;
L103T = 58;
L14T = 59;
L15T = 60;
L16T = 61;
L17T = 62;
L18T = 63;
L19T = 64;
L20T = 65;
L21T = 66;
L56T = 67;
L57T = 68;
L68T = 69;
L69T = 70;
L81T = 71;
L82T = 72;
L95T = 73;
L96T = 74;
L104T = 75;
L105T = 76;
L24T = 77;
L25T = 78;
L26T = 79;
L27T = 80;
L28T = 81;
L29T = 82;
L30T = 83;
L31T = 84;
P1T = 85;
P2T = 86;
P6T = 87;
P7T = 88;
P9T = 89;
P10T = 90;
P11T = 91;
P12T = 92;
P13T = 93;
P15T = 94;
P16T = 95;
P17T = 96;
P18T = 97;

% Observability:
% Observable queue length state nodes
obs_QLS_nodes = [L11Q, L12Q, L25Q, L26Q, L28Q, L29Q, L31Q, ...
                 L93Q, L94Q, L95Q, L96Q, L103Q];
% Observable TT: without psuedo links
obs_TT_nodes_noPsuedo = [L5T, L6T, L11T, L12T, ...
                         L55T, L66T, L67T, L93T, L94T, L103T, ...
                         L15T, ...
                         L57T, L95T, L96T, L104T, L105T, ...
                         L24T, L25T, L26T, L27T, L28T, L29T, L30T];
% Observable TT: with psuedo links
obs_TT_nodes_psuedo = [L5T, L6T, L11T, L12T, ...
                       L54T, L55T, L66T, L67T, L93T, L94T, L102T, L103T, ...
                       L14T, L15T, L21T, ...
                       L57T, L69T, L95T, L96T, L104T, L105T, ...
                       L24T, L25T, L26T, L27T, L28T, L29T, L30T, L31T];    
% Observable path TT
obs_path_nodes = [P1T, P2T, P6T, P7T, P9T, P10T, P11T, P12T, P13T, P15T, P16T, P17T, P18T];