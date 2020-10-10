%% Link data config
% Link data: 1-Var ID; 2-link ID; 3-Type; 4-Dir code; 5-Length
link_data_simple = [
1	5	1	4	503.25
2	6	1	2	496.66
3	7	3	4	583.56
4	8	2	2	577.76
5	9	2	4	619.5
6	10	3	2	613.54
7	11	1	4	613.88
8	12	1	2	629.88
9	54	2	3	741.25
10	55	1	1	734.1
11	66	1	3	706.35
12	67	1	1	699.84
13	93	1	3	657.68
14	94	1	1	644.24
15	102	2	3	653.52
16	103	1	1	640.93
17	14	2	4	504.41
18	15	1	2	492.51
19	16	3	4	574.73
20	17	2	2	599.98
21	18	2	4	612.21
22	19	3	2	626.73
23	20	3	4	640.4
24	21	2	2	640.48
25	56	3	3	528.69
26	57	1	1	528.99
27	68	3	3	595.88
28	69	2	1	635.05
29	81	2	3	731.65
30	82	3	1	669.53
31	95	1	3	701.31
32	96	1	1	715.69
33	104	1	3	725.82
34	105	1	1	740.43
35	24	1	4	551.61
36	25	1	2	578.94
37	26	1	4	524.77
38	27	1	2	534.71
39	28	1	4	623.5
40	29	1	2	618.11
41	30	1	4	682.35
42	31	2	2	671.4];
% Number of links
Nlink = 42;
% Mapping from link ID to Var ID
linkID2VarID = zeros(max(link_data_simple(:,2)),1);
for i = 1:Nlink
    linkID2VarID(link_data_simple(i,2)) = i;
end
% All links with observed TT and their free flow TT
obs_TT_link = [
5	14.88476891
6	11.8202634
11	21.30267761
12	7.475910371
15	2.491811816
24	13.03904105
25	13.90399403
26	6.226356805
27	21.25129487
28	19.5250947
29	6.526319566
30	5.282549065
55	5.148888457
57	6.21659229
66	21.73063033
67	6.37022932
93	14.52063761
94	15.12368075
95	20.27876196
96	7.263366017
103	14.79511808
104	7.919750368
105	22.43727273];
% Pseudo links with obsevered TT and their free flow TT & path ID
pseudo_TT_link = [
14	5	21.93086957
21	8	6.342613401
31	19	20.98407006
54	3	13.67777482
69	14	11.05889345
102	4	14.0601569];
% Links with unknown TT with free flow flow TT
unknown_TT_link = [
7	15
8	15
9	15
10	15
16	10
17	10
18	10
19	10
20	10
56	10
68	15
81	15
82	15];
% Paths with TT: 1-path ID; 2-VarID; 3-link 1; 4-link 2
obs_TT_path = [
1	85	7	9
2	86	10	8
6	87	16	18
7	88	19	17
9	89	20	103
10	90	20	104
11	91	56	24
12	92	68	25
13	93	68	26
15	94	16	81
16	95	82	17
17	96	19	81
18	97	82	18];
% observed queue lengths
obs_QL_link = [9;11;12;18;21;25;26;28;29;31;81;93;94;95;96;103];
% Mapping from path ID to Var ID
pathID2VarID = zeros(max(obs_TT_path(:,1)),1);
for i = 1:length(obs_TT_path(:,1))
    pathID2VarID(obs_TT_path(i,1)) = obs_TT_path(i,2);
end

%% Add free flow TT to each link and path
link_data = zeros(Nlink, 6);
link_data(:,1:5) = link_data_simple;
for i = 1:length(obs_TT_link(:,1))
    linkID = obs_TT_link(i,1);
    VarID = linkID2VarID(linkID);
    link_data(VarID, 6) = link_data(VarID, 5) / obs_TT_link(i, 2);
end
for i = 1:length(pseudo_TT_link(:,1))
    linkID = pseudo_TT_link(i,1);
    VarID = linkID2VarID(linkID);
    link_data(VarID, 6) = link_data(VarID, 5) / pseudo_TT_link(i, 3);
end
for i = 1:length(unknown_TT_link(:,1))
    linkID = unknown_TT_link(i,1);
    VarID = linkID2VarID(linkID);
    link_data(VarID, 6) = link_data(VarID, 5) / unknown_TT_link(i, 2);
end
path_data = zeros(length(obs_TT_path(:,1)),5);
path_data(:,1:4) = obs_TT_path;
for i = 1:length(obs_TT_path(:,1))
    VarID1 = linkID2VarID(obs_TT_path(i,3));
    VarID2 = linkID2VarID(obs_TT_path(i,4));
    path_data(i,5) = link_data(VarID1, 6) + link_data(VarID2, 6);
end

%% Observed variable counts
NQL = length(obs_QL_link(:,1));
NTT_obs = length(obs_TT_link(:,1));
NTT_pseudo = length(pseudo_TT_link(:,1));
NPATH = length(path_data(:,1));

