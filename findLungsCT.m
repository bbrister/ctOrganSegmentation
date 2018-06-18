function mask = findLungsCT(im, units)
% Find the lungs in a CT scan using thresholding and morphology. Assumes
% that im is in Hounsfield units. Optionally find the mediastinum as well.

if iscolumn(units)
    units = units';
end;

% Lung window
thresh = -150;

% Apply thresholding
mask = im <= thresh;

% Remove anything which is connected to the perimeter of the axial slice.
% This is outside the body in the CT scan.
for k = 1 : size(im, 3)
    mask(:, :, k) = imclearborder(mask(:, :, k));
end

% To remove the muscle, perform opening with a width of 1cm
openWidth = ceil(10 ./ units);
opened = imopen(mask, strel(ones(openWidth)));

% Take the two largest connected components, which are the lungs
cc = bwconncomp(opened);
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

end