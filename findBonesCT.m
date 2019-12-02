function mask = findBonesCT(im, units, ignore)
% Find the lungs in a CT scan using thresholding and morphology. Assumes
% that im is in Hounsfield units. Anything in 'ignore' is not treated as
% bone, e.g. other organs which were found.

% Depednencies
addpath(genpath('aimutil')) % for ballMask

if iscolumn(units)
    units = units';
end

% Bones window
threshLo = 0; % Most of the bone should be greater than this
%threshHi = 200; 
threshHi = 175; % This is mostly bone, but also some soft tissues

% Apply the high threshold
mask = im >= threshHi;

% Remove 'ignore' pixels
haveIgnore = nargin > 2  && ~isempty(ignore);
if haveIgnore
    mask = mask & ~ignore;
end

% The skeleton is the largest CC
mask = largestCC(mask);

% Close, to fill gaps
closeRad = 25;
mask = closeMm(mask, units, closeRad); 

% Apply the low threshold
mask = mask & (im >= threshLo);

% Fill AXIAL holes
for k = 1 : size(mask, 3)
        mask(:, :, k) = imfill(mask(:, :, k), 'holes');
end

% Ignore again
if haveIgnore
    mask = mask & ~ignore;
end

end

function im = closeMm(im, units, mm)
% Morphological closing by the given number of mm

% Get the width, in voxel
closeWidth = ceil(mm ./ units);

% Get a 3D ball
center = 1 + (closeWidth - 1) / 2;
ball = ballMask(closeWidth, center, mm / 2, units);

im = bwCloseN(im, ball);

end
