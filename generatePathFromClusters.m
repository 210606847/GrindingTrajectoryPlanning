%GENERATEPATH generate path
%
% path = generatePathFromClusters(clusters, v, f, n), generate path
% after clusters generated.
function path = generatePathFromClusters(clusters, v, f, n, gap)
if argin < 5
    gap = 1.0;
end
[~, cluster_num] = size(clusters);
for cluIdx=1:cluster
    [pointsCloud, pointsCloudFaceIdx] = generatePointsCloud(clusters{cluIdx}, v, f, n, gap);
end
end