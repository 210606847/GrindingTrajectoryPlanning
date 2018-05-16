%CONNECTPATHS connect path of different clusters
%
% Ts = connectPaths(paths, normalVecs, clustersIdx)
% connect path according to their normal vectors, cluster index, and
% return homogeneous transformation matrix.
%
%Params::
% - paths, points, shape [pointsNum, 3]
% - normalVecs, normal vectors, shape [pointsNum, 3]
% - clustersIdx, array of cluster index, shape [pointsNum, 1]
%
%Author::
% - JunrZhou

function [Ts, connectInfo] = connectPaths(paths, normalVecs, clustersIdx)
[pathNum, ~] = size(paths);
lastCluIdx = clustersIdx(1);
% Ts0 for path in clusters
Ts0 = zeros(4 * pathNum, 4);
connectInfo0 = ones(pathNum, 1);
% Ts1 for path between clusters
Ts1 = [];
Ts1PosIdx = [];
Ts1Num = [];
Ts1TotalNum = 0;
for i=1:pathNum
    tmpPath = paths(i, :);

    % TODO: Can do some modification for normal vector
    %
    tmpNormalVec = normalVecs(i, :);
    tmpCluIdx = clustersIdx(i);

    if (abs(tmpCluIdx - lastCluIdx) < 1e-5)
        lastCluIdx = tmpCluIdx;
        % if different cluster, do some connection
        Ts0((4*i-3):(4*i-1), 1:3) = normal2T(tmpNormalVec);
        Ts0((4*i-3):(4*i-1), 4) = tmpPath';
        Ts0((4*i), 4) = 1;
        Ts1PosIdx = [Ts1PosIdx; 4*i];

        % TODO: add additional path
        % 
        tmpTs1Num = 0; % points number
        Ts1Num = [Ts1Num; 4*tmpTs1Num];
        Ts1TotalNum = Ts1TotalNum + 4*tmpTs1Num;
    else
        Ts0((4*i-3):(4*i-1), 1:3) = normal2T(tmpNormalVec);
        Ts0((4*i-3):(4*i-1), 4) = tmpPath';
        Ts0((4*i), 4) = 1;
    end

end
[Ts1Size, ~] = size(Ts1PosIdx);
tmpCount = 1;
tmpCountTs0 = 1;
Ts = zeros(4*(pathNum + Ts1TotalNum), 4);
connectInfo = zeros(pathNum + Ts1TotalNum, 1);
for i=1:Ts1Size
    tmpIdx = Ts1PosIdx(i, 1);
    Ts(tmpCount:(tmpCount+tmpIdx-tmpCountTs0), :) = Ts0(tmpCountTs0:tmpIdx, :);
    connectInfo((tmpCount+3)/4:(tmpCount+tmpIdx-tmpCountTs0)/4) = connectInfo0((tmpCountTs0+3)/4:tmpIdx/4);
    tmpCount = tmpCount + (tmpIdx-tmpCountTs0+1);
    tmpCountTs0 = tmpIdx+1;
    if (abs(Ts1Num(i)) > 1e-5)
        Ts(tmpCount:(tmpCount + Ts1Num(i)), :) = Ts1(i, :);
        tmpCount = tmpCount + Ts1Num(i) + 1;
    end
end
Ts(tmpCount:4*(pathNum + Ts1TotalNum), :) = Ts0(tmpCountTs0:(4*pathNum), :);
connectInfo((tmpCount+3)/4:(pathNum + Ts1TotalNum)) = connectInfo0((tmpCountTs0+3)/4:pathNum);
end

function T = normal2T(normalVector)
%NORMAL2T turn normal vector to rotation matrix
%
% T = normal2T(normalVector)
%
%Params::
% - normalVector
%Return::
% - T, [3, 3] array
T = zeros(3, 3);
tmp_l = normalVector / norm(normalVector);
tmp_count = find(tmp_l); % find nonzero
tmp_x = [(tmp_l(mod(tmp_count, 3) + 1) + tmp_l(mod(1 + tmp_count, 3) + 1)) / (-tmp_l(tmp_count)), 1, 1];
tmp_x = tmp_x / norm(tmp_x);
tmp_y = cross(tmp_l, tmp_x);
T(1:3, 1) = tmp_x;
T(1:3, 2) = tmp_y;
T(1:3, 3) = tmp_l;
end