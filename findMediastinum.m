function mask = findMediastinum(lungs, liver)
% Find the mediastinum, given that we know where the lungs and liver are.
% The inputs are binary masks, as this function does not even need to look 
% at the original image.

% Take the convex hull of the lungs
[I, J, K] = ind2sub(size(lungs), find(lungs));
hullTri = convhull(I, J, K, 'simplify', true);

% Convert the convex hull to a Delaunay triangulation
ptsMat = [I, J, K];
triMat = zeros(size(hullTri));
for k = 1 : 3
   triMat(:, k) = ptsMat(hullTri(:, k), k); 
end
clear ptsMat I J K
dt = delaunayTriangulation(triMat);

% Use the Delaunay triangulation to generate a mask for the convex hull
siz = size(lungs);
[I, J, K] = ndgrid(1 : siz(1), 1 : siz(2), 1 : siz(3));
hullMask = ~isnan(pointLocation(dt, I(:), J(:), K(:)));
hullMask = reshape(hullMask, size(im));

% Take the complement of the lungs, relative to the convex hull
mediastinum = hullMask & ~lungs;

% Remove any voxels which are already known to be liver
mediastinum = mediastinum & ~liver;