%% For generating training cases
% For large network: this one is problematic
% 1- Link/path ID; 2- slot_data column index; 3- DBN Var ID
input_data_mapping_all = [
11	2	7
12	3	8
25	4	36
26	5	37
28	6	39
29	7	40
31	8	42
93	9	13
94	10	14
95	11	31
103	12	16
5	13	43
6	14	44
11	15	49
12	16	50
15	17	60
24	18	77
25	19	78
26	20	79
27	21	80
28	22	81
29	23	82
30	24	83
55	25	52
57	26	68
66	27	53
67	28	54
93	29	55
94	30	56
95	31	73
96	32	74
103	33	58
104	34	75
105	35	76
14	36	59
21	37	66
31	38	84
54	39	51
69	40	70
102	41	57
1	42	85
2	43	86
6	44	87
7	45	88
9	46	89
10	47	90
11	48	91
12	49	92
13	50	93
15	51	94
16	52	95
17	53	96
18	54	97];
% For small network: for version 2
% 1- Link/path ID; 2- slot_data column index; 3- DBN Var ID
input_data_mapping_small2 = [
9	2	-1
11	3	1
12	4	2
18	5	9
21	6	12
25	7	-1
26	8	21
28	9	23
29	10	24
31	11	26
81	12	15
93	13	3
94	14	4
95	15	17
96	16	18
103	17	6
5	18	-1
6	19	-1
11	20	27
12	21	28
15	22	-1
24	23	-1
25	24	-1
26	25	47
27	26	48
28	27	49
29	28	50
30	29	51
55	30	-1
57	31	-1
66	32	-1
67	33	-1
93	34	29
94	35	30
95	36	43
96	37	44
103	38	32
104	39	45
105	40	46
14	41	-1
21	42	38
31	43	52
54	44	-1
69	45	40
102	46	31
1	47	-1
2	48	-1
6	49	53
7	50	54
9	51	55
10	52	56
11	53	-1
12	54	-1
13	55	57
15	56	58
16	57	59
17	58	60
18	59	61];

% For small network: version 3:
% 1- Link/path ID; 2- slot_data column index; 3- DBN Var ID
input_data_mapping_small3 = [
9	2	-1
11	3	1
12	4	2
18	5	7
21	6	10
25	7	-1
26	8	-1
28	9	17
29	10	18
31	11	20
81	12	11
93	13	3
94	14	4
95	15	13
96	16	14
103	17	6
5	18	-1
6	19	-1
11	20	21
12	21	22
15	22	-1
24	23	-1
25	24	-1
26	25	-1
27	26	-1
28	27	37
29	28	38
30	29	39
55	30	-1
57	31	-1
66	32	-1
67	33	-1
93	34	23
94	35	24
95	36	33
96	37	34
103	38	26
104	39	35
105	40	36
14	41	-1
21	42	30
31	43	40
54	44	-1
69	45	-1
102	46	25
1	47	-1
2	48	-1
6	49	-1
7	50	-1
9	51	41
10	52	42
11	53	-1
12	54	-1
13	55	-1
15	56	-1
16	57	-1
17	58	43
18	59	44];

% For small network: P1:
% 1- Link/path ID; 2- slot_data column index; 3- DBN Var ID
input_data_mapping_smallP1 = [
9	2	-1
11	3	1
12	4	2
18	5	-1
21	6	8
25	7	-1
26	8	-1
28	9	-1
29	10	-1
31	11	14
81	12	-1
93	13	3
94	14	4
95	15	9
96	16	10
103	17	6
5	18	-1
6	19	-1
11	20	15
12	21	16
15	22	-1
24	23	-1
25	24	-1
26	25	-1
27	26	-1
28	27	-1
29	28	-1
30	29	-1
55	30	-1
57	31	-1
66	32	-1
67	33	-1
93	34	17
94	35	18
95	36	-1
96	37	24
103	38	20
104	39	25
105	40	26
14	41	-1
21	42	22
31	43	28
54	44	-1
69	45	-1
102	46	19
1	47	-1
2	48	-1
6	49	-1
7	50	-1
9	51	29
10	52	30
11	53	-1
12	54	-1
13	55	-1
15	56	-1
16	57	-1
17	58	-1
18	59	-1];

% For small network: P2:
% 1- Link/path ID; 2- slot_data column index; 3- DBN Var ID
input_data_mapping_smallP2 = [
9	2	-1
11	3	-1
12	4	-1
18	5	5
21	6	-1
25	7	16
26	8	17
28	9	19
29	10	20
31	11	-1
81	12	11
93	13	-1
94	14	-1
95	15	13
96	16	14
103	17	-1
5	18	-1
6	19	-1
11	20	-1
12	21	-1
15	22	22
24	23	35
25	24	36
26	25	37
27	26	38
28	27	39
29	28	40
30	29	-1
55	30	-1
57	31	28
66	32	-1
67	33	-1
93	34	-1
94	35	-1
95	36	33
96	37	34
103	38	-1
104	39	-1
105	40	-1
14	41	21
21	42	-1
31	43	-1
54	44	-1
69	45	30
102	46	-1
1	47	-1
2	48	-1
6	49	41
7	50	42
9	51	-1
10	52	-1
11	53	-1
12	54	43
13	55	-1
15	56	-1
16	57	44
17	58	-1
18	59	45];

% For reduced network:
% 1- Link/path ID; 2- slot_data column index; 3- DBN Var ID
input_data_mapping_reduce = [
9	2	-1
11	3	1
12	4	2
18	5	11
21	6	14
25	7	26
26	8	27
28	9	29
29	10	30
31	11	32
81	12	19
93	13	3
94	14	4
95	15	21
96	16	22
103	17	6
5	18	-1
6	19	-1
11	20	33
12	21	34
15	22	40
24	23	57
25	24	58
26	25	59
27	26	60
28	27	61
29	28	62
30	29	63
55	30	-1
57	31	48
66	32	-1
67	33	-1
93	34	35
94	35	36
95	36	53
96	37	54
103	38	38
104	39	55
105	40	56
14	41	39
21	42	46
31	43	64
54	44	-1
69	45	50
102	46	37
1	47	-1
2	48	-1
6	49	65
7	50	66
9	51	67
10	52	68
11	53	69
12	54	70
13	55	-1
15	56	71
16	57	72
17	58	-1
18	59	73];