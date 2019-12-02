function mask = findMediastinum(lungs, liver)
% Find the mediastinum, given that we know where the lungs and liver are.
% The inputs are binary masks, as this function does not even need to look 
% at the original image.

addpath(genpath('aimutil'))

% Take the complement of the lungs, relative to the convex hull
hull = convHull3D(lungs);
mask = hull & ~lungs;

% Remove any voxels which are already known to be liver
mask = mask & ~liver;
