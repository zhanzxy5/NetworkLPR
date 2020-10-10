%% Configure intersection data
switch intersectionID
    case 'test'
        laneDir1 = [2,3];
        laneDir2 = [2,3];
        laneDir3 = [2,3];
        laneDir4 = [2,3];
    case '1310000001'
        % Lane configurations: for through movement only
        laneDir1 = [3, 4];
        laneDir2 = [3, 4];
        laneDir3 = [3, 4];
        laneDir4 = [3, 4];
    case '1310000002'
        % Lane configurations: for through movement only
        laneDir1 = [3, 4];
        laneDir2 = [2, 3];
        laneDir3 = [3, 4];
        laneDir4 = [2, 3];
    case '1310000007'
        % Lane configurations: for through movement only
        laneDir1 = [2, 3];
        laneDir2 = [3, 4];
        laneDir3 = [2, 3];
        laneDir4 = [3, 4];
    case '1310000012'
        % Lane configurations: for through movement only
        laneDir1 = [2, 3];
        laneDir2 = [2, 3];
        laneDir3 = [2, 3];
        laneDir4 = [2, 3];
%         laneDir1 = [2,3];
%         laneDir2 = [];
%         laneDir3 = [];
%         laneDir4 = [2,3];
%         laneDir1 = [];
%         laneDir2 = [2];
%         laneDir3 = [2, 3];
%         laneDir4 = [];
    case '1310000018'
        % Lane configurations: for through movement only
        laneDir1 = [2, 3];
        laneDir2 = [3, 4];
        laneDir3 = [];
        laneDir4 = [3, 4];
    case '1310000019'
        % Lane configurations: for through movement only
%         laneDir1 = [2, 3];
%         laneDir2 = [2];
%         laneDir3 = [3, 4];
%         laneDir4 = [];
        laneDir1 = [4];
        laneDir2 = [2];
        laneDir3 = [];
        laneDir4 = [];
    case '1310000028'
        % Lane configurations: for through movement only
        laneDir1 = [3];
        laneDir2 = [];
        laneDir3 = [2, 3];
        laneDir4 = [2];
    case '1310000034'
        % Lane configurations: for through movement only
%         laneDir1 = [3, 4];
%         laneDir2 = [3, 4];
%         laneDir3 = [3, 4];
%         laneDir4 = [3, 4];
        laneDir1 = [2, 3];
        laneDir2 = [2, 3];
        laneDir3 = [2, 3];
        laneDir4 = [2, 3];
    case '1310000053'
        % Lane configurations: for through movement only
        laneDir1 = [2]; % [1, 2];
        laneDir2 = [2]; % [1, 2];
        laneDir3 = [2]; % [1, 2];
        laneDir4 = [1]; % [1, 2];
%         laneDir1 = [1];
%         laneDir2 = [1];
%         laneDir3 = [1];
%         laneDir4 = [1];
    case '1310000054'
        % Lane configurations: for through movement only
        laneDir1 = [];
        laneDir2 = [2, 3];
        laneDir3 = [];
        laneDir4 = [2, 3];
    case '1310000056'
        % Lane configurations: for through movement only
        laneDir1 = [2, 3];
        laneDir2 = [2, 3];
        laneDir3 = [];
        laneDir4 = [2, 3];
    case '1310000068'
        % Lane configurations: for through movement only
%         laneDir1 = [1, 2];
%         laneDir2 = [1, 2];
%         laneDir3 = [];
%         laneDir4 = [2, 3];
        laneDir1 = [1, 2];
        laneDir2 = [1, 2];
        laneDir3 = [];
        laneDir4 = [1, 2];
    case '1310000069'
        % Lane configurations: for through movement only
        laneDir1 = [1, 2];
        laneDir2 = [];
        laneDir3 = [1, 2];
        laneDir4 = [];
    otherwise
        disp('Wrong intersection!');
end