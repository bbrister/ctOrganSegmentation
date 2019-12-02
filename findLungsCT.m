function mask = findLungsCT(im, units, ignore)
% Find the lungs in a CT scan using thresholding and morphology. Assumes
% that im is in Hounsfield units. Optionally find the mediastinum as well.
% Use 'ignore' to supply previously-found organs, which are automatically
% removed from the lungs.

% Depednencies
addpath(genpath('aimutil')) % for ballMask

if iscolumn(units)
    units = units';
end;

% Lung window
thresh = -150;

% Apply thresholding
mask = im <= thresh;

% Remove 'ignore' pixels
haveIgnore = nargin > 2 && ~isempty(ignore);
if haveIgnore
    mask = mask & ~ignore;
end

% To remove the exam table, close with a vertical rectangle, 1cm thick
closeMm = 10;
closeHeight = ceil(closeMm / units(2));
closeHeight = closeHeight + 1 - mod(closeHeight, 2); % Make it odd
rectangle = ones(1, closeHeight, 1);
removeBorder = bwCloseN(mask, rectangle);

% Remove anything which is connected to the perimeter of the axial slice.
% This is outside the body in the CT scan.
for k = 1 : size(im, 3)
    removeBorder(:, :, k) = imclearborder(removeBorder(:, :, k));
end
mask = mask & removeBorder;
clear removeBorder

% To remove the muscle, open with a width of 1cm
openMm = 10;
openWidth = ceil(openMm ./ units);
center = 1 + (openWidth - 1) / 2;
ball = ballMask(openWidth, center, openMm / 2, units);
seed = bwOpenN(mask, ball);

% Take the two largest connected components, which are the lungs
cc = bwconncomp(seed);
clear seed
assert(cc.NumObjects >= 2)
volumes = cell2mat(struct2cell(regionprops(cc, 'Area')));
[~, ranking] = sort(volumes, 'descend');

% Fill in these components, ignore all others
detect = false(size(mask));
for i = 1 : 2
   detect(cc.PixelIdxList{ranking(i)}) = true;
end

% Reconstruct the lungs from the detected seeds
mask = imreconstruct(detect, mask);

% Fill in any holes
mask = imfill(mask, 'holes');

% Remove 'ignore' pixels again
if haveIgnore
    mask = mask & ~ignore;
end

end
